function logl = logl_mex_tcm(param, data, var_param)
%LOGL_MEX_TCM   Calculate log likelihood for free recall using TCM.
%
%  Similar to tcm_general, but calls C++ code that is much faster
%  (about 18-30X faster, depending on the data and model type). Unlike
%  tcm_general_bin.m, uses a direct interface to C++ that passes data
%  much more quickly. Currently does not support var_param.
%
%  logl = logl_mex_tcm(param, data)
%
%  INPUTS:
%   param:  structure with model parameters. Each field must contain a
%           scalar or a string. 
%
%    data:  free recall data structure, with repeats and intrusions
%           removed. Required fields:
%            recalls
%            pres_itemnos
%    
% var_param: structure with information about parameters that vary
%            by trial, by study event, or by recall event.
%            Required fields:
%             name
%             update_level
%             val
%
%  OUTPUTS:
%      logl:  [lists X recalls] matrix with log likelihood values for
%             all recall events in data.recalls (plus stopping events).

param_vec = param_vec_tcm(param);

% run until we get a non-zero lnL
max_tries = 100;
success = false;
for i = 1:max_tries
    logl = run_tcm(data, param, param_vec);
    if logl ~= 0
        success = true;
        break
    else
        pause(1)
    end
end

if logl == 0
    job_id = getenv('SLURM_JOB_ID');
    error_file = sprintf('~/%s_error.log', job_id);
    mat_file = sprintf('~/%s_dump.mat', job_id);
    fid = fopen(error_file, 'w');
    fprintf(fid, 'Somehow logl is still 0!');
    fclose(fid);
    save(mat_file);
end

if ~success || logl == 0
    % always got 0 for some reason; return a very low value
    logl = -1e10;
end


function logl = run_tcm(data, param, param_vec)

    if isfield(param, 'sem_mat') && ~isempty(param.sem_mat)
        logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                          data.pres_itemnos, param.sem_mat);
    else
        logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec);
    end
