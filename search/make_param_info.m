function param_info = make_param_info(names, varargin)
%MAKE_PARAM_INFO   Make a structure with information about parameters.
%
%  param_info = make_param_info(names, ...)
%
%  INPUTS:
%    names:  cell array of strings with parameter names.
%
%  OUTPUTS:
%  param_info:  struct with information about parameters, including
%               how to translate between vector and structure
%               format, and parameter ranges to use for searches.
%
%  OPTIONS:
%  Defaults shown in parentheses.
%   vector_index - numeric array with indices indicating where each
%                  parameter will be held when in vector format.
%                  (1:length(names))
%   range        - [parameters X 2] numeric array of ranges.
%                  range(i,1) and range(i,2) give the minimum and
%                  maximum, respectively, of the parameter named
%                  names{i}. ([])
%   start        - numeric array of starting points for searches.
%                  start(i,j) gives the starting point for
%                  parameter i, for run j. May specify multiple
%                  "runs" for different starting points to examine.
%                  ([])

% options
def.vector_index = 1:length(names);
def.range = cell(1, length(names));
def.start = cell(1, length(names));
def.init = cell(1, length(names));
def.n_groups = 1;
opt = propval(varargin, def);

n_params = length(names);
if isnumeric(opt.range) && size(opt.range, 2) == 2
    opt.range = unpack_mat(opt.range);
end

n_params = length(names);
if isnumeric(opt.init) && size(opt.init, 2) == 2
    opt.init = unpack_mat(opt.init);
end

if isnumeric(opt.start) && ~isempty(opt.start)
    opt.start = unpack_mat(opt.start);
end

if iscolumn(names)
    names = names';
end
if iscolumn(opt.vector_index)
    opt.vector_index = opt.vector_index';
end
if iscolumn(opt.range)
    opt.range = opt.range';
end
if iscolumn(opt.init)
    opt.init = opt.init';
end
if iscolumn(opt.start)
    opt.start = opt.start';
end

param_info = struct('name', names, ...
                    'vector_index', num2cell(opt.vector_index), ...
                    'range', opt.range, 'init', opt.init, ...
                    'start', opt.start, 'group', []);

if opt.n_groups > 1
    temp = [];
    for i = 1:n_params
        for j = 1:opt.n_groups
            param_info(i).group = j;
            temp = [temp param_info(i)];
        end
    end
    param_info = temp;
    for i = 1:length(param_info)
        param_info(i).vector_index = i;
    end
end


function c = unpack_mat(x)

    c = cell(1, size(x, 1));
    for i = 1:size(x, 1)
        c{i} = x(i,:);
    end
