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
systemParameters.freqMax = 160000; % max frequency in GHz
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
Ndemands = 2;
distributionName = 'normal';
p1 = 150;
p2 = 20;
ndprob=0.8;
ndmax=2;
NMonteCarlo = 1000;
Repeat = 1;
Nsamples = 1e6;

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

%% Monte Carlo
tic
demandsNoise = simulateNoiseRandomDemand(systemParameters, ...
    TopologyStruct, SimulationParameters);
runtimeMonteCarlo = toc;
%% Sample noise
tic
SampleNoise = sampleNoiseRandomDemand(systemParameters, ...
    TopologyStruct, SimulationParameters);
runtimeSample = toc;
%% Plot XCI per demand per link
% 187, 11; 237, 21; 246, 18; 70, 39; 179, 45
% close all;
% clc;

% sparseDemandMatrix = sparse(demandsMatrix(:, 4:end));
% [idxDemands, idxLinks, ~] = find(sparseDemandMatrix);
% r = randi([1, length(idxDemands)]);
% idxDemand = idxDemands(r);
% idxLink = idxLinks(r);
% 
% % Monte Carlo
% demandsNoiseXCIPerLink = demandsNoise.XCIPerLink;
% demandsNoiseXCI = demandsNoise.XCI;
% demandsNoiseALL = demandsNoise.ALL;
% demandsNoiseXCIUB = demandsNoise.XCIUB;
% demandsNoiseXCIUBPerLink = demandsNoise.XCIUBPerLink;
% demandsNoiseALLUB = demandsNoise.ALLUB;
% 
% ALL = demandsNoiseALL(idxDemand, :);
% XCI = demandsNoiseXCI(idxDemand, :);
% XCIUB = demandsNoiseXCIUB(idxDemand, :);
% XCIUBPerLink = squeeze(demandsNoiseXCIUBPerLink(idxDemand, idxLink, :));
% XCIPerLink = squeeze(demandsNoiseXCIPerLink(idxDemand, idxLink, :));
% ALLUB = demandsNoiseALLUB(idxDemand, :);
% 
% ALL(ALL==0) = [];
% XCI(XCI==0) = [];
% XCIUB(XCIUB==0) = [];
% XCIUBPerLink(XCIUBPerLink==0) = [];
% XCIPerLink(XCIPerLink==0) = [];
% ALLUB(ALLUB==0) = [];
% 
% 
% % Sample Noise
% sampleNoiseXCIPerLink = SampleNoise.XCIPerLink;
% sampleNoiseSCIPerLink = SampleNoise.SCIPerLink;
% sampleNoiseNLIPerLink = sampleNoiseXCIPerLink+sampleNoiseSCIPerLink;
% sampleXCI = squeeze(sampleNoiseXCIPerLink(idxDemand, idxLink, :));
% sampleSCI = squeeze(sampleNoiseSCIPerLink(idxDemand, idxLink, :));
% sampleNLI = squeeze(sampleNoiseNLIPerLink(idxDemand, idxLink, :));
% 
% %
% figure
% hold on;
% histogram(XCIPerLink, 'normalization', 'probability', 'displayname', 'simulation')
% histogram(sampleXCI, 'normalization', 'probability', 'displayname', 'upper bound')
% grid on;
% titleName = sprintf('demand %d, link %d', idxDemand, idxLink);
% title(titleName)
% xlabel('$G^{NLI}_{i,l}$ ($\mu$W/THz)','Interpreter','LaTex', 'fontsize', 14)
% ylabel('Probability')
% legend('show')

%% Plot XCI per demand
% close all;
% idxDemand = 201;
% figure
% hold on;
% histogram(demandsNoise.NLI(idxDemand, :), 'normalization', 'probability', 'displayname', 'simulation', 'edgecolor', 'none')
% histogram(SampleNoise.NLI(idxDemand, :), 'normalization', 'probability', 'displayname', 'upper bound', 'edgecolor', 'none')
% grid on;
% titleName = sprintf('demand %d', idxDemand);
% title(titleName)
% xlabel('$G^{NLI}_{i,l}$ ($\mu$W/THz)','Interpreter','LaTex', 'fontsize', 14)
% ylabel('Probability')
% legend('show')

%% Plot XCI per link
% close all;
% idxLink = 25;
% figure
% hold on;
% grid on;
% box on;
% histogram(demandsNoise.linkNLI(idxLink, :), 20, 'normalization', 'probability', 'displayname', 'simulation', 'edgecolor', 'none')
% histogram(SampleNoise.linkNLI(idxLink, :), 20, 'normalization', 'probability', 'displayname', 'upper bound', 'edgecolor', 'none')
% titleName = sprintf('link %d', idxLink);
% title(titleName)
% xlabel('$G^{NLI}_{i,l}$ ($\mu$W/THz)', 'Interpreter','LaTex', 'fontsize', 14)
% ylabel('Probability', 'fontsize', 14)
% set(gca, 'FontSize', 12)
% set(gca, 'plotboxaspectratio', [7, 4, 1])
% set(gca,'position',[0.12 -0 0.85 1],'units','normalized')
% h = legend('show', 'location', 'north');
% h.FontSize = 12;
% 
% pathName = 'LinkDistribution';
% if ~isempty(pathName)
%     filename = sprintf('figures2/%s-%d.fig', pathName, idxLink);
%     savefig(filename)
%     filename = sprintf('figures2/%s-%d.png', pathName, idxLink);
%     rez=600; %resolution (dpi) of final graphic
%     f=gcf; %f is the handle of the figure you want to export
%     figpos=getpixelposition(f); %dont need to change anything here
%     resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
%     set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
%     print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file
% end
% 
% %% link distribution averages
% close all;
% sampleLinkNLIave = mean(SampleNoise.linkALL, 2);
% sampleLinkNLIstd = std(SampleNoise.linkALL, 0, 2);
% simulationLinkNLIave = mean(demandsNoise.linkALL, 2);
% simulationLinkNLIstd = std(demandsNoise.linkALL, 0, 2);
% figure;
% hold on;
% box on;
% grid on;
% % errorbar(simulationLinkNLIave, sampleLinkNLIstd, 'displayname', 'simulation mean')
% % errorbar(sampleLinkNLIave, simulationLinkNLIstd, 'displayname', 'upper bound mean')
% plot(simulationLinkNLIave, 'displayname', 'simulation mean', 'linewidth', 1.5)
% plot(sampleLinkNLIave, 'displayname', 'upper bound mean', 'linewidth', 1.5)
% h = legend('show');
% h.FontSize = 12;
% set(gca, 'plotboxaspectratio', [7, 4, 1])
% set(gca,'position',[0.1 -0 0.85 1],'units','normalized')
% xlabel('Link index', 'fontsize', 14)
% ylabel('PSD (\muW/GHz)', 'fontsize', 14)
% set(gca, 'FontSize', 12)
% 
% pathName = 'LinkALLAve';
% if ~isempty(pathName)
%     filename = sprintf('figures2/%s.fig', pathName);
%     savefig(filename)
%     filename = sprintf('figures2/%s.png', pathName);
%     rez=600; %resolution (dpi) of final graphic
%     f=gcf; %f is the handle of the figure you want to export
%     figpos=getpixelposition(f); %dont need to change anything here
%     resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
%     set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
%     print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file
% end