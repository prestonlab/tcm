function param = unpack_param(param_vec, param_info, fixed)
%UNPACK_PARAM   Translate from a parameter vector to a struct.
%
%  param = unpack_param(param_vec, param_info, fixed)
%
%  INPUTS:
%   param_vec:  numeric vector of parameter values.
%
%  param_info:  vector structure with one element for each
%               parameter. Must have fields:
%                vector_index - index in param_vec
%                name         - name in the parameter structure
%
%  OUTPUTS:
%    param:  parameter structure for use in running simulations.

if nargin < 3
    fixed = struct();
end

param = fixed;
vector_index = [param_info.vector_index];
for i = 1:length(param_vec)
    % find this element in the info struct
    ind = find(vector_index == i);
    for j = 1:length(ind)
        param.(param_info(ind(j)).name) = param_vec(i);
    end
end
