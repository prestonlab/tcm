function [pres_itemnos_trim, sem_mat_trim] = trim_sem_mat(pres_itemnos, ...
                                                  sem_mat)
%TRIM_SEM_MAT   Remove unused items from a semantic matrix.
%
%  Can be used to speed up execution of simulations that vary with the
%  size of the semantic matrix. This is the case when using
%  tcm_general_mex, which has to pass the semantic matrix from Matlab
%  to the c++ program.
%
%  [pres_itemnos_trim, sem_mat_trim] = trim_sem_mat(pres_itemnos, sem_mat)

[itemnos, ia, ic] = unique(pres_itemnos);
n_item = length(itemnos);
new_itemnos = [1:n_item]';
pres_itemnos_trim = reshape(new_itemnos(ic), size(pres_itemnos));

sem_mat_trim = sem_mat(itemnos, itemnos);
