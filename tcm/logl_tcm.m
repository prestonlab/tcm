function [logl, logl_all, net] = logl_tcm(param, data)
%LOGL_TCM   Calculate log likelihood for free recall using TCM.
%
%  Calculates log likelihood for multiple lists. param and data are
%  assumed to be pre-processed, including setting defaults for
%  missing parameters, etc.
%
%  [logl, logl_all, net] = logl_tcm(param, data)
%
%  INPUTS
%  param - struct
%      Structure with model parameters. See check_param_tcm for details.
%
%  data - frdata struct
%      Standard free recall data structure. Must have repeats and
%      intrusions removed. Required fields:
%      recalls - [lists x output position] numeric array
%          Serial position of each recalled item. Output positions
%          were no item was recalled should be zero.
%
%      pres_itemnos - [lists x input position] numeric array
%          Number of each presented item. If modeling semantic
%          similarity, indicates the position of each item in the
%          semantic matrix.
%
%  OUTPUTS
%  logl - [lists x recall events] numeric array
%      Log likelihood for all recall events in data.recalls, plus
%      stopping events.
%
%  logl_all - [lists x recall events x possible events] numeric array
%      Likelihood for all possible events, after each recall event
%      in data.recalls.
%
%  net - struct
%      Network structure. If recordings are not enabled, this will
%      just contain the state of the network at the end of recall
%      for the last trial.

[n_trials, n_items, n_recalls] = size_frdata(data);

if isfield(param, 'record') && ~isempty(param.record)
    for i = 1:length(param.record)
        net.pres.(param.record{i}) = cell(n_trials, n_items);
        net.rec.(param.record{i}) = cell(n_trials, n_recalls);
    end
end
logl = NaN(n_trials, n_recalls + 1);
logl_all = NaN(n_trials, n_recalls + 1, n_items + 1);
for i = 1:n_trials
    % run a trial. Assuming for now that each trial is independent of
    % the others
    [logl_trial, logl_all_trial, net_trial] = ...
        run_trial(param, data.pres_itemnos(i,:), data.recalls(i,:));
    
    if isfield(param, 'record') && ~isempty(param.record)
        for j = 1:length(param.record)
            net.pres.(param.record{j})(i,:) = net_trial.pres.(param.record{j});
            rc = net_trial.rec.(param.record{j});
            net.rec.(param.record{j})(i,1:length(rc)) = rc;
        end
    end
    
    ind = 1:length(logl_trial);
    logl(i,ind) = logl_trial;
    logl_all(i,ind,:) = logl_all_trial;
end


function [logl, logl_all, net] = run_trial(param, pres_itemnos, recalls)
    
    LL = size(pres_itemnos, 2);
    
    % get the set of events to model
    seq = [nonzeros(recalls)' LL + 1];
    
    % initialize the model
    net = init_network_tcm(param, pres_itemnos);
    net.itemnos = pres_itemnos;
    
    % study
    net = present_items_tcm(net, param);

    if isfield(param, 'record') && ~isempty(param.record)
        for i = 1:length(param.record)
            net.rec.(param.record{i}) = cell(1, length(seq));
        end
    end
    logl = zeros(size(seq));
    logl_all = NaN(length(seq), LL+1);
    for i = 1:length(seq)
        if isfield(param, 'record') && ~isempty(param.record)
            for j = 1:length(param.record)
                net.rec.(param.record{j}){i} = net.(param.record{j});
            end
        end
        
        % probability of all possible events
        output_pos = i - 1;
        prev_rec = seq(1:output_pos);
        prob_model = p_recall_tcm(net, param, prev_rec);
        
        % calculate log likelihood for actual and possible events
        logl(i) = log(prob_model(seq(i)));
        logl_all(i,:) = log(prob_model);

        if i < length(seq)
            % reactivate the item and reinstate context
            net = reactivate_item_tcm(net, seq(i), param);
        end
    end
