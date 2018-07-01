
%% load basic data

files = get_exp_info_cfrl('cfr');
real = load(files.data);
sem = load(files.wikiw2v.raw);

%% testing out logl model fits

% based on search with 10 replications, relatively lax finish
% criterion (0.01 threshold, 100 generations stall)

% prepare semantic CRP analysis (only have to run once)
create_sem_crp_bins(real.data, sem.sem_mat, files.wikiw2v.bin);

% make standard plots, get some stats
fig_dir = '~/work/cfr/figs';
fits = {'data' 'base' 'wikiw2v_context' 'wikiw2v_item' 'wikiw2v_context_item'};
lbc_scores = NaN(29, length(fits));
cat_types = {'within' 'from' 'to'};
[~, ind] = unique(real.data.pres_itemnos);
category = real.data.pres.category(ind);
for i = 1:length(fits)
    disp(fits{i})
    info = get_fit_info_cfrl(fits{i}, 'cfr');
    load(info.stat_file);
    res_dir = fullfile(fig_dir, fits{i});
    if ~exist(res_dir, 'dir')
        mkdir(res_dir)
    end
    
    % standard catfr analyses
    print_spc_cat(data, fullfile(res_dir, 'spc_cat.eps'), 'spc');
    print_spc_cat(data, fullfile(res_dir, 'pfr_cat.eps'), 'pfr');
    print_crp_cat(data, 1, 'cat', fullfile(res_dir, 'crp_within_cat.eps'));
    print_crp_cat(data, 2, 'cat', fullfile(res_dir, 'crp_from_cat.eps'));
    print_crp_cat(data, 3, 'cat', fullfile(res_dir, 'crp_to_cat.eps'));
    s_lbc = lbc(data.pres.category, data.rec.category, data.subject, ...
                'recall_mask', make_clean_recalls_mask2d(data.recalls));
    lbc_scores(:,i) = s_lbc;
    
    % semantic crp
    bin = load(files.wikiw2v.bin);
    [act, poss] = item_crp(data.recalls, ...
                           data.pres_itemnos, ...
                           data.subject, ...
                           length(sem.sem_mat));
    print_sem_crp(act, poss, sem.sem_mat, bin.edges, bin.centers, ...
                  fullfile(res_dir, 'sem_crp.eps'));
    print_sem_crp(act, poss, sem.sem_mat, bin.edges, bin.centers, ...
                  fullfile(res_dir, 'sem_crp_within.eps'), ...
                  'mask', category == category');
    print_sem_crp(act, poss, sem.sem_mat, bin.edges, bin.centers, ...
                  fullfile(res_dir, 'sem_crp_between.eps'), ...
                  'mask', category ~= category');
end
