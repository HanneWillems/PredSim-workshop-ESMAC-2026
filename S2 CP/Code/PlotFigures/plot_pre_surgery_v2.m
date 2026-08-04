function [] = plot_pre_surgery_v2(result_paths,IKResultsFolder)
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
legend_names = {'Experimental Kinematics pre surgery','Simulation results pre surgery'};
IK_names =  {'pelvis_tilt',  'pelvis_tx', 'pelvis_ty',...
    'hip_flexion_r',  'knee_angle_r', 'ankle_angle_r',...
    'hip_flexion_l',...
    'knee_angle_l', 'ankle_angle_l', 'lumbar_extension'};
%% IK files
% paths with the IK data
IKdata_paths = {fullfile(IKResultsFolder,'CP_SMALLL_IK_pre_1.mot'),...
                fullfile(IKResultsFolder,'CP_SMALLL_IK_pre_2.mot')};
% GC's
load(fullfile(IKResultsFolder,'GC.mat'))
[avg,sd,~,~,data,~] = getIK_SD_and_mean(IKdata_paths,GC.pre);


%% IK
fig3 = figure;
colororder({'k','k'});
for idx_AngleIK = 1:length(IK_names)
    AngleName = IK_names{idx_AngleIK};

    idx_col = find(strcmp(data.colheaders, AngleName));
    
    % Convert OpenSim convention to clinical convention (flip sign where needed)   
    if contains(AngleName, {'knee','pelvis_list','lumbar_bending','lumbar_extension'})
        flip_data = -1;
    else
        flip_data = 1;
    end

    % Left side -> use left mean and standard deviation
    if contains(AngleName, '_l')
        avg_col = avg.L(:,idx_col) * flip_data;
        sd_col  = sd.L(:,idx_col)  * flip_data;
    else % Right side and axial coordinates -> use right mean and standard deviation
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
    if idx_AngleIK == 1
    hIKline = plot(1:length(avg_col), avg_col, ...
        'k','LineWidth',2);
    else
        plot(1:length(avg_col), avg_col, ...
            'k','LineWidth',2);
    end
   
    title(IK_names(idx_AngleIK),interpreter="none")
end



%% Plot simulation results
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

% Determine left gait cycle based on GRF (analogous to right gait cycle)
R_left = get_left_gait_cycle(R, model_info);
% kinematics/kinetics
for idx_AngleIK = 1:length(IK_names)

    AngleName = IK_names{idx_AngleIK};

    % pick right (R) or lef (GRF-based R_left) results struct
    if contains(AngleName, '_l')
        R_plot = R_left;
    else
        R_plot = R;
    end

    % Convert OpenSim convention to clinical convention (flip sign where needed)   
    if contains(AngleName, {'knee','pelvis_list','lumbar_bending','lumbar_extension'})
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
    if idx_AngleIK == 1
    hsimline = plot(x_i,y_i,'r','LineWidth',2);
    else
        plot(x_i,y_i,'r','LineWidth',2);
    end
    
end

% lay out
sgtitle('Pre surgery: simulation results vs. experimental kinematics')
han = axes(fig3,'visible','off');

han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';

xlabel(han,'Gait cycle (%)','FontSize',12)
ylabel(han,'Angle (°)','FontSize',12)

legend1 = legend([hIKline hsimline],legend_names);
legend1.ItemTokenSize = [30,18];
set(legend1,...
    'Position',[0.677123632983556 0.103763141299236 0.236785717759814 0.118925488587332]);