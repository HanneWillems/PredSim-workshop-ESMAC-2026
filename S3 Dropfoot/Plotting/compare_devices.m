clear all; close all; clc
vs = [1 7 23]; % versions that we want to plot 

% change this to your own paths
filename = which('initializeSettings.m');

PredSimSettingsFolder = fileparts(filename);
cd(PredSimSettingsFolder)
cd ..
PredSimRepo = cd;

addpath(fullfile(cd,'PlotFigures'))

cd(PredSimRepo)
cd ..
cd('PredSimResults')

PredSimResultsRepo = cd;

figure(1)
plot_data();

% plot all versions
for k = 1:length(vs)
    
    result_paths = fullfile(PredSimResultsRepo,['gait1018\gait1018_v', num2str(vs(k)), '.mat']);
    legend_name = ['gait1018_v', num2str(vs(k)), '.mat'];

    load(result_paths,'R','model_info');
    
    % get orthosis stiffness
    if ~isempty(R.S.orthosis.settings)
        k_ankle = R.S.orthosis.settings{1}.ankle_stiffness;
        txt2 = ' + orthosis';
    else
        txt2 = '';
    end
    
    % get TA strength
    TA_strength = model_info.muscle_info.parameters(9).muscle_strength;
   
    if TA_strength == .05
        txt_append = 'weak'; 
    else
        txt_append = 'healthy';
    end
    
    txt = [txt_append, txt2];
    
    is = [8 6 4 9 7 5];
    
    figure(1)
    ylabels = {'Dorsiflexion (deg)', 'Knee extension (deg)', 'Hip flexion (deg)','Dorsiflexion (deg)', 'Knee extension (deg)', 'Hip flexion (deg)'};
    
    for i = 1:6
        subplot(2,3,i)
        plot(R.kinematics.Qs(:,is(i)),'DisplayName',txt, 'linewidth', 1.5); hold on
        title(strrep(R.colheaders.coordinates{is(i)}, '_', '-')); hold on
        ylim([-70 70])
        box off
        ylabel(ylabels{i})
        xlabel('Gait cycle (%)')
    end
    
    legend show
    legend('location', 'best')
    legend boxoff
    
end

%%
figure(1)
set(gcf, 'units', 'centimeters', 'position', [10 10 20 15])

filename = which('compare_devices');
folder = filename(1:end-18);
cd(folder);


exportgraphics(gcf,'Fig2.png')


