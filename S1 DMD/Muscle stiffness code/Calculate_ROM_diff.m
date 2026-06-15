function ROM_diff = Calculate_ROM_diff(ROMs_TD, ROMs_Case)
%%% This function calculates the difference in range of motion (ROM) between the reference values of typically developing (TD) children and the ROM values of a specific case.
%%%
%%% Inputs:
%%%     - ROMs_TD: Table containing range of motion values for typically developing children.
%%%     - ROMs_Case: Table containing range of motion values for the case being analyzed.
%%%     Both input tables must have the same structure:
%%%         - Each column represents a different joint ROM.
%%%         - Column names include the suffix "_ROM".
%%%         - In the TD table, the ROM columns have an additional "_TD" suffix (e.g., "Hip_add_ROM_TD").
%%%         - The part of the column name preceding "_ROM" must match between the two tables (e.g., "Hip_add_", "Hip_ext_", etc.).
%%% Output:
%%%     - ROM_diff: Table containing the difference between TD reference values and the case values.
%%%       Differences are expressed both in degrees and radians (radian values are labeled with the suffix "_rad").
%%% -----------------------------------------------------------------------------------------------------------------

% Get variable names from the case table
vars = ROMs_Case.Properties.VariableNames;

% Initialize a new table for differences
ROM_diff = table();

for i = 1:numel(vars)
    varCase = vars{i};
    varTD = [varCase '_TD'];

    if ismember(varTD, ROMs_TD.Properties.VariableNames)
        %1) Difference in degress
        ROM_diff.(varCase) =  ROMs_TD.(varTD) - ROMs_Case.(varCase);
        %2) Same difference in radians
        ROM_diff.([varCase '_rad']) = ROM_diff.(varCase) * (pi/180);
    else
    end
end