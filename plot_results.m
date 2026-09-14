% plot data
if ishandle(1), close(1); end
plot_data()

% load simulataion results
% PredSimResultsRepo = uigetdir('Select the folder that contains the simulation output');
cd(PredSimResultsRepo);
files = dir('*.mat');

% select a few outputs
ylabels = {'Dorsiflexion (deg)', 'Knee extension (deg)', 'Hip flexion (deg)','Dorsiflexion (deg)', 'Knee extension (deg)', 'Hip flexion (deg)'};
is = [8 6 4 9 7 5];

% loop over versions
for k = 1:length(files)
    
    load(files(k).name,'R','model_info');
     
    figure(1)
    
    for i = 1:6
        subplot(2,3,i)
        plot(R.kinematics.Qs(:,is(i)),'DisplayName',['Simulation ', files(k).name(17:end-4)], 'linewidth', 1.5); hold on
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
% figure(1)
% set(gcf, 'units', 'centimeters', 'position', [10 10 20 15])
% cd(pathRepo);
% exportgraphics(gcf,'Fig2.png')

%% functions
function [] = plot_data()

    data = read_json('vanderzee2022_1p4ms.json');

    joints = {'ankle_angle', 'knee_angle', 'hip_flexion'};
    legs = {'l', 'r'};
    signs = [1 -1 1];

    %% Plot
    for jj = 1:2 % legs
        for i = 1:3 % joint

            subplot(2,3,(jj-1)*3 + i);
            z = linspace(0,100,100);

            meanPlusSTD = data.ik.([joints{i}, '_', legs{jj}]) + data.ik_std.([joints{i}, '_', legs{jj}]);
            meanMinusSTD = data.ik.([joints{i}, '_', legs{jj}]) - data.ik_std.([joints{i}, '_', legs{jj}]);

            fill([z fliplr(z)],signs(i)*[meanPlusSTD'*180/pi fliplr(meanMinusSTD'*180/pi)], [0 0 0], 'EdgeColor', 'none' ,'Displayname', 'Data (healthy)'); hold on
            alpha(.20);

            ylim([-70 25]); ylabel('Angle (deg)')

        end
    end
end

