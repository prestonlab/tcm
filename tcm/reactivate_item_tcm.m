function net = reactivate_item_tcm(net, unit, param)
%REACTIVATE_ITEM_TCM   Reactivate a recalled item and update context.
%
%  [f, c] = reactivate_item_tcm(f, c, w_fc, unit, param)
%
%  INPUTS:
%       f:  [list length+1 X 1] vector feature layer.
%
%       c:  [list length+1 X 1] vector context layer.
%
%    w_fc:  [list length+1 X list length+1] matrix of item-to-context
%           associative weights.
%
%    unit:  index of the recalled item in the feature layer.
%
%   param:  structure of model parameters.
%
%  OUTPUTS:
%        f:  the recalled item is activated.
%
%        c:  context is updated through associations with the
%            retrieved item.

% reactivate the recalled item
net.f(:) = 0;
net.f(unit) = 1;

% update context based on what was recalled
c_in = (net.w_fc_exp + net.w_fc_pre) * net.f;
c_in = normalize_vector(c_in);
rho = scale_context(dot(net.c, c_in), param.B_rec);
net.c = rho * net.c + param.B_rec * c_in;


function rho = scale_context(cdot, B)

rho = sqrt(1 + B^2 * (cdot^2 - 1)) - (B * cdot);
