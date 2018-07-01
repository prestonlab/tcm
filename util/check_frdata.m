function check_frdata(data, wordpool)
%CHECK_FRDATA   Run sanity checks on a standard free recall data structure.
%
%  Checks standard fields on a free recall data structure:
%   'subject'      - numeric subject identifier
%   'session'      - numeric session identifier (may overlap between
%                    subjects)
%   'pres_items'   - [lists X items] cell array of strings
%                    representing presented items
%   'pres_itemnos' - [lists X items] numeric array, giving the index of
%                    each presented item in the word pool
%   'rec_items'    - [lists X recalls] cell array of strings
%                    representing recalled items (may include
%                    intrusions of items not in the word pool)
%   'rec_itemnos'  - [lists X recalls] numeric array of item numbers.
%                    Items not in the word pool should be labeled
%                    with -1
%   'recalls'      - [lists X recalls] numeric array of serial positions
%                    of recalled items. Intrusions should be labeled
%                    with -1
%   'times'        - [lists X recalls] numeric array of times (in ms)
%                    that each item was recalled (relative to the start
%                    of the recall period)
%   'intrusions'   - [lists X recalls] numeric array of codes indicating
%                    different types of intrusions. Extra-list
%                    intrusions should be labeled -1. Prior-list
%                    intrusions should have a positive number indicating
%                    the most recent list that the item was presented.
%                    Correct recalls are marked as 0
%  The function will check whatever standard fields are present,
%  even if some of them are missing.
%
%  Arrays containing recall data need to be padded, since the number
%  of recalls varies by list. Numeric arrays may have padding of zeros
%  or NaNs; cell arrays of strings should have padding of '' or [].
%
%  USAGE:
%  check_frdata(frdata, wordpool)
%
%  INPUTS:
%    frdata:  standard free recall data structure. See above for
%             fields that will be checked.
%
%  wordpool:  if given, and if pres_items or rec_items fields exist,
%             item numbers will be checked for consistency with the
%             wordpool.
%
%  See also check_itemnos.

fprintf(['\nGeneral\n' ...
         '-------\n'])

% subject information
if ~isfield(data, 'subject')
    fprintf('Could not locate subject labels.\n')
else
    fprintf('Found %d subjects.\n', length(unique(data.subject)))
end

% session information
if ~isfield(data, 'session')
    fprintf('Could not locate session numbers.\n')
else
    if isfield(data, 'subject')
        [sess_index, labels] = make_index(data.subject, data.session);
        n_sess = collect([labels{:,1}], unique(data.subject));
        if length(unique(n_sess)) ~= 1
            fprintf('Found %d sessions (%d-%d per subject).\n', ...
                    sum(n_sess), min(n_sess), max(n_sess))
        else
            fprintf('Found %d sessions (%d per subject).\n', ...
                    sum(n_sess), n_sess(1))
        end
    end
end

fprintf(['\nStudy\n' ...
         '-----\n'])

% checks on item numbers and consistency with wordpool
if ~isfield(data, 'pres_itemnos')
    fprintf('Could not locate presented item numbers.\n')
    if isfield(data, 'listLength')
        list_length = data.listLength;
    elseif isfield(data, 'list_length')
        list_length = data.list_length;
    end
else
    list_length = size(data.pres_itemnos, 2);
    n_lists = size(data.pres_itemnos, 1);
    fprintf('List length: %d.\n', list_length)
    fprintf('Number of lists: %d.\n', n_lists)
    fprintf('Found %d unique presented items.\n', ...
            length(unique(data.pres_itemnos)))
    
    if isfield(data, 'pres_items') && exist('wordpool', 'var')
        fprintf('Checking presented item number consistency...\n')
        check_itemnos(data.pres_items, data.pres_itemnos, wordpool)
    elseif ~isfield(data, 'pres_items')
        fprintf('No presented item strings located. Cannot check item number consistency.\n')
    elseif ~exist('wordpool', 'var')
        fprintf('No wordpool given. Cannot check recalled item number consistency.\n')
    end
end

fprintf(['\nRecall\n' ...
         '------\n'])

% checks on item numbers and consistency with wordpool
fprintf('Checking recalled item numbers...\n')
if ~isfield(data, 'rec_itemnos')
    fprintf('Could not locate recalled item numbers.\n')
else
    n_lists = size(data.rec_itemnos, 1);
    urec_itemnos = unique(data.rec_itemnos);
    urec_itemnos = urec_itemnos(~isnan(urec_itemnos) & urec_itemnos > 0);
    fprintf('Found %d unique recalled items not in the wordpool.\n', ...
            nnz(data.rec_itemnos == -1))
    fprintf('Found %d unique within-wordpool recalled items.\n', ...
            length(urec_itemnos))
    
    if isfield(data, 'rec_items') && exist('wordpool', 'var')
        fprintf('Checking recalled item number consistency...\n')
        check_itemnos(data.rec_items, data.rec_itemnos, wordpool)
    elseif ~isfield(data, 'rec_items')
        fprintf('No recalled item strings located. Cannot check item number consistency.\n')
    elseif ~exist('wordpool', 'var')
        fprintf('No wordpool given. Cannot check recalled item number consistency.\n')
    end
end

% checks on recalls matrix information
fprintf('\nChecking recalls matrix...\n')
if ~isfield(data, 'recalls')
    fprintf('Could not locate recall serial position information.\n')
else
    fprintf('Found recall serial position information.\n')
    urecalls = unique(data.recalls);
    urecalls = urecalls(~isnan(urecalls));
    
    if exist('list_length', 'var')
        fprintf('Checking recall information codes...\n')
        codes = [1:list_length, 0, -1];
        other = setdiff(urecalls, codes);
        if ~isempty(other)
            fprintf('Found unknown recall information codes:\n')
            for i = 1:length(other)
                disp(other(i))
            end
        else
            fprintf('Recall codes OK.\n')
        end
        
        n_lists = size(data.recalls, 1);
        mask = make_clean_recalls_mask2d(data.recalls);
        fprintf('Found %.2f valid recalls per list.\n', ...
                nnz(mask) / n_lists)
        
        rep = ~make_mask_exclude_repeats2d(data.recalls) & data.recalls ~= 0;
        fprintf('Found %.2f repeats per list.\n', ...
                nnz(rep) / n_lists);

        fprintf('Found %.2f intrusions per list.\n', ...
                nnz(data.recalls < 0) / n_lists)
    else
        fprintf('List length not found. Cannot check recall codes.\n')
    end
end

% intrusions matrix
fprintf('\nChecking intrusions matrix...\n')
if ~isfield(data, 'intrusions')
    fprintf('Could not locate detailed intrusions information.\n')
else
    n_lists = size(data.intrusions, 1);
    pli = data.intrusions > 0;
    eli = data.intrusions == -1;
    fprintf('Found %.2f PLIs and %.2f ELIs per list.\n', ...
            nnz(pli) / n_lists, nnz(eli) / n_lists)

    if isfield(data, 'rec_itemnos')
        % consistency with item numbers matrix
        if any(data.rec_itemnos(pli) <= 0)
            fprintf('Warning: Recalls labeled as PLIs have no index in the word pool.\n')
        end
    end
    
    if isfield(data, 'recalls')
        % consistency with recalls matrix
        if any(data.recalls(pli | eli) ~= -1)
            fprintf('Warning: Recalls matrix codes do not match intrusions matrix.\n')
        end
    end
end

% recall timing
fprintf('\nChecking recall times matrix...\n')
if ~isfield(data, 'times')
    fprintf('Could not locate recall timing information.\n')
else
    fprintf('Found recall timing information.\n')
end
