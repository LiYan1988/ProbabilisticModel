
%Script matlabpool_submit
% This script is an example of submitting a Matlab pool parallel job
% to the fir.itc Linux cluste using the functions solver_large1.m 
% or pclac1.m and either waiting for the output or retrieving output later.

clc
clear all

% Specify cluster confgiuration to use
% This is version dependent, but an older profile can
% be updated with new path information
cluster=parcluster('PBSProProfile_2013b')

% Specify PBS sumbit arguments
cluster.SubmitArguments=...
    '-q nopreempt -l walltime=0:20:00 -m ae -M teh1m@virginia.edu';

% Specify number of nodes, number of cpus, amount of memory
cluster.ResourceTemplate=' -l select=2:ncpus=4:mem=2GB'

% Create matlabpool job and submit to PBS
% Set number of workers corresponding to ResourceTemplate above

% Linear solver on distributed arrays example
mpjob=batch(cluster,@solver_large1,2,{1000},'AdditionalPaths',...
    {'/home/teh1m/matlab/ClassExamples_Fa14'},'matlabpool',8,...
    'CaptureDiary',true)

% Using a parfor loop for independent iterations
% mpjob=batch(cluster,@pcalc,1,{1000},'AdditionalPaths',...
%     {'/home/teh1m/matlab/ClassExamples_Fa14'},'matlabpool',8,...
%     'CaptureDiary',true)


interact=1; % Set flag for interactive or batch submissions

if interact == 1
    
    % for interactive testing, uncomment the following lines
    wait(mpjob)
    
    errmsgs = get(mpjob.Tasks, {'ErrorMessage'})
    nonempty = ~cellfun(@isempty, errmsgs)
    celldisp(errmsgs(nonempty))
    
    results=mpjob.fetchOutputs;
    nonempty = ~cellfun(@isempty, results)
    celldisp(results(nonempty))
    
    % Now that we have the results of the job, we do not need it any more 
    % so we remove it from the queue.
    delete(mpjob)
    
    
else % submit job and save job id to retrieve results with matlab_retieve_13a
    
    % Save job information to retrieve results later
    mpjob_id=mpjob.ID % Store parallel job id to variable pjob_id
    % Saving parallel job id to my_pjob.mat file for later retieval
    save my_pjob mpjob_id 
    
end

