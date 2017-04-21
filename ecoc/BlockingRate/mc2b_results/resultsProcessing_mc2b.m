clc;
clear;
close all;

%% Change names and move to new folder
newFolderName = 'mc2b0';
dataDirs = {'mc2b_bm', 'mc2b_p1', 'mc2b_p2'};

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
        num = str2num(num{1});
        newName = sprintf('../mc2b0/BP_%s_%d.mat', dataDirs{dirIdx}, num);
        copyfile(name, newName);
    end
    cd(oldFolder);
end

%% 
cd(newFolderName);