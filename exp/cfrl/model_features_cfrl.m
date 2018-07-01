function opt = model_features_cfrl(model_type)
%MODEL_FEATURES_CFRL   Set non-numeric options for the model.
%
%  Given a model type string, determines the options to be
%  used. Each set of options defines a model variant.
%
%  opt = model_features_cfrl(model_type)

opt.sem_model = '';

if namecheck('wikiw2v', model_type)
    opt.sem_model = 'wikiw2v';
end

opt.stop_rule = 'op';
opt.init_item = false;


function tf = namecheck(opt_name, model_type)

if ischar(opt_name)
    opt_name = {opt_name};
end

tf = false(1, length(opt_name));
for i = 1:length(opt_name)
    tf(i) = ~isempty(strfind(model_type, opt_name{i}));
end
tf = any(tf);
