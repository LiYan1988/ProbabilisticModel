clc;
clear;
close all;

%% Convert cells to matrices with -1 padding and save to csv
load('templateCellMD.mat')

% demandPathLinks
Ndemands = size(demandPathLinks, 1);
nCols = zeros(Ndemands, 1);
for n = 1:Ndemands
    nCols(n) = length(demandPathLinks{n});
end
colMax = max(nCols);
demandPathLinksMatrix = zeros(Ndemands, colMax);
for n = 1:Ndemands
    demandPathLinksMatrix(n, 1:nCols(n)) = demandPathLinks{n};
end
demandPathLinksMatrix(:, end+1) = nCols;

% demandPaths
nCols = zeros(Ndemands, 1);
for n = 1:Ndemands
    nCols(n) = length(demandPaths{n});
end
colMax = max(nCols);
demandPathsMatrix = zeros(Ndemands, colMax);
for n = 1:Ndemands
    demandPathsMatrix(n, 1:nCols(n)) = demandPaths{n};
end
demandPathsMatrix(:, end+1) = nCols;

% SetOfDemandsOnLink
Nlinks = size(SetOfDemandsOnLink, 1);
nCols = zeros(Nlinks, 1);
for n = 1:Nlinks
    nCols(n) = length(SetOfDemandsOnLink{n});
end
colMax = max(nCols);
SetOfDemandsOnLinkMatrix = zeros(Nlinks, colMax);
for n = 1:Nlinks
    SetOfDemandsOnLinkMatrix(n, 1:nCols(n)) = SetOfDemandsOnLink{n};
end
SetOfDemandsOnLinkMatrix(:, end+1) = nCols;

% SetOfDemandsOnNode
Nnodes = size(SetOfDemandsOnNode, 1);
nCols = zeros(Nnodes, 1);
for n = 1:Nnodes
    nCols(n) = length(SetOfDemandsOnNode{n});
end
colMax = max(nCols);
SetOfDemandsOnNodeMatrix = zeros(Nnodes, colMax);
for n = 1:Nnodes
    SetOfDemandsOnNodeMatrix(n, 1:nCols(n)) = SetOfDemandsOnNode{n};
end
SetOfDemandsOnNodeMatrix(:, end+1) = nCols;

save('CellMatricesMD.mat', 'SetOfDemandsOnLinkMatrix', ...
    'SetOfDemandsOnNodeMatrix', 'demandPathLinksMatrix', ...
    'demandPathsMatrix');