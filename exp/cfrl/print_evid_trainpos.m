function print_evid_trainpos(evid, fig_file)
%PRINT_EVID_TRAINPOS   Print a plot of evidence by train position.
%
%  print_evid_trainpos(evid, fig_file)

x = 1:size(evid, 1);
y = NaN(3, size(evid, 1));
l = NaN(3, size(evid, 1));
u = NaN(3, size(evid, 1));
for i = 1:size(evid, 2)
    mat = permute(evid(:,i,:), [3 1 2]);
    n = sum(~isnan(mat), 1);
    y(i,:) = nanmean(mat);
    [l(i,:), u(i,:)] = bootstrap_ci(mat, 1, 5000, .05);
end

clf
h = mseb(x, y, cat(3, u-y, y-l));
a = gca;
%set(a, 'XLim', [.5 1], 'XTick', .5:.1:1, ...
%       'YLim', [0 .2], 'YTick', 0:.05:.2)
xlabel('train position')
ylabel('classifier evidence')
box off
font_prop = {'FontSize' 28 'FontWeight' 'normal' ...
             'FontName' 'Helvetica'};
set(a, 'LineWidth', 1, font_prop{:})
set(get(a, 'XLabel'), font_prop{:})
set(get(a, 'YLabel'), font_prop{:})
%l = legend([h.mainLine], {'celebrity' 'location' 'object'});
%set(l, 'Location', 'NorthWest', font_prop{:}, 'Box', 'off')

if ~isempty(fig_file)
    print(gcf, '-depsc', fig_file);
end
