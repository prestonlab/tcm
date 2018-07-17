function p = p_recall_tcm(net, param, prev_rec)
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

output_pos = length(prev_rec);
LL = length(net.f_item);

% determine cue strength
if isfield(param, 'I') && param.I ~= 0 && ~isempty(prev_rec)
    % at least part of the cue is item-based

    % temporal cuing (context)
    strength_temp = ((net.w_cf_exp + net.w_cf_pre) * net.c)';

    % semantic cuing (item and context)
    net.f(:) = 0;
    net.f(prev_rec(end)) = 1;
    pre_exp_cue = param.I * net.f + (1 - param.I) * net.c;
    strength_sem = (net.w_cf_sem * pre_exp_cue)';
    
    % combine temporal and semantic cues
    strength = strength_temp + strength_sem;
elseif isfield(param, 'I') && param.I == 1 && isempty(prev_rec)
    % item semantic cuing only, but no item to cue with
    strength = ((net.w_cf_exp + net.w_cf_pre) * net.c)';
else
    % context used for both cues
    strength = ((net.w_cf_exp + net.w_cf_pre) * net.c)';
end

% get strength just for items; set to minimum activation level
strength = strength(1:LL);
strength(strength < AMIN) = AMIN;

% scale strength
if isfield(param, 'ST') && param.ST ~= 0
    remaining = 1:LL;
    remaining = remaining(~ismember(remaining, prev_rec));
    s = sum(strength(remaining));
    param.T = param.T * (s^param.ST);
end
strength = strength .^ param.T;

% if strength is zero for everything, set equal support for everything
if sum(strength) == 0
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
