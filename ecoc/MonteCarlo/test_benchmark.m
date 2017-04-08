clc;
close all;
clear;

%% topology
% Coronet
coronet = load('CoronetTopology.mat');
networkCostMatrix = coronet.networkCostMatrix;
networkAdjacentMatrix = coronet.networkAdjacentMatrix;

se = 4;
bandwidth = 200;
tr = findTR(bandwidth, se);
tr = 22;
%%
N = size(networkCostMatrix, 1); % number of nodes

C = 1:N; % candidate nodes

Asap = graphallshortestpaths(sparse(networkCostMatrix)); % ASAP in #span
Eadj = Asap<=tr; % adjacent matrix of augment graph
Ecost = Eadj; % cost matrix of augment graph, in terms of #hops
P = Eadj; % initial path matrix
RS = []; % regen sites
D = graphallshortestpaths(sparse(Eadj)); % D = ASAP(Eadj)

Rp = []; % R+
for i=1:N
    tmpAsap = D;
    tmpAsap(i, :) = [];
    tmpAsap(:, i) = [];
    tmpCost = Eadj;
    tmpCost(i, :) = [];
    tmpCost(:, i) = [];
    rmvAsap = graphallshortestpaths(sparse(tmpCost));
    if norm(tmpAsap-rmvAsap)>0
        Rp(end+1) = i;
    end
end

C(Rp) = []; % delete R+ from the candidate set
for i=1:length(Rp)
    P = updateP(P, D, Rp(i));
end
RS = Rp; % initialize the candidate set

while sum(P(:))<N*N && length(RS)<N && ~isempty(C)
    % select cb, the best node
    r = rank2(P, D);
    cb = find(r==max(r)); 
    P = updateP(P, D, cb(1));
    % update RS
    RS(end+1) = cb(1);
    % update C
    C(C==cb(1)) = [];
end

fprintf('Find %d regen sites.\n', length(RS))
fprintf('At least %d regen sites.\n', length(Rp))

%%
c_r = 1;
c_m = 0;
[RS1] = barebone(networkCostMatrix, tr, c_r, c_m);
fprintf('Min-Regeneration: %d\n', length(RS1))

c_r = 0;
c_m = 1;
RS2 = barebone(networkCostMatrix, tr, c_r, c_m);
fprintf('Min-Distance: %d\n', length(RS2))

c_r = 1;
c_m = 1;
RS3 = barebone(networkCostMatrix, tr, c_r, c_m);
fprintf('Min-Cost: %d\n', length(RS3))

c_r = 1;
c_m = 1000;
RS4 = barebone(networkCostMatrix, tr, c_r, c_m);
fprintf('Min-Distance-Min-Regeneration: %d\n', length(RS4))