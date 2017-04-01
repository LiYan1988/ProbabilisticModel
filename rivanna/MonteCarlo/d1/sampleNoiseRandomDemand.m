function [ SampleNoise ] = sampleNoiseRandomDemand(systemParameters, ...
    TopologyStruct, SimulationParameters)
% Sample noise for all demands on each link according to (3) in the
% document
%
% Units of input parameters:
% psd: muW/GHz ~ 10e-15 W/Hz, typical value: 15 muW/GHz
% bandwidth and center frequency: GHz, typical value: 100 GHz
%
% Corresponding constants:
% mu: 7.58e-7 (muW/GHz)^(-2)
% rho: 2.11e-3 (GHz)^(-2)
% Nase: 3.58e-2 (muW/GHz)

p1 = SimulationParameters.p1;
p2 = SimulationParameters.p2;
ndprob = SimulationParameters.ndprob;
ndmax = SimulationParameters.ndmax;
distributionName = SimulationParameters.distributionName;
NMonteCarlo = SimulationParameters.NMonteCarlo;
Repeat = SimulationParameters.Repeat;
Ndemands = SimulationParameters.Ndemands;
Nsamples = SimulationParameters.Nsamples;

%% extract parameters
alpha = systemParameters.alpha;
beta = systemParameters.beta;
gamma = systemParameters.gamma;
Nase = systemParameters.Nase;
gb = systemParameters.gb;
freqMax = systemParameters.freqMax;
psd = systemParameters.psd;

NodeList = TopologyStruct.NodeList;
NNodes = TopologyStruct.NNodes;
NetworkCost = TopologyStruct.NetworkCost;
NetworkConnectivity = TopologyStruct.NetworkConnectivity;
LinkList = TopologyStruct.LinkList;
NLinks = TopologyStruct.NLinks;
LinkListIDs = TopologyStruct.LinkListIDs;
LinkLengths = TopologyStruct.LinkLengths;
LinksTable = TopologyStruct.LinksTable;

% change units
mu = 3*gamma^2/(2*pi*alpha*abs(beta));
rho = pi^2*abs(beta)/(2*alpha);
mu = mu*1e-30;
rho = rho*1e18;
Nase = Nase*1e15;

%%
DemandStruct = createTrafficDemands(TopologyStruct, Ndemands, ...
    p1, p2, distributionName, 1, 1);
demandsMatrix = DemandStruct.demandsMatrix;
demandsTable = DemandStruct.demandsTable;
SetOfDemandsOnLink = DemandStruct.SetOfDemandsOnLink;
demandPathLength = DemandStruct.demandPathLength;
demandPaths = DemandStruct.demandPaths;
NumberOfDemandsOnLink = DemandStruct.NumberOfDemandsOnLink;
distributionName = DemandStruct.distribution;
p1 = DemandStruct.distributionParameter1;
p2 = DemandStruct.distributionParameter2;
Ndemands = size(demandsMatrix, 1);

%% Sample from distributions
sampleNoiseALLLink = zeros(Nsamples, NLinks);
sampleNoiseNLILink = zeros(Nsamples, NLinks);
sampleNoiseXCILink = zeros(Nsamples, NLinks);
sampleNoiseSCILink = zeros(Nsamples, NLinks);

Bi = sampleSumDistribution(distributionName, p1, p2, 1, Nsamples);
for i=1:NLinks
    tmpLength = LinkLengths(i);
    tmpSCI = mu*tmpLength*psd^3*asinh(rho*Bi.^2);
    tmpASE = tmpLength*Nase;
    samplesXCI = zeros(Nsamples, NumberOfDemandsOnLink(i)+1);
    % generate a Nsamples x (NumberOfDemandsOnLink(i) matrix storing
    % samples of XCI, each column is a possible number of demands on the
    % link
    for j=1:NumberOfDemandsOnLink(i)
        Btotal = sampleSumDistribution(distributionName, p1, p2, ...
            j, size(samplesXCI, 1));
        samplesXCI(:, j+1) = 2*mu*tmpLength*psd^3*log((Btotal+...
            Bi+2*gb)./(Bi+2*gb));
    end
    % sample the matrix, column probability according to binomial
    % distribution, row according to uniform distribution
    colIdx = binornd(NumberOfDemandsOnLink(i), ndprob, Nsamples, 1)+1;
    rowIdx = randi([1, size(samplesXCI, 1)], Nsamples, 1);
    ind = sub2ind(size(samplesXCI), rowIdx, colIdx);
    tmpXCI = samplesXCI(ind);
    
    sampleNoiseSCILink(:, i) = tmpSCI;
    sampleNoiseXCILink(:, i) = tmpXCI;
    sampleNoiseNLILink(:, i) = tmpXCI+tmpSCI;
    sampleNoiseALLLink(:, i) = tmpXCI+tmpSCI+tmpASE;
end

SampleNoise = struct();
SampleNoise.linkALL = sampleNoiseALLLink;
SampleNoise.linkSCI = sampleNoiseSCILink;
SampleNoise.linkXCI = sampleNoiseXCILink;
SampleNoise.linkNLI = sampleNoiseNLILink;