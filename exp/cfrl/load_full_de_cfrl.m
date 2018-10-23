function res = load_full_de_cfrl(job, experiments, fits)
%LOAD_FULL_DE_CFRL   Load a set of searches.
%
%  res = load_full_de_cfrl(job, experiments, fits)

if ischar(experiments)
    experiments = {experiments};
end
if ischar(fits)
    fits = {fits};
end

try
    out = fetchOutputs(job);
catch
    fprintf('There was a problem loading job %d\n', job.ID);
    res = [];
    return
end

if length(out) ~= length(fits)
    error('Fits must be the same length as job.Tasks')
end

res = struct;
for i = 1:length(out)
    info = get_fit_info_cfrl(fits{i}, experiments{i});
    f = [experiments{i} '_' fits{i}];

    if ~isfield(out{i}, 'fitness')
        res.(f) = [];
        fprintf('Search did not finish for %s.\n', f);
        continue
    end
    
    stats = [];
    for j = 1:length(out{i})
        % results for this subject and model
        sout = out{i}(j);
        parameters = sout.parameters;
        fitness = sout.fitness;
        
        % best-fitting parameters
        [fval, ind] = min(fitness);
        param_vec = parameters(ind,:);
        param = unpack_param(param_vec, sout.fstruct.param_info);
        [~, fixed] = search_param_cfrl(sout.fstruct.model_type, experiments{i});
        param = propval(fixed, param, 'strict', false);
        param.data = sout.fstruct.data;
        param = check_param_cfrl(param);
        
        % save search information in standard format
        s = struct;
        s.model_type = sout.fstruct.model_type;
        s.param = param;
        s.fval = fval;
        s.parameters = parameters;
        s.fitness = fitness;
        s.names = {sout.fstruct.param_info.name};
        s.param_info = sout.fstruct.param_info;
        s.fixed = fixed;
        s.search_opt = sout.search_opt;
        s.run_opt = sout.run_opt;
        s.rseed = sout.rseed;
        
        stats = cat_structs(stats, s);
    end
    
    res.(f).fitness = cat(1, stats.fitness);
    res.(f).parameters = cat(1, stats.parameters);
    res.(f).names = stats(1).names;
    res.(f).stats = stats;
end
