
clear
close all
clc

%% General settings
% These settings will apply to all figures
% Construct a cell array with full paths to files with saved results for
% which you want to appear on the plotted figures.

% -------    start edit  -------
results_folder = 'C:\GBW_MyPrograms\PredSimResults';

%  add the paths of the figures you want to plot
    % EXAMPLE
    % results_path = struct( ...
        % 'post_surgery',fullfile(results_folder,'gait1018','gait1018_v24.mat'));
    % only post surgery is plotted 

results_path = struct( ...
    'reference',   fullfile(results_folder,'gait1018','gait1018_v28.mat'), ...
    'pre_surgery', fullfile(results_folder,'gait1018','gait1018_v26.mat'), ...
    'post_surgery',fullfile(results_folder,'gait1018','gait1018_v27.mat'));

% enable/disable the visualisation of experimental kinematics
experimental_kinematics = 1; % options: 1 (yes) 0 (no)

% legend for your figure
legend_names = {'reference', 'pre surgery', 'post surgery'};

% Path to the folder where figures are saved
figure_folder = results_folder;

% Common part of the filename for all saved figures
figure_savename = 'ComparisonSimulations_CP_SMALLL';


% -------    stop edit  -------

[pathRepo,~,~] = fileparts(mfilename('fullpath'));
IKResultsFolder = fullfile(fileparts(pathRepo), 'IK');
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
%   * Cell array of strings. Containsone or more variable names. e.g. 'Qs'
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

%%
result_fieldnames = fieldnames(results_path);

for i = 1:length(result_fieldnames)
    resultName = result_fieldnames{i};

    result_paths{i} = results_path.(resultName);
end

plot_figures(result_paths,legend_names,figure_settings);


if experimental_kinematics
    if isfield(results_path, 'pre_surgery')
        idx_pre = find(strcmp(result_fieldnames,'pre_surgery'));
        plot_pre_surgery(result_paths{idx_pre},IKResultsFolder)
    end
    if isfield(results_path, 'post_surgery') 
        idx_post = find(strcmp(result_fieldnames,'post_surgery'));
        plot_post_surgery(result_paths{idx_post},IKResultsFolder)
    end
end