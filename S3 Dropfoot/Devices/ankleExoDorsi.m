function [exo] = ankleExoDorsi(init, settings_orthosis)
% --------------------------------------------------------------------------
%
% INPUT:
%   - init -
%   * struct with information used to initialise the Orthosis object.
% 
%   - settings_orthosis -
%   * struct with information about this orthosis, containing the fields:
%       - function_name = 'ankleExoDorsi'  i.e. name of this function           
%       - ankle_stiffness:  ankle stiffness in Nm/rad
%       - left_right:       'l' for left or 'r' for right
%   Values are set via S.orthosis.settings{i} in main.m, with i the index
%   of the orthosis.
%
%
% OUTPUT:
%   - AFO -
%   * an object of the class Orthosis
% 
% Original author: Tim van der Zee
% Original date: 20/11/2025
% --------------------------------------------------------------------------

% create Orthosis object
exo = Orthosis('exo',init);

% read settings that were passed from main.m
k_ankle = settings_orthosis.ankle_stiffness * 180/pi; % ankle stiffness in Nm/rad
o_ankle = settings_orthosis.ankle_offset    * pi/180; % ankle offset in rad
side = settings_orthosis.left_right; % 'l' for left or 'r' for right

% get joint angles
q_ankle = exo.var_coord(['ankle_angle_',side]); % ankle angle in rad;

% calculate moments
% T_ankle = k_ankle*(q_ankle+0.1).*smoothIf(q_ankle+0.1,0.05,0);
% T_ankle = k_ankle*(q_ankle-0.1).*smoothIf(q_ankle-0.1,-.05, 0);
T_ankle = k_ankle*(q_ankle-o_ankle);
T_ankle = [0;0; T_ankle];

% apply exo torque on tibia and calcn
exo.addBodyMoment(T_ankle, ['T_exo_shank_',side],['tibia_',side]);
exo.addBodyMoment(-T_ankle, ['T_exo_foot_',side],['calcn_',side],['tibia_',side]);


end