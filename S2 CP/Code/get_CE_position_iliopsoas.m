function [Qs,Qdots,idx_joint,coord_name] = get_CE_position_iliopsoas(delta_hip,side,coordinates)
% get_CE_position_iliopsoas
%   Generates joint positions and velocities corresponding to a clinical
%   exam (CE) posture for iliopsoas assessment by defining a range of hip
%   flexion angles around a specified clinical exam angle. The function
%   identifies the relevant hip joint coordinate (contralateral to the
%   specified side), constructs joint angle matrices (Qs) and joint
%   velocity matrices (Qdots), and returns the index of the selected joint.
%
% INPUT:
%   - delta_hip -
%   * scalar defining the hip flexion angle (in degrees) observed during
%     the clinical exam; a ±20° range is created around this value
%
%   - side -
%   * string/char indicating the side being examined
%     > 'l' : left
%     > 'r' : right
%     The joint on the opposite side is used to define the ROM
%
%   - coordinates -
%   * cell array of coordinate names from the musculoskeletal model
%
% OUTPUT:
%   - Qs -
%   * matrix of joint angles for all coordinates across the defined
%     range of motion (in radians)
%
%   - Qdots -
%   * matrix of joint angular velocities (initialised to zero)
%
%   - idx_joint -
%   * index of the hip flexion coordinate associated with the clinical
%     exam position
%
%   - coord_name -
%   * base name of the coordinate used ('hip_flexion')

% Original authors: Ellis Van Can
% Original date: November 19,2024

% Last edit by: 
% Last edit date: 
% --------------------------------------------------------------------------
if strcmp(side,'r')
    other_side = 'l';
elseif strcmp(side,'l')
    other_side = 'r';
end
coord_name = 'hip_flexion';
coord_name_side = [coord_name,'_',other_side];
% joint index
idx_joint = find(strcmp(coordinates,coord_name_side));

% Create Qs (joint angles) and Qdot (angular velocity)
ROM = linspace((delta_hip-20)*pi/180,(delta_hip+20)*pi/180,25); % Range of motion
nr = length(ROM);
ncoords = length(coordinates);
Qs = zeros(nr,ncoords);
Qdots = zeros(nr,ncoords);

% QS
Qs(:,idx_joint) = ROM; 