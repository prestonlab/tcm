
%% load basic data

files = get_exp_info_cfrl('cdcfr2');
real = load(files.data);
sem = load(files.wikiw2v.raw);

create_sem_crp_bins(real.data, sem.sem_mat, files.wikiw2v.bin);

%% sample simulation to test out distraction code

% fit of one subject
files = get_exp_info_cfrl('cdcfr2-1');
real = load(files.data);
res = indiv_search_cfrl('cdcfr2-1', 'base', 'search_type', 'de');
[res_file, stats] = save_search_cfrl(res, 'cdcfr2-1', 'base');
data = run_indiv_best_params_cfrl('cdcfr2-1', 'base', 'n_rep', 1);

split = split_distract_cfrl(data);
p_recall = NaN(length(split), 24);
for i = 1:length(split)
    rec = spc(split{i}.recalls, split{i}.subject, split{i}.listLength);
    p_recall(i,:) = rec;
end
