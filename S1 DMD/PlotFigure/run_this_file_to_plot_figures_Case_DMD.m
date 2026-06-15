
clear
close all
clc

%% General settings
% These settings will apply to all figures

% Construct a cell array with full paths to files with saved results for
% which you want to appear on the plotted figures.
results_folder = fullfile('C:\GBW_MyPrograms\PredSimResults');
result_paths{1} = fullfile(results_folder,'gait1018','gait1018_v1.mat');
result_paths{2} = fullfile(results_folder,'gait1018','gait1018_v2.mat');


% Cell array with legend name for each result
legend_names = {'Reference simulation', 'DMD simulation'};

% Path to the folder where figures are saved
figure_folder = results_folder;

% Common part of the filename for all saved figures
figure_savename = 'MyFirstPredictiveSimulationFigure';

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

figure_settings(fig_count).name = 'Selected_angles';
figure_settings(fig_count).dofs = {'pelvis_tilt', ...
    'hip_flexion_r', 'knee_angle_r', 'ankle_angle_r'};
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

% figure_settings(fig_count).name = 'all_activations';
% figure_settings(fig_count).dofs = {'muscles_r'};
% figure_settings(fig_count).variables = {'a'};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {};
% fig_count = fig_count+1;

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

plot_figures(result_paths,legend_names,figure_settings);

%% add Experimental Data

load('ExpData_Case_DMD.mat');
ExpData = ExpData_Case_DMD;

joints_ref_DMD = {'pelvis_tilt',...
    'hip_flexion',...
    'knee_angle','ankle_angle',...
    };
hold on 
figure(2);
hold on

number_subplot =[4 2 3 1 ];
for i=1:length(joints_ref_DMD)
idx_jref_DMD = strcmp(ExpData.kinematics.colheaders,joints_ref_DMD{i});
        DMDdata = ExpData.kinematics.mean(:,idx_jref_DMD);
        meanPlusSTD_DMD = ExpData.kinematics.mean(:,idx_jref_DMD) + 2*ExpData.kinematics.sd(:,idx_jref_DMD);
        meanMinusSTD_DMD = ExpData.kinematics.mean(:,idx_jref_DMD) - 2*ExpData.kinematics.sd(:,idx_jref_DMD);
        hold on
        figure(2);
        subplot(2,2,number_subplot(i));
        z=[1:1:100];
        fill([z fliplr(z)],[meanPlusSTD_DMD' fliplr(meanMinusSTD_DMD')], [0 0 0], 'EdgeColor', 'none' );
        alpha(.20);   

        % Set ylabel and y-limits for specific subplots 
        switch number_subplot(i)
            case 1  % subplot 1: ankle
                ylabel('Ankle dorsiflexion angle (°)', 'FontSize', 14);
                ylim([-60 20]);
            case 2  % subplot 2: hip
                ylabel('Hip flexion angle (°)', 'FontSize', 14);
            case 3  % subplot 3: knee
                ylabel('Knee extension angle (°)', 'FontSize', 14);
            case 4  % subplot 4: pelvis
                ylabel('Posterior pelvic tilt angle (°)', 'FontSize', 14);
                ylim([-20 0]);
        end

        % Increase font size for axes (ticks, labels, titles)
        set(gca, 'FontSize', 14);
end
