function [] = plot_experimental_comparison_DMD_ESMAC(result_path, opts)
% plot_experimental_comparison
%   Both the simulation and the experimental curves can be shown in
%   OpenSim convention, or transformed to clinical convention using the
%   shared transform_result_clinical_format.m
%
% INPUT
%   result_path     - struct where each field is a named simulation, and
%                      each value is the full path to a PredSim .mat
%                      result file (must contain R and model_info).
%                      e.g. result_path.reference       = 'C:\...\gait1018_esmac_v1.mat'
%                           result_path.DMD_simulation  = 'C:\...\gait1018_esmac_v2.mat'
%   opts            - struct, all fields optional:
%       .apply_clinical_convention
%           If true: sim results are transformed via
%           transform_result_clinical_format.m, the curves are
%           transformed.
%       .include_TD_reference
%           Overlay TD reference mean +/- SD.
%       .include_patient_ik
%           Overlay the subject's experimental IK mean +/- SD.
%       .TD_path (string)
%           Full path to the TD reference .mat file.
%       .DMD_exp_path (string)
%           Full path to the patient experimental IK .mat file.
%       .side ('right'/'left') default 'right'
%           Passed to transform_result_clinical_format.m. Does not affect
%           which of the fixed set of coordinates below get plotted.
%
% Original author: Ellis Van Can
% Original date: September 3, 2026

% Last edit by: Ines Vandekerckhove
% Last edit date: September 5, 2026

%% coordinates to plot (fixed set, OpenSim names)
IK_names_os = {'pelvis_tilt',...
    'hip_flexion_r',  'knee_angle_r', 'ankle_angle_r',...
    'hip_flexion_l', 'knee_angle_l', 'ankle_angle_l'};

% Clinical-convention names.
IK_names_clin = strrep(IK_names_os,     'pelvis_tilt',      'pelvis_ant_tilt');
IK_names_clin = strrep(IK_names_clin,   'knee_angle',       'knee_flexion');
IK_names_clin = strrep(IK_names_clin,   'lumbar_extension', 'lumbar_flexion');

if opts.apply_clinical_convention
    plot_titles = IK_names_clin;
    sim_names   = IK_names_clin;   % R.colheaders.coordinates gets renamed by the transform
else
    plot_titles = IK_names_os;
    sim_names   = IK_names_os;
end

if opts.apply_clinical_convention
    convention_str = 'clinical convention';
else
    convention_str = 'OpenSim convention';
end

%% load all simulation results under result_path
sim_fields = fieldnames(result_path);
n_sims     = numel(sim_fields);

R_all      = cell(n_sims,1);
R_left_all = cell(n_sims,1);

for s = 1:n_sims
    sim_path = result_path.(sim_fields{s});

    loaded = load(sim_path,'model_info');   % model_info is unaffected by the transform
    model_info = loaded.model_info;

    if opts.apply_clinical_convention
        % Shared transform (also writes a *_transf_<side>.mat next to
        % sim_path; we only need the returned R here).
        R      = transform_result_clinical_format(sim_path, 'right');
        R_left = transform_result_clinical_format(sim_path, 'left');
        R_left = get_left_gait_cycle(R_left, model_info);
    else
        loaded = load(sim_path,'R');
        R      = loaded.R;
        R_left = get_left_gait_cycle(R, model_info);
    end

    R_all{s}      = R;
    R_left_all{s} = R_left;
end

%% colors
% TD reference (fill) / reference simulation (line) -> gray family
c_TD      = [0.75 0.75 0.75];   % light gray fill - TD reference band
c_ref_sim = [0.30 0.30 0.30];   % dark gray line  - reference simulation

% DMD experimental data (fill) / DMD simulation(s) (line) -> gold family
c_DMD_exp = [0.9294 0.6941 0.1255]; % gold fill - DMD experimental band
c_DMD_sim = [0.9294 0.6941 0.1255]; % gold line - DMD simulation(s)

% line styles to cycle through when there is more than one DMD simulation
DMD_linestyles = {'-', '--', ':', '-.'};

% assign a color + linestyle to each simulation field based on its name
sim_colors     = cell(n_sims,1);
sim_linestyles = cell(n_sims,1);
dmd_count = 0;
for s = 1:n_sims
    if contains(lower(sim_fields{s}), 'dmd')
        dmd_count = dmd_count + 1;
        sim_colors{s}     = c_DMD_sim;
        sim_linestyles{s} = DMD_linestyles{mod(dmd_count-1, numel(DMD_linestyles)) + 1};
    else
        sim_colors{s}     = c_ref_sim;
        sim_linestyles{s} = '-';
    end
end

%% patient experimental IK
if opts.include_patient_ik
    DMD_loaded  = load(opts.DMD_exp_path);
    fn_DMD      = fieldnames(DMD_loaded);
    ExpData_DMD = DMD_loaded.(fn_DMD{1});
end

%% TD reference data
if opts.include_TD_reference
    TD_loaded = load(opts.TD_path);
    fn = fieldnames(TD_loaded);
    TD = TD_loaded.(fn{1});   % struct is named ExpData_TD or ExpData_TD_transf
end

%% figure
fig = figure;

legend_handles = gobjects(0);
legend_labels  = {};

n_rows = 3; n_cols = 3;

for i = 1:length(IK_names_os)

    AngleName_os = IK_names_os{i};   % OpenSim name -> used to look up angles

    subplot(n_rows, n_cols, i); hold on

    % TD reference (plotted first, in the background)
    if opts.include_TD_reference
        TD_name = regexprep(plot_titles{i}, '_[rl]$', '');  % TD data has no side suffix
        idx_TD = find(strcmp(TD.kinematics.colheaders, TD_name));
        if ~isempty(idx_TD)
            avg_TD = TD.kinematics.mean(:,idx_TD);
            sd_TD  = TD.kinematics.sd(:,idx_TD);

            hTD = fill([1:length(avg_TD), fliplr(1:length(avg_TD))], ...
                [(avg_TD-sd_TD)', fliplr((avg_TD+sd_TD)')], ...
                c_TD, 'FaceAlpha',0.3,'EdgeColor','none' );
            lbl = sprintf('TD reference %s', convention_str);
            if isempty(legend_handles) || ~any(contains(legend_labels,'TD reference'))
                legend_handles(end+1) = hTD; %#ok<AGROW>
                legend_labels{end+1}  = lbl; %#ok<AGROW>
            end
        end
    end

    % patient experimental IK
    if opts.include_patient_ik
        DMD_name = regexprep(plot_titles{i}, '_[rl]$', '');  % DMD data has no side suffix
        idx_DMD = find(strcmp(ExpData_DMD.kinematics.colheaders, DMD_name));
        if ~isempty(idx_DMD)
            avg_DMD = ExpData_DMD.kinematics.mean(:,idx_DMD);
            sd_DMD  = ExpData_DMD.kinematics.sd(:,idx_DMD);

            hDMD = fill([1:length(avg_DMD), fliplr(1:length(avg_DMD))], ...
                [(avg_DMD-sd_DMD)', fliplr((avg_DMD+sd_DMD)')], ...
                c_DMD_exp, 'FaceAlpha',0.3,'EdgeColor','none' );
            lbl = sprintf('DMD experimental data %s', convention_str);
            if isempty(legend_handles) || ~any(contains(legend_labels,'DMD experimental data'))
                legend_handles(end+1) = hDMD; %#ok<AGROW>
                legend_labels{end+1}  = lbl; %#ok<AGROW>
            end
        end
    end

    % simulation(s) - one line per struct field in result_path
    AngleName_sim = sim_names{i};

    for s = 1:n_sims
        R      = R_all{s};
        R_left = R_left_all{s};

        idx_coordinate = strcmp(R.colheaders.coordinates, AngleName_sim);

        if contains(AngleName_os, '_l')
            R_plot = R_left;
        else
            R_plot = R;
        end

        ydata = R_plot.kinematics.Qs;
        y_i   = ydata(:, idx_coordinate);
        x_i   = linspace(1, 100, length(y_i));

        sim_label = strrep(sim_fields{s}, '_', ' ');
        hsim = plot(x_i, y_i, 'Color', sim_colors{s}, 'LineStyle', sim_linestyles{s}, 'LineWidth', 2);

        lbl = sprintf('%s - %s', sim_label, convention_str);
        if ~any(strcmp(legend_labels,lbl))
            legend_handles(end+1) = hsim; %#ok<AGROW>
            legend_labels{end+1}  = lbl;  %#ok<AGROW>
        end
    end

    title(plot_titles{i}, 'Interpreter','none')
end

sgtitle('Simulation vs. experimental kinematics')

han = axes(fig,'visible','off');
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
xlabel(han,'Gait cycle (%)','FontSize',12)
ylabel(han,'Angle (deg)','FontSize',12)

legend1 = legend(legend_handles, legend_labels);
legend1.ItemTokenSize = [30,18];
set(legend1,'Position',[0.677123632983556 0.103763141299236 0.236785717759814 0.118925488587332]);

end
