function out = fetchOutputsRobust(job)
%FETCHOUTPUTSROBUST   Load job outputs, even if some tasks failed.
%
%  out = fetchOutputsRobust(job)
%
%  INPUTS
%  job - job
%      job object used for job submission
%
%  OUTPUTS
%  out - [tasks x 1] cell array
%      Output arguments from each task. Output j of task i is
%      in out{i}{j}. If a task failed, each output cell for that
%      task will be empty.

n_out = job.Tasks(1).NumOutputArguments;

try
    out = fetchOutputs(job);
catch
    out = {};
    for i = 1:length(job.Tasks)
        out_task = job.Tasks(i).OutputArguments;
        if isempty(out_task)
            out = [out; cell(1, n_out)];
            continue
        end
        out = [out; out_task];
    end
end
