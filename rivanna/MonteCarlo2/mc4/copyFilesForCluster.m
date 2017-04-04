clc;
clear;
close all;
rng(321289);
%% define simulation parameters
% system parameters
modulationFormat = 'PM_16QAM';
Cmax = 10;
CircuitWeight = 0.05;
RegenWeight = 1;
outageProb = 0.01;

% simulation parameters
nArray = 200; % how many array jobs
ntotal = 800; % #of different demands
distributionName = 'normal';
p1 = 150; % mean of normal distribution
p2 = 20; % std of normal distribution
ndprob=0.8; % probability of having a demand
ndmax=2; % maximum number of demands a node pair can have
NMonteCarlo = 1000; % number of simulations in one Monte Carlo simulation
Repeat = round(ntotal/nArray); % number of different total demands per job
Nbins = 65;
Mbins = 50;
Sbins = 15;

% define cluster parameters
nodes = 1;
ntasks_per_task = 1;
cpus_per_task = 1;
mem_per_cpu = 4;
mem_per_cpu_unit = 'G';
nday = 0;
nhrs = 15;
nmin = 0;
nsec = 0;
simulationName = 'mc4';
partition = 'economy';
account = 'maite_group';
matlabVersion = 'R2015a';

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
    A{37} = sprintf('systemParameters.modulationFormat = ''%s'';', ...
        modulationFormat);
    A{38} = sprintf('systemParameters.Cmax = %d;', Cmax);
    A{39} = sprintf('systemParameters.CircuitWeight = %.2f;', ...
        CircuitWeight);
    A{40} = sprintf('systemParameters.RegenWeight = %.2f;', ...
        RegenWeight);
    A{41} = sprintf('systemParameters.outageProb = %.2f;', ...
        outageProb);
    A{79} = sprintf('distributionName = ''%s'';', distributionName);
    A{80} = sprintf('p1 = %d;', p1);
    A{81} = sprintf('p2 = %d;', p2);
    A{82} = sprintf('ndprob = %.2f;', ndprob);
    A{83} = sprintf('ndmax = %d;', ndmax);
    A{84} = sprintf('NMonteCarlo = %d;', NMonteCarlo);
    A{85} = sprintf('Repeat = %d;', Repeat);
    A{86} = sprintf('Nbins = %d;', Nbins);
    A{87} = sprintf('Mbins = %d;', Mbins);
    A{88} = sprintf('Sbins = %d;', Sbins);
    
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
A{13} = sprintf('module load matlab/%s gurobi/6.5.1', matlabVersion);
A{15} = sprintf('matlab -nodesktop -nojvm -noFigureWindows -nosplash -nodisplay -r "jobArray${SLURM_ARRAY_TASK_ID};" -logfile %s${SLURM_ARRAY_TASK_ID}', ...
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