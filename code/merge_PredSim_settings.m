function out = merge_PredSim_settings(existing, new)
%MERGE_PREDSIM_SETTINGS Merge or override PredSim-style settings cell arrays.
%
%   OUT = MERGE_PREDSIM_SETTINGS(EXISTING, NEW) merges NEW entries into
%   EXISTING, following PredSim's flexible cell-array settings format:
%
%       { {names}, value1, value2, ..., {names}, value1, value2, ... }
%
%   Each entry starts with a cell array of muscle/dof names, followed by
%   one or more associated values. Two group shapes are supported:
%
%     - {names}, value                  e.g. muscle_pass_stiff_scale
%     - {names}, 'param', value         e.g. scale_MT_params
%
%   Behaviour:
%     - If a group's key in NEW already exists in EXISTING (same names,
%       any order, and same param if present), its value is
%       OVERWRITTEN with the value from NEW.
%     - If the key does not exist yet in EXISTING, the entry is
%       APPENDED.
%     - If EXISTING is empty, NEW is returned unchanged.
%
%   Purpose: a settings file (e.g. update_settings_pre) can safely add
%   to or override specific entries of a generic settings struct,
%   without a plain '=' assignment silently wiping out unrelated
%   entries defined earlier (e.g. in generic settings).
%
%   Example:
%       S.subject.scale_MT_params = merge_PredSim_settings(...
%           S.subject.scale_MT_params, ...
%           {{'tib_ant_l','tib_ant_r'},'FMo',0.6});
%
%       S.subject.muscle_pass_stiff_scale = merge_PredSim_settings(...
%           S.subject.muscle_pass_stiff_scale, ...
%           {{'iliopsoas_l','iliopsoas_r'}, 4.0});
%
% Original author: Ellis Van Can
% Original date: September 9, 2026

% Last edit by: 
% Last edit date: 


    if isempty(existing)
        out = new;
        return
    end

    existing_key_idx = find(cellfun(@iscell, existing));
    new_key_idx      = find(cellfun(@iscell, new));
    n_new            = length(new_key_idx);

    out = existing;
    out_key_idx = existing_key_idx;

    for i = 1:n_new
        % Extract the i-th group from 'new'
        start_i = new_key_idx(i);
        if i < n_new
            end_i = new_key_idx(i+1) - 1;
        else
            end_i = length(new);
        end
        group_new = new(start_i:end_i);
        names_new = group_new{1};

        % Match key includes the param string if this group has one
        % (i.e. group is {names, 'param', value} rather than {names, value:}
        % e.g. muscle_pass_stiff_scale)
        
        has_param_new = length(group_new) >= 3 && ischar(group_new{2});
        if has_param_new
            param_new = group_new{2};
        else
            param_new = '';
        end

        % Look for a matching key in 'out'
        match_idx = [];
        for j = 1:length(out_key_idx)
            start_j = out_key_idx(j);
            if j < length(out_key_idx)
                end_j = out_key_idx(j+1) - 1;
            else
                end_j = length(out);
            end
            group_existing = out(start_j:end_j);
            names_existing = group_existing{1};

            has_param_existing = length(group_existing) >= 3 && ischar(group_existing{2});
            if has_param_existing
                param_existing = group_existing{2};
            else
                param_existing = '';
            end

            same_names = isequal(sort(names_existing), sort(names_new));
            same_param = isequal(param_existing, param_new);

            if same_names && same_param
                match_idx = j;
                match_range = start_j:end_j;
                break
            end
        end

        if ~isempty(match_idx)
            % Overwrite the matched group in place
            out = [out(1:match_range(1)-1), group_new, out(match_range(end)+1:end)];
        else
            % Append as a new group
            out = [out, group_new];
        end

        % Recompute key indices since 'out' length may have changed
        out_key_idx = find(cellfun(@iscell, out));
    end
end