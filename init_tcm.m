function init_tcm()
%INIT_TCM   Initialize TCM dependencies.
%
%  init_tcm()

proj_dir = fileparts(mfilename('fullpath'));

% main directories
addpath(fullfile(proj_dir, 'lib', 'parallel'))
addpath(fullfile(proj_dir, 'lib', 'search'))
addpath(fullfile(proj_dir, 'lib', 'tcm'))
addpath(fullfile(proj_dir, 'lib', 'tcm', 'tests'))
addpath(fullfile(proj_dir, 'lib', 'util'))

% compiled binary files
addpath(fullfile(proj_dir, 'src'))

% sample data
addpath(fullfile(proj_dir, 'data'))
