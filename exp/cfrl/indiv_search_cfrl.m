function res = indiv_search_cfrl(experiment, fit, varargin)
%INDIV_SEARCH_CFRL   Run searches for individual subjects.
%
%  res = indiv_search_cfrl(experiment, fit, ...)
%
%  INPUTS:
%  experiment - char
%      Names of the experiment to run.
%
%  fits - char
%      Names of the model fit to run.
%
%  OUTPUTS:
%  res - struct
%      Results of the parameter search.
%
%  OPTIONS:
%  f_logl - function_handle - @tcm_general_mex
%      Handle to function to evaluate likelihood, of the form:
%          logl = f_logl(param, data)
%
%  f_check_param - function_handle - @check_param_cfrl
%      Handle to function that completes a parameter struct by
%      setting defaults, etc., of the form:
%          param_out = f_check_param(param_in)
%
%  n_search - int - 1
%      Number of times to replicate each search, with different
%      random starting points.
%
%  n_workers - int - 1
%      Number of parallel workers to use when optimizing parameters
%      for diferrent subjects.

def.f_logl = @logl_tcm;
def.f_check_param = @check_param_cfrl;
def.n_search = 1;
def.n_workers = 1;
def.search_type = 'de';
run_opt = propval(varargin, def);

if run_opt.n_workers > 1 && isempty(gcp('nocreate'))
    [pool, cluster] = job_parpool(run_opt.n_workers);
end

% get parameters of the model and data to fit
simdef = sim_def_cfrl(experiment, fit);

% search settings
init = cat(1, simdef.param_info.init)';
search_opt = search_opt_cfrl(run_opt.search_type, 'init_ranges', init);
fprintf('Search settings:\n');
disp(search_opt)

% options for evaluating the model
fstruct = simdef.fixed;
fstruct.data = getfield(load(simdef.data_file), 'data');
fstruct.load_data = false;
fstruct.param_info = simdef.param_info;
% semantic cuing
if simdef.opt.qsem
    fstruct.sem_mat = getfield(load(simdef.sem_mat_file, ...
                                    'sem_mat'), 'sem_mat');
else
    fstruct.sem_mat = [];
end
% semantic context
if simdef.opt.dc
    fstruct.sem_vec = getfield(load(simdef.sem_mat_file, ...
                                    'vectors'), 'vectors')';
else
    fstruct.sem_vec = [];
end
fstruct.f_logl = run_opt.f_logl;
fstruct.f_check_param = run_opt.f_check_param;

% initialize the random number generator, so that replications of
% the search will be independent
subject = unique(fstruct.data.subject);
n_subj = length(subject);
if exist('pool', 'var')
    % we have a parpool open, so must use a different random stream for
    % each individual subject
    job_id = getenv('SLURM_JOB_ID');
    if ~isempty(job_id)
        seed = str2num(job_id);
    else
        seed = 'shuffle';
    end
    rstream = cell(1, n_subj);
    [rstream{:}] = RandStream.create('mrg32k3a', 'NumStreams', n_subj, ...
                                     'Seed', seed);
    run_opt.mult_rstreams = true;
    run_opt.rstream = rstream;
else
    % if not using a parpool, we only need one random stream
    rng('shuffle');
    run_opt.mult_rstreams = false;
end

% run all subject searches
res_cell = cell(1, n_subj);
if run_opt.mult_rstreams
    parfor i = 1:n_subj
        res_cell{i} = run_search(fstruct, i, subject, search_opt, run_opt);
    end
else
    for i = 1:n_subj
        res_cell{i} = run_search(fstruct, i, subject, search_opt, run_opt);
    end
end

% concatenate subject results
all_res = [];
for i = 1:n_subj
    all_res = cat_structs(all_res, res_cell{i});
end
res = all_res;

if exist('pool', 'var')
    try
        local_dir = cluster.JobStorageLocation;
        delete(pool);
        metadata_file = fullfile(local_dir, 'matlab_metadata.mat');
        delete(metadata_file);
        rmdir(local_dir);
    catch
        warning('Problem deleting parallel pool.');
    end
end


function res = run_search(fstruct, ind, subject, search_opt, run_opt)

    if run_opt.mult_rstreams
        RandStream.setGlobalStream(run_opt.rstream{ind});
    end
    rseed = rng;

    % prepare the data for the subject
    subj_data = trial_subset(fstruct.data.subject == subject(ind), ...
                             rmfieldifexist(fstruct.data, 'recalls_vec'));
    subj_data.recalls_vec = recalls_vec_tcm(subj_data.recalls, ...
                                            fstruct.data.listLength);
    subj_data_orig = subj_data;

    % trim the semantic matrix to just hold the relevant items;
    % change item number accordingly. This speeds up execution
    if ~isempty(fstruct.sem_mat) || ~isempty(fstruct.sem_vec)
        [subj_data.pres_itemnos, fstruct.sem_mat, fstruct.sem_vec] = ...
            trim_sem_mat(subj_data.pres_itemnos, fstruct.sem_mat, ...
                         fstruct.sem_vec);
    end

    % prep the eval function
    fstruct.data = subj_data;
    f = @(x) eval_param_tcm(x, fstruct);
    ranges = cat(1, fstruct.param_info.range)';
    
    % run the search (multiple replications if desired, though the
    % latest postprocessing code may not expect this)
    parameters = [];
    fitness = [];
    for i = 1:run_opt.n_search
        switch run_opt.search_type
          case 'de'
            [par, fval] = de_search(f, ranges, search_opt);
          otherwise
            error('Unsupported search type: %s', run_opt.search_type)
        end
        parameters = [parameters; par];
        fitness = [fitness; fval];
    end
    
    % save out details about the search
    res = [];
    res.fstruct = rmfield(fstruct, 'sem_mat');
    res.fstruct.data = subj_data_orig;
    res.parameters = parameters;
    res.fitness = fitness;
    res.rseed = rseed;
    res.search_opt = search_opt;
    res.run_opt = run_opt;
