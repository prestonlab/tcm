function logl = logl_cdcfr2(param, data)
%LOGL_CDCFR2   Evaluate a model for multiple distraction conditions.
%
%  logl = logl_cdcfr2(param, data)

% run separately for each distraction condition
logl = 0;
for i = 1:length(data.distract)
    distract_len = data.distract{i}.distract_len;
    if distract_len == 2.5
        param.B_ipi = param.B_ipi1;
        param.B_ri = param.B_ri1;
        param.X2 = param.X21;
    elseif distract_len == 7.5
        param.B_ipi = param.B_ipi2;
        param.B_ri = param.B_ri2;
        param.X2 = param.X22;
    end
    logl_distract = logl_mex_tcm(param, data.distract{i});
    logl = logl + logl_distract;
end
