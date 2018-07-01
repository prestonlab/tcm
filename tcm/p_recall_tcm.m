function p = p_recall_tcm(w_cf, c, LL, prev_rec, output_pos, param, w_cf_pre)
%P_RECALL_TCM   Probability of recall according to TCM.
%
%  p = p_recall_tcm(w_cf, c, LL, prev_rec, output_pos, param)
%
%  INPUTS:
%        w_cf:  [list length+1 X list length+1] matrix of
%               context-to-item associative weights.
%
%           c:  [list length+1 X 1] vector indicating the state of
%               context to use as a cue.
%
%          LL:  list length.
%
%    prev_rec:  vector of the serial positions of previous recalls.
%
%  output_pos:  output position (the number of items previously
%               recalled; the first recall attempt is 0).
%
%       param:  structure with model parameter values.
%
%  OUTPUTS:
%        p:  [1 X list length+1] vector of recall event probabilities;
%            p(LL+1) is the probability of stopping.

AMIN = 0.000001;
PMIN = 0.000001;

% determine cue strength
if isfield(param, 'I') && param.I ~= 0 && ...
        (~isempty(prev_rec) || param.init_item)
    % experimental cuing strength
    strength_exp = (w_cf * c)';
    f = zeros(size(c));
    if isempty(prev_rec)
        unit = LL;
    else
        unit = prev_rec(end);
    end
    f(unit) = 1;
    
    % pre-exp cuing strength
    %pre_exp_cue = normalize_vector(param.I * f + (1 - param.I) * c);
    pre_exp_cue = param.I * f + (1 - param.I) * c;
    strength_pre = (w_cf_pre * pre_exp_cue)';
    strength = strength_exp + strength_pre;
elseif isfield(param, 'I') && param.I == 1 && ...
        (isempty(prev_rec) && ~param.init_item)
    strength = (w_cf * c)';
else
    strength = ((w_cf + w_cf_pre) * c)';
end

strength = strength(1:LL);
strength(strength < AMIN) = AMIN;
if isfield(param, 'ST') && param.ST ~= 0
    remaining = 1:LL;
    remaining = remaining(~ismember(remaining, prev_rec));
    s = sum(strength(remaining));
    % if isempty(prev_rec)
    %   s = sum(strength) / min(strength);
    % else
    %   s = sum(strength(remaining)) / sum(strength(prev_rec));
    % end
    param.T = param.T * (s^param.ST);
end
strength = strength .^ param.T;

if sum(strength(1:LL)) == 0
    % if strength is zero for everything, set equal support for everything
    strength(1:LL) = 1;
end

% set activation of previously recalled items to 0
strength_all = strength;
strength(prev_rec) = 0;

% stop probability
p = NaN(1, LL+1);
p(end) = p_stop_tcm(output_pos, prev_rec, strength_all, param, PMIN);

if p(end) == 1
    % if stop probability is 1, recalling any item is impossible
    p(1:LL) = 0;
else
    % recall probability conditional on not stopping
    p(1:LL) = (1 - p(LL+1)) .* (strength ./ sum(strength));
end

if any(isnan(p))
    % sanity check in case some weird case comes through in the data
    % that the code wasn't expecting
    error('Undefined probability.')
end
