function [logl, logl_all] = logl_tcm(param, data, var_param)
%LOGL_TCM   Calculate log likelihood for free recall using TCM.
%
%  Calculates log likelihood for multiple lists. param and data are
%  assumed to be pre-processed, including setting defaults for
%  missing parameters, etc.
%
%  [logl, logl_all] = logl_tcm(param, data, var_param)
%
%  INPUTS:
%   param:  structure with model parameters. Each field must contain a
%           scalar or a string. 
%
%    data:  free recall data structure, with repeats and intrusions
%           removed. Required fields:
%            recalls
%            pres_itemnos
%    
% var_param: structure with information about parameters that vary
%            by trial, by study event, or by recall event.
%            Required fields:
%             name
%             update_level
%             val
%
%  OUTPUTS:
%      logl:  [lists X recalls] matrix with log likelihood values for
%             all recall events in data.recalls (plus stopping events).
%
%  logl_all:  [lists X recalls X events] matrix of log likelihood values
%             for all possible events, after each recall event in
%             data.recalls.

if nargin < 3
    var_param = [];
end

param = check_param_tcm(param);

[n_trials, n_items, n_recalls] = size_frdata(data);
logl = NaN(n_trials, n_recalls + 1);
logl_all = NaN(n_trials, n_recalls + 1, n_items + 1);
for i = 1:n_trials
    % run a trial. Assuming for now that each trial is independent of
    % the others
    env.trial = i;
    env.event = 1;
    
    if ~isempty(var_param)
        param = update_param(param,var_param,env);
    end
    
    [logl_trial, logl_all_trial] = run_trial(param, ...
                                             var_param, ...
                                             env, ...
                                             data.pres_itemnos(i,:), ...
                                             data.recalls(i,:));
    
    ind = 1:length(logl_trial);
    logl(i,ind) = logl_trial;
    logl_all(i,ind,:) = logl_all_trial;
end


function [logl, logl_all] = run_trial(param, var_param, env, pres_itemnos, recalls)
    
    LL = size(pres_itemnos, 2);
    
    % get the set of events to model
    seq = [nonzeros(recalls)' LL + 1];
    
    % initialize the model
    [f, c, w_fc, w_cf, w_cf_pre, env] = init_network_tcm(param, env, pres_itemnos);
    
    % study
    w_fc_pre_s = w_fc;
    w_cf_pre_s = w_cf;
    [f, c, w_fc, w_cf, env] = present_items_tcm(f, c, w_fc, w_cf, param, ...
                                                var_param, env, LL);

    logl = zeros(size(seq));
    logl_all = NaN(length(seq), LL+1);
    for i = 1:length(seq)
        
        if ~isempty(var_param)
            param = update_param(param,var_param,env);
        end
        
        % probability of all possible events
        output_pos = i - 1;
        prev_rec = seq(1:output_pos);
        prob_model = p_recall_tcm(w_cf, c, LL, prev_rec, output_pos, ...
                                  param, w_cf_pre);
        
        % calculate log likelihood for actual and possible events
        logl(i) = log(prob_model(seq(i)));
        logl_all(i,:) = log(prob_model);

        if i < length(seq)
            % reactivate the item and reinstate context
            [f, c] = reactivate_item_tcm(f, c, w_fc, seq(i), param);
        end
        
        env.event = env.event+1;
    end
