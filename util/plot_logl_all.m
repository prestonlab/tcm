function plot_logl_all(logl_all, recalls, grid, mrange)
%PLOT_LOGL_ALL   Visualize recall probabilities generated by a model.
%
%  All probabilities are plotted as a colormap. Each row
%  corresponds to one recall attempt. The first (list length)
%  columns correspond to items on the list. The last column
%  indicates the probability of stopping. Actual recall events are
%  indicated by red dots. The size of the dots is scaled to be
%  larger for relatively low-probability events, according to the
%  model. This can help spot recall events that are not
%  well-captured by the model.
%
%  plot_logl_all(logl_all, recalls, grid)
%
%  INPUTS
%  logl_all - [lists x output positions x recall events] numeric array
%      Predicted (log) probability of each possible recall event,
%      according to some model like TCM.
%
%  recalls - [lists x output positions] numeric array
%      Serial position of each actual recall in the experiment.
%
%  grid - [1 x 2] numeric array
%      Size of grid of subplots to make to display all lists. Set
%      to [1 1] to just plot one list.
%
%  mrange - [1 x 2] numeric array
%      Range of sizes to use when plotting actual recall events.

logl_actual = NaN(size(recalls, 1), size(recalls, 2) + 1);
recall_events = cell(1, size(recalls, 1));
for i = 1:size(recalls, 1)
    rec = [nonzeros(recalls(i,:))' size(logl_all, 3)];
    for j = 1:length(rec)
        logl_actual(i,j) = -logl_all(i,j,rec(j));
    end
    recall_events{i} = rec;
end

l_min = min(logl_actual(:));
l_range = range(logl_actual(:));

for i = 1:size(logl_all, 1);
    subplot(grid(1), grid(2), i);
    imagesc(squeeze(logl_all(i,:,:)));
    hold on
    rec = [nonzeros(recalls(i,:))' size(logl_all, 3)];
    rec = recall_events{i};
    s = (logl_actual(i,:) - l_min) / l_range;
    s2 = mrange(1) + range(mrange) * s(1:length(rec));
    scatter(rec, 1:length(rec), s2, '.r');
    axis tight
    set(gca, 'XTick', [], 'YTick', [])
end
