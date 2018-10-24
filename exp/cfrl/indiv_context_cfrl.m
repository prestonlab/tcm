function [subj_data, subj_param, c_pres, c_rec] = indiv_context_cfrl(stats, simdef)
%INDIV_CONTEXT_CFRL   Record states of context for subject simulations.
%
%  [subj_data, c_pres, c_rec] = indiv_context_cfrl(stats, simdef)

pool = load(simdef.pool_file);
subj_data = cell(1, length(stats));
subj_param = cell(1, length(stats));
c_pres = cell(1, length(stats));
c_rec = cell(1, length(stats));
for i = 1:length(stats)
    % construct parameters from the best-fitting vector
    param = unpack_param(stats(i).parameters, stats(i).param_info);
    param = propval(simdef.fixed, param, 'strict', false);
    param = prep_param_cfrl(param, simdef, pool.category);
    param = check_param_cfrl(param);

    % enable context recording
    param.record = {'c'};
    [logl, logl_all, net] = logl_tcm(param, stats(i).param.data);

    subj_data{i} = stats(i).param.data;
    subj_param{i} = param;
    c_pres{i} = net.pres.c;
    c_rec{i} = net.rec.c;
end
