%% scaling lMo soleus gastrocnemii and hamstrings of a musculoskeletal model
%   Scales the optimal muscle fiber length (lMo) of selected plantarflexor
%   or hamstring muscles (soleus, gastrocnemii, or hamstrings) based on a
%   clinical passive range of motion (pROM) assessment. The script estimates
%   the appropriate scaling factor by matching the passive joint torque at
%   the clinical exam angle with an assumed examiner-applied torque.
%   It visualises the effect of different scaling factors to support
%   selection of an optimal value.

% Original author: Ellis Van Can
% Original date: November 19,2025

% Last edit by:
% Last edit date:
% --------------------------------------------------------------------------
clc; clear; close all

%% 1. Add paths 

% -------   start edit   -------
PredSim_path = 'C:\GBW_MyPrograms\PredSim'; % path to PredSim
casadi_path = 'C:\GBW_MyPrograms\casadi_3_5_5'; % path to Casadi
% -------   stop edit    -------

addpath(genpath(PredSim_path));
addpath(genpath(casadi_path));
%% 2. Intialize settings
subject_name = 'CP_ESMAC'; 

osim_path = fullfile(PredSim_path,'Subjects','gait1018','gait1018.osim');

%% 3 Get the passive range of motion (pROM) scores from the clinical exam
% -------    start edit  -------
muscle_toScale = 'hamstrings'; % Options: 'soleus', 'gastrocnemii','hamstrings'
side = 'l'; % Options: 'l', 'r' 
CE_angle = -65 ; % Passive ROM angle Clinical Exam

% -------    stop edit   -------

    % NOTE:
    % The length (and thus scaling) of other muscles (e.g. soleus, gastrocnemii)
    % also affects the joint posture during the clinical exam.
    % Therefore, CE_angle should represent the posture that results from the
    % (possibly scaled) distal muscle-tendon lengths used in this model.

if ~exist('sf_lMo_prev','var') || ~isfield(sf_lMo_prev, side)
    sf_lMo_prev.(side) = {};
end

[sf_lMo_prev] = get_sf_lMo(muscle_toScale,side,sf_lMo_prev);

%% 4 put the model in position of clinical exam
[f_lMT_vMT_dM, model_info,coordinates] = generatePolynomials_ESMAC(osim_path, PredSim_path);
[Qs,Qdots,idx_joint,coord_name] = get_CE_position(CE_angle,muscle_toScale,side,coordinates);

%% 5. evaluate scaling factor
%% Background:
% Assume the eximator applies a torque of 15 Nm. 
% Then the passive torque around the joint should be 15 Nm at the end of
% the ROM observed during the clinical exam 

% Find the scaling factor (sf) that reflects this 15 Nm. 
% Then run the code and pick the right scaling factor from the figure 
% (find the line that goes through the crosssection of -15 % Nm and the
% clinical exam angle)

%% Instructions:
% To find the sf you have to play a little with sf_lMo (line ...)
% It can be useful to begin with a broader range, such as [0.7:0.1:1], and
% then narrow it down and increase the stepsize

% [start range  :   step size   :   end range]

% NOTE: 15 NM is a rough estimate of the examinators torque and
% this can vary between examinators and clinical examinations

% -------    start edit  -------

% Define scaling factor range 
% (sf_lMo = flip([start range : step size : end range]);

sf_lMo = flip([0.7:0.1:1]); 

% -------    stop edit   -------

calculate_sf_lMo(sf_lMo,muscle_toScale,side,model_info,sf_lMo_prev,Qs,Qdots,coordinates,f_lMT_vMT_dM,idx_joint,coord_name,CE_angle)


