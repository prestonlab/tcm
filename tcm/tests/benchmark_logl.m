function [t1, t2] = benchmark_logl(ver, n_rep)
%BENCHMARK_LOGL   Compare the speed of matlab and mex implementations.
%
%  [t1, t2] = benchmark_logl(ver, imp)
%
%  INPUTS
%  ver - int - 1
%     Version of the model to run:
%     1 - Basic version with no semantics.
%     2 - Semantic associations on Mcf.
%     3 - Distributed context based on semantic feature vectors.
%
%  n_rep - int - 10
%     Number of times to repeat likelihood calculation for each
%     implementation.
%
%  OUTPUTS
%  t1 - double
%      Time in seconds for logl_tcm to execute.
%
%  t2 - double
%      Time in seconds for tcm_matlab to execute.

if nargin < 2
    n_rep = 10;
    if nargin < 1
        ver = 1;
    end
end

param = struct();
param.B_enc = 0.79;
param.B_rec = 0.94;
param.P1 = 16.84;
param.P2 = 1.64;
param.G = 1;
param.X1 = 0.0093;
param.X2 = 0.32;
param.C = 1.22;
param.D = 100;
param.T = 4.64;
param.B_s = 0.1;
param.S = 2.5;
param.I = 0;
param.stop_rule = 'op';
param.init_item = 0;
param.B_ipi = 0;
param.B_ri = 0;
param.Dfc = 70.46;
param.Dcf = 100 - 1.22; % adjust for new parameter definition
param.Afc = 0;
param.Acf = 1.22;
param.Sfc = 0;
param.Lfc = 1;
param.Lcf = 1;
param.Scf = 2.5;

data = getfield(load('cfr_benchmark_data.mat', 'data'), 'data');
sem = load('cfr_wikiw2v.mat');
param_vec = param_vec_tcm(param);

switch ver
  case 1
    tic;
    for i = 1:n_rep
        logl_tcm(param, data);
    end
    t1 = toc;
    
    tic;
    for i = 1:n_rep
        tcm_matlab(data.listLength, data.recalls_vec, param_vec);
    end
    t2 = toc;
  case 2
    param.sem_mat = sem.sem_mat;
    tic;
    for i = 1:n_rep
        logl_tcm(param, data);
    end
    t1 = toc;
    
    sem_mat = sem.sem_mat;
    tic;
    for i = 1:n_rep
        tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                   1, data.pres_itemnos, sem_mat);
    end
    t2 = toc;
  case 3
    param.pre_vec = sem.vectors';
    tic;
    for i = 1:n_rep
        logl_tcm(param, data);
    end
    t1 = toc;
    
    pre_vec = sem.vectors';
    tic;
    for i = 1:n_rep
        tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                   2, data.pres_itemnos, pre_vec);
    end
    t2 = toc;
end
