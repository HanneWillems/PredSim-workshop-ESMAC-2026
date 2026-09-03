function [] = plot_experimental_comparison_CP_ESMAC(result_path, T, IKResultsFolder, opts)
% plot_experimental_comparison
%   Both the simulation and the experimental curves can be shown in
%   OpenSim convention, or transformed to clinical convention using the
%   shared transform_result_clinical_format.m (
%
% INPUT
%   result_path     - full path to a PredSim .mat result file
%                      (must contain R and model_info).
%   T               - 'pre' or 'post'
%   IKResultsFolder - folder containing GC.mat and the subject's .mot
%                      files. 
%   opts            - struct, all fields optional:
%       .apply_clinical_convention 
%           If true: sim results are transformed via
%           transform_result_clinical_format.m, the curves are
%           transformed.
%       .include_TD_reference 
%           Overlay TD reference mean +/- SD.
%       .include_patient_ik (
%           Overlay the subject's  experimental IK mean +/- SD.
%       .TD_path (string)
%           Full path to the TD reference .mat file.
%       .side ('right'/'left') default 'right'
%           Passed to transform_result_clinical_format.m. Does not affect
%           which of the fixed set of coordinates below get plotted.
%
% Original author: Ellis Van Can
% Original date: September 3, 2026

% Last edit by: 
% Last edit date: 


%% Defaults 
% plotting colors
if strcmp(T,'pre')
    c_exp = [0 255 0]/255;
    c_sim = [0 150 0]/255;

elseif strcmp(T,'post')
    c_exp = [0 0 255]/255;
    c_sim = [0 0 150]/255;
end

%coordinates to plot (fixed set, OpenSim names) 
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

%% simulation results 
loaded = load(result_path,'model_info');   % model_info is unaffected by the transform
model_info = loaded.model_info;

if opts.apply_clinical_convention
    % Shared transform (also writes a *_transf_<side>.mat next to
    % result_path; we only need the returned R here).
    R = transform_result_clinical_format(result_path, 'right');
    R_left = transform_result_clinical_format(result_path, 'left');
    R_left = get_left_gait_cycle(R_left, model_info);

else
    loaded = load(result_path,'R');
    R = loaded.R;
    R_left = get_left_gait_cycle(R, model_info);
end

%%  patient experimental IK 
if opts.include_patient_ik
    GC = load(fullfile(IKResultsFolder,'GC.mat'));
    GC = GC.GC;
    if ~isfield(GC, T)
        error('plot_experimental_comparison:noPhaseInGC', ...
            'GC.mat has no field ''%s''.', T);
    end

    IK_files_struct = dir(fullfile(IKResultsFolder, sprintf('CP_SMALLL_IK_%s_*.mot', T)));
    IKdata_paths = fullfile({IK_files_struct.folder}, {IK_files_struct.name});

    [avg,sd,~,~,ik_data,~] = getIK_SD_and_mean(IKdata_paths, GC.(T));
end

%%  TD reference data 
if opts.include_TD_reference
    TD_loaded = load(opts.TD_path);
    fn = fieldnames(TD_loaded);
    TD = TD_loaded.(fn{1});   % struct is named ExpData_TD or ExpData_TD_transf
end

%% figure 
fig = figure;
% colororder({'k','k'});

legend_handles = gobjects(0);
legend_labels  = {};

n_rows = 3; n_cols = 3;

for i = 1:length(IK_names_os)

    AngleName_os = IK_names_os{i};   % OpenSim name -> used to look up angles

    subplot(n_rows, n_cols, i); hold on

    %  TD reference (plotted first, in the background) 
    if opts.include_TD_reference
        TD_name = regexprep(plot_titles{i}, '_[rl]$', '');  % TD data has no side suffix
        idx_TD = find(strcmp(TD.kinematics.colheaders, TD_name));
        if ~isempty(idx_TD)
            avg_TD = TD.kinematics.mean(:,idx_TD);
            sd_TD  = TD.kinematics.sd(:,idx_TD);

           hTD = fill([1:length(avg_TD), fliplr(1:length(avg_TD))], ...
                [(avg_TD-sd_TD)', fliplr((avg_TD+sd_TD)')], ...
                [0.5 0.5 0.5], 'FaceAlpha',0.3,'EdgeAlpha',0.4,'EdgeColor',[0.5 0.5 0.5]);
            % hTD = plot(1:length(avg_TD), avg_TD, 'Color',[0.5 0.5 0.5],'LineWidth',2);
            lbl = sprintf('TD reference %s', convention_str);
            if isempty(legend_handles) || ~any(contains(legend_labels,'TD reference'))
                legend_handles(end+1) = hTD; 
                legend_labels{end+1}  = lbl; 
            end
        end
    end

    % patient experimental IK 
    if opts.include_patient_ik
        idx_col = find(strcmp(ik_data.colheaders, AngleName_os));

        if contains(AngleName_os, '_l')
            avg_col = avg.L(:,idx_col);
            sd_col  = sd.L(:,idx_col);
        else
            avg_col = avg.R(:,idx_col);
            sd_col  = sd.R(:,idx_col);
        end

        if opts.apply_clinical_convention
            flip = 1;
            if contains(AngleName_os, {'pelvis_tilt','knee','lumbar_extension'})
                flip = -1;
            end

            avg_col = avg_col * flip;

            if contains(AngleName_os, {'pelvis_tilt','hip_flexion'})
                avg_col = avg_col + 13;
            elseif contains(AngleName_os, 'lumbar_extension')
                avg_col = avg_col - 13;
            end
        end

        hIK =fill([1:length(avg_col), fliplr(1:length(avg_col))], ...
            [(avg_col-sd_col)', fliplr((avg_col+sd_col)')], ...
            c_exp, 'FaceAlpha',0.4,'EdgeAlpha',0.5,'EdgeColor',c_exp);
        % plot(1:length(avg_col), avg_col, 'Color', c_exp,'LineWidth',2);
        lbl = sprintf('experimental kinematics - %s surgery %s', T,convention_str);
        if ~any(strcmp(legend_labels,lbl))
            legend_handles(end+1) = hIK; 
            legend_labels{end+1}  = lbl; 
        end
    end

    % simulation 
    AngleName_sim = sim_names{i};
    idx_coordinate = strcmp(R.colheaders.coordinates, AngleName_sim);

    if contains(AngleName_os, '_l')
        R_plot = R_left;
    else
        R_plot = R;
    end

    ydata = R_plot.kinematics.Qs;
    y_i = ydata(:, idx_coordinate);
    x_i = linspace(1, 100, length(y_i));
    
  
    hsim = plot(x_i, y_i,'Color', c_sim, 'LineWidth', 2);
    lbl = sprintf('simulation results - %s surgery %s', T, convention_str);
    if ~any(strcmp(legend_labels,lbl))
        legend_handles(end+1) = hsim; 
        legend_labels{end+1}  = lbl; 
    end

    title(plot_titles{i}, 'Interpreter','none')
end

phase_title = [upper(T(1)) T(2:end)];
sgtitle(sprintf('%s surgery: simulation vs. experimental kinematics', phase_title))

han = axes(fig,'visible','off');
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
xlabel(han,'Gait cycle (%)','FontSize',12)
ylabel(han,'Angle (deg)','FontSize',12)

legend1 = legend(legend_handles, legend_labels);
legend1.ItemTokenSize = [30,18];
set(legend1,'Position',[0.677123632983556 0.103763141299236 0.236785717759814 0.118925488587332]);

end

