% test network scenario

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
systemParameters.freqMax = 4000; % max frequency in GHz
systemParameters.psd = 15;

%% topology
% NetworkCost = [[inf, 5, inf, inf]; [5, inf, 10, inf]; ...
%     [inf, 10, inf, 5]; [inf, inf, 5, inf]]; % unit is the number of spans
NetworkCost = [[inf, 5, inf, inf, inf, 6];...
    [5, inf, 4, inf, 5, 3];...
    [inf, 4, inf, 5, 3, inf];...
    [inf, inf, 5, inf, 6, inf];...
    [inf, 5, 3, 6, inf, 4];...
    [6, 3, inf, inf, 4, inf]];
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

%% generate traffic demands
Ndemands = 100;
randomSeed = 4839;
DemandStruct = createTrafficDemands(TopologyStruct, Ndemands, randomSeed);

demandsMatrix = DemandStruct.demandsMatrix;
demandsTable = DemandStruct.demandsTable;
SetOfDemandsOnLink = DemandStruct.SetOfDemandsOnLink;
demandPathLength = DemandStruct.demandPathLength;
demandPaths = DemandStruct.demandPaths;

%% calculate noise based on bandwidths
% NMonteCarlo = 1000; % number of Monte Carlo trials
% demandsFrequency = zeros(NMonteCarlo, Ndemands);
% for i=1:NMonteCarlo
%     demandsOrder = randperm(Ndemands);
%     for j=1:Ndemands
%         allocate
%     end
% end
NMonteCarlo = 1000;
demandsFrequency = cell(NMonteCarlo, 1);
demandsNoisePerLink = cell(NMonteCarlo, 1);
for i=1:NMonteCarlo
    demandsOrder = randperm(Ndemands);
    [demandsFrequency{i}, demandsNoisePerLink{i}] = allocateOneByOne(...
        systemParameters, TopologyStruct, DemandStruct, demandsOrder);
end
%% test calculateNoise
% Nuser = 10;
% demandsBandwidth = 100*ones(Nuser, 1);
% demandsCenterFrequency = 112.5*(0:Nuser-1).';
% psd = 15*ones(Nuser, 1);
% Nspan = 70;
% [ noise_all, noise_sci, noise_xci, noise_ase ] = ...
%     calculateNoise(demandsBandwidth, demandsCenterFrequency, psd, ...
%     Nspan, alpha, beta, gamma, Nase);
% snr = psd./noise_all