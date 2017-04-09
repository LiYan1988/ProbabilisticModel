clc;
close all;
clear;

%% 
load('templateDemandStruct.mat')

coronet = load('CoronetTopology.mat');
networkCostMatrix = coronet.networkCostMatrix;
networkAdjacentMatrix = coronet.networkAdjacentMatrix;
N = size(networkCostMatrix, 1);
tr = 26;
paths = DemandStruct.demandPaths;

RS = [];
n = 1;
for s=1:N
    for t=s+1:N
        path = paths{n};
        dist = networkCostMatrix(path(1), path(2));
        for i=2:length(paths{n})-1
            if dist+networkCostMatrix(path(i), path(i+1))>tr
                if ~ismember(path(i), RS)
                    RS(end+1) = path(i);
                end
                dist = networkCostMatrix(path(i), path(i+1));
            else
                dist = dist+networkCostMatrix(path(i), path(i+1));
            end
        end
        n = n+1;
    end
end
