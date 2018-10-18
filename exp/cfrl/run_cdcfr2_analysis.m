
%% load basic data

files = get_exp_info_cfrl('cdcfr2');
real = load(files.data);
sem = load(files.wikiw2v.raw);

create_sem_crp_bins(real.data, sem.sem_mat, files.wikiw2v.bin);

