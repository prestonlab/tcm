function decode_cfrl(stats, experiment, fit, outfile)
%DECODE_CFRL   Decode EEG and context.
%
%  decode_cfrl(stats, experiment, fit, outfile)

simdef = sim_def_cfrl(experiment, fit);
load(simdef.data_file);
subjnos = unique(data.subject);
n_subj = length(subjnos);

if exist(outfile, 'file')
    load(outfile);
end

if ~exist('c_pres', 'var')
    disp('Recording context for best-fitting parameters...')
    [subj_data, subj_param, c_pres, c_rec] = indiv_context_cfrl(stats, simdef);
    save(outfile, 'subj_data', 'subj_param', 'c_pres');
end

pat_file = cell(1, length(subjnos));
for i = 1:n_subj
    switch experiment
      case 'cfr'
        filename = sprintf('psz_abs_emc_sh_rt_t2_LTP%03d.mat', subjnos(i));
        pat_file{i} = fullfile('~/work/cfr/eeg/study_patterns', filename);
    end
end

if ~exist('eeg_evidence_raw', 'var')
    disp('Decoding EEG...')
    eeg_evidence_raw = cell(1, length(subjnos));
    eeg_perf = NaN(1, length(subjnos));
    parfor i = 1:n_subj
        pat = getfield(load(pat_file{i}, 'pat'), 'pat');
        [eeg_evidence_raw{i}, eeg_perf(i)] = decode_eeg(pat);
    end
    save(outfile, 'pat_file', 'eeg_evidence_raw', 'eeg_perf', '-append');
end

if ~exist('eeg_evidence', 'var')
    disp('Matching up trials...')
    eeg_evidence = cell(1, length(subjnos));
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

disp('Decoding context...')
con_evidence = cell(1, length(subjnos));
con_perf = cell(1, length(subjnos));
sigma = NaN(1, length(subjnos));
for i = 1:n_subj
    [con_evidence{i}, con_perf{i}, sigma(i)] = ...
        decode_context_match(c_pres{i}, subj_data{i}.pres.category, ...
                             eeg_perf(i));
end
save(outfile, 'con_evidence', 'con_perf', 'sigma', '-append');