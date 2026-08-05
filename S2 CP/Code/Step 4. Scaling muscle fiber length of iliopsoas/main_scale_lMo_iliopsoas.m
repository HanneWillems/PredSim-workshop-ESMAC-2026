%% scaling lMo soleus gastrocnemii and hamstrings of a musculoskeletal model


% Original authors: Ellis Van Can
% Original date: November 19,2025

clc; clear; close all

%% 1. Add paths 

% ------- start edit -------
PredSim_path = 'C:\GBW_MyPrograms\PredSim'; % path to PredSim
casadi_path = 'C:\GBW_MyPrograms\casadi_3_5_5'; % path to Casadi
% ------- stop edit -------

addpath(genpath(PredSim_path));
addpath(genpath(casadi_path));
%% 2. Intialize settings
subject_name = 'CP_ESMAC'; 

osim_path = fullfile(PredSim_path,'Subjects','gait1018','gait1018.osim');

%% 3 Get the passive range of motion (pROM) scores from the clinical exam
% -------   start edit   -------
muscle_toScale = 'soleus'; 

CE_side = 'r'; % side on which the Clinical Exam is performed; options: 'l', 'r' 
CE_angle_uni = -80 ; 
CE_angle_bi = -70 ; 
% -------   stop edit   -------

    % NOTE:
    % The length (and thus scaling) of other muscles (e.g. soleus, gastrocnemii, hamstrings)
    % also affects the joint posture during the clinical exam.
    % Therefore, CE_angle should represent the posture that results from the
    % (possibly scaled) distal muscle-tendon lengths used in this model.

if ~exist('sf_lMo_prev','var') || ~isfield(sf_lMo_prev, CE_side)
    sf_lMo_prev.(CE_side) = {};
end

[sf_lMo_prev] = get_sf_lMo(muscle_toScale,CE_side,sf_lMo_prev);

%% 4. get model info
[f_lMT_vMT_dM, model_info,coordinates] = generatePolynomials_ESMAC(osim_path, PredSim_path);

%% 5. get delta hip
hip_name_side = ['hip_flexion_',CE_side];
knee_name_side = ['knee_angle_',CE_side];
idx_hip = find(strcmp(coordinates,hip_name_side));
idx_knee = find(strcmp(coordinates,knee_name_side));

% get moment arms
[MA] = calculate_MA_iliopsoas(CE_side,model_info,sf_lMo_prev,coordinates,f_lMT_vMT_dM,CE_angle_bi);

idx_biarticulair = find(all(MA(:, [idx_hip idx_knee]) ~= 0, 2));
i_hamstring = 1;
for i = 1:length(idx_biarticulair)
    if contains(model_info.muscle_info.muscle_names(i),'hamstrings') % only the case for 2D models
        idx_m_biart = idx_biarticulair(i);
        ratio(i) = MA(idx_m_biart, idx_knee)/MA(idx_m_biart, idx_hip);
        i_hamstring = i_hamstring+1;
    else
        ratio(i) = 0;
    end
end
delta_hip = (CE_angle_bi-CE_angle_uni) * (sum(ratio)/i_hamstring);

%% 5. put the model in position of delta hip
[Qs,Qdots,idx_joint,coord_name] = get_CE_position_iliopsoas(delta_hip,CE_side,coordinates);
%% 6. evaluate scaling factor
%% Background
% The contracture of the !!! contralateral !!! iliopsoas is determined by solving
% for the scaling factor that produces passive torque when the
% contralateral hip is extended beyond delta_hip.
%
% In other words, when the hip angle is at delta_hip, the passive torque
% should be zero. As the hip extends further beyond delta_hip, the passive
% torque begins to increase.

%% Instructions:
% Find the scaling factor that ensures zero passive torque at delta_hip.

% To find the sf you have to play a little with sf_lMo 
% It can be useful to begin with a broader range, such as [0.7:0.1:1], and
% then narrow it down.

% -------   start edit   -------

% Define scaling factor range 
% (sf_lMo = flip([start range : step size : end range]);

sf_lMo = flip([0.7:0.1:1]); 

% -------   stop edit   -------


calculate_sf_lMo_iliopsoas(sf_lMo,muscle_toScale,CE_side,model_info,sf_lMo_prev,Qs,Qdots,coordinates,f_lMT_vMT_dM,idx_joint,coord_name,delta_hip)


