function param = check_param_tcm(param)
%CHECK_PARAM_TCM   Prepare parameters for running TCM.
%
%  param = check_param_tcm(param)

if isfield(param, 'B')
    % convert to two-parameter version
    if ~isfield(param, 'B_enc')
        param.B_enc = param.B;
    end
    if ~isfield(param, 'B_rec')
        param.B_rec = param.B;
    end
end

if isfield(param, 'P')
    % convert to two-parameter version
    if ~isfield(param, 'P1')
        param.P1 = param.P;
    end
end

if ~isfield(param, 'Dfc')
    if isfield(param, 'G') && ~isempty(param.G)
        param.Dfc = (1 - param.G) / param.G;
        param.G = 1;
    else
        param.Dfc = 0;
    end
else
    % setting diagonal, so don't need the G parameter to vary
    param.G = 1;
end
if isfield(param, 'D')
    param.Dcf = param.D;
elseif ~isfield(param, 'Dcf')
    param.Dcf = 0;
end

if ~isfield(param, 'Afc')
    param.Afc = 0;
end
if isfield(param, 'C')
    param.Acf = param.C;
elseif ~isfield(param, 'Acf')
    param.Acf = 0;
end

if ~isfield(param, 'Afc')
    param.Afc = 0;
end

if ~isfield(param, 'P2')
    % default is that only serial position 1 is affected by primacy boost
    param.P2 = 1000000;
end

if ~isfield(param, 'Sfc')
    param.Sfc = 0;
end

if ~isfield(param, 'Lfc')
    param.Lfc = 1;
end

if ~isfield(param, 'Lcf')
    param.Lcf = 1;
end

if isfield(param, 'S')
    param.Scf = param.S;
end

if ~isfield(param, 'C')
    param.C = 0;
end

if ~isfield(param, 'T')
    param.T = 1;
end

if ~isfield(param, 'stop_rule')
    param.stop_rule = 'op';
end
