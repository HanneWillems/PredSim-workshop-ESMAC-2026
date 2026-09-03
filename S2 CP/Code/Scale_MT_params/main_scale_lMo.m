%% Scaling optimal muscle fiber length (lMo) of a musculoskeletal model
%
% Scales the optimal muscle fiber length (lMo) of selected muscles:
%   - soleus
%   - gastroc
%   - hamstrings
%   - iliopsoas
%
% For soleus, gastroc and hamstrings, the scaling factor is estimated
% by matching passive joint torque at the clinically measured pROM angle.
%
% For iliopsoas, the contralateral contracture is estimated from unilateral
% and bilateral popliteal angles. The corresponding hip correction angle
% is calculated from hamstring moment arms and used to estimate the lMo
% scaling factor.
%
% Original author: Ellis Van Can
% Original date: November 19, 2025
%
% Last edit by: Ellis Van Can
% Last edit date: August 26, 2026
clc; clear; close all

%% 1. Specify local paths 

% -------   start edit   -------
PredSim_path = 'C:\GBW_MyPrograms\PredSimSHARED'; % path to PredSim
casadi_path = 'C:\GBW_MyPrograms\casadi_3_5_5'; % path to Casadi
% -------   stop edit    -------

addpath(genpath(PredSim_path));
addpath(genpath(casadi_path));
%% 2. Initialize settings
subject_name = 'gait1018_esmac'; 

osim_path = fullfile(PredSim_path,'Subjects',subject_name,[subject_name,'.osim']);

%% 3 Get the passive range of motion (pROM) scores from the clinical exam
%% -------    start edit  -------
muscle_toScale = 'iliopsoas'; % Options: 'soleus', 'gastroc','hamstrings','iliopsoas'

side = 'r'; % side evaluated in clinical exam

% Step 3. scaling muscle fiber length of the hamstrings
if ismember(muscle_toScale, {'soleus','gastroc','hamstrings'})

    CE_angle = 20;

% Step 4. Scaling optimal muscle fiber length of iliopsoas
elseif strcmp(muscle_toScale, 'iliopsoas')

    CE_angle_bi  = -70;
    CE_angle_uni = -80;

end

%% -------    stop edit   -------
    % NOTE:
    % The length (and thus scaling) of other muscles (e.g. soleus, gastroc)
    % also affects the joint posture during the clinical exam.
    % Therefore, CE_angle should represent the posture that results from the
    % (possibly scaled) distal muscle-tendon lengths used in this model.


if ~exist('sf_lMo_prev','var') || ~isfield(sf_lMo_prev, side)
    sf_lMo_prev.(side) = {};
end

[sf_lMo_prev] = get_sf_lMo(muscle_toScale,side,sf_lMo_prev);

%% 4 put the model in position of clinical exam
[f_lMT_vMT_dM, model_info,coordinates] = generatePolynomials_ESMAC(osim_path, PredSim_path);

% Step 3. scaling muscle fiber length of the hamstrings
if ismember(muscle_toScale, {'soleus','gastroc','hamstrings'})

    [Qs,Qdots,idx_joint,coord_name] = ...
        get_CE_position(CE_angle,muscle_toScale,side,coordinates);

% Step 4. Scaling optimal muscle fiber length of iliopsoas
elseif strcmp(muscle_toScale,'iliopsoas')

        % calculate delta hip
        hip_name_side = ['hip_flexion_',side];
        knee_name_side = ['knee_angle_',side];

        idx_hip = find(strcmp(coordinates,hip_name_side));
        idx_knee = find(strcmp(coordinates,knee_name_side));


        [MA] = calculate_MA_iliopsoas(side,model_info,sf_lMo_prev,coordinates,f_lMT_vMT_dM,CE_angle_bi);


        idx_biart = find(MA(:,idx_hip)~=0 & MA(:,idx_knee)~=0);


        ratios=[];

        for i=1:length(idx_biart)

            m_idx = idx_biart(i);
            mname=model_info.muscle_info.muscle_names{m_idx};


            hamstring_names = {'bifemlh','bifemsh','semiten','semimem','hamstrings'};

            if any(cellfun(@(x) contains(mname,x),hamstring_names))

                ratios(end+1)=MA(m_idx,idx_knee)/MA(m_idx,idx_hip);

            end

        end


        mean_ratio=mean(ratios);

        delta_hip=(CE_angle_bi-CE_angle_uni)*mean_ratio;


        [Qs,Qdots,idx_joint,coord_name] = ...
            get_CE_position_iliopsoas(delta_hip,side,coordinates);
end

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

%% -------    start edit  -------

% Define scaling factor range 
% (sf_lMo = flip([start range : step size : end range]);

sf_lMo = flip([0.7:0.01:0.8]); 

%% -------    stop edit   -------

% Step 3. scaling muscle fiber length of the hamstrings
if ismember(muscle_toScale, {'soleus','gastroc','hamstrings'})

calculate_sf_lMo(sf_lMo, muscle_toScale, side, model_info, sf_lMo_prev,...
    Qs, Qdots, coordinates, f_lMT_vMT_dM, idx_joint, coord_name, CE_angle)


% Step 4. Scaling optimal muscle fiber length of iliopsoas
elseif strcmp(muscle_toScale, 'iliopsoas')

calculate_sf_lMo_iliopsoas(sf_lMo,muscle_toScale,side,model_info,sf_lMo_prev,...
    Qs,Qdots,coordinates,f_lMT_vMT_dM,idx_joint,coord_name,delta_hip)


end


