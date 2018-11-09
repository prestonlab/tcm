function logl = logl_mex_tcm(param, data)
%LOGL_MEX_TCM   Calculate log likelihood for free recall using TCM.
%
%  Calculates log likelihood for multiple lists. param and data are
%  assumed to be pre-processed, including setting defaults for
%  missing parameters, etc.
%
%  Similar to logl_tcm, but calls C++ code that is much faster
%  (about 10-30X faster, depending on the data and model type).
%
%  logl = logl_mex_tcm(param, data)
%
%  INPUTS
%  param - struct
%      Structure with model parameters. See check_param_tcm for details.
%
%  data - frdata struct
%      Standard free recall data structure. Must have repeats and
%      intrusions removed. Required fields:
%      recalls_vec - [1 x recall events] numeric array
%          Serial position of each recalled item. Stop events
%          should be coded as list length + 1. See recalls_vec_tcm.
%
%      pres_itemnos - [lists x input position] numeric array
%          Number of each presented item. If modeling semantic
%          similarity, indicates the position of each item in the
%          semantic matrix.
%
%  OUTPUTS
%  logl - [lists x recall events] numeric array
%      Log likelihood for all recall events in data.recalls, plus
%      stopping events.

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
        issem = true;
    else
        issem = false;
    end
    if isfield(param, 'pre_vec') && ~isempty(param.pre_vec)
        isvec = true;
    else
        isvec = false;
    end
    
    if issem && ~isvec
        logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                          1, data.pres_itemnos, param.sem_mat);
    elseif isvec && ~issem
        logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                          2, data.pres_itemnos, param.pre_vec);
    elseif isvec && issem
        logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                          3, data.pres_itemnos, param.pre_vec, ...
                          param.sem_mat);
    else
        logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec);
    end
