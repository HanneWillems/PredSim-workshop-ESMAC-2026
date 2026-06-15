function OptimalFiberLengthTable = Get_OptimalFiberLengths(pathModel)
%%% This function extracts the Optimal Fiber Lengths of the muscles of an OpenSim
%%% model 
%%% 
%%% Input: pathModel = the path to your OpenSim model
%%% Output: OptimalFiberLengthTable = Table with the Optimal Fiber Lengths of the muscles
%%% -----------------------------------------------------------------------------------------------------------------

% Import OpenSim libraries
import org.opensim.modeling.*;

% Load the model
model = Model(pathModel);

% Get the list of muscles
muscleSet = model.getMuscles();

% Initialize arrays to store muscle names and optimal fiber lengths
numMuscles = muscleSet.getSize();
muscleNames = cell(numMuscles, 1);
optimalFiberLengths = zeros(numMuscles, 1);

% Iterate through muscles to extract names and optimal fiber lengths
for i = 0:numMuscles-1
    muscle = muscleSet.get(i);
    muscleNames{i+1} = char(muscle.getName());
    optimalFiberLengths(i+1) = muscle.getOptimalFiberLength();
end

% Create a table with muscle names and optimal fiber lengths
OptimalFiberLengthTable = table(optimalFiberLengths, 'RowNames', muscleNames);

