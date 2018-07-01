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

param = check_param_tcm(param);
