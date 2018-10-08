function indiv_decode_cfrl(subj_data, subj_c_pres)

x = NaN(length(subj_data), 3, 6, 3);
for i = 1:length(subj_data)
    data = subj_data{i};
    c_pres = subj_c_pres{i};
    
    % set up decoding
    labels = data.pres.category';
    labels = labels(:);
    targets = zeros(length(labels), 3);
    for j = 1:3
        targets(labels==j,j) = 1;
    end
    list = repmat([1:30]', [1 24])';
    list = list(:);
    
    c = c_pres';
    pattern = cat(2, c{:})';

    % run decoding
    opt = struct;
    opt.f_train = @train_logreg;
    opt.train_args = {struct('penalty', 10)};
    opt.f_test = @test_logreg;
    
    res = xval(pattern, list, targets, opt);
    
    evidence = NaN(size(targets, 1), size(targets, 2));
    for j = 1:length(res.iterations)
        test_ind = res.iterations(j).test_idx;
        evidence(test_ind,:) = res.iterations(j).acts';
    end
    
    mat = struct;
    [mat.curr, mat.prev, mat.base, mat.trainpos] = ...
        train_category(data.pres.category);
    
    vec = struct;
    f = fieldnames(mat);
    for j = 1:length(f)
        m = mat.(f{j})';
        vec.(f{j}) = m(:);
    end

    ttype = {'curr' 'prev' 'base'};
    for j = 1:length(ttype)
        tvec = vec.(ttype{j});
        for k = 1:6
            for l = 1:3
                ind = vec.trainpos == k & tvec == l;
                x(i,j,k,l) = nanmean(evidence(ind,l));
            end
        end
    end
end
