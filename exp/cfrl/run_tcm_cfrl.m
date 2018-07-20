
%% fits using the MortPoly17 models

fits = {'base', 'wikiw2v_context' 'wikiw2v_item' 'wikiw2v_context_item'};

fits = {'dc_wikiw2v' 'dc_ncf_wikiw2v'};
experiments = {'cfr'};

flags = '-t 04:00:00 --mem=8gb --cpus-per-task=12';
n_rep = 10;
jobs = cell(1, n_rep);
for i = 1:n_rep
    jobs{i} = submit_searches_cfrl(experiments, fits, flags, 'n_workers', 12);
end

rep = load_rep_de_cfrl(jobs, true);
job = submit_indiv_best_params_cfrl(experiments, fits, '-t 02:00:00 --mem=4gb');
