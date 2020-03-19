function result = run_tests_tcm()
%RUN_TESTS_TCM   Run a suite of unit tests for TCM code.
%
%  Will run all tests in this directory and return results.
%
%  result = run_tests_tcm()
%
%  OUTPUTS
%  result - TestResult array
%      Results from each individual unit test. Use table(result) to
%      show a summary.

d = fileparts(mfilename('fullpath'));

import matlab.unittest.TestSuite;
suite = TestSuite.fromFolder(d);
result = run(suite);
