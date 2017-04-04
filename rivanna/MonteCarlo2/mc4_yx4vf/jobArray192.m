%% a template file for running jobs on Rivanna
warning off;
addpath(genpath('/scratch/yx4vf/YALMIP'));
addpath(genpath('/share/apps/gurobi/6.5.1/matlab'));

simuID = 192;
rng(76598);

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

%####################################################################
systemParameters.gb = 13; % the guardband
systemParameters.freqMax = 160000; % max frequency in GHz
systemParameters.psd = 15;
systemParameters.modulationFormat = 'PM_16QAM';
systemParameters.Cmax = 10;
systemParameters.CircuitWeight = 0.05;
systemParameters.RegenWeight = 1.00;
systemParameters.outageProb = 0.01;
%####################################################################

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
%####################################################################
Ndemands = 2; % don't need to change
Nsamples = 1; % don't need to change
distributionName = 'normal';
p1 = 150;
p2 = 20;
ndprob = 0.80;
ndmax = 2;
NMonteCarlo = 1000;
Repeat = 4;
Nbins = 65;
Mbins = 50;
Sbins = 15;
%####################################################################

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
tic
simulateNoiseRandomDemand(systemParameters, ...
    TopologyStruct, SimulationParameters, simuID);
runtimeMonteCarlo = toc;

%% Regen for Monte Carlo
tic
for j=1:Repeat
    load(sprintf('simuResults_%d_%d.mat', simuID, j))
    for k=1:NMonteCarlo
        yalmip('clear')
        regenStructMC = allocateRegenMC(systemParameters, TopologyStruct, ...
            DemandStruct, demandsNoise, k);
        save(sprintf('regenStructMC_%d_%d_%d.mat', simuID, j, k), 'regenStructMC')
    end
end
runtimeRegenMC = toc;
