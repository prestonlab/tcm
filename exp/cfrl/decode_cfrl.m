function outfile = decode_cfrl(experiment, fit, res_name, w)
%DECODE_CFRL   Decode EEG and context.
%
%  outfile = decode_cfrl(stats, experiment, fit, res_name, w)

info = get_fit_info_cfrl('local_cat_wikiw2v', 'cfr');
[par, base, ext] = fileparts(info.res_file);
outfile = fullfile(par, sprintf('%s_%s.mat', base, res_name));

stats = getfield(load(info.res_file, 'stats'), 'stats');
simdef = sim_def_cfrl(experiment, fit);
load(simdef.data_file);
subjnos = unique(data.subject);
n_subj = length(subjnos);

if exist(outfile, 'file')
    load(outfile);
end

if ~exist('c', 'var')
    disp('Recording context for best-fitting parameters...')
    [subj_data, subj_param, c, c_in, ic] = ...
        indiv_context_cfrl(stats(1:n_subj), simdef);
    save(outfile, 'subj_data', 'subj_param', 'c', 'c_in', 'ic');
end

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
