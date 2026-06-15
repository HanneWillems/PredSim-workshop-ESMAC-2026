function Final_shift = Calculate_avg_shift(muscleGroups, Shift_ROM, Shift_stiff)
%%% This function calculates average start of passive force-length curves based on ROM values and stiffness scale values
%%%
%%% Inputs:
%%%     - muscleGroups: Configuration Table containing the link between the clinical examination values and specific muscles
%%%     - Shift_ROM: Matrix containing the shifts based on ROM values
%%%     - Shift_stiff: Matrix containing the shifts based on stiffness scale value
%%%
%%% Output:
%%%     - Final_shift: Table containing the shifts based on ROM, stiffness scale and the average shift and the names of the muscles that should be shifted
%%%      
%%% -----------------------------------------------------------------------------------------------------------------

avg_shift = mean([Shift_ROM, Shift_stiff], 2);

% Nice listing of muscles per group
muscles_str = cellfun(@(c) strjoin(c, ', '), muscleGroups.Muscles, ...
                      'UniformOutput', false);

Final_shift = table(muscles_str, Shift_ROM, Shift_stiff, avg_shift, ...
    'VariableNames', {'Muscles','Shift_ROM','Shift_stiff','Shift_avg'});