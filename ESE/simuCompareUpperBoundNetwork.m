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
systemParameters.freqMax = 2000; % max frequency in GHz
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
Ndemands = 100;
randomSeed = 4249;
% normal
% DemandStruct = createTrafficDemands(TopologyStruct, Ndemands, randomSeed, 200, 40, 'normal');
% uniform
DemandStruct = createTrafficDemands(TopologyStruct, Ndemands, randomSeed, 30, 400, 'uniform');

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
NMonteCarlo = 2000;
demandsFrequency = zeros(Ndemands, 3, NMonteCarlo);
demandsNoisePerLinkXCI = zeros(Ndemands, NLinks, NMonteCarlo);
demandsNoiseXCI = zeros(Ndemands, NMonteCarlo);
demandsNoiseALL = zeros(Ndemands, NMonteCarlo);
demandsNoiseXCIUB = zeros(Ndemands, NMonteCarlo);
parfor i=1:NMonteCarlo
    demandsOrder = randperm(Ndemands);
    [demandsFrequency(:, :, i), noiseTemp] = ...
        allocateOneByOne(systemParameters, TopologyStruct, ...
        DemandStruct, demandsOrder);
    if i>1
        demandsNoisePerLink(i) = noiseTemp;
    else
        demandsNoisePerLink = noiseTemp;
    end
    demandsNoisePerLinkXCI(:, :, i) = noiseTemp.XCI;
    demandsNoiseXCI(:, i) = sum(noiseTemp.XCI, 2);
    demandsNoiseALL(:, i) = sum(noiseTemp.ALL, 2);
    demandsNoiseXCIUB(:, i) = sum(noiseTemp.XCIUB, 2);
end
demandsNoiseXCIError = (demandsNoiseXCIUB-demandsNoiseXCI)./demandsNoiseXCI;
demandsNoiseXCIError = demandsNoiseXCIError(:);
demandsNoiseXCIError(isnan(demandsNoiseXCIError)) = [];

%%
figure1 = figure(1);
histogram(demandsNoiseXCIError, 'normalization', 'probability')
xlim([-1, 2])
grid on;
box on;

% a=[cellstr(num2str(get(gca,'xtick')'*100))];
% % Create a vector of '%' signs
% pct = char(ones(size(a,1),1)*'%');
% % Append the '%' signs after the percentage values
% new_xticks = [char(a),pct];
% % 'Reflect the changes on the plot
% set(gca,'xticklabel',new_xticks)
% 
% a=[cellstr(num2str(get(gca,'ytick')'*100))];
% % Create a vector of '%' signs
% pct = char(ones(size(a,1),1)*'%');
% % Append the '%' signs after the percentage values
% new_yticks = [char(a),pct];
% % 'Reflect the changes on the plot
% set(gca,'yticklabel',new_yticks)

xlabel('Relative error')
ylabel('Probability')
set(gca, 'plotboxaspectratio', [7, 4, 1])
xlim([-0.2, 2])
set(gca,'position',[0.1 -0 0.85 1],'units','normalized')

filename = sprintf('figures/simuCompareUpperBoundNetwork-DT-%ddemands-normal.fig', Ndemands);
savefig(filename)
filename = sprintf('figures/simuCompareUpperBoundNetwork-DT-%ddemands-normal.png', Ndemands);

rez=600; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file 

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