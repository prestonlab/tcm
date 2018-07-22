
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

%% test out context recording

% run a quick fit to get some parameters
data = getfield(load('cfr_benchmark_data.mat', 'data'), 'data');
[logl, logl_all, param, seq] = run_logl_fit(data);

% run an actual fit of one subject, with relatively lax optimization
res = indiv_search_cfrl('cfr', 'full_wikiw2v', 'n_workers', 1, ...
                        'search_type', 'de_fast', 'subject', 1);

stats = plot_subj_sim_results(res);

% set up decoding
labels = data.pres.category';
labels = labels(:);
targets = zeros(length(labels), 3);
for i = 1:3
    targets(labels==i,i) = 1;
end
list = repmat([1:30]', [1 24])';
list = list(:);
c = stats.net.pres.c';
pattern = cat(2, c{:})';

% run decoding
opt = struct;
opt.f_train = @train_logreg;
opt.train_args = {struct('penalty', 10)};
opt.f_test = @test_logreg;

% target is 58.9%
target_perf = .589;
n = linspace(.05, .25, 11);
n_rep = 10;
perf = NaN(length(n), n_rep);
for i = 1:length(n)
    for j = 1:n_rep
        noise = randn(size(pattern)) * n(i);
        res = xval(pattern+noise, list, targets, opt);
        perf(i,j) = mean([res.iterations.perf]);
    end
end
[~, ind] = min(abs(mean(perf, 2) - target_perf));
n_target = n(ind);

% calculate average evidence over many replications, for the
% best-matching noise level
n_rep = 100;
evidence_all = NaN(size(targets, 1), size(targets, 2), n_rep);
perf = NaN(1, n_rep);
for i = 1:n_rep
    noise = randn(size(pattern)) * n_target;
    res = xval(pattern+noise, list, targets, opt);
    perf(i) = mean([res.iterations.perf]);
    for k = 1:length(res.iterations)
        test_ind = res.iterations(k).test_idx;
        evidence_all(test_ind,:,i) = res.iterations(k).acts';
    end
end

% unpack evidence for each category on each trial
evidence = mean(evidence_all, 3);

% plot individual lists
colors = get(groot, 'defaultAxesColorOrder');
for i = 1:30
    clf
    hold on
    ind = list == i;
    for j = 1:3
        plot(evidence(ind,j), '-', 'Color', colors(j,:));
        plot(targets(ind,j), 'o', 'Color', colors(j,:));
    end
    pause
end

% sort by curr, prev, base
mat = struct;
[mat.curr, mat.prev, mat.base, mat.trainpos] = ...
    train_category(data.pres.category);

subject = repmat(data.subject, [1 24]);
v_subject = subject';
v_subject = v_subject(:);
usubject = unique(data.subject);

vec = struct;
f = fieldnames(mat);
for i = 1:length(f)
    m = mat.(f{i})';
    vec.(f{i}) = m(:);
end

n_subj = length(unique(data.subject));
x = NaN(n_subj, 3, 6, 3);
ttype = {'curr' 'prev' 'base'};
for i = 1:n_subj
    for j = 1:length(ttype)
        tvec = vec.(ttype{j});
        for k = 1:6
            for l = 1:3
                ind = v_subject == usubject(i) & ...
                      vec.trainpos == k & ...
                      tvec == l;
                x(i,j,k,l) = nanmean(evidence(ind,l));
            end
        end
    end
end

clf
y = squeeze(mean(x, 4));
plot(y');
l = legend(ttype);
ylabel('classifier evidence');
xlabel('train position');
