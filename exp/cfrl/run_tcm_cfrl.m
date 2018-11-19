
restoredefaultpath
cd ~/matlab/tcm
init_tcm
addpath ~/matlab/accre

%% fits using the MortPoly17 models

fits = {'base', 'wikiw2v_context' 'wikiw2v_item' 'wikiw2v_context_item'};

% test job
fits = {'base'};
experiments = {'cfr'};
flags = '-t 00:30:00 --mem=8gb --cpus-per-task=8 --partition=debug';
jobs = {};
for i = 1:2
    jobs{i} = submit_searches_cfrl(experiments, fits, flags, 'n_workers', 8);
end

% full search (based on JML paper search parameters)
fits = {'base' 'hybrid_' 'full_wikiw2v'};
flags = '-t 24:00:00 --mem=12gb --cpus-per-task=12';
n_rep = 15;
jobs = cell(1, n_rep);
for i = 1:n_rep
    jobs{i} = submit_searches_cfrl(experiments, fits, flags, 'n_workers', 12);
end

rep = load_rep_de_cfrl(jobs, true);
job = submit_indiv_best_params_cfrl(experiments, fits, '-t 04:00:00 --mem=4gb');

% new fits with the different choice rule, and testing more
% combinations of context subregions
% Job
fits = {'local' 'cat' 'wikiw2v' ...
        'local_cat' 'local_wikiw2v' 'cat_wikiw2v' ...
        'local_cat_wikiw2v'};
experiments = {'cfr'};
flags = '-t 24:00:00 --mem=12gb --cpus-per-task=12';
n_rep = 1;
jobs = cell(1, n_rep);
for i = 1:n_rep
    jobs{i} = submit_searches_cfrl(experiments, fits, flags, 'n_workers', 12);
end


%% cdcfr2 fits

experiments = {'cdcfr2'};
%fits = {'base' 'cat' 'full_wikiw2v'};
fits = {'full_wikiw2v'};
flags = '-t 24:00:00 --mem=12gb --cpus-per-task=12';
n_rep = 10;
jobs = {};
for i = 1:n_rep
    jobs{end+1} = submit_searches_cfrl(experiments, fits, flags, ...
                                       'n_workers', 10, ...
                                       'search_type', 'de');
end

% jobs [80:89 91:130]
% submit a job to load replications and save best parameters
load_job = submit_job(@load_rep_de_cfrl, 0, {jobs, true}, ...
                      '-t 00:30:00 --mem=12gb');

jobs = cluster.Jobs([80:89 91:130]);
rep = load_rep_de_cfrl(jobs, true);

sim_job = submit_indiv_best_params_cfrl(experiments, fits, '-t 01:00:00 --mem=4gb');
