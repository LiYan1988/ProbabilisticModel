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
% tr = 22;
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
% for i=1:N
%     tmpAsap = D;
%     tmpAsap(i, :) = [];
%     tmpAsap(:, i) = [];
%     tmpCost = Eadj;
%     tmpCost(i, :) = [];
%     tmpCost(:, i) = [];
%     rmvAsap = graphallshortestpaths(sparse(tmpCost));
%     if norm(tmpAsap-rmvAsap)>0
%         Rp(end+1) = i;
%     end
% end
% 
% C(Rp) = []; % delete R+ from the candidate set
% for i=1:length(Rp)
%     P = updateP(P, D, Rp(i));
% end
RS = Rp; % initialize the candidate set
Cd = zeros(N^2, N);
while sum(P(:))<N*N && length(RS)<N && ~isempty(C)
    % select cb, the best node
    r = rank2(P, D);
    cb = find(r==max(r)); 
    [P, Cd] = updateP(P, D, cb(1), Cd);
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
[RS1, Rp1, Ctot1, cost1, paths1, D1] = barebone(networkCostMatrix, tr, c_r, c_m);
% fprintf('Min-Regeneration: %d\n', length(RS1))
fprintf('Min-Regeneration: #RS: %d, #Rp: %d, #circuit: %d\n', length(RS1), ...
    length(Rp1), sum(Ctot1(:)))

c_r = 0;
c_m = 1;
[RS2, Rp2, Ctot2, cost2, paths2, D2] = barebone(networkCostMatrix, tr, c_r, c_m);
fprintf('Min-Distance: #RS: %d, #Rp: %d, #circuit: %d\n', length(RS2), ...
    length(Rp2), sum(Ctot2(:)))

c_r = 1;
c_m = 1;
[RS3, Rp3, Ctot3, cost3, paths3, D3] = barebone(networkCostMatrix, tr, c_r, c_m);
% fprintf('Min-Cost: %d\n', length(RS3))
fprintf('Min-Cost: #RS: %d, #Rp: %d, #circuit: %d\n', length(RS3), ...
    length(Rp3), sum(Ctot3(:)))

c_r = 1;
c_m = 1000;
[RS4, Rp4, Ctot4, cost4, paths4, D4] = barebone(networkCostMatrix, tr, c_r, c_m);
% fprintf('Min-Distance-Min-Regeneratio n: %d\n', length(RS4))
fprintf('Min-Distance-Min-Regeneration: #RS: %d, #Rp: %d, #circuit: %d\n', length(RS4), ...
    length(Rp4), sum(Ctot4(:)))

save('ResultsBH.mat')
%%
% [~, Csort] = sort(sum(Ctot1, 1), 'descend');
% Csort = Csort(1:length(RS1));