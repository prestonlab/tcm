function [logl, logl_all, param, seq] = run_logl_fit(data)
%RUN_LOGL_FIT   Fit a standard model to some data.
%
%  This function implements a basic search of parameters to fit a
%  (relatively) simple version of TCM to some free recall data. If no
%  data are specified, will use sample benchmark data from one subject
%  from the scalp EEG study reported in Morton et al. 2013.
%
%  This code can be used as an example for fitting data, to be
%  customized as needed for a given project. Some features, like
%  semantic cuing, are not supported. See indiv_search_cfrl for a
%  more complete example of model fitting.
%
%  [logl, logl_all, param, seq] = run_logl_fit(data)
%
%  INPUTS
%  data - frdata struct
%      Struct with data from a free recall study in standard
%      format. See logl_tcm for details. If not specified, sample
%      data from one subject in the Morton et al. (2013) study will
%      be used.
%
%  OUTPUTS
%  logl - [lists x recall events] numeric array
%      Log likelihood for all recall events in data.recalls, plus
%      stopping events.
%
%  logl_all - [lists x recall events x possible events] numeric array
%      Likelihood for all possible events, after each recall event
%      in data.recalls.
%
%  param - struct
%      Best-fitting parameters.
%
%  seq - [list x recalls] numeric array
%      Simulated data from the model, using the best-fitting
%      parameters. Runs the simulated study once. In practice, you
%      may want to call gen_tcm to generate data for many
%      replications of the study, to obtain a stable estimate of
%      behavior like the serial position curve.

if nargin < 1
    data = getfield(load('cfr_benchmark_data.mat', 'data'), 'data');
end

%% search parameters

% allowed range for free parameters
par = struct;
par.B_enc = [0 1];
par.B_rec = [0 1];
par.Dfc = [0 100];
par.Acf = [0 100];
par.Dcf = [0 100];
par.P1 = [0 100];
par.P2 = [0 100];
par.T = [0 100];
par.X1 = [0 1];
par.X2 = [0 1];
par.B_s = [0 1];

% set other required parameters that are fixed
fixed = struct;
fixed.B_ipi = 0;
fixed.B_ri = 0;
fixed.Afc = 0;
fixed.Sfc = 0;
fixed.Scf = 0;
fixed.Lfc = 1;
fixed.Lcf = 1;
fixed.stop_rule = 'op';
fixed.B_ipi = 0;
fixed.B_ri = 0;
fixed.I = 0;
fixed.init_item = false;

% initial ranges (for unbounded parameters)
init = par;
init.Dfc = [0 1];
init.Acf = [0 1];
init.Dcf = [0 1];
init.P1 = [0 10];
init.P2 = [0 10];
init.T = [0 1];

% make a standard param_info struct with search parameter information
names = fieldnames(par);
ranges = struct2cell(par);
init = struct2cell(init);
param_info = make_param_info(names, 'range', ranges, 'init', init);

%% data

% vectorized version of the recalls matrix (required for tcm_mex_logl)
data.recalls_vec = recalls_vec_tcm(data.recalls, data.listLength);

%% simulation settings

fstruct = fixed;
fstruct.data = data;
fstruct.param_info = param_info;

% this is the compiled version of the code to evaluate the likelihood
% of data given a set of parameters. If problems compiling
% logl_mex_tcm and getting it to work, can still use the matlab
% version, tcm_logl. That version is also useful for debugging
fstruct.f_logl = @logl_mex_tcm; 

% makes sure that all required parameter fields are defined
fstruct.f_check_param = @check_param_tcm;

% random number generator (seeded based on the current time, so
% each run of the search will be different)
rng('shuffle');

%% parameter search

% settings for differential evolution search
search_opt = struct;
search_opt.generations = 1000;
search_opt.tol = 0.01;
search_opt.popsize = 100;
search_opt.stall_gen_limit = 50;
search_opt.init_ranges = cat(1, param_info.init)';
ranges = cat(1, param_info.range)';

% function handle for evaluating a given set of parameters x
f = @(x) eval_param_tcm(x, fstruct);

% search to find the best-fitting parameters
[par, fval] = de_search(f, ranges, search_opt);

%% unpack results

% convert vector to structure with named fields, make sure it's valid
param = unpack_param(par, param_info, fixed);
check_param_tcm(param);

% evaluate the fitness of the parameters
[logl, logl_all] = logl_tcm(param, data);

% sanity check; should match the final best fitness from the search
assert(abs(nansum(logl(:)) - (-fval)) < .0001, ...
       'Final evaluation does not match search results')

%% generate some simulated data

seq = gen_tcm(param, data);
