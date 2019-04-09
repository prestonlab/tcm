function [evidence, fitted_perf, sigma] = decode_context_match(context, ...
                                                  category, target_perf, w)
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
%  target_perf - float
%      Target decoding performance to match.
%
%  w - [1 x 2] numeric array
%      Weight of effect of noise on item (w(1)) and context (w(2)). If
%      either weight is negative, that segment will be omitted.
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
[n_list, n_trial] = size(category);
list = repmat([1:n_list]', [1 n_trial])';
list = list(:);

c = context';
pattern = cat(2, c{:})';

% run cross-validation
opt = struct;
opt.f_train = @train_logreg;
opt.train_args = {struct('penalty', 10)};
opt.f_test = @test_logreg;
opt.verbose = false;
opt.runpar = true;

% set noise level
fprintf('Optimizing noise...\n')
n = 0:.01:.5; % 51 tests
n_rep_optim = 50;
[n_item, n_feat] = size(pattern);
pat_ind = {1:(n_feat/2) (n_feat/2+1):n_feat};
perf = NaN(length(n), n_rep_optim);
for i = 1:length(n)
    fprintf('.')
    for j = 1:n_rep_optim
        % add noise, with potentially different amounts added to
        % the item and context parts
        vec = add_noise(pattern, n(i), pat_ind, w);
        res = xval(vec, list, targets, opt);
        perf(i,j) = mean_evidence(res);
    end
end
fprintf('\n');

% results of noise fitting
optim_perf = mean(perf, 2);

% interpolate to estimate the best noise level
xx = linspace(n(1), n(end), 10000);
s = spline(n, optim_perf, xx);
[~, ind] = min(abs(s - target_perf));
sigma = xx(ind);
fprintf('Target: %.4f Actual: %.4f Sigma: %.4f\n', ...
        target_perf, s(ind), sigma);

% plot
% clf
% plot(xx, s, '-k');
% hold on
% plot(n, optim_perf, 'ro');
% drawnow

% get average evidence for each trial
fprintf('Running replications with fitted noise level...\n');
n_rep = 100;
evidence_all = cell(1, n_rep);
rep_perf = NaN(1, n_rep);
for i = 1:n_rep
    vec = add_noise(pattern, sigma, pat_ind, w);
    res = xval(vec, list, targets, opt);
    rep_perf(i) = mean_evidence(res);
    evidence_rep = NaN(size(targets, 1), size(targets, 2));
    for j = 1:length(res.iterations)
        test_ind = res.iterations(j).test_idx;
        evidence_rep(test_ind,:) = res.iterations(j).acts';
    end
    evidence_all{i} = evidence_rep;
end

evidence = cat(3, evidence_all{:});
fitted_perf = rep_perf;


function y = add_noise(x, sigma, ind, w)

    noise = randn(size(x)) * sigma;
    y = NaN(size(x));
    for i = 1:length(ind)
        y(:,ind{i}) = x(:,ind{i}) + noise(:,ind{i}) * w(i);
    end
    
    for i = 1:length(w)
        if w(i) < 0
            y(:,ind{i}) = [];
        end
    end