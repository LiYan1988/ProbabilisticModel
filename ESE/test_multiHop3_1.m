% test the multi hop scenario
% for all the simulations, the number of channels on each link is fixed,
% and then compared with the single link case

clc;
clear;
close all;

rng(312);

%% Define fiber parameters
alpha = 0.22; % dB/km, attenuation of fiber, NOTE: alpha is positive!
alpha = alpha*1e-4*log(10); % 1/m
L = 100e3; % m, length of one span
h = 6.626e-34; % J*s, Plank's constant
niu = 193.548e12; % Hz, frequency of lightwave at 1550 nm
nsp = 10^(5.5/10)/2; % spontaneous emission factor
Nase = (exp(alpha*L)-1)*h*niu*nsp; % ASE per polarization per span
% W/Hz, signal side ASE noise spectral density
gamma = 1.32e-3; % 1/(W*m), nonlinear parameter
% gamma = 0;
beta = -2.1668e-26; % s^2/m, GVD parameter, D = 18 ps/(nm*km),
% beta = -D*lambda^2/(2*pi*c)
beta = abs(beta); % the absolute value is used in calculation

systemParameters = struct();
systemParameters.alpha = alpha;
systemParameters.beta = beta;
systemParameters.gamma = gamma;
systemParameters.Nase = Nase;
systemParameters.gb = 10; % the guardband

%% topology
NodeList = [1; 2; 3; 4];
NNodes = length(NodeList);
NetworkCost = [[inf, 10, inf, inf]; [10, inf, 20, inf]; ...
    [inf, 20, inf, 10]; [inf, inf, 10, inf]]; % unit is the number of spans
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

%% load traffic demands
% load('data/multiHop2_input.mat')

%% or generate traffic demands
dPairs = [repmat([1, 2], 3, 1); repmat([1, 3], 3, 1); ...
    repmat([1, 4], 3, 1); repmat([2, 3], 3, 1); repmat([2, 4], 3, 1); ...
    repmat([3, 4], 3, 1)];
Ndemands = size(dPairs, 1);
Nsimu = 1e5;
rnds = randi([1, 1e6], [Nsimu, 1]);
for n=1:Nsimu
    %     tmp = createTrafficDemands(TopologyStruct, Ndemands, rnds(n));
    tmp = createFixedTrafficDemands(TopologyStruct, dPairs, rnds(n));
    if n==1
        DemandStruct = tmp;
        
    else
        DemandStruct(end+1) = tmp;
    end
    if mod(n, 1000)==0
        fprintf('Demand %d is created.\n', n);
    end
end
save('data/multiHop3_input_1e5simulations.mat')

%% calculate noise based on bandwidths
demandsBandwidthsTR = zeros(Ndemands, Nsimu);

tic;
for k=1:Nsimu
    [demandsBandwidthsTR(:, k)] = solveBWNetworkInitialize(TopologyStruct, ...
        DemandStruct(k), systemParameters);
    if mod(k, 1000)==0
        fprintf('Simulation %d is done.\n', k);
    end
end
runtime = toc;
save('data/multiHop3_TR_1e5simulations.mat')
