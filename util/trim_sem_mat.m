function [pres_itemnos_trim, sem_mat_trim, sem_vec_trim] = trim_sem_mat(pres_itemnos, ...
                                                  sem_mat, sem_vec)
%TRIM_SEM_MAT   Remove unused items from a semantic matrix.
%
%  Can be used to speed up execution of simulations that vary with the
%  size of the semantic matrix. This is the case when using
%  tcm_general_mex, which has to pass the semantic matrix from Matlab
%  to the c++ program.
%
%  [pres_itemnos_trim, sem_mat_trim] = trim_sem_mat(pres_itemnos, sem_mat)

if nargin < 3
    sem_vec = [];
end

[itemnos, ia, ic] = unique(pres_itemnos);
n_item = length(itemnos);
new_itemnos = [1:n_item]';
pres_itemnos_trim = reshape(new_itemnos(ic), size(pres_itemnos));

if ~isempty(sem_mat)
    sem_mat_trim = sem_mat(itemnos, itemnos);
else
    sem_mat_trim = [];
end

if ~isempty(sem_vec)
    sem_vec_trim = sem_vec(:,itemnos);
else
    sem_vec_trim = [];
end
