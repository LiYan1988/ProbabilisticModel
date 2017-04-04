%% a template file for running jobs on Rivanna
warning off;
clc;
close all;
clear;
simuID = 1;
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
systemParameters.snrThresholds = struct('PM_BSPK', 3.52, ...
    'PM_QPSK', 7.03, 'PM_8QAM', 17.59, 'PM_16QAM', 32.60, ...
    'PM_32QAM', 64.91, 'PM_64QAM', 127.51);
systemParameters.gb = 13; % the guardband
systemParameters.freqMax = 160000; % max frequency in GHz
systemParameters.psd = 15;
systemParameters.modulationFormat = 'PM_16QAM';
systemParameters.Cmax = 100;
systemParameters.CircuitWeight = 0.1;
systemParameters.RegenWeight = 1;
systemParameters.outageProb = 0.01;

%% topology
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
Ndemands = 2;
distributionName = 'normal';
p1 = 150;
p2 = 20;
ndprob = 0.8;
ndmax = 1;
NMonteCarlo = 1;
Repeat = 1;
Nsamples = 10000;
Nbins = 505;
Mbins = 500;
Sbins = 15;

SimulationParameters = struct();
SimulationParameters.p1 = p1;
SimulationParameters.p2 = p2;
SimulationParameters.ndprob = ndprob;
SimulationParameters.ndmax = ndmax;
SimulationParameters.distributionName = distributionName;
SimulationParameters.NMonteCarlo = NMonteCarlo;
SimulationParameters.Repeat = Repeat;
SimulationParameters.Ndemands = Ndemands;
SimulationParameters.Nsamples = Nsamples;
SimulationParameters.Nbins = Nbins;
SimulationParameters.Mbins = Mbins;
SimulationParameters.Sbins = Sbins;

%% Monte Carlo
% tic
% simulateNoiseRandomDemand(systemParameters, ...
%     TopologyStruct, SimulationParameters, simuID);
% runtimeMonteCarlo = toc;

%% Sample noise
tic
SampleNoise = sampleNoiseRandomDemand(systemParameters, ...
    TopologyStruct, SimulationParameters);
runtimeSample = toc;
save('SampleNoise.mat', 'SampleNoise');

%% Regen for Monte Carlo
% tic
% load('simuResults_1_1.mat')
% regenStructMC = allocateRegenMC(systemParameters, TopologyStruct, ...
%     DemandStruct, demandsNoise, 1);
% runtimeRegenMC = toc;

%% Regen for Sampling
fprintf('Regen for sampling\n')
tic
regenStructSN = allocateRegenSN(systemParameters, TopologyStruct, ...
    SimulationParameters, SampleNoise);
runtimeRegenSN = toc;
% 
%%
% a = zeros(546, 14);
% Ndi = regenStructSN.Ndi;
% figure; hold on;
% for i=1:546
%     for j=1:14
%         a(i, j) = Ndi(1, i, j);
%         plot(Ndi(:, i, j))
%     end
% end

%%
% close all;
% MCmax = zeros(46, 1);
% for j=1:46
%     figure; hold on;
%     MCmax(j) = max(demandsNoise.ALLPerLinkDemand{1}(:, j));
%     plot([MCmax(j), MCmax(j)], [0, 1]);
%     histogram('BinEdges', SampleNoise.histEdges, 'BinCounts', SampleNoise.histPerLink(:, j))
% end