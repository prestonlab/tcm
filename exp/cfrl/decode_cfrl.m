function outfile = decode_cfrl(experiment, fit, res_name, w, varargin)
%DECODE_CFRL   Decode EEG and context.
%
%  outfile = decode_cfrl(experiment, fit, res_name, w, ...)
%
%  INPUTS
%  experiment : char
%      Name of the experiment to process.
%
%  fit : char
%      Name of the model fit to use.
%
%  res_name : char
%      Name of the results. Used in creating the output file.
%
%  w : double
%      Weighting of noise on item features. Item noise will be 
%      w * sigma, while context noise will be sigma.
%
%  OPTIONS
%  subj_ind : numeric array : []
%      Index of the subject to include, within the sorted list of
%      subject numbers. Will create an output file specific to that
%      subject.
%
%  overwrite : boolean : false
%      If true, will overwrite existing output files.

def = struct();
def.subj_ind = [];
def.overwrite = false;
def.n_workers = [];
opt = propval(varargin, def);

if ~isempty(opt.n_workers) && isempty(gcp('nocreate'))
    [pool, cluster] = job_parpool(opt.n_workers);
end

% simulation info
info = get_fit_info_cfrl(fit, experiment);
stats = getfield(load(info.res_file, 'stats'), 'stats');
simdef = sim_def_cfrl(experiment, fit);
load(simdef.data_file);

% output file
[par, base, ext] = fileparts(info.res_file);

% get subject(s) to process
subjnos = unique(data.subject);
if ~isempty(opt.subj_ind)
    subj_ind = opt.subj_ind;
    subjnos = subjnos(subj_ind);
    n_subj = length(subj_ind);
    outfile = fullfile(par, sprintf('%s_%s_%d.mat', base, res_name, subj_ind));
else
    n_subj = length(subjnos);
    subj_ind = 1:n_subj;
    outfile = fullfile(par, sprintf('%s_%s.mat', base, res_name));
end

% load existing results
if exist(outfile, 'file')
    if opt.overwrite
        fprintf('Overwriting existing results in: %s\n', outfile);
        delete(outfile);
    else
        fprintf('Loading existing results from: %s\n', outfile);
        load(outfile);
    end
else
    fprintf('Saving results to: %s\n', outfile);
end

% record context
if ~exist('c', 'var')
    disp('Recording context for best-fitting parameters...')
    [subj_data, subj_param, c, c_in, ic] = ...
        indiv_context_cfrl(stats(subj_ind), simdef);
    save(outfile, 'subj_data', 'subj_param', 'c', 'c_in', 'ic');
end

% decode EEG
pat_file = cell(1, n_subj);
for i = 1:n_subj
    switch experiment
      case 'cfr'
        filename = sprintf('psz_abs_emc_sh_rt_t2_LTP%03d.mat', subjnos(i));
        pat_file{i} = fullfile('~/work/cfr/eeg/study_patterns', filename);
    end
end

if ~exist('eeg_evidence_raw', 'var')
    disp('Decoding EEG...')
    eeg_evidence_raw = cell(1, n_subj);
    eeg_perf = NaN(1, n_subj);
    for i = 1:n_subj
        pat = getfield(load(pat_file{i}, 'pat'), 'pat');
        [eeg_evidence_raw{i}, eeg_perf(i)] = decode_eeg(pat);
    end
    save(outfile, 'pat_file', 'eeg_evidence_raw', 'eeg_perf', '-append');
end

% match EEG to full set of trials
if ~exist('eeg_evidence', 'var')
    disp('Matching up trials...')
    eeg_evidence = cell(1, n_subj);
    for i = 1:n_subj
        n_trial = prod(size(subj_data{i}.pres_itemnos));
        eeg_evidence_exp = NaN(n_trial, 3);
        session = repmat(subj_data{i}.session, [1 24])';
        session = session(:);
        itemno = subj_data{i}.pres_itemnos';
        itemno = itemno(:);
        
        pat = getfield(load(pat_file{i}, 'pat'), 'pat');
        events = pat.dim.ev.mat;
        for j = 1:length(events)
            ind = session == events(j).session & itemno == events(j).itemno;
            if nnz(ind) == 0
                keyboard
            end
            eeg_evidence_exp(ind,:) = eeg_evidence_raw{i}(j,:);
        end
        eeg_evidence{i} = eeg_evidence_exp;
    end
    save(outfile, 'eeg_evidence', '-append');
end

% decode context without added noise
if ~exist('con_evidence_raw', 'var')
    disp('Decoding context...')
    con_evidence_raw = cell(1, n_subj);
    con_perf_raw = cell(1, n_subj);
    for i = 1:n_subj
        [con_evidence_raw{i}, con_perf_raw{i}] = ...
            decode_context(ic.pres{i}, subj_data{i}.pres.category);
    end
    save(outfile, 'con_evidence_raw', 'con_perf_raw', '-append');
end

% decode context with matched noise
if ~exist('con_evidence', 'var')
    disp('Decoding context with matched noise...')
    con_evidence_rep = cell(1, n_subj);
    con_evidence = cell(1, n_subj);
    con_perf = cell(1, n_subj);
    sigma = NaN(1, n_subj);
    for i = 1:n_subj
        [con_evidence_rep{i}, con_perf{i}, sigma(i)] = ...
            decode_context_match(ic.pres{i}, subj_data{i}.pres.category, ...
                                 eeg_perf(i), w);
        con_evidence{i} = mean(con_evidence_rep{i}, 3);        
    end
    save(outfile, 'con_evidence_rep', 'con_evidence', ...
         'con_perf', 'sigma', '-append');
end
