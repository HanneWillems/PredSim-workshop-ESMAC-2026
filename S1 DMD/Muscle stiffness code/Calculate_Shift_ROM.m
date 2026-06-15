function Shift_ROM = Calculate_Shift_ROM(muscleGroups, momentArmsTable, OptimalFiberLengthTable, ROM_diff)
%%% This function calculates the shift of the passive force-length curves of the muscles for an OpenSim model based on the range of motion values from a clinical examination
%%%
%%% Inputs:
%%%     - muscleGroups: Configuration Table containing the link between the clinical examination values and specific muscles
%%%     - momentArmsTable: Table containing the moment arms of the muscles of an OpenSim model in anatomical position
%%%     - OptimalFiberLengthTable: Table containing the optimal fiber lengths of the muscles of an OpenSim model
%%%     - ROM_diff: Table containing the difference between TD reference values and the case values (the difference in radians will be used)
%%%  
%%% Output:
%%%     - Shift_ROM: Table containing the shift of the passive force-length curves of the muscles for an OpenSim model based on the range of motion values from a clinical examination
%%%      
%%% -----------------------------------------------------------------------------------------------------------------

nGroups   = height(muscleGroups);
Shift_ROM = zeros(nGroups,1);

for i = 1:nGroups
    % Find the ROM column for this group
    idxROM = strcmp(ROM_diff.Properties.VariableNames, muscleGroups.ROMVar{i});

    % Find the correct joint angle column in momentArmsTable
    idxMA = strcmp(momentArmsTable.Properties.VariableNames, muscleGroups.JointAngle{i});

    % Moment arms for all muscles in this group (take absolute value and mean)
    MA_muscle_group = abs(momentArmsTable{muscleGroups.Muscles{i}, idxMA});
    av_MA = mean(MA_muscle_group, "all");

    % Optimal fiber lengths for all muscles in group (mean over all columns)
    Lmo_muscle_group = OptimalFiberLengthTable{muscleGroups.Muscles{i}, :};
    av_Lmo = mean(Lmo_muscle_group, "all");

    % Shift based on ROM (ROM_diff assumed to have 1 row for this case)
    rom_value = ROM_diff{1, idxROM};

    if any(ismember(muscleGroups.Muscles{i},{'gastroc_r', 'gastroc_l' ,'soleus_r' ,'soleus_l'}))
    Shift_ROM(i) = 0.9 - (rom_value * av_MA) / av_Lmo;
    else 
    Shift_ROM(i) = 1 - (rom_value * av_MA) / av_Lmo;
    end
    
end