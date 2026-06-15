%% Personalization of Passive Muscle Stiffness Based on Clinical Examination
% This script calculates the start of the passive muscle force-length curve 
% based on clinical examination data.
%
% It returns the normalized muscle length at which passive muscle force 
% begins, personalized using:
%   (1) range-of-motion (ROM) values, and
%   (2) the clinical stiffness scale.
%
% The output can be used as input to PredSim via:
%   S.subject.muscle_pass_stiff_shift

clear all
close all
clc

%% Provide the paths to your OpenSim Model, excel with ROM reference values of TD children, and excel with ROM values of your case
[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);

pathModel = fullfile(pathRepo,'Model','gait1018.osim'); 
pathROM_TD = fullfile(pathRepo,'Clinical Exam','Ref_ROM_TD.xlsx'); 
pathCE_Case = fullfile(pathRepo,'Clinical Exam','Clinical_Exam_DMDcase.xlsx');

%% Config table to link clinical examination values to specific muscles 

muscleGroups = table;

% Corresponds to prefix of column names from excel with clinical
% examination data
muscleGroups.CE = { ...
    'Ankledf0_r'; 'Ankledf0_l'; ...
    'Ankledf90_r'; 'Ankledf90_l'; ...
    'Poplbi_r';    'Poplbi_l'; ...
    'modThomas_r'; 'modThomas_l'};
% Corresponds to column names from excel with clinical examination data
muscleGroups.ROMVar   = strcat(muscleGroups.CE, '_pROM_rad');
muscleGroups.StiffVar = strcat(muscleGroups.CE, '_stiff');

% Corresponds to muscle row names from OptimalFiberLengthTable (this table will be
% created later with the function Get_OptimalFiberLengths)
muscleGroups.Muscles = { ...
    {'gastroc_r'}; ...
    {'gastroc_l'}; ...
    {'soleus_r'}; ...
    {'soleus_l'}; ...
    {'bifemsh_r','hamstrings_r'}; ...
    {'bifemsh_l','hamstrings_l'}; ...
    {'iliopsoas_r','rect_fem_r'}; ...
    {'iliopsoas_l','rect_fem_l'}};

% Corresponds to joint angle column names from momentArmsTable (this table
% will be created later with the function Get_MomentArms)
muscleGroups.JointAngle = { ...
    'ankle_angle_r'; ...
    'ankle_angle_l'; ...
    'ankle_angle_r'; ...
    'ankle_angle_l'; ...
    'knee_angle_r'; ...
    'knee_angle_l'; ...
    'hip_flexion_r'; ...
    'hip_flexion_l'};

%% Calculate the start of passive force-length curves based on ROM values 

% Get moment arms of muscles of an Opensim model in anatomical position of model
momentArmsTable = Get_Momentarms(pathModel);

% Extract all optimal fiber length from all the muscles 
OptimalFiberLengthTable = Get_OptimalFiberLengths(pathModel);

% Read Excel files with TD data and Case data
ROMs_TD=readtable(pathROM_TD);
CE_Case=readtable(pathCE_Case);

% Calculate difference in ROM between TD ROM and Case ROM (in degrees and
% in radians)
ROM_diff = Calculate_ROM_diff(ROMs_TD, CE_Case);

% Calculate shift based on ROM values
Shift_ROM = Calculate_Shift_ROM(muscleGroups, momentArmsTable, OptimalFiberLengthTable, ROM_diff);


%% Calculate the start of passive force-length curves based on stiffness scale values 

Shift_stiff = Calculate_Shift_stiff(muscleGroups, CE_Case);

%% Calculate the average start of passive force-length curves based on ROM values and stiffness scale values
Final_shift = Calculate_avg_shift(muscleGroups, Shift_ROM, Shift_stiff);

disp(Final_shift)