function net = reactivate_item_tcm(net, item, param)
%REACTIVATE_ITEM_TCM   Reactivate a recalled item and update context.
%
%  net = reactivate_item_tcm(net, item, param)
%
%  INPUTS
%  net - struct
%      Struct with network components. See init_network_tcm for
%      details. Context updated depends on c, w_fc_exp, and w_fc_pre.
%
%  item - int
%      Serial position of the recalled item.
%
%  param - struct
%      Structure of model parameters.
%
%  OUTPUTS
%  net - struct
%      Network with c updated to reflect the recalled item.

% context associated with the recalled item
ind = net.f_item(item);
c_in = normalize_vector(net.w_fc_exp(:,ind) + net.w_fc_pre(:,ind));

% update context
rho = scale_context(dot(net.c, c_in), param.B_rec);
net.c = rho * net.c + param.B_rec * c_in;


function rho = scale_context(cdot, B)

rho = sqrt(1 + B^2 * (cdot^2 - 1)) - (B * cdot);
