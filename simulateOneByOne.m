function [ demandsNoise ] = simulateOneByOne(systemParameters, ...
    TopologyStruct, DemandStruct, NMonteCarlo, Nsamples)
% simulate noise distribution by allocating demands one by one

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

%% Monte Carlo simulation
demandsFrequency = zeros(Ndemands, 3, NMonteCarlo);
demandsNoiseXCIPerLink = zeros(Ndemands, NLinks, NMonteCarlo);
demandsNoiseXCI = zeros(Ndemands, NMonteCarlo);
demandsNoiseALL = zeros(Ndemands, NMonteCarlo);
demandsNoiseXCIUB = zeros(Ndemands, NMonteCarlo);
demandsNoiseXCIUBPerLink = zeros(Ndemands, NLinks, NMonteCarlo);
demandsNoiseALLUB = zeros(Ndemands, NMonteCarlo);
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
    demandsNoiseXCIPerLink(:, :, i) = noiseTemp.XCI;
    demandsNoiseXCI(:, i) = sum(noiseTemp.XCI, 2);
    demandsNoiseALL(:, i) = sum(noiseTemp.ALL, 2);
    demandsNoiseXCIUB(:, i) = sum(noiseTemp.XCIUB, 2);
    demandsNoiseXCIUBPerLink(:, :, i) = noiseTemp.XCIUB;
    demandsNoiseALLUB(:, i) = sum(noiseTemp.ALLUB, 2);
end

%%
demandsNoise = struct();
demandsNoise.XCIPerLink = demandsNoiseXCIPerLink;
demandsNoise.XCI = demandsNoiseXCI;
demandsNoise.ALL = demandsNoiseALL;
demandsNoise.XCIUB = demandsNoiseXCIUB;
demandsNoise.XCIUBPerLink = demandsNoiseXCIUBPerLink;
demandsNoise.ALLUB = demandsNoiseALLUB;
demandsNoise.demandsFrequency = demandsFrequency;