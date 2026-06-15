function Shift_stiff = Calculate_Shift_stiff(muscleGroups, CE_Case)
%%% This function calculates the shift of the passive force-length curves of the muscles for an OpenSim model based on the stiffness scale values from a clinical examination
%%%
%%% Inputs:
%%%     - muscleGroups: Configuration Table containing the link between the clinical examination values and specific muscles
%%%     - CE_Case: Table containing stiffness scale values of a Case
%%%
%%% Output:
%%%     - Shift_stiff: Table containing the shift of the passive force-length curves of the muscles for an OpenSim model based on the stiffness scale values from a clinical examination
%%%      
%%% -----------------------------------------------------------------------------------------------------------------

nGroups   = height(muscleGroups);
Shift_stiff = zeros(nGroups,1);

for i = 1:nGroups
    idxStiff = strcmp(CE_Case.Properties.VariableNames, muscleGroups.StiffVar{i});
    stiff_value = CE_Case{1, idxStiff};

    % Your linear mapping from stiffness scale → shift
    Shift_stiff(i) = (-1/6) * stiff_value + 1;
end