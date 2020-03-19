function data = fetchInputs(job)
%fetchInputs  Retrieve input arguments from all tasks in a job
%    data = fetchInputs(job) returns data, the input arguments
%    contained in the tasks of a finished job. If the scalar job has M
%    tasks, each row of the M-by-N cell array data contains the input
%    arguments for the corresponding task in the job.

n_task = length(job.Tasks);
n_input = length(job.Tasks(1).InputArguments);

data = cell(n_task, n_input);
for i = 1:n_task
    data(i,:) = job.Tasks(i).InputArguments;
end
