function data = clean_frdata(data)
%CLEAN_FRDATA   Remove repeats and intrusions from a data struct.
%
%  data = clean_frdata(data)

mask = make_clean_recalls_mask2d(data.recalls);
n_col = max(sum(mask, 2));

% standard recall fields
f_rec = {'rec_items' 'rec_itemnos' 'recalls' 'times' 'intrusions'};
for i = 1:length(f_rec)
    if isfield(data, f_rec{i})
        data.(f_rec{i}) = clean_mat(data.(f_rec{i}), mask, n_col);
    end
end

% custom recall fields
if isfield(data, 'rec')
    f = fieldnames(data.rec);
    for i = 1:length(f)
        data.rec.(f{i}) = clean_mat(data.rec.(f{i}), mask, n_col);
    end
end


function cmat = clean_mat(mat, mask, n_col)

    sz = [size(mat, 1) n_col];
    if isnumeric(mat)
        cmat = zeros(sz);
    elseif iscell(mat)
        cmat = cell(sz);
    else
        error('Unsupported data type.')
    end
    
    % add back in only unmasked recalls
    for j = 1:size(mat, 1)
        seq = mat(j,mask(j,:));
        cmat(j,1:length(seq)) = seq;
    end
    