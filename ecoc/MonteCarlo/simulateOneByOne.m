function [ demandsNoise ] = simulateOneByOne(systemParameters, ...
    TopologyStruct, DemandStruct, NMonteCarlo)
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
linkNoiseXCI = zeros(NLinks, NMonteCarlo);
linkNoiseSCI = zeros(NLinks, NMonteCarlo);
linkNoiseNLI = zeros(NLinks, NMonteCarlo);
linkNoiseALL = zeros(NLinks, NMonteCarlo);
XCIPerLinkDemand = cell(NMonteCarlo, 1);
SCIPerLinkDemand = cell(NMonteCarlo, 1);
NLIPerLinkDemand = cell(NMonteCarlo, 1);
ALLPerLinkDemand = cell(NMonteCarlo, 1);
for i=1:NMonteCarlo
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
    demandsNoiseALLUBPerLink(:, :, i) = noiseTemp.ALLUB;
    demandsNoiseALLUB(:, i) = sum(noiseTemp.ALLUB, 2);
    demandsNoiseSCI(:, i) = sum(noiseTemp.SCI, 2);
    linkNoiseXCI(:, i) = sum(noiseTemp.XCI, 1);
    linkNoiseSCI(:, i) = sum(noiseTemp.SCI, 1);
    linkNoiseNLI(:, i) = sum(noiseTemp.NLI, 1);
    linkNoiseALL(:, i) = sum(noiseTemp.ALL, 1);
    XCIPerLinkDemand{i} = sparse(noiseTemp.XCI);
    SCIPerLinkDemand{i} = sparse(noiseTemp.SCI);
    NLIPerLinkDemand{i} = sparse(noiseTemp.NLI);
    ALLPerLinkDemand{i} = sparse(noiseTemp.ALL);
end

XCILinkHist = cell(NLinks, 1);
SCILinkHist = cell(NLinks, 1);
NLILinkHist = cell(NLinks, 1);
ALLLinkHist = cell(NLinks, 1);
XCILinkMean = zeros(NLinks, 1);
SCILinkMean = zeros(NLinks, 1);
NLILinkMean = zeros(NLinks, 1);
ALLLinkMean = zeros(NLinks, 1);
for l=1:NLinks
    xcitmp = [];
    scitmp = [];
    nlitmp = [];
    alltmp = [];
    for i=1:NMonteCarlo
        [~, ~, v] = find(XCIPerLinkDemand{i}(:, l));
        xcitmp = [xcitmp; v];
        [~, ~, v] = find(SCIPerLinkDemand{i}(:, l));
        scitmp = [scitmp; v];
        [~, ~, v] = find(NLIPerLinkDemand{i}(:, l));
        nlitmp = [nlitmp; v];
        [~, ~, v] = find(ALLPerLinkDemand{i}(:, l));
        alltmp = [alltmp; v];
    end
    XCILinkHist{l} = xcitmp;
    SCILinkHist{l} = xcitmp;
    NLILinkHist{l} = nlitmp;
    ALLLinkHist{l} = alltmp;
    XCILinkMean(l) = mean(xcitmp);
    SCILinkMean(l) = mean(scitmp);
    NLILinkMean(l) = mean(nlitmp);
    ALLLinkMean(l) = mean(alltmp);
end
%%
demandsNoise = struct();
demandsNoise.XCIPerLink = demandsNoiseXCIPerLink;
demandsNoise.demandSCI = demandsNoiseSCI;
demandsNoise.demandXCI = demandsNoiseXCI;
demandsNoise.demandNLI = demandsNoiseXCI+demandsNoiseSCI;
demandsNoise.demandALL = demandsNoiseALL;
demandsNoise.demandXCIUB = demandsNoiseXCIUB;
demandsNoise.XCIUBPerLink = demandsNoiseXCIUBPerLink;
demandsNoise.ALLUBPerLink = demandsNoiseALLUBPerLink;
demandsNoise.demandALLUB = demandsNoiseALLUB;
demandsNoise.demandsFrequency = demandsFrequency;
demandsNoise.linkSCI = linkNoiseSCI;
demandsNoise.linkXCI = linkNoiseXCI;
demandsNoise.linkNLI = linkNoiseNLI;
demandsNoise.linkALL = linkNoiseALL;
demandsNoise.XCIPerLinkDemand = XCIPerLinkDemand;
demandsNoise.SCIPerLinkDemand = SCIPerLinkDemand;
demandsNoise.NLIPerLinkDemand = NLIPerLinkDemand;
demandsNoise.ALLPerLinkDemand = ALLPerLinkDemand;
demandsNoise.XCILinkHist = XCILinkHist;
demandsNoise.SCILinkHist = SCILinkHist;
demandsNoise.NLILinkHist = NLILinkHist;
demandsNoise.ALLLinkHist = ALLLinkHist;
demandsNoise.XCILinkMean = XCILinkMean;
demandsNoise.SCILinkMean = SCILinkMean;
demandsNoise.NLILinkMean = NLILinkMean;
demandsNoise.ALLLinkMean = ALLLinkMean;