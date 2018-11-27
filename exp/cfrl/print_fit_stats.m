function print_fit_stats(mat, fit_names, fig_file)
%PRINT_FIT_STATS   Make a bar plot of fit statistics by model.
%
%  print_fit_clust(mat, fit_names, fig_file)

clf
m = mean(mat);
[l, u] = bootstrap_ci(mat, 1, 5000, 0.05);
%x = [1 3:9];
x = 1:length(fit_names);
isdata = strcmp(fit_names, 'data');

[hbar, herr] = ebar(x, m, l, u);
hbar.FaceColor = [.8 .8 .8];
hbar.LineStyle = 'none';
hbar.BarWidth = .8;
herr.CapSize = 15;

set(gca, 'XTick', x, 'XTickLabel', fit_names);
ylabel('AIC weight')
set(gca, 'YLim', [0 1], 'YTick', 0:.2:1)
set(gca, 'FontSize', 16, 'LineWidth', 1)
box off

if ~isempty(fig_file)
    set(gcf, 'PaperPosition', [0 0 4.5 4])
    print(gcf, '-depsc', fig_file);
end
