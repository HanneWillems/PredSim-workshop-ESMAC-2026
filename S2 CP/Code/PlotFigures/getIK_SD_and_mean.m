function [avg,sd,R,L,data,t_norm] = getIK_SD_and_mean(data_paths,GCs)
% getIK_SD_and_mean
%   Generalized version: works for an arbitrary number of trials
%   (previously hardcoded for exactly 2 trials/data_paths).
%
% INPUT:
%   - data_paths : cell array with N paths to .mot/data files
%   - GCs        : struct array of length N, each with fields .R and .L
%                  (gait cycle timepoints, [start end] per row)
%
% Original author: Bram Van Den Bosch
% Last edit by: Ellis Van Can 04/08/2026

n_trials = length(data_paths);

%% combine data from all trials
data.data = [];
data.colheaders = {};
R = [];
L = [];
time_offset = 0;

for i_trial = 1:n_trials
    data_trial = importdata(data_paths{i_trial});

    if i_trial == 1
        data.colheaders = data_trial.colheaders;
    end

    % gait cycle timepoints of this trial, shifted by cumulative time
    R_trial = GCs(i_trial).R + time_offset;
    L_trial = GCs(i_trial).L + time_offset;
    R = [R; R_trial];
    L = [L; L_trial];

    % shift time column (col 1) by cumulative time
    trial_data = data_trial.data;
    trial_data(:,1) = trial_data(:,1) + time_offset;
    data.data = [data.data; trial_data];

    % update cumulative end time for the next trial
    time_offset = data.data(end,1);
end

R = round(R,2);  % round to 2 decimal places
L = round(L,2);  % round to 2 decimal places
data.data(:,1) = round(data.data(:,1), 2); % round to 2 decimal places

%% calculate std
nCols = size(data.data,2);

A = [];
avg = struct;
sd = struct;
for j = 1:nCols
    for i = 1:length(R)
        idx_start = find(data.data(:,1) == R(i,1));
        idx_end = find(data.data(:,1) == R(i,2));
        duration = R(i,2) - R(i,1);
        new_points = linspace(1,duration*100,100);
        data2plot = interp1(data.data(idx_start:idx_end,j),new_points);
        A = [A data2plot'];
        t_norm.R{i}(:,j) = data2plot';
    end
    sd.R(:,j) = std(A');
    avg.R(:,j) = mean(A');
    A = [];
end

A = [];
for j = 1:nCols
    for i = 1:length(L)
        idx_start = find(data.data(:,1)==L(i,1));
        idx_end = find(data.data(:,1)==L(i,2));
        duration = L(i,2) - L(i,1);
        new_points = linspace(1,duration*100,100);
        data2plot = interp1(data.data(idx_start:idx_end,j),new_points);
        A = [A data2plot'];
        t_norm.L{i}(:,j) = data2plot';
    end
    sd.L(:,j) = std(A');
    avg.L(:,j) = mean(A');
    A = [];
end
end