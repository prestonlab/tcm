function net = present_items_tcm(net, param)
%PRESENT_ITEMS_TCM   Present a series of items to a TCM network.
%
%  net = present_items_tcm(net, param)
%
%  INPUTS
%  net - struct
%      Struct with network components. See init_network_tcm for
%      details. Context updating depends on c and
%      w_fc_exp. Special fields used here:
%      dc - logical
%          If true, will assume that pre-experimental contexts
%          associated with items are not orthogonal. This requires
%          the use of a more computationally expensive rule for
%          updating context. If false, all inputs to context during
%          study are assumed to be orthogonal. This means that the
%          code will not work correctly if items are repeated in
%          the list.
%
%  param - struct
%      Struct with model parameters. See check_param_tcm for
%      details.
%
%  OUTPUTS
%  net - struct
%      Learning modifies w_fc_exp and w_cf_exp. Context (c) is also
%      updated to its end state after list presentation.

if isfield(param, 'record') && ~isempty(param.record)
    for i = 1:length(param.record)
        net.pres.(param.record{i}) = cell(1, length(net.f_item));
    end
end

net.c_in = zeros(size(net.c));
for i = 1:length(net.f_item)
    % interpresentation interval
    if param.B_ipi > 0;
        % assuming context input is orthgonal to current context
        rho = sqrt(1 - param.B_ipi^2);
        net.c_in(:) = 0;
        net.c_in(net.c_ipi(i)) = 1;
        net.c = rho * net.c + param.B_ipi * net.c_in;
    end
    
    % update context with item input
    ind = net.f_item(i);
    net.c_in(:) = normalize_vector(net.w_fc_pre(:,ind));
    rho = scale_context(net.c, net.c_in, param.B_enc);
    net.c = rho * net.c + param.B_enc * net.c_in;
    
    % learning rate
    Lcf = param.Lcf + (param.P1 * exp(-param.P2 * (i - 1)));
    
    % update weights
    net.w_fc_exp(:,ind) = net.w_fc_exp(:,ind) + (param.Lfc * net.c);
    net.w_cf_exp(ind,:) = net.w_cf_exp(ind,:) + (Lcf * net.c');
    
    if isfield(param, 'record') && ~isempty(param.record)
        for j = 1:length(param.record)
            net.pres.(param.record{j}){i} = net.(param.record{j});
        end
    end
end

% retention interval
if param.B_ri > 0;
    % assuming context input is orthogonal to current context
    rho = sqrt(1 - param.B_ri^2);
    net.c_in(:) = 0;
    net.c_in(net.c_ri) = 1;
    net.c = rho * net.c + param.B_ri * net.c_in;
end

if param.B_s > 0;
    % retrieve start-list context
    net.c_in(:) = 0;
    net.c_in(net.c_start) = 1;
    rho = scale_context(net.c, net.c_in, param.B_s);
    net.c = rho * net.c + param.B_s * net.c_in;
end

function rho = scale_context(c, c_in, B)

cdot = dot(c, c_in);
rho = sqrt(1 + B^2 * (cdot^2 - 1)) - (B * cdot);
