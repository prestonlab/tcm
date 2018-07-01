function p = p_stop_tcm(output_pos, prev_rec, strength, param, p_min)
%P_STOP_TCM   Calculate stop probability according to TCM.
%
%  p = p_stop_tcm(output_pos, prev_rec, strength, param, p_min)
%
%  INPUTS:
%  output_pos:  output position (the number of items previously
%               recalled; the first recall attempt is 0).
%
%    prev_rec:  vector of the serial positions of previous recalls.
%
%    strength:  vector of activation strengths for all recallable items.
%
%       param:  structure with model parameters.
%
%       p_min:  (optional) minimum probability. Returned probability
%               will be at least this distance from both 0 and 1.
%               Default is 0.
%
%  OUTPUTS:
%        p:  probability of stopping.

if nargin < 5
    p_min = 0;
end

LL = length(strength);
if output_pos == LL
    p = 1;
    return
end

switch param.stop_rule
  case 'strength'
    % P(stop) is a negative exponential function of strength
    % for all non-repeat items
    repeat = false(1, LL);
    repeat(prev_rec) = true;
    p = param.X1 + exp(-param.X2 * sum(strength(~repeat)));
  case 'op'
    % P(stop) is an exponential function of output position
    p = param.X1 * exp(param.X2 * output_pos);
  case 'ratio'
    % ratio of items not yet recalled and items that have already
    % been recalled
    repeat = false(1, LL);
    repeat(prev_rec) = true;
    ratio = sum(strength(~repeat)) / sum(strength(repeat));
    p = param.X1 + exp(-param.X2 * ratio);
    
  otherwise
    error('Unknown stopping rule.')
end

% keep probability off floor and ceiling, to avoid making events
% completely impossible
if p > 1 - p_min
    p = 1 - p_min;
elseif p < p_min
    p = p_min;
end
