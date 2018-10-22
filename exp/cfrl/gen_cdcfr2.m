function seq = gen_cdcfr2(param, data, n_rep)
%GEN_CDCFR2   Simulate data for multiple distraction conditions.
%
%  seq = gen_cdcfr2(param, data, n_rep)

% original and replicated distraction labels
distract = data.pres.distractor(:,1);
udistract = unique(distract);
rep_distract = repmat(distract, [n_rep 1]);

% generate sequences for all distraction conditions
[n_list, n_item] = size(data.pres_itemnos);
seq = NaN(n_list * n_rep, n_item);
for i = 1:length(udistract)
    % get data for this subset of trials
    include = distract==udistract(i);
    d = struct;
    d.recalls = data.recalls(include,:);
    d.pres_itemnos = data.pres_itemnos(include,:);
    
    % simulate this distraction condition
    d_param = param_cdcfr2(param, udistract(i));
    d_seq = gen_tcm(d_param, d, n_rep);
    seq(rep_distract==udistract(i),1:size(d_seq, 2)) = d_seq;
end

cols = ~all(seq==0, 1);
seq = seq(:,cols);
