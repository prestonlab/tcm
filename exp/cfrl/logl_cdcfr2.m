function logl = logl_cdcfr2(param, data)
%LOGL_CDCFR2   Evaluate a model for multiple distraction conditions.
%
%  logl = logl_cdcfr2(param, data)

% run separately for each distraction condition
logl = 0;
for i = 1:length(data.distract)
    d_param = param_cdcfr2(param, data.distract{i}.distract_len);
    logl_distract = logl_mex_tcm(d_param, data.distract{i});
    logl = logl + logl_distract;
end
