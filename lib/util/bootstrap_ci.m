function [l, u] = bootstrap_ci(x, dim, n_perm, alpha)
%BOOTSTRAP_CI   Calculate a confidence interval based on bootstrapping.
%
%  [l, u] = bootstrap_ci(x, dim, n_perm, alpha)

if nargin < 4
  alpha = .05;
end

n_dims = ndims(x);
s = size(x);
sb = s;
sb(dim) = n_perm;
m = NaN(sb);
all = repmat({':'}, 1, n_dims);
for i = 1:n_perm
  ind = randsample(size(x, dim), size(x, dim), true);
  full_ind = all;
  full_ind{dim} = ind;
  perm_ind = all;
  perm_ind{dim} = i;
  m(perm_ind{:}) = nanmean(x(full_ind{:}), dim);
end

l = prctile(m, (alpha / 2) * 100, dim);
u = prctile(m, (1 - (alpha / 2)) * 100, dim);
