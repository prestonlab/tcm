function init_tcm()
%INIT_TCM   Initialize TCM dependencies.
%
%  init_tcm()

proj_dir = fileparts(mfilename('fullpath'));

% main directories
addpath(fullfile(proj_dir, 'parallel'))
addpath(fullfile(proj_dir, 'search'))
addpath(fullfile(proj_dir, 'tcm'))
addpath(fullfile(proj_dir, 'tcm', 'tests'))
addpath(fullfile(proj_dir, 'src'))
addpath(fullfile(proj_dir, 'util'))

% experiments
addpath(fullfile(proj_dir, 'exp', 'cfrl'))
addpath(fullfile(proj_dir, 'exp', 'cfrl', 'data'))
