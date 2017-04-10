%% a template file for running jobs on Rivanna
warning off;



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
ndmax = 3;
NMonteCarlo = 100;
Repeat = 1;
Nsamples = 1000;

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
SimulationParameters.CircuitWeight = 0.1;
SimulationParameters.RegenWeight = 1;

%% Monte Carlo
tic
simulateNoiseRandomDemand(systemParameters, ...
    TopologyStruct, SimulationParameters, simuID);
runtimeMonteCarlo = toc;

%% Sample noise
tic
SampleNoise = sampleNoiseRandomDemand(systemParameters, ...
    TopologyStruct, SimulationParameters);
runtimeSample = toc;

%% process results
% load data 
load('simuResults_1_1.mat')

sciMC = demandsNoise.SCILinkMean;
xciMC = demandsNoise.XCILinkMean;
nliMC = demandsNoise.NLILinkMean;
allMC = demandsNoise.ALLLinkMean;

sciSP = mean(SampleNoise.linkSCI, 1)';
xciSP = mean(SampleNoise.linkXCI, 1)';
nliSP = mean(SampleNoise.linkNLI, 1)';
allSP = mean(SampleNoise.linkALL, 1)';

% std
nliMCstd = zeros(46, 1);
for i=1:46
    nliMCstd(i) = std(demandsNoise.NLILinkHist{i});
end

nliSPstd = std(SampleNoise.linkNLI, 1)';

close all
figure; 
hold on;
box on;
grid on;
plot(nliMC, 'linewidth', 1.5, 'linestyle', '-', 'displayname', 'Monte Carlo');
plot(nliSP, 'linewidth', 1.5, 'linestyle', '--', 'displayname', 'Distribution Sampling');
% errorbar(nliMC, nliMCstd, 'linewidth', 1.5, 'linestyle', '-', 'displayname', 'MonteCarlo')
% errorbar(nliSP, nliSPstd, 'linewidth', 1.5, 'linestyle', '--', 'displayname', 'Upper Bound')
h = legend('show');
h.FontSize = 12;
set(gca, 'plotboxaspectratio', [7, 4, 1])
set(gca,'position',[0.12 -0 0.85 1],'units','normalized')
xlabel('Link index', 'fontsize', 14)
ylabel('PSD per connection (\muW/GHz)', 'fontsize', 14)
set(gca, 'FontSize', 12)

pathName = 'LinkALLAve2';
if ~exist('figures', 'dir')
    mkdir('figures')
end
if ~isempty(pathName)
    filename = sprintf('figures/%s.fig', pathName);
    savefig(filename)
    filename = sprintf('figures/%s.png', pathName);
    rez=600; %resolution (dpi) of final graphic
    f=gcf; %f is the handle of the figure you want to export
    figpos=getpixelposition(f); %dont need to change anything here
    resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
    set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
    print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file
end