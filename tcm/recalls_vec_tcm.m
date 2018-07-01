function recalls_vec = recalls_vec_tcmbin(recalls, list_length)
%RECALLS_VEC_TCMBIN   Convert a recalls matrix into vector format.
%
%  recalls_vec = recalls_vec_tcmbin(recalls, list_length)

recalls_vec = [];
for i = 1:size(recalls, 1)
  n_recalls(i) = nnz(recalls(i,:));
  recalls_vec = [recalls_vec recalls(i,1:n_recalls(i)) list_length+1];
end

