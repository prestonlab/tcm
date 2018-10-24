function decode_cfrl(stats, experiment, fit, outfile)
%DECODE_CFRL   Decode EEG and context.
%
%  decode_cfrl(stats, experiment, fit, outfile)

simdef = sim_def_cfrl(experiment, fit);
load(simdef.data_file);
subjnos = unique(data.subject);
n_subj = length(subjnos);

fprintf('Recording context for best-fitting parameters...')
[subj_data, subj_param, c_pres, c_rec] = indiv_context_cfrl(stats, simdef);

fprintf('Decoding context...')
con_evidence = cell(1, length(subjnos));
pat_file = cell(1, length(subjnos));
for i = 1:n_subj
    con_evidence{i} = decode_context(c_pres{i}, subj_data{i}.pres.category);
    switch experiment
      case 'cfr'
        filename = sprintf('psz_abs_emc_sh_rt_t2_LTP%03d.mat', subjnos(i));
        pat_file{i} = fullfile('~/work/cfr/eeg/study_patterns', filename);
    end
end

fprintf('Decoding EEG...')
eeg_evidence_raw = cell(1, length(subjnos));
parfor i = 1:n_subj
    pat = getfield(load(pat_file{i}, 'pat'), 'pat');
    eeg_evidence_raw{i} = decode_eeg(pat);
end
save(outfile, 'subj_data' 'con_evidence', 'eeg_evidence_raw');

fprintf('Matching up trials...')
eeg_evidence = cell(1, length(subjnos));
for i = 1:n_subj
    eeg_evidence_exp = NaN(size(con_evidence{i}));
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
