function param = param_cdcfr2(param, distract_len)
%PARAM_CDCFR2   Set parameters that are specific to distraction length.
%
%  param = param_cdcfr2(param, distract_len)

if distract_len == 2.5
    param.B_ipi = param.B_ipi1;
    param.B_ri = param.B_ri1;
    param.X2 = param.X21;
elseif distract_len == 7.5
    param.B_ipi = param.B_ipi2;
    param.B_ri = param.B_ri2;
    param.X2 = param.X22;
end

if param.B_ipi > 1
    param.B_ipi = 1;
end
if param.B_ri > 1
    param.B_ri = 1;
end
if param.X2 > 1
    param.X2 = 1;
end
