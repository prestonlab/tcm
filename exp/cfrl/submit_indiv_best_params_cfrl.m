function job = submit_indiv_best_params_cfrl(experiments, fits, ...
                                             flags, varargin);
%SUBMIT_INDIV_BEST_PARAMS_CFRL   Run simulations for multiple fits.
%
%  job = submit_indiv_best_params_cfrl(experiments, fits, flags, ...)

cluster = getCluster();
cluster.AdditionalProperties.AdditionalSubmitArgs = [' ' flags];

job = createJob(cluster);
for i = 1:length(experiments)
    for j = 1:length(fits)
        task = createTask(job, @run_indiv_best_params_cfrl, 1, ...
                          {experiments{i}, fits{j}, varargin{:}});
    end
end

submit(job);
fprintf('Job submitted.\n');
