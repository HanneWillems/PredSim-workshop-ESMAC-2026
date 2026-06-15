function [] = plot_data()

%% Load and process data
Ajoint = nan(3,2,201,9);

for pp = 1:9
    load(strcat(['p', num2str(pp), '_5StridesData_trial20.mat']),'data');
    
    % Extract grfs for each trial
    if isempty(data.Force)==1
        disp('data.Force is empty')
        keyboard
    else
        GRFL=[data.Force.force1(:,1),...
            data.Force.force1(:,2),...
            data.Force.force1(:,3)];
        
        GRFR=[data.Force.force2(:,1),...
            data.Force.force2(:,2),...
            data.Force.force2(:,3)];
    end
    
    % Get heelstrikes for the left and right (hsl, hsr)
    [hsl, ~, hsr, ~] = invDynGrid_getHS_TO(GRFL, GRFR,40);
    hsr(6) = length(GRFL); % often not found with the function
    
    % divide by ten since mocap was collected at a frequency 10x less
    % than grfs were collected
    hsl = ceil(hsl/10);
    hsr = ceil(hsr/10);
    
    % discard some heelstrikes
    hsl              = unique(hsl);
    hsl(diff(hsl)<5) = [];
    
    hsr              = unique(hsr);
    hsr(diff(hsr)<5) = [];
    
    % store in Ajoint
    Ajoint(1,1,:,pp) = mean(interpolate_to_percgaitcycle(data.Link_Model_Based.l_ank_angle(:,1), hsr, 201),2,'omitnan');
    Ajoint(1,2,:,pp) = mean(interpolate_to_percgaitcycle(data.Link_Model_Based.r_ank_angle(:,1), hsr, 201),2,'omitnan');
    Ajoint(2,1,:,pp) = mean(interpolate_to_percgaitcycle(data.Link_Model_Based.l_kne_angle(:,1), hsr, 201),2,'omitnan');
    Ajoint(2,2,:,pp) = mean(interpolate_to_percgaitcycle(data.Link_Model_Based.r_kne_angle(:,1), hsr, 201),2,'omitnan');
    Ajoint(3,1,:,pp) = mean(interpolate_to_percgaitcycle(data.Link_Model_Based.l_hip_angle(:,1), hsr, 201),2,'omitnan');
    Ajoint(3,2,:,pp) = mean(interpolate_to_percgaitcycle(data.Link_Model_Based.r_hip_angle(:,1), hsr, 201),2,'omitnan');
    
end

%% Plot
for jj = 1:2
    for i = 1:3
        
        subplot(2,3,(jj-1)*3 + i);
        z = linspace(0,100,201);
        meanPlusSTD = squeeze(mean(Ajoint(i,jj,:,:),4)) + squeeze(std(Ajoint(i,jj,:,:),1,4));
        meanMinusSTD = squeeze(mean(Ajoint(i,jj,:,:),4)) -  squeeze(std(Ajoint(i,jj,:,:),1,4));
        
        fill([z fliplr(z)],[meanPlusSTD' fliplr(meanMinusSTD')], [0 0 0], 'EdgeColor', 'none' ,'Displayname', 'Data (healthy)'); hold on
        alpha(.20);
        
        ylim([-70 25]); ylabel('Angle (deg)')
        
    end
end
end

%% functions
function[xi] = interpolate_to_percgaitcycle(x,segm,npoints)

    xi = nan(npoints,length(segm)-1);

    for j = 1:(length(segm)-1)

        % heelstrike to heelstrike, finite only
        xseg = x(segm(j):segm(j+1));
        xfin = xseg(isfinite(xseg)); xfin = xfin(:);

        % make artifical time vector
        tart = linspace(0, 100, length(xfin)); tart = tart(:);

        % interpolate
        xi(:,j) = interp1(tart, xfin, linspace(0, 100, npoints));
    end

end


%%
function [hsl, tol, hsr, tor] = invDynGrid_getHS_TO(GRFl, GRFr, thres)

% Takes grfl and grfr from InverseDynamicsGrid data,
% generates left foot heel strike, left foor toe off, right HS, right TO
% ! GRF vertical threshold is set to be 40. Need to be revised.
% ! This code may cut out 1 HS or TO from each leg for consistency.
% by Hansol

% Adapted from Hansol to make threshold an input

GRFl(GRFl(:,3)<thres,:) = 0;
GRFr(GRFr(:,3)<thres,:) = 0;

cutoff = 6;
fs = 1200;
[b_low,a_low] = butter(2,cutoff/(fs/2),'low');

% GRFl = grfl{1};
temp = filtfilt(b_low,a_low,GRFl(:,3));

idx1 = find(temp<=250);
idx2 = find(temp>250);
ref_idx1 = intersect(idx1+1, idx2); % first point greater than 200
ref_idx2 = intersect(idx1-1, idx2); % last point greater than 200
clearvars idx1 idx2

% detect HS and TO %
hsl = nan(length(ref_idx1),1);
for q=1:length(ref_idx1)
    hs = find(GRFl(1:ref_idx1(q),3)<thres, 1, 'last');
    if(q==1&&numel(hs)==0), hsl(q) = nan;
    else
        hsl(q) = hs;
    end
end

if(isnan(hsl(1))), hsl(1) = []; end

tol = nan(length(ref_idx2),1);
for q=1:length(ref_idx2)
    to = find(GRFl(ref_idx2(q):end,3)<thres, 1, 'first');
    if(q==length(ref_idx2)&&numel(to)==0), tol(q) = nan;
    else
        tol(q) = to + ref_idx2(q) - 1;
    end
end
if(isnan(tol(end))), tol(end) = []; end

if(tol(1)<hsl(1)), tol(1)=[]; end
% if(hsl(end)>tol(end)), hsl(end)=[]; end;



% GRFr = grfr{1};
temp = filtfilt(b_low,a_low,GRFr(:,3));

idx1 = find(temp<=250);
idx2 = find(temp>250);
ref_idx1 = intersect(idx1+1, idx2); % first point greater than 200
ref_idx2 = intersect(idx1-1, idx2); % last point greater than 200
clearvars idx1 idx2

% detect HS and TO %
hsr = nan(length(ref_idx1),1);
for q=1:length(ref_idx1)
    hs = find(GRFr(1:ref_idx1(q),3)<thres, 1, 'last');
    if(q==1&&numel(hs)==0), hsr(q) = nan;
    else
        hsr(q) = hs;
    end
end

if(isnan(hsr(1))), hsr(1) = []; end

tor = nan(length(ref_idx2),1);
for q=1:length(ref_idx2)
    to = find(GRFr(ref_idx2(q):end,3)<thres, 1, 'first');
    if(q==length(ref_idx2)&&numel(to)==0), tor(q) = nan;
    else
        tor(q) = to + ref_idx2(q) - 1;
    end
end
if(isnan(tor(end))), tor(end) = []; end

% if(tor(1)<hsr(1)), tor(1)=[]; end;
if(hsr(end)>tor(end)), hsr(end)=[]; end
end
