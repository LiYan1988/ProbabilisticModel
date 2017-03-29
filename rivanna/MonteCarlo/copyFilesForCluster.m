clc;
clear;
close all;
rng(321289);
%% define simulation parameters
nArray = 20;
ntotal = 400;

% Monte Carlo parameters
distributionName = 'normal';
p1 = 150; % mean of normal distribution
p2 = 20; % std of normal distribution
ndprob=0.8; % probability of having a demand
ndmax=2; % maximum number of demands a node pair can have
NMonteCarlo = 1000; % number of simulations in one Monte Carlo simulation
Repeat = round(ntotal/nArray); % number of repetitions of the Monte Carlo simulations

% define cluster parameters
nodes = 1;
ntasks_per_task = 1;
cpus_per_task = 4;
mem_per_cpu = 4;
mem_per_cpu_unit = 'G';
nday = 0;
nhrs = 15;
nmin = 0;
nsec = 0;
simulationName = 'd2';
partition = 'economy';
account = 'maite_group';

%% write array jobs
if ~exist(simulationName, 'dir')
    mkdir(simulationName)
end
oldFolder = cd(simulationName);
folderList = dir(oldFolder);
for f=1:length(folderList)
    if ~folderList(f).isdir
        copyfile(fullfile(oldFolder, folderList(f).name), '.');
    end
end
% copyfile(fullfile(oldFolder, '*'), '.');

% copy files for cluster
id = 1;
for arrayId = 1:nArray
    fileName = sprintf('jobArray%d.m', id);
    fid = fopen('template_file.m','r');
    i = 1;
    tline = fgetl(fid);
    A{i} = tline;
    while ischar(tline)
        i = i+1;
        tline = fgetl(fid);
        A{i} = tline;
    end
    fclose(fid);
    % Change cell A
    A{6} = sprintf('simuID = %d;', arrayId);
    A{7} = sprintf('rng(%d);', randi(1e5));
    A{66} = sprintf('distributionName = ''%s'';', distributionName);
    A{67} = sprintf('p1 = %d;', p1);
    A{68} = sprintf('p2 = %d;', p2);
    A{69} = sprintf('ndprob = %.2f;', ndprob);
    A{70} = sprintf('ndmax = %d;', ndmax);
    A{71} = sprintf('NMonteCarlo = %d;', NMonteCarlo);
    A{72} = sprintf('Repeat = %d;', Repeat);
%     A{92} = sprintf('save(''array_workspace_%d.mat'')', id);
    
    % Write cell A into txt
    fid = fopen(fileName, 'w');
    for i = 1:numel(A)
        if A{i+1} == -1
            fprintf(fid,'%s', A{i});
            break
        else
            fprintf(fid,'%s\n', A{i});
        end
    end
    fclose(fid);
    
    id = id+1;
end

%% write slurm
fileName = sprintf('%s.slurm', simulationName);
fid = fopen('template_slurm.slurm','r');
i = 1;
tline = fgetl(fid);
A{i} = tline;
while ischar(tline)
    i = i+1;
    tline = fgetl(fid);
    A{i} = tline;
end
fclose(fid);
% Change cell A
A{2} = sprintf('#SBATCH --nodes=%d', nodes);
A{3} = sprintf('#SBATCH --ntasks-per-node=%d', ntasks_per_task);
A{4} = sprintf('#SBATCH --cpus-per-task=%d', cpus_per_task);
A{5} = sprintf('#SBATCH --mem-per-cpu=%d%s', mem_per_cpu, ...
    mem_per_cpu_unit);
A{6} = sprintf('#SBATCH --time=%d-%d:%d:%d', nday, nhrs, nmin, nsec);
A{7} = sprintf('#SBATCH --output=%s_%%a.stdout', simulationName);
A{8} = sprintf('#SBATCH --error=%s_%%a.stderr', simulationName);
A{9} = sprintf('#SBATCH --partition=%s', partition);
A{10} = sprintf('#SBATCH --account=%s', account);
A{11} = sprintf('#SBATCH --array=1-%d', nArray);
A{15} = sprintf('matlab -nodesktop -r "jobArray${SLURM_ARRAY_TASK_ID};" -logfile %s${SLURM_ARRAY_TASK_ID}', ...
    simulationName);

% Write cell A into txt
fid = fopen(fileName, 'w');
for i = 1:numel(A)
    if A{i+1} == -1
        fprintf(fid,'%s', A{i});
        break
    else
        fprintf(fid,'%s\n', A{i});
    end
end
fclose(fid);

cd(oldFolder);