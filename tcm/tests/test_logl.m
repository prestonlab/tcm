function tests = test_logl()
%TEST_LOGL   Check different implementations of likelihood code.

tests = functiontests(localfunctions);


function setupOnce(testCase)

% parameters taken from:
% ~/work/cfr/tcm/tcm_wikiw2v_qc/tcm_wikiw2v_qc_2018-06-28_stats.mat
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
testCase.TestData.param = param;

% data for cfr, subject 1
data = getfield(load('cfr_benchmark_data.mat', 'data'), 'data');
sem = load('cfr_wikiw2v.mat');

testCase.TestData.data = data;
testCase.TestData.sem = sem;


function test_local(testCase)
% basic local model, no semantics

param = testCase.TestData.param;
data = testCase.TestData.data;
param_vec = param_vec_tcm(param);

logl_mex = tcm_matlab(data.listLength, data.recalls_vec, param_vec);
%logl_mex = logl_mex_tcm(param, data);

[logl, logl_all] = logl_tcm(param, data);
logl_mat = nansum(logl(:));
assert(abs(logl_mex - logl_mat) < .001);


function test_local_sem(testCase)
% local model with semantic connections

param = testCase.TestData.param;
data = testCase.TestData.data;
sem = testCase.TestData.sem;
param_vec = param_vec_tcm(param);

logl_mex = tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                      1, data.pres_itemnos, sem.sem_mat);
param.sem_mat = sem.sem_mat;
[logl, logl_all] = logl_tcm(param, data);
logl_mat = nansum(logl(:));
assert(abs(logl_mex - logl_mat) < .001);


function test_dc_mex(testCase)

param = testCase.TestData.param;
data = testCase.TestData.data;
sem = testCase.TestData.sem;

param_vec = param_vec_tcm(param);
logl_mex = tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                      2, data.pres_itemnos, sem.vectors');

param.sem_vec = sem.vectors';
[logl, logl_all] = logl_tcm(param, data);
logl_mat = nansum(logl(:));
assert(abs(logl_mex - logl_mat) < .001);
