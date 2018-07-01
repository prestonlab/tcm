function file = get_search_file_cfrl(res_dir, model_type)
%GET_SEARCH_FILE_CFRL   Get file with search results.
%
%  file = get_search_file_cfrl(res_dir, model_type)

search_dir = fullfile(res_dir, model_type);

% get all mat-files
files = dir(fullfile(search_dir, '*.mat'));

if isempty(files)
    file = '';
    return
end

% find mat files with a date at the end
pattern = [model_type '_\d{4}-\d{2}-\d{2}\.mat'];
f = @(x) ~isempty(regexp(x, pattern));
match = cellfun(f, {files.name}) & ~[files.isdir];

% extract the date strings
search_files = {files(match).name};
f2 = @(x) x(end-13:end-4);
search_dates = cellfun(f2, search_files, 'UniformOutput', false);
%fprintf('Found %d search files.\n', length(search_files));

% convert to date number and sort
datenums = datenum(search_dates, 'yyyy-mm-dd');
[~, ind] = sort(datenums);
file = fullfile(search_dir, search_files{ind(end)});
%fprintf('Returning latest file: %s.\n', file);
