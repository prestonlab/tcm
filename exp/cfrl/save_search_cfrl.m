function [res_file, stats] = save_search_cfrl(res, experiment, fit)
%SAVE_SEARCH_CFRL   Save individual search results to disk.
%
%  [res_file, stats] = save_search_cfrl(res, experiment, fit)

% get search output file
model_type = res(1).model_type;
timestamp = datestr(now, 29);
filename = sprintf('%s_%s.mat', model_type, timestamp);
res_file = get_next_file(fullfile(info.res_dir, filename));

% unpack search results into full format
stats = unpack_search_cfrl(res, experiment, fit);
save(res_file, 'stats');
