function print_sem_crp(act, poss, sem_mat, edges, centers, fig_file, ...
                       varargin)
%PRINT_SEM_CRP   Plot semantic CRP curve.
%
%  print_sem_crp(act, poss, sem_mat, edges, centers, fig_file, ...)
%
%  OPTIONS:
%  mask - [items x items] logical array - true(size(sem_mat))
%      Item pairs to include in analysis.

def.mask = true(size(sem_mat));
opt = propval(varargin, def);

bin_crp = dist_item_crp(act, poss, sem_mat, 'edges', edges, ...
                        'mask', opt.mask);

mat = bin_crp(:,1:end-1);
n = sum(~isnan(mat), 1);
mat(:,n < 10) = NaN;
x = centers;
y = nanmean(mat);
[l, u] = bootstrap_ci(mat, 1, 5000, .05);

clf
h = mseb(x, y, cat(3, u-y, y-l));
a = gca;
set(a, 'XLim', [.5 1], 'XTick', .5:.1:1, ...
       'YLim', [0 .2], 'YTick', 0:.05:.2)
xlabel('semantic similarity')
ylabel('conditional response probability')
box off
font_prop = {'FontSize' 28 'FontWeight' 'normal' ...
             'FontName' 'Helvetica'};
set(a, 'LineWidth', 1, font_prop{:})
set(get(a, 'XLabel'), font_prop{:})
set(get(a, 'YLabel'), font_prop{:})

print(gcf, '-depsc', fig_file);
