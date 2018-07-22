function [param_info, fixed] = search_param_cfrl(model_type, experiment)
%SEARCH_PARAM_CFRL   Get parameter ranges and fixed parameters.
%
%  [param_info, fixed] = search_param_cfrl(model_type, experiment)

% defaults
core.B_enc = [0 1];
core.B_rec = [0 1];
core.G = [0 1];
core.Acf = [0 100];
core.Dcf = [0 100];
core.P1 = [0 100];
core.P2 = [0 100];
core.T = [0 100];
core.X1 = [0 1];
core.X2 = [0 1];
core.B_s = [0 1];

% initial ranges (for unbounded parameters)
init = core;
init.Acf = [0 1];
init.Dcf = [0 1];
init.P1 = [0 10];
init.P2 = [0 10];
init.T = [0 1];

% fixed parameters
fixed = struct;
fixed.model_type = model_type;
fixed.B_ipi = 0;
fixed.B_ri = 0;
fixed.Afc = 0;
fixed.Sfc = 0;
fixed.Scf = 0;
fixed.Lfc = 1;
fixed.Lcf = 1;

par = core;

% semantic scaling
if namecheck({'wikiw2v'}, model_type)
    if namecheck({'qc' 'qi' 'qic'}, model_type)
        par.Scf = [0 100];
        init.Scf = [0 1];
    end
else
    fixed.Scf = 0;
end

% item-context balance
if namecheck('_qci', model_type)
    par.I = [0 1];
    init.I = [0 1];
end
if namecheck('_qi', model_type)
    fixed.I = 1;
end
if namecheck('_qc', model_type)
    fixed.I = 0;
end

% vector matrices
if namecheck('_ncf', model_type)
    % no context-to-feature vectors. There can still be a constant
    % pre-experimental association strength, and learning of
    % experimental associations, but there won't be any "readout"
    % of context during retrieval
    fixed.Dcf = 0;
    par = rmfield(par, 'Dcf');
    init = rmfield(init, 'Dcf');
end

names = fieldnames(par);
ranges = struct2cell(par);
init = struct2cell(init);
param_info = make_param_info(names, 'range', ranges, 'init', init);


function tf = namecheck(opt_name, model_type)

if ischar(opt_name)
    opt_name = {opt_name};
end

tf = false(1, length(opt_name));
for i = 1:length(opt_name)
    tf(i) = ~isempty(strfind(model_type, opt_name{i}));
end
tf = any(tf);
