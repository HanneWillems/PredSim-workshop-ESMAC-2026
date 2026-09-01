figure(1)

joints = {'ankle', 'knee', 'hip'};

sgns = [1 -1 1];

for j = 1:length(joints)
    
    data = csvread(['dropfoot_', joints{j}, '.csv']);

    subplot(2,3,j+3)
    plot(data(:,1), sgns(j)*data(:,2),'k--','linewidth', 2, 'DisplayName', 'Data (dropfoot)')
end
