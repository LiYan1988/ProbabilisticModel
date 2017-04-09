clc;
close all;
clear;

%% Load template and fixed routings
% load('templateDemandStruct.mat')
% 
% coronet = load('CoronetTopology.mat');
% networkCostMatrix = coronet.networkCostMatrix;
% networkAdjacentMatrix = coronet.networkAdjacentMatrix;
% N = size(networkCostMatrix, 1);
% 
% r = load('ResultsBH.mat');

%% Verify shortest path routing
% Paths = r.paths2;
% D = graphallshortestpaths(sparse(networkCostMatrix));
% D2 = zeros(N, N);
% for s=1:N
%     for t=s+1:N
%         path = Paths{s, t};
%         d = 0;
%         for n=1:length(path)-1
%             d = d+networkCostMatrix(path(n), path(n+1));
%         end
%         D2(s, t) = d;
%     end
% end
% D2 = D2+D2';
% fprintf('%.2f\n', norm(D-D2))

%% Create new demand 
% Define topology
% Coronet network
coronet = load('CoronetTopology.mat');
NetworkCost = coronet.networkCostMatrix;

NNodes = size(NetworkCost, 1);
NodeList = 1:NNodes;
NetworkConnectivity = 1-isinf(NetworkCost);
tmpNetworkCost = NetworkConnectivity.*NetworkCost;
tmpNetworkCost(isnan(tmpNetworkCost)) = 0;
[i, j, s] = find(tmpNetworkCost);
LinkList = [i, j];
NLinks = size(LinkList, 1);
LinkListIDs = (1:NLinks)';
LinkLengths = s;

LinksTable = table(LinkListIDs, LinkList(:, 1), LinkList(:, 2), ...
    LinkLengths, 'variablenames', {'LinkID', 'Source', 'Destination', ...
    'LinkLength'});

TopologyStruct = struct();
TopologyStruct.NodeList = NodeList;
TopologyStruct.NNodes = NNodes;
TopologyStruct.NetworkCost = NetworkCost;
TopologyStruct.NetworkConnectivity = NetworkConnectivity;
TopologyStruct.LinkList = LinkList;
TopologyStruct.NLinks = NLinks;
TopologyStruct.LinkListIDs = LinkListIDs;
TopologyStruct.LinkLengths = LinkLengths;
TopologyStruct.LinksTable = LinksTable;

% Generate traffic demands
%####################################################################
Ndemands = 2; % don't need to change
distributionName = 'normal';
p1 = 200;
p2 = 50;
ndprob=1;
ndmax=1;
a2aFlag = true;

routingNames = {'dijstra', 'min-gen', 'min-dist', 'min-cost', 'mdmr'};

% fixRouting = 1;
% DemandStructMG = createTrafficDemands(TopologyStruct, ...
%    Ndemands, p1, p2, distributionName, ndprob, ndmax, a2aFlag, fixRouting);

fixRouting = 2;
DemandStructMD = createTrafficDemands(TopologyStruct, ...
   Ndemands, p1, p2, distributionName, ndprob, ndmax, a2aFlag, fixRouting);

fixRouting = 3;
DemandStructMC = createTrafficDemands(TopologyStruct, ...
   Ndemands, p1, p2, distributionName, ndprob, ndmax, a2aFlag, fixRouting);

fixRouting = 4;
DemandStructMDMR = createTrafficDemands(TopologyStruct, ...
   Ndemands, p1, p2, distributionName, ndprob, ndmax, a2aFlag, fixRouting);

save('templateDemandStruct.mat', 'DemandStructMG', 'DemandStructMD', ...
    'DemandStructMC', 'DemandStructMDMR');
