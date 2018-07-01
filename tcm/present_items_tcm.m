function [f, c, w_fc, w_cf, env] = present_items_tcm(f, c, w_fc, w_cf, ...
                                                  param, env, LL)
%PRESENT_ITEMS_TCM   Present a series of items to a TCM network.
%
%  [f, c, w_fc, w_cf] = present_items_tcm(f, c, w_fc, w_cf, param, LL)
%
%  INPUTS:
%       f:  [list length+1 X 1] vector feature layer.
%
%       c:  [list length+1 X 1] vector context layer, set to an
%           initial state of context orthogonal to all presented
%           items.
%
%    w_fc:  [list length+1 X list length+1] matrix of item-to-context
%           associative weights.
%
%    w_cf:  [list length+1 X list length+1] matrix of context-to-item
%           associative weights.
%
%   param:  structure of model parameters.
%
%      LL:  list length.
%
%  OUTPUTS:
%        f:  set to the last item.
%
%        c:  updated to contain the end-of-list context.
%
%     w_fc:  updated with associations, scaled by param.G.
%
%     w_cf:  updated with associations, scaled by primacy.

for i = 1:LL
    % interpresentation interval distraction
    if isfield(param, 'B_ipi')
        ipi_index = env.ipi_dist_unit(i);
        % present item
        f(:) = 0;
        f(ipi_index) = 1;
        
        % update context (assuming orthogonal item representations,
        % an orthogonal initial state of context, and no off-diagonal
        % pre-experimental associations on Mfc)
        rho = sqrt(1 - param.B_ipi^2);
        c = rho * c + param.B_ipi * f;
    end
    
    % activate item
    f(:) = 0;
    f(i) = 1;
    
    % update context
    if param.Afc == 0 && param.Sfc == 0
        % assuming orthogonal item representations, an orthogonal initial
        % state of context, and no off-diagonal pre-experimental
        % associations on Mfc
        rho = sqrt(1 - param.B_enc^2);
        c = rho * c + param.B_enc * f;
    else
        % must calculate the actual projection
        c_in = normalize_vector(w_fc(:,i));
        rho = scale_context(dot(c, c_in), param.B_enc);
        c = rho * c + param.B_enc * c_in;
    end
    
    % primacy
    P = (param.P1 * exp(-param.P2 * (i - 1))) + 1;

    % learning rate
    if isfield(param, 'L')
        P = P + param.L;
    end
    
    % update weights
    w_fc(:,i) = w_fc(:,i) + c;
    w_cf(i,:) = w_cf(i,:) + (P * c');

    % update event counter
    env.event = env.event + 1;
end

if isfield(param, 'B_ri');
    % end-of-list distraction
    ri_index = env.ri_dist_unit;  
    % present item
    f(:) = 0;
    f(ri_index) = 1;
    
    % update context (assuming orthogonal item representations,
    % an orthogonal initial state of context, and no off-diagonal
    % pre-experimental associations on Mfc)
    rho = sqrt(1 - param.B_ri^2);
    c = rho * c + param.B_ri * f;
end

if isfield(param, 'B_s')
    % at end of list, assume some of start list context is pushed into
    % context
    s_index = env.s_unit;
    
    % present item
    f(:) = 0;
    f(s_index) = 1;
    
    % update context
    rho = scale_context(dot(c, f), param.B_s);
    c = rho * c + param.B_s * f;
end

function rho = scale_context(cdot, B)

rho = sqrt(1 + B^2 * (cdot^2 - 1)) - (B * cdot);
