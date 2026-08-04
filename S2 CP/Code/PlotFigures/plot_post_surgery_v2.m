% function [] = plot_pre_surgery(result_paths,IKResultsFolder)
% plot_pre_surgery
%   Plots and compares pre-surgery simulation results with experimental
%   inverse kinematics (IK) for subject CP_SMALLL. The function loads IK
%   data from predefined .mot files, extracts multiple gait cycles
%   (right foot strike to right foot strike), time-normalises them to
%   0–100% gait, and computes mean ± standard deviation envelopes for a
%   selected set of joint angles. These IK envelopes are plotted together
%   with the corresponding simulated joint trajectories from a PredSim
%   results file, allowing visual comparison of model and experiment.
%
% INPUT:
%   - result_paths -
%   * string/char with full path to a .mat file containing:
%       > R          : struct with simulation results, including
%                     R.kinematics.Qs (time-normalised joint angles)
%       > model_info : struct with model information (not used directly
%                     for plotting in this function, but expected in file)
%
% DEPENDENCIES / EXPECTED FORMAT:
%   - IK .mot files are hard-coded inside the function and must exist in
%     the specified IKResultsFolder.
%   - ReadMotFile            : function to read .mot files into a struct
%                              with fields 'data' and 'names'
%   - ResampleNoEdgeEffects  : function used to resample gait cycles to
%                              100 points (0–100% gait cycle)
%   - getStancePhaseSimulation : function used to extract the GRF-based
%                              left-side gait cycle indices from the
%                              simulated (right-side) GRF signals
%   - R.colheaders.coordinates must contain the same coordinate names as
%     used in the IK files (e.g. 'hip_flexion_r', 'knee_angle_r', etc.).
%
% OUTPUT:
%   - (none)
%   * Creates a multi-subplot figure showing mean ± SD experimental IK
%     envelopes with overlaid pre-surgery simulated kinematics for the
%     selected joint angles, and adds a legend distinguishing IK and
%     simulation curves. Left-side coordinates are taken from a
%     GRF-derived left gait cycle (R_left); right-side and axial
%     coordinates are taken directly from R. Knee angles are sign-flipped
%     from OpenSim to clinical convention.

% Original author: Ellis Van Can
% Original date: November 23,2025

% Last edit by: 
% Last edit date: 
% --------------------------------------------------------------------------
clear figure_settings
%% General settings
% These settings will apply to all figures
% Construct a cell array with full paths to files with saved results for
% which you want to appear on the plotted figures.
legend_names = {'Inverse Kinematics','Post surgery'};

%% IK files
% paths with the IK data
data_paths = {fullfile(IKResultsFolder,'CP_SMALLL_IK_post_1.mot'),...
                fullfile(IKResultsFolder,'CP_SMALLL_IK_post_2.mot'),...
                fullfile(IKResultsFolder,'CP_SMALLL_IK_post_2.mot')};

% GC's
load(fullfile(IKResultsFolder,'GC.mat'))
[avg,sd,~,~,data,~] = getIK_SD_and_mean(data_paths,GC.pre);


%% IK
fig3 = figure;
colororder({'k','k'});
for idx_AngleIK = 1:length(IK_names)
    AngleName = IK_names{idx_AngleIK};

    idx_col = find(strcmp(data.colheaders, AngleName));

    % knee: OpenSim -> klinische conventie
    if contains(AngleName, {'knee','pelvis_list','lumbar_bending','lumbar_extension'})
        flip_data = -1;
    else
        flip_data = 1;
    end

    % left -> avg.L/sd.L
    if contains(AngleName, '_l')
        avg_col = avg.L(:,idx_col) * flip_data;
        sd_col  = sd.L(:,idx_col)  * flip_data;
    else % , right/axial -> avg.R/sd.R
        avg_col = avg.R(:,idx_col) * flip_data;
        sd_col  = sd.R(:,idx_col)  * flip_data;
    end

    plus_stdev  = avg_col + sd_col;
    min_stdev   = avg_col - sd_col;

    subplot(4,3,idx_AngleIK)
    hold on
    fill([1:length(avg_col), fliplr(1:length(avg_col))], ...
        [min_stdev', fliplr(plus_stdev')], ...
        [140, 128, 128]/255,'FaceAlpha',0.5,'EdgeAlpha',0.75,'EdgeColor',[140, 128, 128]/255)

    title(IK_names(idx_AngleIK),interpreter="none")
end




%% plot results in it
% fig4 = figure;
hold on
colororder({'k','k'});

% [~, idx_results_order] = ismember(IK_names,IK.trial1.names);
% determine subplot size
n_rows = 4;
n_cols = 3;

figure_settings.name = 'all_angles';
figure_settings.dofs = {'all_coords'};
figure_settings.variables = {'Qs'};

load(result_paths,'R','model_info');

%% Bereken linker gait cycle (GRF-based, analoog aan rechter simulatie-GC)
dist_trav_opt = R.spatiotemp.dist_trav;
GRF_right = R.ground_reaction.GRF_r;
GRF_left  = R.ground_reaction.GRF_l;
GRFk_opt  = [GRF_left, GRF_right];

[idx_GC, idx_GC_base_forward_offset, ~, threshold] = getStancePhaseSimulation(GRFk_opt, model_info.mass/3);

R_left = struct();
R_left.colheaders = R.colheaders;   % zelfde model -> zelfde kolomvolgorde, alleen rijen herschikt
R_left.kinematics.Qs         = R.kinematics.Qs(idx_GC, :);
R_left.kinematics.Qdots      = R.kinematics.Qdots(idx_GC, :);
R_left.kinematics.Qddots     = R.kinematics.Qddots(idx_GC, :);
R_left.kinematics.Qs_rad     = R.kinematics.Qs_rad(idx_GC, :);
R_left.kinematics.Qdots_rad  = R.kinematics.Qdots_rad(idx_GC, :);
R_left.kinematics.Qddots_rad = R.kinematics.Qddots_rad(idx_GC, :);

% forward positie continu maken en op 0 laten starten
R_left.kinematics.Qs(idx_GC_base_forward_offset, model_info.ExtFunIO.jointi.base_forward) = ...
    R_left.kinematics.Qs(idx_GC_base_forward_offset, model_info.ExtFunIO.jointi.base_forward) + dist_trav_opt;
R_left.kinematics.Qs(:, model_info.ExtFunIO.jointi.base_forward) = ...
    R_left.kinematics.Qs(:, model_info.ExtFunIO.jointi.base_forward) - R_left.kinematics.Qs(1, model_info.ExtFunIO.jointi.base_forward);

R_left.ground_reaction.GRF_r = R.ground_reaction.GRF_r(idx_GC, :);
R_left.ground_reaction.GRF_l = R.ground_reaction.GRF_l(idx_GC, :);
R_left.spatiotemp = R.spatiotemp;

% kinematics/kinetics
for idx_AngleIK = 1:length(IK_raw.names)
    AngleName = IK_raw.names{idx_AngleIK};

    % kies rechter (R) of linker (GRF-based R_left) resultaatstruct
    if contains(AngleName, '_l')
        R_plot = R_left;
    else
        R_plot = R;
    end

    % OpenSim -> klinische conventie: knie-hoek omdraaien
    if contains(AngleName, 'knee')
        flip_data = -1;
    else
        flip_data = 1;
    end

    idx_coordinate = strcmp(R_plot.colheaders.coordinates, AngleName);
    ydata = R_plot.kinematics.(figure_settings.variables{1});
    y_i = ydata(:, idx_coordinate) * flip_data;
    x_i = linspace(1, 100, length(y_i));

    subplot(n_rows, n_cols, idx_AngleIK)
    hold on
    plot(x_i, y_i, '-', LineWidth=2)
end
legend1 = legend(legend_names);
set(legend1,...
    'Position',[0.677123632983556 0.103763141299236 0.236785717759814 0.118925488587332]);
sgtitle('Pre-surgery: simulation results vs. experimental kinematics')
% end