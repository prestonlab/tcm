function param = check_param_tcm(param)
%CHECK_PARAM_TCM   Validate parameters for running TCM.
%
%  Checks that parameters in a parameter struct are defined, have
%  the correct type, and are in the correct range.
%
%  param = check_param_tcm(param)
%
%  PARAMETERS
%  B_enc     - [0,1] - context update rate during encoding.
%  B_rec     - [0,1] - context update rate during recall.
%  Afc, Acf  - [0,Inf] - initial strength value of off-diagonal connections.
%  Dfc, Dcf  - [0,Inf] - initial strength value for self connections.
%  Sfc, Scf  - [0,Inf] - scaling for semantic similarity.
%  Lfc, Lcf  - [0,Inf] - learning rate for item-context associations.
%  P1        - [0,Inf] - magnitude of primacy effect.
%  P2        - [0,Inf] - decay rate of primacy effect.
%  T         - [0,Inf] - exponent applied to strength in choice rule.
%  X1        - [0,1] - probability of recalling nothing.
%  X2        - [0,1] - rate of increase in probability of stopping.
%  stop_rule - {'strength','op','ratio'} - rule for stopping recall.
%  B_s       - [0,1] - context update for reactivating start context.
%  B_ri      - [0,1] - context update rate for retention interval.
%  I         - [0,1] - fraction of semantic cuing that is item-driven.

par_def = {...
    'B_enc', 'numeric', [0 1]
    'B_rec', 'numeric', [0 1]
    'Afc', 'numeric', [0 Inf]
    'Acf', 'numeric', [0 Inf]
    'Dfc', 'numeric', [0 Inf]
    'Dcf', 'numeric', [0 Inf]
    'Sfc', 'numeric', [0 Inf]
    'Scf', 'numeric', [0 Inf]
    'Lfc', 'numeric', [0 Inf]
    'Lcf', 'numeric', [0 Inf]
    'P1', 'numeric', [0 Inf]
    'P2', 'numeric', [0 Inf]
    'T', 'numeric', [0 Inf]
    'X1', 'numeric', [0 1]
    'X2', 'numeric', [0 1]
    'stop_rule', 'char', {'strength' 'op' 'ratio'}
    'B_s', 'numeric', [0 1]
    'B_ri', 'numeric', [0 1]
    'I', 'numeric', [0 1]
    };

for i = 1:size(par_def, 1)
    check_par(param, par_def{i,1}, par_def{i,2}, par_def{i,3});
end


function check_par(param, par_name, valid_type, valid_range)

  if ~isfield(param, par_name)
      error('parameter not specified: %s', par_name);
  end
  
  val = param.(par_name);
  if strcmp(valid_type, 'numeric')
      if ~isnumeric(val)
          error('%s parameter must be numeric.', par_name)
      end
      if ~isscalar(val)
          error('%s parameter must be a scalar.', par_name)
      end
      if ~isempty(valid_range)
          if ~(val >= valid_range(1) && val <= valid_range(2))
              error('%s parameter (%f) is outside of valid range [%f,%f].', ...
                    par_name, val, valid_range(1), valid_range(2));
          end
      end
  elseif strcmp(valid_type, 'char')
      if ~ischar(val)
          error('%s parameter must be a string.', par_name)
      end
      if ~isempty(valid_range)
          if ~ismember(val, valid_range)
              error('%s parameter (%s) value is invalid.', ...
                    par_name, val);
          end
      end
  elseif strcmp(valid_type, 'logical')
      if ~(isnumeric(val) || islogical(val))
          error('%s parameter must be logical or numeric.', par_name)
      end
      if ~(val==0 || val==1)
          error('%s parameter must be 1 or 0.', par_name)
      end
  else
      error('Unknown parameter type: %s', valid_type)
  end
  