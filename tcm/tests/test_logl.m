function tests = test_logl()
%TEST_LOGL   Check different implementations of likelihood code.

tests = functiontests(localfunctions);


function setupOnce(testCase)

% parameters taken from:
% ~/work/cfr/tcm/tcm_wikiw2v_qc/tcm_wikiw2v_qc_2018-06-28_stats.mat
param = struct();
param.B_enc = 0.79;
param.B_rec = 0.94;
param.Afc = 0;
param.Acf = 1.22;
param.Dfc = 70.46;
param.Dcf = 100 - 1.22; % adjust for new parameter definition
param.Sfc = 0;
param.Scf = 2.5;
param.Lfc = 1;
param.Lcf = 1;
param.P1 = 16.84;
param.P2 = 1.64;
param.T = 4.64;
param.X1 = 0.0093;
param.X2 = 0.32;
param.stop_rule = 'op';
param.B_s = 0.1;
param.B_ipi = 0;
param.B_ri = 0;
param.I = 0;
param.init_item = 0;

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

logl_mex = logl_mex_tcm(param, data);
[logl, logl_all] = logl_tcm(param, data);
logl_mat = nansum(logl(:));

assert(abs(logl_mex - logl_mat) < .001);


function test_distract(testCase)

param = testCase.TestData.param;
data = testCase.TestData.data;

param.B_ipi = 0.1;
param.B_ri = 0.2;

logl_mex = logl_mex_tcm(param, data);
[logl, logl_all] = logl_tcm(param, data);
logl_mat = nansum(logl(:));

assert(abs(logl_mex - logl_mat) < .001);


function test_local_sem(testCase)
% local model with semantic connections

param = testCase.TestData.param;
data = testCase.TestData.data;
sem = testCase.TestData.sem;
param.sem_mat = sem.sem_mat;

logl_mex = logl_mex_tcm(param, data);
[logl, logl_all] = logl_tcm(param, data);
logl_mat = nansum(logl(:));

assert(abs(logl_mex - logl_mat) < .001);


function test_distract_sem(testCase)

param = testCase.TestData.param;
data = testCase.TestData.data;
sem = testCase.TestData.sem;
param.sem_mat = sem.sem_mat;
param.B_ipi = 0.1;
param.B_ri = 0.2;

logl_mex = logl_mex_tcm(param, data);
[logl, logl_all] = logl_tcm(param, data);
logl_mat = nansum(logl(:));

assert(abs(logl_mex - logl_mat) < .001);


function test_dc(testCase)

param = testCase.TestData.param;
data = testCase.TestData.data;
sem = testCase.TestData.sem;
param.sem_vec = sem.vectors';

logl_mex = logl_mex_tcm(param, data);
[logl, logl_all] = logl_tcm(param, data);
logl_mat = nansum(logl(:));

assert(abs(logl_mex - logl_mat) < .001);


function test_distract_dc(testCase)

param = testCase.TestData.param;
data = testCase.TestData.data;
sem = testCase.TestData.sem;
param.sem_vec = sem.vectors';
param.B_ipi = 0.1;
param.B_ri = 0.2;

logl_mex = logl_mex_tcm(param, data);
[logl, logl_all] = logl_tcm(param, data);
logl_mat = nansum(logl(:));

assert(abs(logl_mex - logl_mat) < .001);
