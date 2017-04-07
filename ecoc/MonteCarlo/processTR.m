clc;
close all;
clear;

%% Find TR for some modulation formats
% modulationFormats = struct('PM_BSPK', 3.52, ...
%     'PM_QPSK', 7.03, 'PM_8QAM', 17.59, 'PM_16QAM', 32.60, ...
%     'PM_32QAM', 64.91, 'PM_64QAM', 127.51);
% 
% se = [2, 4, 6, 8, 10, 12];
% 
% load('transmissionReach.mat')
% for i=1:length(se)
%     seidx(i) = find(spectralEfficiency==se(i));
% end
% 
% bridx = 20; % bridx*10 Gbps
% tr = Nreach(bridx, seidx);
se = [2, 4, 6, 8, 10, 12];
biteRate = 200;
tr = findTR(biteRate, se);

%% topology
% Coronet
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

%% Simulation parameter
Ndemands = 2;
distributionName = 'normal';
p1 = 200;
p2 = 20;
ndprob = 1;
ndmax = 1;
NMonteCarlo = 4;
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
systemParameters.spectralEfficiency = struct('PM_BSPK', 2, ...
    'PM_QPSK', 4, 'PM_8QAM', 6, 'PM_16QAM', 8, ...
    'PM_32QAM', 10, 'PM_64QAM', 12);
se = [2, 4, 6, 8, 10, 12];
systemParameters.TR = findTR(p1, se); % p1 is the mean of bandwidth request

%####################################################################
systemParameters.gb = 13; % the guardband
systemParameters.freqMax = 160000; % max frequency in GHz
systemParameters.psd = 15;
systemParameters.modulationFormat = 'PM_QPSK';
systemParameters.Cmax = 100;
systemParameters.CircuitWeight = 0.1;
systemParameters.RegenWeight = 1;
systemParameters.outageProb = 0.01;
%####################################################################

%% Demand struct
% a2aFlag = false;
% tic
% DemandStruct = createTrafficDemands(TopologyStruct, Ndemands, ...
%     p1, p2, distributionName, ndprob, ndmax, a2aFlag);
% runtime1 = toc;
% save('templateDemandStruct.mat', 'DemandStruct')

%% Plot topology
x = load('templateDemandStruct.mat');
DemandStructTemplate = x.DemandStruct;
clear x;
gplot(NetworkConnectivity, fliplr(coronet.locations))

%% Test modifying demands
tic
DemandStruct2 = modifyDemandStruct(DemandStructTemplate);
runtime2 = toc;

%% Monte Carlo 
tic
[demandsNoise, DemandStruct] = ...
    simulateNoiseRandomDemand(systemParameters, ...
    TopologyStruct, SimulationParameters, DemandStructTemplate, 1);
runtimeMonteCarlo = toc;

%% Save data
% load('simuResults_1_1.mat')
% fileName = 'for_python';
% idMC = 1;
% saveDataForAllocateRegenMC(systemParameters, ...
%     TopologyStruct, DemandStruct, demandsNoise, fileName)
