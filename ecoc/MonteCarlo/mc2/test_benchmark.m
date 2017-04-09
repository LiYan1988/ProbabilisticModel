clc;
close all;
clear;

%% topology
% Coronet
coronet = load('CoronetTopology.mat');
networkCostMatrix = coronet.networkCostMatrix;
networkAdjacentMatrix = coronet.networkAdjacentMatrix;
N = size(networkAdjacentMatrix, 1);
se = 4;
bandwidth = 200;
tr = findTR(bandwidth, se);
% tr = 22;

%% All-to-all shortest path based on networkCostMatrix
% ASAPpath = cell(N);
% ASAPcost = zeros(N);
% for s=1:N
%     for t=1:N
%         [ASAPpath{s, t}, ASAPcost(s, t)] = ...
%             dijkstra(networkCostMatrix, s, t);
%     end
% end
% save('CoronetASAP.mat', 'ASAPpath', 'ASAPcost')

%%
% N = size(networkCostMatrix, 1); % number of nodes
% 
% C = 1:N; % candidate nodes
% 
% Asap = graphallshortestpaths(sparse(networkCostMatrix)); % ASAP in #span
% Eadj = Asap<=tr; % adjacent matrix of augment graph
% Ecost = Eadj; % cost matrix of augment graph, in terms of #hops
% P = Eadj; % initial path matrix
% RS = []; % regen sites
% D = graphallshortestpaths(sparse(Eadj)); % D = ASAP(Eadj)
% 
% Rp = []; % R+
% % for i=1:N
% %     tmpAsap = D;
% %     tmpAsap(i, :) = [];
% %     tmpAsap(:, i) = [];
% %     tmpCost = Eadj;
% %     tmpCost(i, :) = [];
% %     tmpCost(:, i) = [];
% %     rmvAsap = graphallshortestpaths(sparse(tmpCost));
% %     if norm(tmpAsap-rmvAsap)>0
% %         Rp(end+1) = i;
% %     end
% % end
% % 
% % C(Rp) = []; % delete R+ from the candidate set
% % for i=1:length(Rp)
% %     P = updateP(P, D, Rp(i));
% % end
% RS = Rp; % initialize the candidate set
% Cd = cell(N, N);
% while sum(P(:))<N*N && length(RS)<N && ~isempty(C)
%     % select cb, the best node
%     r = rank2(P, D);
%     cb = find(r==max(r)); 
%     [P, Cd] = updateP(P, D, cb(1), Cd);
%     % update RS
%     RS(end+1) = cb(1);
%     % update C
%     C(C==cb(1)) = [];
% end
% 
% fprintf('Find %d regen sites.\n', length(RS))
% fprintf('At least %d regen sites.\n', length(Rp))

%%
% min-regen
c_r = 1;
c_m = 0;
[RS1, Cdn1, Cd1, Cn1, paths1, demandCost1] = barebone(networkCostMatrix, tr, c_r, c_m);
fprintf('Min-Regeneration: #RS: %d, #circuit: %d\n', length(RS1), sum(Cn1))

% min-dist
c_r = 0;
c_m = 1;
[RS2, Cdn2, Cd2, Cn2, paths2, demandCost2] = barebone(networkCostMatrix, tr, c_r, c_m);
fprintf('Min-Distance: #RS: %d, #circuit: %d\n', length(RS2), sum(Cn2))

% min-cost
c_r = 1;
c_m = 1;
[RS3, Cdn3, Cd3, Cn3, paths3, demandCost3] = barebone(networkCostMatrix, tr, c_r, c_m);
fprintf('Min-Cost: #RS: %d, #circuit: %d\n', length(RS3), sum(Cn3))

% min-dist-min-regen
c_r = 1;
c_m = 1e6;
[RS4, Cdn4, Cd4, Cn4, paths4, demandCost4] = barebone(networkCostMatrix, tr, c_r, c_m);
fprintf('Min-Distance-Min-Regeneration: #RS: %d, #circuit: %d\n', length(RS4), sum(Cn4))

save('ResultsBH.mat')
