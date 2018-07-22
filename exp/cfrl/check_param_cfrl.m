function param = check_param_cfrl(param)
%CHECK_PARAM_CFRL   Prepare parameters for running TCM in CFRL.
%
%  param = check_param_cfrl(param)

% get non-numeric settings from the model type string
opt = model_features_cfrl(param.model_type);

if ~isfield(param, 'stop_rule')
    param.stop_rule = opt.stop_rule;
end

if ~isfield(param, 'B_s')
    param.B_s = 0;
end

if ~isfield(param, 'I')
    param.I = 0;
end

if ~isfield(param, 'init_item')
    param.init_item = opt.init_item;
end

if ~isfield(param, 'B_ri')
    param.B_ri = 0;
end

% translate the G parameter (a ratio) to Dfc (a value for
% pre-experimental context relative to a fixed learning rate of 1)
if isfield(param, 'G') && ~isempty(param.G)
    param.Dfc = (1 - param.G) / param.G;
    param.G = 1;
end

if isfield(param, 'D')
    param.Dcf = param.D;
end

if isfield(param, 'C')
    param.Acf = param.C;
end

if isfield(param, 'S')
    param.Scf = param.S;
end

if isfield(param, 'SL')
    if isfield(param, 'SC')
        SL = param.SL;
        SC = param.SC;
        SD = 1;
        ST = SL + SC + SD;
        x = [(SL/ST) * param.loc_vec
             (SC/ST) * param.cat_vec
             (SD/ST) * param.sem_vec];
    else
        SL = param.SL;
        SD = 1;
        ST = SL + SD;
        x = [(SL/ST) * param.loc_vec
             (SD/ST) * param.sem_vec];
    end
    param.sem_vec = x ./ sqrt(sum(x.^2,1));    
end

param = check_param_tcm(param);
