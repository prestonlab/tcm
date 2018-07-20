function recalls_vec = recalls_vec_tcm(recalls, list_length)
%RECALLS_VEC_TCM   Convert a recalls matrix into vector format.
%
%  Used to prepare data for use with logl_mex_tcm.
%
%  recalls_vec = recalls_vec_tcm(recalls, list_length)
%
%  INPUTS
%  recalls - [lists x items] numeric array
%      Serial position of recalled items, organized by output
%      position. Output positions with no recall should be zero.
%
%  list_length - int
%      Length of each list.
%
%  OUTPUTS
%  recalls_vec - [1 x recalls] numeric array
%      Vector of all recall events with no padding. Stop events are
%      coded as list_length + 1.

recalls_vec = [];
for i = 1:size(recalls, 1)
    n_recalls(i) = nnz(recalls(i,:));
    recalls_vec = [recalls_vec recalls(i,1:n_recalls(i)) list_length+1];
end
