function files = get_exp_info_cfrl(experiment, check)
%GET_EXP_INFO_CFRL   Get files needed to run a simulation of an experiment.
%
%  files = get_exp_info_cfrl(experiment)

if nargin < 2
    check = false;
end

proj_dir = fileparts(mfilename('fullpath'));

sem_exp = experiment;
switch experiment
  case 'cfr'
    files.res_dir = '~/work/cfr';
    files.model_dir = '~/work/cfr/tcm';
    files.data_dir = fullfile(proj_dir, 'data');
    files.data = fullfile(files.data_dir, 'cfr_eeg_mixed_data_clean.mat');
    files.data_raw = fullfile(files.data_dir, 'cfr_eeg_mixed_data.mat');
    files.pool = fullfile(files.data_dir, 'cfr_pool.mat');
  case 'cdcfr2'
    % full dataset
    files.res_dir = '~/work/cdcfr2';
    files.model_dir = '~/work/cdcfr2/tcm';
    files.data_dir = fullfile(proj_dir, 'data');
    files.data = fullfile(files.data_dir, 'cdcfr2_data_clean.mat');
    files.data_raw = fullfile(files.data_dir, 'cdcfr2_data.mat');
    files.pool = fullfile(files.data_dir, 'cdcfr2_pool.mat');
  case {'cdcfr2-d0' 'cdcfr2-d1' 'cdcfr2-d2'}
    % one distractor condition at a time
    c = regexp(experiment, '-', 'split');
    distract = c{2};
    files.res_dir = fullfile('~/work', experiment);
    files.model_dir = fullfile('~/work', experiment, 'tcm');
    files.data_dir = fullfile(proj_dir, 'data');
    datafile = sprintf('cdcfr2_data_clean_%s.mat', distract);
    files.data = fullfile(files.data_dir, datafile);
    files.data_raw = fullfile(files.data_dir, 'cdcfr2_data.mat');
    files.pool = fullfile(files.data_dir, 'cdcfr2_pool.mat');
    sem_exp = 'cdcfr2';
  case 'cdcfr2-1'
    files.res_dir = '~/work/cdcfr2-1';
    files.model_dir = '~/work/cdcfr2-1/tcm';
    files.data_dir = fullfile(proj_dir, 'data');
    files.data = fullfile(files.data_dir, 'cdcfr2_data_clean_s1.mat');
    files.data_raw = fullfile(files.data_dir, 'cdcfr2_data.mat');
    files.pool = fullfile(files.data_dir, 'cdcfr2_pool.mat');
    sem_exp = 'cdcfr2';
  case 'cdcfr2-2'
    files.res_dir = '~/work/cdcfr2-2';
    files.model_dir = '~/work/cdcfr2-2/tcm';
    files.data_dir = fullfile(proj_dir, 'data');
    files.data = fullfile(files.data_dir, 'cdcfr2_data_clean_s2.mat');
    files.data_raw = fullfile(files.data_dir, 'cdcfr2_data.mat');
    files.pool = fullfile(files.data_dir, 'cdcfr2_pool.mat');
    sem_exp = 'cdcfr2';
  otherwise
    error('Unknown experiment: %s.', experiment)
end

sem_models = {'wikiw2v'};
names = {'wikiw2v'};
for i = 1:length(sem_models)
    f_base = sem_models{i};
    f_raw = [sem_models{i} '_raw'];
    f_bin = [sem_models{i} '_bin'];
    s.name = names{i};
    s.mat = fullfile(files.data_dir, ...
                     sprintf('%s_%s.mat', sem_exp, sem_models{i}));
    s.raw = fullfile(files.data_dir, ...
                     sprintf('%s_%s_raw.mat', sem_exp, sem_models{i}));
    s.bin = fullfile(files.data_dir, ...
                     sprintf('%s_%s_bin.mat', sem_exp, sem_models{i}));
    files.(sem_models{i}) = s;
end

if check
    check_paths(files);
end


function check_paths(files)

f = fieldnames(files);
for i = 1:length(f)
    if strcmp(f{i}, 'name')
        continue
    end
    
    if isstruct(files.(f{i}))
        check_paths(files.(f{i}))
    elseif exist(files.(f{i})) < 2
        fprintf('Warning: path does not exist: %s\n', files.(f{i}));
    end
end