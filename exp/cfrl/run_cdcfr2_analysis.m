
%% load basic data

files = get_exp_info_cfrl('cdcfr2');
real = load(files.data);
sem = load(files.wikiw2v.raw);

create_sem_crp_bins(real.data, sem.sem_mat, files.wikiw2v.bin);

%% plot SPC for all subjects

usubj = unique(real.data.subject);
udistract = unique(real.data.pres.distractor);
for i = 1:length(usubj)
    s_data = trial_subset(real.data.subject == usubj(i), real.data);
    p_recall = [];
    for j = 1:length(udistract)
        d_data = trial_subset(s_data.pres.distractor(:,1) == udistract(j), ...
                              s_data);
        p_recall = [p_recall; spc(d_data.recalls, d_data.subject, ...
                                  d_data.listLength)];
    end
    subplot(3,4,i)
    h = plot(p_recall');
    set(gca, 'YLim', [0 1]);
    if i == 1
        l = legend(h, {'IFR' 'CDS' 'CDL'});
        l.Location = 'NorthWest';
    end
end

%% sample simulation to test out distraction code

% fit of one subject
files = get_exp_info_cfrl('cdcfr2-2');
real = load(files.data);
res = indiv_search_cfrl('cdcfr2-2', 'base', 'search_type', 'de');
[res_file, stats] = save_search_cfrl(res, 'cdcfr2-2', 'base');
data = run_indiv_best_params_cfrl('cdcfr2-2', 'base', 'n_rep', 100);

split_net = split_distract_cfrl(data);
split_real = split_distract_cfrl(real.data);
p_recall_net = NaN(length(split), 24);
p_recall_real = NaN(length(split), 24);
for i = 1:length(split)
    rec = spc(split_net{i}.recalls, split_net{i}.subject, ...
              split_net{i}.listLength);
    p_recall_net(i,:) = rec;
    
    rec = spc(split_real{i}.recalls, split_real{i}.subject, ...
              split_real{i}.listLength);
    p_recall_real(i,:) = rec;
end

subplot(2,1,1)
plot(p_recall_real');
set(gca, 'YLim', [0 1]);
subplot(2,1,2)
plot(p_recall_net');
set(gca, 'YLim', [0 1]);

%% test out effects of distraction

strength = [1 2 4 8 16];
strength = strength ./ sum(strength);
fp1 = @(s, T) (s.^T) ./ sum(s.^T);
fp2 = @(s, T) exp((2*s)/T) / (sum(exp(2*s)./T));
f = {fp1 fp2};
t = linspace(0.01, 1, 5);
for i = 1:length(f)
    subplot(1,2,i);
    hold on
    for j = 1:length(t)
        plot(f{i}(strength, t(j)));
    end
    set(gca, 'YLim', [0 1])
end

% does exponential scaling lead to sensitivity to distraction?
strength = [1 2 4 8 16];
strength = strength ./ sum(strength);
scale = linspace(0.01, 1, 5);
fp1 = @(s, T) (s.^T) ./ sum(s.^T);
fp2 = @(s, T) exp((2*s)/T) / (sum(exp(2*s)./T));
f = {fp1 fp2};
T = .5;
for i = 1:length(f)
    subplot(1,2,i);
    hold on
    for j = 1:length(scale)
        plot(f{i}(strength * scale(j), T));
    end
    set(gca, 'YLim', [0 1])
end
