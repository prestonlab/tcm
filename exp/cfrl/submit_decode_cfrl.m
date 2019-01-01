function job = submit_decode_cfrl(experiment, fit, res_name, w, ...
                                  n_workers, overwrite, flags)
%SUBMIT_DECODE_CFRL   Submit jobs to run decoding analysis in parallel.
%
%  job = submit_decode_cfrl(experiment, fit, res_name, w,
%      n_workers, overwrite, flags)

info = get_fit_info_cfrl('local_cat_wikiw2v', 'cfr');
[par, base, ext] = fileparts(info.res_file);

s = load(info.res_file);
n_subj = length(s.stats);

cluster = parallel.cluster.Generic();
cluster.JobStorageLocation = '~/runs';
cluster.IntegrationScriptsLocation = '~/matlab/accre';
cluster.AdditionalProperties.AdditionalSubmitArgs = [' ' flags];

job = createJob(cluster);
for i = 1:n_subj
    outfile = fullfile(par, sprintf('%s_%s_%d.mat', base, res_name, i));
    task = createTask(job, @decode_cfrl, 1, {experiment, fit, res_name, ...
                      w, 'subj_ind', i, 'overwrite', overwrite, ...
                      'n_workers', n_workers});
end

submit(job);
