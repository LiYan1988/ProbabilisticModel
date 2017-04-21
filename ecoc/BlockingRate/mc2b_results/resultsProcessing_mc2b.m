clc;
clear;
close all;

%% Change names and move to new folder
newFolderName = 'mc2b0';
dataDirs = {'mc2b_bm', 'mc2b_p1', 'mc2b_p2'};
NArray = 10;
NMonteCarlo = 40;
NDemands = 5550;

if ~exist(newFolderName, 'dir')
    mkdir(newFolderName)
end

for dirIdx = 1:length(dataDirs)
    oldFolder = cd(dataDirs{dirIdx});
    fprintf('Old folder: %s\n', oldFolder)
    fprintf('New folder: %s\n', pwd);
    lists = dir();
    for i = 1:length(lists)
        if lists(i).isdir
            continue
        end
        name = lists(i).name;
        num = strsplit(name, '_');
        num = strsplit(num{2}, '.');
        num = str2double(num{1});
        newName = sprintf('../mc2b0/BP_%s_%d.mat', dataDirs{dirIdx}, num);
        copyfile(name, newName);
    end
    cd(oldFolder);
end

%% Extract useful data
cd(newFolderName);
BlockHistory = zeros(NDemands, NMonteCarlo*NArray, length(dataDirs));
for dirIdx = 1:length(dataDirs)
    for num=1:NArray
        matName = sprintf('../mc2b0/BP_%s_%d.mat', dataDirs{dirIdx}, num);
        tmp = load(matName);
        BlockHistory(:, (num-1)*NMonteCarlo+1:num*NMonteCarlo, dirIdx) = ...
            tmp.blockHistory;
    end
end
BlockHistoryAve = squeeze(mean(BlockHistory, 2));
clear dirIdx i lists matName name newName num oldFolder tmp
save('ExtractedData.mat')

%%
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,'YGrid','on','XGrid','on','YMinorTick','on',...
    'YScale','log');
box(axes1,'on');
hold(axes1,'on');

% Create multiple lines using matrix input to semilogy
semilogy1 = semilogy(BlockHistoryAve,'Parent',axes1);
set(semilogy1(1),'DisplayName','Benchmark');
set(semilogy1(2),'DisplayName','Rank by #RS');
set(semilogy1(3),'DisplayName','Rank by #circuit');

legend('show', 'location', 'best')
xlabel('Number of demands')
ylabel('Blocking Probability')