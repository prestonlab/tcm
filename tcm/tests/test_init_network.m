function tests = test_init_network()

tests = functiontests(localfunctions);


function setupOnce(testCase)

param = struct();
param.Afc = 0;
param.Acf = 1;
param.Dfc = .5;
param.Dcf = 2;
param.sem_mat = [];
testCase.TestData.param = param;


function test_local(testCase)

param = testCase.TestData.param;
e = 10e-6;

env = struct;
pres_itemnos = [4 2 1 3];
net = init_network_tcm(param, pres_itemnos);

% test dimensions
assert(length(net.f) == 5)
assert(length(net.c) == 5)
assert(norm(net.c) == 1)
assert(isequal(size(net.w_fc_exp), [5 5]))
assert(isequal(size(net.w_fc_pre), [5 5]))
assert(isequal(size(net.w_cf_exp), [5 5]))
assert(isequal(size(net.w_cf_pre), [5 5]))


function test_local_distract(testCase)

param = testCase.TestData.param;
param.B_ipi = 0.1;
param.B_ri = 0.2;
env = struct;
pres_itemnos = [4 2 1 3];

net = init_network_tcm(param, pres_itemnos);

assert(length(net.f) == 10)
assert(length(net.c) == 10)
assert(norm(net.c) == 1)
assert(isequal(size(net.w_fc_exp), [10 10]))
assert(isequal(size(net.w_fc_pre), [10 10]))
assert(isequal(size(net.w_cf_exp), [10 10]))
assert(isequal(size(net.w_cf_pre), [10 10]))


function test_sem(testCase)

param = testCase.TestData.param;
param.sem_mat = squareform(1:15);
param.Sfc = 0;
param.Scf = 2;
env = struct;
pres_itemnos = [2 6 3 4];

net = init_network_tcm(param, pres_itemnos);

mat = [...
     0    18    12    14     0
    18     0    24    28     0
    12    24     0    20     0
    14    28    20     0     0
     0     0     0     0     0];
assert(isequal(net.w_cf_pre, mat))


function test_distrib(testCase)

param = testCase.TestData.param;
param.Sfc = 1;
param.Scf = 1;
param.sem_vec = reshape(1:60, [10 6]);
for i = 1:size(param.sem_vec, 2)
    param.sem_vec(:,i) = param.sem_vec(:,i) / norm(param.sem_vec(:,i));
end
env = struct;
pres_itemnos = [2 6 3 4];

net = init_network_tcm(param, pres_itemnos);

assert(length(net.f) == 5)
assert(length(net.c) == 11)
assert(norm(net.c) == 1)
assert(isequal(size(net.w_fc_exp), [11 5]))
assert(isequal(size(net.w_fc_pre), [11 5]))
assert(isequal(size(net.w_cf_exp), [5 11]))
assert(isequal(size(net.w_cf_pre), [5 11]))
