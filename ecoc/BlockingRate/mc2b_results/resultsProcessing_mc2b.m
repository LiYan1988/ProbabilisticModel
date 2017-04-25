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

%%
% load routing
templateDataStruct = load('../../templateDemandStruct.mat');
DemandStructMD = templateDataStruct.DemandStructMD;
N = 75;
pathOnNode = zeros(N, 1);
for i=1:N
    pathOnNode(i) = length(DemandStructMD.SetOfDemandsOnNode{i});
end

pathOnNode = pathOnNode-2;
NodeProbRO = pathOnNode./sum(pathOnNode);
[NodeProbROSorted, NodeProbROSortedIdx] = sort(NodeProbRO, 'descend');
clear DemandStructMD i newFolderName templateDataStruct
cd('..')
save('ExtractedData.mat')
save('NodeProbIdxBenchmark.mat', 'NodeProbROSortedIdx')
%%
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,'YGrid','on','XGrid','on','YMinorTick','on',...
    'YScale','log');
box(axes1,'on');
hold(axes1,'on');

% Create multiple lines using matrix input to semilogy
x = linspace(0, 1, 5550);
BlockHistoryAve = [BlockHistoryAve(:, 3), BlockHistoryAve(:, 2), BlockHistoryAve(:, 1)];
semilogy1 = semilogy(BlockHistoryAve,'Parent',axes1, 'linewidth', 1);
set(semilogy1(1),'DisplayName','RS based', 'linestyle', '-.');
set(semilogy1(2),'DisplayName','RC based', 'linestyle', '--');
set(semilogy1(3),'DisplayName','Benchmark$^2$', 'linestyle', '-');
h = legend('show', 'location', 'east');
h.Interpreter = 'latex';
xlabel('Relative traffic load')
ylabel('Blocking Probability')
set(gca, 'ytick', [1e-6, 1e-4, 1e-2, 1e0])
set(gca, 'xtick', [0, 0.2, 0.4, 0.6, 0.8, 1])
%
set(gca,'yticklabel',[], 'xticklabel', []) %Remove tick labels
% Get tick mark positions
yTicks = get(gca,'ytick');
xTicks = get(gca, 'xtick');
ax = axis; %Get left most x-position
HorizontalOffset = 0.01;
% Reset the ytick labels in desired font
for i = 1:length(yTicks)
%Create text box and set appropriate properties
     text(ax(1) - HorizontalOffset,yTicks(i),['10$^{' num2str(log10(yTicks(i))) '}$'],...
         'HorizontalAlignment','Right','interpreter', 'latex', ...
         'fontsize', 14);   
end
% Reset the xtick labels in desired font 
minY = min(yTicks);
verticalOffset = 7e-7;
for xx = 1:length(xTicks)
%Create text box and set appropriate properties
     text(xTicks(xx)+0.01, minY - verticalOffset, ['$' num2str( xTicks(xx)) '$'],...
         'HorizontalAlignment','Right','interpreter', 'latex', ...
         'fontsize', 14);   
end

%
xlabel('Relative traffic load', 'interpreter', 'latex', ...
    'Position', [0.5 2e-7 0], 'fontsize', 16);
ylabel('Blocking probability', 'interpreter', 'latex', 'Position', ...
    [-0.09 1e-3 0], 'fontsize', 16);

set(gca, 'plotboxaspectratio', [7, 3, 1])

filename = sprintf('blockingPlot1.fig');
savefig(filename)
filename = sprintf('blockingPlot1.pdf');

rez=600; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(f, filename,'-dpdf') %save file 