clear
% close all
clc

%% General settings
% These settings will apply to all figures
% Construct a cell array with full paths to files with saved results for
% which you want to appear on the plotted figures.
[pathRepo,~,~] = fileparts(mfilename('fullpath')); 
addpath(genpath(pathRepo));
IKResultsFolder = fullfile(fileparts(pathRepo), 'IK');
TD_reference_folder = fullfile(fileparts(fileparts(pathRepo)), 'Reference');

% -------    start edit  -------
results_folder = 'C:\GBW_MyPrograms\PredSimResults';

% results_path = struct( ...
%     'reference',   fullfile(results_folder,'gait1018_esmac','gait1018_esmac_v1.mat'), ...
%     'DMD_simulation', fullfile(results_folder,'gait1018_esmac','gait1018_esmac_v2.mat'));

results_path = struct( ...
    'reference',   fullfile(results_folder,'gait1018_esmac','gait1018_esmac_v1.mat'), ...
    'DMD_simulation', fullfile(results_folder,'gait1018_esmac','gait1018_esmac_v2.mat'), ...
    'DMD_simulation_AT_surgery',fullfile(results_folder,'gait1018_esmac','gait1018_esmac_v3.mat'));

% enable/disable:
    % visualization of experimental kinematics of the patient
    plot_experimental_kinematics = true; % options: true/false

    % visualization of TD reference data
    include_TD_reference = true; % options: true/false
    
    % clinical convention instead of open sim convention
    apply_clinical_convention = true; % options: true/false

% legend for your figure
legend_names = strrep(fieldnames(results_path), '_', ' ')';

% Path to the folder where figures are saved
figure_folder = IKResultsFolder;

% Common part of the filename for all saved figures
figure_savename = 'DMD_ESMAC_simulations';

% -------    stop edit  -------

%% Settings for each figure to be made
% "figure_settings" is a cell array where each cell contains a struct with
% the settings for a single figure.
% These settings are defined by several fields:
%   - name -
%   * String. Name assigned to the figure, and by default
%   appended to the filename when saving the figure.
%
%   - dofs -
%   * Cell array of strings. Can contain coordinate names OR muscle names.
%   Alternatively, 'all_coords' will use all coordinates from the 1st
%   result. Enter 'custom' to use variables that do not exist for individual
%   coordinates or muscles.
%
%   - variables -
%   * Cell array of strings. Contains one or more variable names. e.g. 'Qs'
%   to plot coordinate positions, 'a' to plot muscle activity. Variables
%   that do not rely on coordinates or muscles (e.g. GRFs)
%
%   - savepath -
%   * String. Full path + filename used to save the figure. Does not
%   include file extension.
%
%   - filetype -
%   * Cell array of strings. File extensions to save the figure as, leave
%   empty to not save the figure. Supported types are: 'png', 'jpg', 'eps'
%
%



% initilise the counter for dynamic indexing
fig_count = 1;

figure_settings(fig_count).name = 'all_angles';
figure_settings(fig_count).dofs = {'all_coords'};
figure_settings(fig_count).variables = {'Qs'};
figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
figure_settings(fig_count).filetype = {};
fig_count = fig_count+1;

% figure_settings(fig_count).name = 'all_angles';
% figure_settings(fig_count).dofs = {'all_coords'};
% figure_settings(fig_count).variables = {'Qdots'};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {};
% fig_count = fig_count+1;

% figure_settings(fig_count).name = 'all_angles';
% figure_settings(fig_count).dofs = {'all_coords'};
% figure_settings(fig_count).variables = {'Qddots'};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {};
% fig_count = fig_count+1;

figure_settings(fig_count).name = 'all_activations';
figure_settings(fig_count).dofs = {'muscles_r'};
figure_settings(fig_count).variables = {'a'};
figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
figure_settings(fig_count).filetype = {};
fig_count = fig_count+1;

% figure_settings(fig_count).name = 'selected_angles';
% figure_settings(fig_count).dofs = {'hip_flexion_r','hip_adduction_r','hip_rotation_r','knee_angle_r',...
%     'ankle_angle_r','subtalar_angle_r','mtp_angle_r'};
% figure_settings(fig_count).variables = {'Qs'};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {'jpeg'};
% fig_count = fig_count+1;

% figure_settings(fig_count).name = 'torques';
% figure_settings(fig_count).dofs = {'all_coords'};
% figure_settings(fig_count).variables = {'T_ID'};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {'png'};
% fig_count = fig_count+1;

% figure_settings(fig_count).name = 'ankle_muscles';
% figure_settings(fig_count).dofs = {'soleus_r','med_gas_r','lat_gas_r','tib_ant_r'};
% figure_settings(fig_count).variables = {'a','FT','lMtilde','Wdot','Edot_gait'};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {};
% fig_count = fig_count+1;

% figure_settings(fig_count).name = 'grfs';
% figure_settings(fig_count).dofs = {'custom'};
% figure_settings(fig_count).variables = {'GRF'};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {};
% fig_count = fig_count+1;

% figure_settings(fig_count).name = 'template';
% figure_settings(fig_count).dofs = {'custom'};
% figure_settings(fig_count).variables = {' '};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {};
% fig_count = fig_count+1;

%% Experimental kinematics / TD reference comparison figures
% Adds up to two extra figures (pre_surgery and post_surgery, whichever
% are present in results_path), each showing the simulated kinematics
% together with:
%   - the subject's own experimental IK envelope, if experimental_kinematics = 1
%   - the TD reference envelope, if include_TD_reference = 1
% If apply_clinical_convention = 1, both the simulation results (via the
% shared transform_result_clinical_format.m) and the experimental curves
% are converted to clinical convention, and ExpData_TD_transf.mat is used
% for the TD reference instead of ExpData_TD.mat.
%


if plot_experimental_kinematics || include_TD_reference

    fig_opts = struct( ...
        'apply_clinical_convention', apply_clinical_convention, ...
        'include_TD_reference',      include_TD_reference, ...
        'include_patient_ik',        plot_experimental_kinematics);

    if fig_opts.apply_clinical_convention
        fig_opts.TD_path = fullfile(TD_reference_folder,'ExpData_TD_transf.mat');
        fig_opts.DMD_exp_path = fullfile(IKResultsFolder,'ExpData_Case_DMD_transf.mat');
    else
        fig_opts.TD_path = fullfile(TD_reference_folder,'ExpData_TD.mat');
        fig_opts.DMD_exp_path = fullfile(IKResultsFolder,'ExpData_Case_DMD.mat'); 
    end


    plot_experimental_comparison_DMD_ESMAC(results_path, fig_opts);

    % if isfield(results_path,'pre') && ~isempty(results_path.pre)
    %     plot_experimental_comparison_CP_ESMAC(results_path.pre_surgery, 'pre', IKResultsFolder, fig_opts);
    % end
    % 
    % if isfield(results_path,'post') && ~isempty(results_path.post)
    %     plot_experimental_comparison_CP_ESMAC(results_path.post_surgery, 'post', IKResultsFolder, fig_opts);
    % end
end