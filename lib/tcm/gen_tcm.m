function seq = gen_tcm(param, data, n_rep)
%GEN_TCM   Generate simulated data from TCM.
%
%  Same as logl_tcm, but generates recall sequences rather than
%  calculating the probability of data given the model.
%
%  param and data are assumed to be pre-processed, including setting
%  defaults for missing parameters, etc.
%
%  seq = gen_tcm(param, data, n_rep)
%
%  INPUTS
%  param - struct
%      Structure with model parameters. See check_param_tcm for details.
%
%  data - frdata struct
%      Standard free recall data structure. Must have repeats and
%      intrusions removed. Required fields:
%
%          recalls - [lists x output position] numeric array
%              Serial position of each recalled item. Output
%              positions were no item was recalled should be zero.
%
%          pres_itemnos - [lists x input position] numeric array
%              Number of each presented item. If modeling semantic
%              similarity, indicates the position of each item in
%              the semantic matrix.
%
%  n_rep - int
%      Number of times to replicate the study when generating
%      data. Can run many times to get a stable estimate of the
%      model's behavior.
%
%  OUTPUTS
%  seq - [lists x output position]
%      Serial positions of simulated recalls. Output positions with no
%      recalls are zero. Stop events are not included, so that the
%      matrix is comparable to data.recalls.
  
if nargin < 3
    n_rep = 1; 
end

[n_trials, n_items, n_recalls] = size_frdata(data);
seq = zeros(n_trials * n_rep, n_items);
n = 0;
for i = 1:n_rep
    for j = 1:n_trials
        % run a trial. Assuming for now that each trial is independent of
        % the others
        n = n + 1;

        seq_trial = run_trial(param, data.pres_itemnos(j,:));
        seq(n,1:length(seq_trial)) = seq_trial;
    end
end

% remove padding
cols = ~all(seq==0, 1);
seq = seq(:,cols);


function seq = run_trial(param, pres_itemnos)
    
    LL = size(pres_itemnos, 2);

    % initialize the model
    net = init_network_tcm(param, pres_itemnos);
    net.itemnos = pres_itemnos;
    
    % study
    net = present_items_tcm(net, param);

    % recall
    stopped = false;
    pos = 0;
    seq = [];
    while ~stopped
        % recall probability given associations, the current cue, and
        % given that previously recalled items will not be repeated
        prob_model = p_recall_tcm(net, param, seq);
        
        % sample an event
        event = randsample(1:(LL+1), 1, true, prob_model);

        if event == (LL + 1)
            % if the termination event was chosen, stop recalling
            stopped = true;
        else
            % record the serial position of the recall
            seq = [seq event];
            pos = pos + 1;
        end

        if ~stopped
            % uncomment to display probability plots
            % clf
            % plot(prob_model);
            % set(gca, 'YLim', [0 1])
            % hold on
            % plot(seq(1:end-2), repmat(0, [1 length(seq)-2]), 'k*');
            % if length(seq) > 0
            %     plot(seq(end), 0, 'r*');
            %     if length(seq) > 1
            %         plot(seq(end-1), 0, 'b*');
            %     end
            % end
            % drawnow
            % pause
            
            % reactivate the item and reinstate context
            net = reactivate_item_tcm(net, event, param);
        end
    end
