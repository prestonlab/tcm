
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
% Job43, Job53-Job61, Job63-72
fits = {'local' 'cat' 'wikiw2v' ...
        'local_cat' 'local_wikiw2v' 'cat_wikiw2v' ...
        'local_cat_wikiw2v'};
experiments = {'cfr'};
flags = '-t 06:00:00 --mem=12gb --cpus-per-task=12';
jobs = {};
n_rep = 10;
for i = 1:n_rep
    jobs{end+1} = submit_searches_cfrl(experiments, fits, flags, 'n_workers', 12);
end

% run classification and noise-level estimation for context
flags = '-t 06:00:00 --mem=24gb --cpus-per-task=16';
job = submit_decode_cfrl('cfr', 'local_cat_wikiw2v', ...
                         'decode_ic_evid_30', [.3 1], 16, true, ...
                         [2 3 4 5 6 7 8 9 10 11 12 13], flags);

%% cdcfr2 fits

% starting at Job37; should have 20 jobs before this with the same settings,
% which can all be merged together, excluding Job36 (an aborted stats job)
experiments = {'cdcfr2'};
%fits = {'base' 'cat' 'full_wikiw2v'};
fits = {'local_cat_wikiw2v' 'local_cat_wikiw2v_dsl' ...
        'local_cat_wikiw2v_dsc' 'local_cat_wikiw2v_dsd'};
flags = '-t 10:00:00 --mem=12gb --cpus-per-task=12';
n_rep = 30;
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

clust = getCluster();
jobs = num2cell(clust.Jobs([16:35 37:66]));
jobs = cluster.Jobs([80:89 91:130]);
rep = load_rep_de_cfrl(jobs, true);

sim_job = submit_indiv_best_params_cfrl(experiments, fits, '-t 01:00:00 --mem=4gb');

% new fits of each distraction condition separately
experiments = {'cdcfr2_d0' 'cdcfr2_d1' 'cdcfr2_d2'};
fits = {'local_cat_wikiw2v'};
flags = '-t 10:00:00 --mem=12gb --cpus-per-task=12';
n_rep = 9;
%jobs = {};
for i = 1:n_rep
    jobs{end+1} = submit_searches_cfrl(experiments, fits, flags, ...
                                       'n_workers', 10, ...
                                       'search_type', 'de');
end

% load distraction condition parameters and fitness
f = struct;
p = cell(1, length(experiments));
for i = 1:length(experiments)
    c = regexp(experiments{i}, '_', 'split');
    field = c{2};
    info = get_fit_info_cfrl(fits{1}, experiments{i});
    s = load(info.res_file);
    f.(field) = cat(1, s.stats.fitness);
    p{i} = cat(1, s.stats.parameters);
end
param_names = s.stats(1).names;

ftab = struct2table(f);

% parameter contrasts
cont = [1 2; 2 3; 1 3];
ptab = cell(1, length(experiments));
ctab = cell(1, size(cont, 1));
for i = 1:size(cont, 1)
    ptab{i} = array2table(p{i}, 'VariableNames', param_names);
    
    p_cont = p{cont(i,1)} - p{cont(i,2)};
    ctab{i} = array2table(p_cont, 'VariableNames', param_names);
end

sim_experiment = {'cdcfr2_d0' 'cdcfr2_d1' 'cdcfr2_d2'};
decode_cfrl('cdcfr2', 'local_cat_wikiw2v', 'decode_ic', [.3 1], ...
            'sim_experiment', sim_experiment, ...
            'subj_ind', 1, 'overwrite', true);

flags = '-t 12:00:00 --mem=24gb --cpus-per-task=16';
job = submit_decode_cfrl('cdcfr2', 'local_cat_wikiw2v', ...
                         'decode_ic_evid_30', [.3 1], 16, true, ...
                         1:10, flags);

flags = '-t 12:00:00 --mem=24gb --cpus-per-task=16';
job = {};
%wi = .1:.1:1;
wi = [.1 .3 .5];
for i = 1:length(wi)
    res_name = sprintf('decode_ic_evid_test_%.0f', wi(i)*100);
    job{i} = submit_decode_cfrl('cdcfr2', 'local_cat_wikiw2v', ...
                                res_name, [wi(i) 1], 16, true, ...
                                1:10, flags);
end
