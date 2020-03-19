function structout = trial_assign(trials, structin, new, dim)

if nargin < 3
    dim = 1;
end

% sanity checks
if ~isstruct(structin)
    error('structin must be a structure.');
elseif ~islogical(trials) || ~isvector(trials)
    error('trials must be a logical array.');
end

structout = struct;
names = fieldnames(structin);

n_dims = max(structfun(@ndims, structin));
ind = repmat({':'}, 1, n_dims);
ind{dim} = trials;
for i = 1:length(names)
    % existing data matrix/struct
    out_field = structin.(names{i});
    
    % new data for updating the existing data
    new_field = new.(names{i});
    if isstruct(this_field)
        % recurse for data.pres and data.rec and similar
        out_field = trial_subset(trials, this_field, dim);
    elseif isscalar(this_field) || ischar(this_field)
        % copy scalar values
        out_field = this_field;
    else
        message = sprintf('Field "%s" does not match index vector on dimension %d.', ...
                          names{i}, dim);
        assert(size(this_field, dim) == length(trials), message);
        out_field = this_field(ind{:});
    end

    structout.(names{i}) = out_field;
end
