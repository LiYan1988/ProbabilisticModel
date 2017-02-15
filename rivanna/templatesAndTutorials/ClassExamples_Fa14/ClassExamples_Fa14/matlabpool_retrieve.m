
% Script matalbpool_retrieve
% This script is an example of retrieving the results of a previously
% submitted parallel job by loading the saved job id number, in this
% case from the file matlabpool_submit_13b.m.

clc
clear

% reopen the scheduler
cluster=parcluster('PBSProProfile_2013b')

% load job ID and find the job
load my_pjob;
mpjob = findJob(cluster, 'ID', mpjob_id);

% Retrieve any error messages generated
errmsgs = get(mpjob.Tasks, {'ErrorMessage'})
nonempty = ~cellfun(@isempty, errmsgs)
celldisp(errmsgs(nonempty))

% Retrieve any output 
results=mpjob.fetchOutputs;
nonempty = ~cellfun(@isempty, results)
celldisp(results(nonempty))