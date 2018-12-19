function [evidence, fitted_perf, sigma] = decode_context_match(context, category, target_perf)
%DECODE_CONTEXT   Use pattern classification to decode stimulus category.
%
%  Use a ridge regression classifier to decode category from states
%  of context, using cross-validation at the level of lists.
%
%  evidence = decode_context(context, category)
%
%  INPUTS
%  context - [lists x items] cell array
%      The state of context predicted to be active during each trial.
%
%  category - [lists x items] numeric array
%      The category code for each trial.
%
%  OUTPUTS
%  evidence - [trials x categories] numeric array
%      Classifier evidence for each category. Categories are in the
%      sorting order of the category codes.

% set up decoding
ucat = unique(category);
labels = category';
labels = labels(:);
targets = zeros(length(labels), 3);
for i = 1:length(ucat)
    targets(labels==ucat(i),i) = 1;
end
list = repmat([1:30]', [1 24])';
list = list(:);

c = context';
pattern = cat(2, c{:})';

% run cross-validation
opt = struct;
opt.f_train = @train_logreg;
opt.train_args = {struct('penalty', 10)};
opt.f_test = @test_logreg;
opt.verbose = false;

% set noise level
fprintf('Optimizing noise...\n')
n = 0:.01:.15;
n_rep_optim = 20;
perf = NaN(length(n), n_rep_optim);
for i = 1:length(n)
    fprintf('.')
    parfor j = 1:n_rep_optim
        noise = randn(size(pattern)) * n(i);
        res = xval(pattern+noise, list, targets, opt);
        perf(i,j) = mean([res.iterations.perf]);
    end
end
fprintf('\n');

% results of noise fitting
optim_perf = mean(perf, 2);

% interpolate to estimate the best noise level
xx = linspace(n(1), n(end), 1000);
s = spline(n, optim_perf, xx);
[~, ind] = min(abs(s - target_perf));
sigma = xx(ind);
fprintf('Target: %.4f Actual: %.4f Sigma: %.4f\n', ...
        target_perf, s(ind), sigma);

% plot
clf
plot(xx, s, '-k');
hold on
plot(n, optim_perf, 'ro');
drawnow

% get average evidence for each trial
fprintf('Running replications with fitted noise level...\n');
n_rep = 100;
evidence_all = cell(1, n_rep);
rep_perf = NaN(1, n_rep);
parfor i = 1:n_rep
    noise = randn(size(pattern)) * sigma;
    res = xval(pattern+noise, list, targets, opt);
    rep_perf(i) = mean([res.iterations.perf]);
    evidence_rep = NaN(size(targets, 1), size(targets, 2));
    for j = 1:length(res.iterations)
        test_ind = res.iterations(j).test_idx;
        evidence_rep(test_ind,:) = res.iterations(j).acts';
    end
    evidence_all{i} = evidence_rep;
end

evidence_mat = cat(3, evidence_all{:});
evidence = mean(evidence_mat, 3);
fitted_perf = mean(rep_perf);
