function [err, logl, logl_all] = eval_param_tcm(param, varargin)
%EVAL_PARAM_TCM   Calculate likelihood for TCM with a given set of parameters.
%
%  Used to evaluate parameters within a search algorithm like
%  de_search. Takes a vector of free parameters, unpacks them and
%  combines them with fixed parameters, and evaluates the log
%  likelihood of the data. 
%
%  Negative log likelihood is returned; this is convenient for search
%  algorithms, as they are generally designed to minimize error. In
%  this case, they will minimize negative log likelihood, resulting in
%  parameters under which the data have a high likelihood.
%
%  [err, logl, logl_all] = eval_param_tcm(param, fstruct)
%
%  INPUTS
%  param - struct
%      Parameter structure, or numeric vector of parameter values (if
%      numeric, must also pass param_info; see below).
%
%  fstruct - struct
%      Structure with settings for evaluating the parameters. Fields
%      may include:
%      data - frdata struct - required
%          Standard free recall data structure. See logl_tcm for details.
%      param_info - [1 x parameters] struct
%          Information about free parameters. See unpack_param for
%          details.
%      f_logl - function_handle - @logl_tcm
%          Handle to a function of the form:
%              logl = f_logl(param, data)
%                  or
%              [logl, logl_all] = f_logl(param, data)
%          that calculates log likelihood.
%      f_check_param - function_handle - @check_param_tcm
%          Handle to a function of the form:
%              param = f_check_param(param)
%          Used to run sanity checks on parameters and/or set
%          parameters that are derived from the free parameters.
%      verbose - bool - isstruct(param)
%          If true, more information is printed.
%      May also pass additional parameter fields for f_logl.
%
%  OUTPUTS
%  err - double
%      Negative total log likelihood of the data.
%
%  logl - [lists x recall events] numeric array
%      Log likelihood for all recall events in data.recalls, plus
%      stopping events.
%
%  logl_all - [lists x recall events x possible events] numeric array
%      Likelihood for all possible events, after each recall event
%      in data.recalls.

% param evaluation configuration
def.data = '';
def.param_info = [];
def.f_logl = @logl_tcm;
def.f_check_param = @check_param_tcm;
def.verbose = isstruct(param);
[opt, custom_param] = propval_lite(varargin, def);

if ~isstruct(param)
    % convert to struct format
    if isempty(opt.param_info)
        error('Cannot interpret parameter vector without param_info')
    end
    param = unpack_param(param, opt.param_info);
end

% merge in additional parameters set
if ~isempty(custom_param)
    param = propval_lite(custom_param, param);
end

% sanity checks, set default parameters, etc.
param = opt.f_check_param(param);

if opt.verbose
    disp(param)
end

% calculate log likelihood
if nargout(opt.f_logl) == 2
    [logl, logl_all] = opt.f_logl(param, opt.data);
else
    logl = opt.f_logl(param, opt.data);
    logl_all = [];
end
err = -nansum(logl(:));

if err == 0
    err = Inf;
end

if opt.verbose
    fprintf('Log likelihood: %.4f\n', -err)
end
