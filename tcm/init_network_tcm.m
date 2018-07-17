function net = init_network_tcm(param, pres_itemnos)
%INIT_NETWORK_TCM   Initialize network variables for TCM.
%
%  net = init_network_tcm(param, pres_itemnos)
%
%  INPUTS
%  param - struct
%      Parameter struct defining a model network. See
%      check_param_tcm for details. Special fields used here:
%      sem_vec - [dimensions x items] matrix
%          Pre-experimental feature vector associated with each
%          item. Item with item number x is in sem_vec(:,x).
%      sem_mat - [items x items] matrix
%          Pre-experimental associations between each pair of
%          items. The strength of association between items with
%          numbers x and y is in sem_mat(x,y). The diagonal
%          (self-strengths) is generally assumed to be zero, though
%          that isn't required here.
%
%  pres_itemnos - [lists X items] numeric array
%      Number of each presented item in the wordpool. Used to look
%      up semantic vectors and matrices.
%
%  OUTPUTS:
%  net - struct
%      Struct defining the network. Fields are:
%      f - [nf x 1] vector
%          Feature (item) vector. Items are assumed to be localist,
%          so there is just one unit for each item.
%      c - [nc x 1] vector
%          Context vector. States of context may be in the same space
%          as f (localist context), or may have a different feature
%          space (distributed context).
%      w_fc_exp - [nc x nf] matrix
%          Weight matrix of non-semantic associations linking f to c.
%      w_fc_pre - [nc x nf] matrix
%          Weight matrix of semantic associations linking f to c.
%      w_cf_exp - [nf x nc] matrix
%          Weight matrix of non-semantic associations linking c to f.
%      w_cf_pre - [nf x nc] matrix
%          Weight matrix of semantic associations linking c to f.
%      dc - logical
%          True if context is distributed (i.e., a different
%          feature space than the feature vectors).
%      f_item - [1 x items] vector
%          Indices of item units in f.
%      c_item - [1 x items] vector
%          Indices of item units in c.
%      f_start - numeric
%          Index of start unit in f.
%      c_start - numeric
%          Index of start unit in c.

LL = size(pres_itemnos, 2);

% item units
if isfield(param, 'sem_vec') && ~isempty(param.sem_vec)
    net.dc = true;
    IU = size(param.sem_vec, 1);
    item_vecs = param.sem_vec(:,pres_itemnos);
else
    net.dc = false;
    IU = LL;
    item_vecs = [];
end
net.f_item = 1:LL;
net.c_item = 1:IU;
n_f = LL;
n_c = IU;

% ipi units
if isfield(param, 'B_ipi') && param.B_ipi ~= 0
    net.f_ipi = (n_f+1):(n_f+LL);
    net.c_ipi = (n_c+1):(n_c+LL);
    n_f = n_f + LL;
    n_c = n_c + LL;
else
    net.f_ipi = [];
    net.c_ipi = [];
end

% ri units
if isfield(param, 'B_ri') && param.B_ri ~= 0
    net.f_ri = n_f + 1;
    net.c_ri = n_c + 1;
    n_f = n_f + 1;
    n_c = n_c + 1;
else
    net.f_ri = [];
    net.c_ri = [];
end

% start unit
net.f_start = n_f + 1;
net.c_start = n_c + 1;
n_f = n_f + 1;
n_c = n_c + 1;

% initialize the model representations
f = zeros(n_f, 1);
c = zeros(n_c, 1);

% this is the start unit
c(net.c_start) = 1;

w_fc_exp = zeros(n_c, n_f);
w_fc_pre = zeros(n_c, n_f);
w_cf_exp = zeros(n_f, n_c);
w_cf_pre = zeros(n_f, n_c);

% have a separate semantic matrix, to allow for item-based semantic
% cuing
w_cf_sem = zeros(n_f, n_c);

% constant connection strength within item units
if param.Afc ~= 0
    w_fc_pre(net.c_item,net.f_item) = w_fc_pre(net.c_item,net.f_item) + ...
        param.Afc;
end

if param.Acf ~= 0
    w_cf_pre(net.f_item,net.c_item) = w_cf_pre(net.f_item,net.c_item) + ...
        param.Acf;
end

% strength of pre-experimental associations
if net.dc
    if param.Dfc ~= 0
        w_fc_pre(net.c_item,net.f_item) = w_fc_pre(net.c_item,net.f_item) + ...
            item_vecs * param.Dfc;
    end
    if param.Dcf ~= 0
        w_cf_pre(net.f_item,net.c_item) = w_cf_pre(net.f_item,net.c_item) + ...
            item_vecs' * param.Dcf;
    end
else
    if param.Dfc ~= 0
        for i = 1:LL
            w_fc_pre(i,i) = w_fc_pre(i,i) + param.Dfc;
        end
    end
    if param.Dcf ~= 0
        for i = 1:LL
            w_cf_pre(i,i) = w_cf_pre(i,i) + param.Dcf;
        end
    end
end

if isfield(param, 'sem_mat') && ~isempty(param.sem_mat)
    % scale by a free parameter
    semantic = param.sem_mat(pres_itemnos, pres_itemnos);

    if param.Sfc ~= 0
        w_fc_sem(1:LL, 1:LL) = w_fc_sem(1:LL, 1:LL) + semantic * param.Sfc;
    end
    if param.Scf ~= 0
        w_cf_sem(1:LL, 1:LL) = w_cf_sem(1:LL, 1:LL) + semantic * param.Scf;
    end
end

% put standard fields on net struct
net.f = f;
net.c = c;
net.w_fc_exp = w_fc_exp;
net.w_fc_pre = w_fc_pre;
net.w_cf_exp = w_cf_exp;
net.w_cf_pre = w_cf_pre;
net.w_cf_sem = w_cf_sem;
