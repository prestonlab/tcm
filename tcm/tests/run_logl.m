function logl = run_logl(ver, imp, list)
%RUN_LOGL   Run a basic test of likelihood calculation.
%
%  logl = run_logl(ver, imp)
%
%  INPUTS
%  ver - int - 1
%     Version of the model to run:
%     1 - Basic version with no semantics.
%     2 - Semantic associations on Mcf.
%     3 - Distributed context based on semantic feature vectors.
%  imp - int - 2
%     Implementation of the model to run:
%     1 - Matlab.
%     2 - MEX.
%
%  OUTPUTS
%  logl - double
%      Calculated log likelihood of the data from a sample subject,
%      using sample best-fitting parameters.

if nargin < 2
    imp = 2;
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

if nargin > 2
    data.recalls = data.recalls(list,:);
    data.pres_itemnos = data.pres_itemnos(list,:);
    data.rec_itemnos = data.rec_itemnos(list,:);
    data.recalls_vec = recalls_vec_tcm(data.recalls, data.listLength);
end

sem = load('cfr_wikiw2v.mat');

if imp == 1
    switch ver
      case 2
        param.sem_mat = sem.sem_mat;
      case 3
        param.sem_vec = sem.vectors';
      case 4
        if nargin > 2
            param.sem_vec = eye(24);
            data.pres_itemnos = 1:24;
        else
            param.sem_vec = eye(768);
        end
    end
    [logl_mat, logl_all] = logl_tcm(param, data);
    logl = nansum(logl_mat(:));
else
    param_vec = param_vec_tcm(param);
    switch ver
      case 1
        logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec);
      case 2
        logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                          1, data.pres_itemnos, sem.sem_mat);
      case 3
        logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                          2, data.pres_itemnos, sem.vectors');
      case 4
        if nargin > 2
            logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                              2, 1:24, eye(24));
        else
            logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                              2, data.pres_itemnos, eye(768));
        end
    end
end
