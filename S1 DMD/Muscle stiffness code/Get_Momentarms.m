function momentArmsTable = Get_Momentarms(pathModel)
%%% This function calculates the momentArms of the muscles of an OpenSim
%%% model in the anatomical position
%%%
%%% Input: pathModel = the path to your OpenSim model
%%% Output: momentArmsTable = Table with the momentArms of the muscles
%%% -----------------------------------------------------------------------------------------------------------------

% Import OpenSim libraries
import org.opensim.modeling.*;

% Load the model
model = Model(pathModel);

% Get the default (anatomical) state of the model
state = model.initSystem();

% Set all coordinates to their default (zero) values
coordSet = model.getCoordinateSet();
for i = 0:coordSet.getSize()-1
    coordSet.get(i).setDefaultValue(0);
    coordSet.get(i).setValue(state, 0);
end

% Ensure the model is in the default position
model.realizePosition(state);

% Get the list of muscles
muscleSet = model.getMuscles();

% Get the list of coordinates (DOFs)
coordNames = cell(coordSet.getSize(), 1);
for i = 0:coordSet.getSize()-1
    coordNames{i+1} = char(coordSet.get(i).getName());
end

% Initialize a cell array to store the moment arms
momentArms = cell(muscleSet.getSize(), length(coordNames));

% Initialize a cell array for muscle names
muscleNames = cell(muscleSet.getSize(), 1);

% Loop through each muscle and DOF to get the moment arms
for i = 0:muscleSet.getSize()-1
    muscle = muscleSet.get(i);
    muscleName = char(muscle.getName());
    muscleNames{i+1} = muscleName;
    for j = 1:length(coordNames)
        coordName = coordNames{j};
        % Get the moment arm
        momentArm = muscle.computeMomentArm(state, coordSet.get(coordName));
        % Store the result in the cell array
        momentArms{i+1, j} = momentArm;
    end
end

% Convert the cell array to a table for better visualization
momentArmsTable = cell2table(momentArms, 'VariableNames', coordNames, 'RowNames', muscleNames);

