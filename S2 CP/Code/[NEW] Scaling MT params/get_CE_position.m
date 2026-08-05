function [Qs,Qdots,idx_joint,coord_name] = get_CE_position(CE_angle,muscle_toScale,side,coordinates)
% get_CE_position
%   Generates joint position and velocity vectors corresponding to a
%   clinical exam (CE) posture for soleus, gastrocnemii or hamstrings
%   length assessment. The function selects the relevant joint coordinate
%   (ankle or knee) on the specified side, builds a small range of motion
%   (±20°) around the clinical exam angle, and optionally fixes another
%   joint (hip or knee) at a prescribed posture, depending on the muscle
%   being scaled.
%
%   For:
%   - soleus       : varies ankle_angle_side, fixes knee_angle_side at -90°
%   - gastrocnemii : varies ankle_angle_side, no additional joint change
%   - hamstrings   : varies knee_angle_side, fixes hip_flexion_side at 90°
%
% INPUT:
%   - CE_angle -
%   * scalar, clinical exam angle (in degrees) around which a ±20° range
%     of motion is constructed for the selected joint
%
%   - muscle_toScale -
%   * string/char specifying which muscle group is being scaled:
%       > 'soleus'
%       > 'gastrocnemii'
%       > 'hamstrings'
%     This determines which joint is varied and which, if any, is held at
%     a fixed posture.
%
%   - side -
%   * string/char indicating the body side:
%       > 'l' : left
%       > 'r' : right
%     Used to construct the full coordinate name, e.g. 'ankle_angle_r'.
%
%   - coordinates -
%   * cell array of coordinate names from the musculoskeletal model; used
%     to locate the index of the joint being varied/fixed
%
% OUTPUT:
%   - Qs -
%   * matrix (n × nCoordinates) with joint angles (in radians) for the
%     defined range of motion; only the selected coordinate (and, if
%     applicable, the secondary fixed coordinate) is non-zero
%
%   - Qdots -
%   * matrix (n × nCoordinates) of joint angular velocities; initialised
%     to zero for all coordinates
%
%   - idx_joint -
%   * index of the coordinate in 'coordinates' corresponding to the joint
%     varied around CE_angle
%
%   - coord_name -
%   * base name of the varied coordinate: 'ankle_angle' or 'knee_angle'

% Original authors: Ellis Van Can
% Original date: November 19,2024

% Last edit by: 
% Last edit date: 
% --------------------------------------------------------------------------
if strcmp(muscle_toScale,'soleus')
            coord_name = 'ankle_angle';
            model_toDiffPos = 1;
            model_changeAngle = ['knee_angle_',side];
            model_changeDeg = -90;
elseif strcmp(muscle_toScale,'gastrocnemii')
            coord_name = ['ankle_angle'];
            model_toDiffPos = 0;
elseif strcmp(muscle_toScale,'hamstrings')
            coord_name = ['knee_angle'];
            model_toDiffPos = 1;
            model_changeAngle = ['hip_flexion_',side];
            model_changeDeg = 90;    
end
coord_name_side = [coord_name,'_',side];

% Find joint index in coordinates
idx_joint = find(strcmp(coordinates,coord_name_side));

% Create Qs (joint angles) and Qdot (angular velocity)
ROM = linspace((CE_angle-20)*pi/180,(CE_angle+20)*pi/180,25); % Range of motion
n = length(ROM);

Qs = zeros(n,length(coordinates));
Qdots = zeros(n,length(coordinates));
Qs(:,idx_joint) = ROM; 

if model_toDiffPos
Qs(:,strcmp(coordinates,model_changeAngle)) = ones(n,1)*(model_changeDeg*pi/180); %knee_angle_r 90°
end