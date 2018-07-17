function tests = test_present_items()
%TEST_PRESENT_ITEMS   Define unit tests for item presentation.
%
%  tests = test_present_items()

tests = functiontests(localfunctions);


function setupOnce(testCase)

param = struct();
param.Afc = 0;
param.Acf = 0;
param.Dfc = 0;
param.Dcf = 0;
param.Lfc = 0.5;
param.Lcf = 1;
param.P1 = 1;
param.P2 = 1;
param.B_enc = 0.6;
param.B_s = 0.3;
testCase.TestData.param = param;


function test_local(testCase)

param = testCase.TestData.param;
pres_itemnos = 1:4;
net = init_network_tcm(param, pres_itemnos);

net = present_items_tcm(net, param);
c = [...
    0.2577
    0.3222
    0.4027
    0.5034
    0.6436];
w_fc_exp = [...
    0.3000    0.2400    0.1920    0.1536         0
         0    0.3000    0.2400    0.1920         0
         0         0    0.3000    0.2400         0
         0         0         0    0.3000         0
    0.4000    0.3200    0.2560    0.2048         0];
w_cf_exp = [...
    1.8000         0         0         0    2.4000
    1.1366    1.4207         0         0    1.5154
    0.8200    1.0250    1.2812         0    1.0933
    0.6297    0.7871    0.9839    1.2299    0.8396
         0         0         0         0         0];

e = 0.0001;

assert(abs(norm(c) - 1) < e);
assert(all(abs(net.c - c) < e));
assert(all(all(abs(net.w_fc_exp - w_fc_exp) < e)));
assert(all(all(abs(net.w_cf_exp - w_cf_exp) < e)));


function test_local_distract(testCase)

param = testCase.TestData.param;
param.B_ipi = 0.1;
param.B_ri = 0.2;
pres_itemnos = 1:2;
net = init_network_tcm(param, pres_itemnos);

net = present_items_tcm(net, param);

c = [...
    0.3677
    0.4619
    0.7878
    0.0490
    0.0616
    0.1571];
w_fc_exp = [...
    0.3000    0.2388         0         0         0         0
         0    0.3000         0         0         0         0
    0.3980    0.3168         0         0         0         0
    0.0400    0.0318         0         0         0         0
         0    0.0400         0         0         0         0
         0         0         0         0         0         0];
w_cf_exp = [...
    1.8000         0    2.3880    0.2400         0         0
    1.1309    1.4207    1.5003    0.1508    0.1894         0
         0         0         0         0         0         0
         0         0         0         0         0         0
         0         0         0         0         0         0
         0         0         0         0         0         0];

e = 0.0001;
assert(abs(norm(c) - 1) < e);
assert(all(abs(net.c - c) < e));
assert(all(all(abs(net.w_fc_exp - w_fc_exp) < e)));
assert(all(all(abs(net.w_cf_exp - w_cf_exp) < e)));


function test_distrib(testCase)

param = testCase.TestData.param;
param.Sfc = 1;
param.Scf = 1;
param.sem_vec = reshape(1:12, [4 3]);
for i = 1:size(param.sem_vec, 2)
    param.sem_vec(:,i) = param.sem_vec(:,i) / norm(param.sem_vec(:,i));
end
pres_itemnos = 1:3;
net = init_network_tcm(param, pres_itemnos);

net = present_items_tcm(net, param);

c = [...    
    0.3400
    0.4051
    0.4703
    0.5354
    0.4610];
w_fc_exp = [...
    0.0548    0.1424    0.1885         0
    0.1095    0.1939    0.2246         0
    0.1643    0.2453    0.2607         0
    0.2191    0.2967    0.2968         0
    0.4000    0.2096    0.0892         0];
w_cf_exp = [...
    0.3286    0.6573    0.9859    1.3145    2.4000
    0.6744    0.9180    1.1616    1.4053    0.9925
    0.8050    0.9592    1.1134    1.2676    0.3811
         0         0         0         0         0];

e = 0.0001;
assert(abs(norm(c) - 1) < e);
assert(all(abs(net.c - c) < e));
assert(all(all(abs(net.w_fc_exp - w_fc_exp) < e)));
assert(all(all(abs(net.w_cf_exp - w_cf_exp) < e)));
