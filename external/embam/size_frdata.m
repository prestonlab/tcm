function [n_trials, n_items, max_recalls] = size_frdata(data)
%SIZE_FRDATA   Get size information for a standard free recall data struct.
%
%  [n_trials, n_items, max_recalls] = size_frdata(data)

% study period information
try
    [n_trials, n_items] = size_if_exist(data, {'pres_itemnos'});
catch
    n_items = data.listLength;
end

% recall period information
[n_trials, max_recalls] = size_if_exist(data, {'rec_itemnos', 'recalls'});


function [r, c] = size_if_exist(data, fields)

    f_ind = find(isfield(data, fields));
    if isempty(f_ind)
        error('None of the queried fields exist')
    end

    % get the size from the first existing field
    f = fields{f_ind(1)};
    if ndims(data.(f)) ~= 2
        error('Unexpected number of dimensions in field %s.', f)
    end
    [r, c] = size(data.(f));
