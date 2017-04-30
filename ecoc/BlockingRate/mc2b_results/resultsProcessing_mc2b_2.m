clc;
clear;
close all;

% %% Change names and move to new folder
% newFolderName = 'mc2b0';
% dataDirs = {'mc2b_bm', 'mc2b_p1', 'mc2b_p2'};
% NArray = 10;
% NMonteCarlo = 40;
% NDemands = 5550;
% 
% if ~exist(newFolderName, 'dir')
%     mkdir(newFolderName)
% end
% 
% for dirIdx = 1:length(dataDirs)
%     oldFolder = cd(dataDirs{dirIdx});
%     fprintf('Old folder: %s\n', oldFolder)
%     fprintf('New folder: %s\n', pwd);
%     lists = dir();
%     for i = 1:length(lists)
%         if lists(i).isdir
%             continue
%         end
%         name = lists(i).name;
%         num = strsplit(name, '_');
%         num = strsplit(num{2}, '.');
%         num = str2double(num{1});
%         newName = sprintf('../mc2b0/BP_%s_%d.mat', dataDirs{dirIdx}, num);
%         copyfile(name, newName);
%     end
%     cd(oldFolder);
% end
% 
% %% Extract useful data
% cd(newFolderName);
% BlockHistory = zeros(NDemands, NMonteCarlo*NArray, length(dataDirs));
% for dirIdx = 1:length(dataDirs)
%     for num=1:NArray
%         matName = sprintf('../mc2b0/BP_%s_%d.mat', dataDirs{dirIdx}, num);
%         tmp = load(matName);
%         BlockHistory(:, (num-1)*NMonteCarlo+1:num*NMonteCarlo, dirIdx) = ...
%             tmp.blockHistory;
%     end
% end
% cd(oldFolder);
% clear dirIdx i lists matName name newName num oldFolder tmp
% 
% save('BlockHistory.mat')

%% 
load('BlockHistory.mat')
nd = zeros(400, 3, 4);
bp = [0.005, 0.01, 0.02, 0.04];
for s=1:4
    for t=1:3
        tmp = bp(s);
        parfor m=1:400
            nd(m, t, s) = find(BlockHistory(:, m, t)<tmp, 1, 'last');
        end
    end
end

for s=1:4
    for m=1:400
        nd(m, 2, s) = nd(m, 2, s)/nd(m, 1, s)-1;
        nd(m, 3, s) = nd(m, 3, s)/nd(m, 1, s)-1;
    end
end

gainstd = zeros(4, 2);
for s=1:4
    for t=1:2
        gainstd(s, t) = std(nd(:, t+1, s));
    end
end
gainstd = gainstd*1.645/20; % 90% confidence interval