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
systemParameters.gb = 13; % the guardband
systemParameters.freqMax = 16000; % max frequency in GHz
systemParameters.psd = 15;

%% topology
% chain network
% NetworkCost = [[inf, 5, inf, inf]; [5, inf, 10, inf]; ...
%     [inf, 10, inf, 5]; [inf, inf, 5, inf]]; % unit is the number of spans
% 6-node network
% NetworkCost = [[inf, 5, inf, inf, inf, 6];...
%     [5, inf, 4, inf, 5, 3];...
%     [inf, 4, inf, 5, 3, inf];...
%     [inf, inf, 5, inf, 6, inf];...
%     [inf, 5, 3, 6, inf, 4];...
%     [6, 3, inf, inf, 4, inf]];
% German network
german = load('GermenNetworkTopology.mat');
NetworkCost = german.networkCostMatrix/100;

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
Ndemands = 250;
distributionName = 'normal';
p1 = 30;
p2 = 100;
% normal
DemandStruct = createTrafficDemands(TopologyStruct, Ndemands, ...
    p1, p2, distributionName);
% uniform
% DemandStruct = createTrafficDemands(TopologyStruct, Ndemands, randomSeed, 30, 400, 'uniform');

demandsMatrix = DemandStruct.demandsMatrix;
demandsTable = DemandStruct.demandsTable;
SetOfDemandsOnLink = DemandStruct.SetOfDemandsOnLink;
demandPathLength = DemandStruct.demandPathLength;
demandPaths = DemandStruct.demandPaths;
NumberOfDemandsOnLink = DemandStruct.NumberOfDemandsOnLink;


%%
Nsamples = 10000;
SampleNoise = sampleNoise(systemParameters, TopologyStruct, ...
    DemandStruct, Nsamples);

%% calculate noise based on bandwidths
NMonteCarlo = 1000;
demandsNoise = simulateOneByOne(systemParameters, TopologyStruct, ...
    DemandStruct, NMonteCarlo);

%% Plot
close all;
clc;

sparseDemandMatrix = sparse(demandsMatrix(:, 4:end));
[idxDemands, idxLinks, ~] = find(sparseDemandMatrix);
r = randi([1, length(idxDemands)]);
idxDemand = idxDemands(r);
idxLink = idxLinks(r);

% Monte Carlo
demandsNoiseXCIPerLink = demandsNoise.XCIPerLink;
demandsNoiseXCI = demandsNoise.XCI;
demandsNoiseALL = demandsNoise.ALL;
demandsNoiseXCIUB = demandsNoise.XCIUB;
demandsNoiseXCIUBPerLink = demandsNoise.XCIUBPerLink;
demandsNoiseALLUB = demandsNoise.ALLUB;

ALL = demandsNoiseALL(idxDemand, :);
XCI = demandsNoiseXCI(idxDemand, :);
XCIUB = demandsNoiseXCIUB(idxDemand, :);
XCIUBPerLink = squeeze(demandsNoiseXCIUBPerLink(idxDemand, idxLink, :));
XCIPerLink = squeeze(demandsNoiseXCIPerLink(idxDemand, idxLink, :));
ALLUB = demandsNoiseALLUB(idxDemand, :);

ALL(ALL==0) = [];
XCI(XCI==0) = [];
XCIUB(XCIUB==0) = [];
XCIUBPerLink(XCIUBPerLink==0) = [];
XCIPerLink(XCIPerLink==0) = [];
ALLUB(ALLUB==0) = [];


% Sample Noise
sampleNoiseXCIPerLink = SampleNoise.XCIPerLink;
sampleNoiseSCIPerLink = SampleNoise.SCIPerLink;
sampleNoiseNLIPerLink = sampleNoiseXCIPerLink+sampleNoiseSCIPerLink;
sampleXCI = squeeze(sampleNoiseXCIPerLink(idxDemand, idxLink, :));
sampleSCI = squeeze(sampleNoiseSCIPerLink(idxDemand, idxLink, :));
sampleNLI = squeeze(sampleNoiseNLIPerLink(idxDemand, idxLink, :));

%
hold on;
histogram(XCIPerLink, 'normalization', 'probability', 'displayname', 'simulation')
histogram(sampleXCI, 'normalization', 'probability', 'displayname', 'upper bound')
grid on;
titleName = sprintf('demand %d, link %d', idxDemand, idxLink);
title(titleName)
xlabel('$G^{NLI}_{i,l}$ ($\mu$W/THz)','Interpreter','LaTex', 'fontsize', 14)
ylabel('Probability')
legend('show')

