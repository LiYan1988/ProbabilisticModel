function [ SampleNoise ] = sampleNoise(systemParameters, ...
    TopologyStruct, DemandStruct, Nsamples)
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

% change units
mu = 3*gamma^2/(2*pi*alpha*abs(beta));
rho = pi^2*abs(beta)/(2*alpha);
mu = mu*1e-30;
rho = rho*1e18;
Nase = Nase*1e15;

%% Sample from distributions
sampleNoiseALLPerLink = zeros(Nsamples, NLinks, Ndemands);
sampleNoiseNLIPerLink = zeros(Nsamples, NLinks, Ndemands);
sampleNoiseXCIPerLink = zeros(Nsamples, NLinks, Ndemands);
sampleNoiseSCIPerLink = zeros(Nsamples, NLinks, Ndemands);
% sampleNoiseNLIPerLink = cell(Ndemands, 1);
for i=1:Ndemands
    linkUsed = demandsMatrix(i, 4:end);
    tmpSCI = zeros(Nsamples, NLinks);
    tmpXCI = zeros(Nsamples, NLinks);
    tmpASE = zeros(Nsamples, NLinks);
    % sample the bandwidth of demand i
    Bi = sampleSumDistribution(distributionName, p1, p2, 1, Nsamples);
    Btotal = zeros(Nsamples, NLinks);
    for j=1:NLinks
        if linkUsed(j)==0
            continue
        end
        tmpLength = LinkLengths(j);
        % sample SCI
        tmpSCI(:, j) = mu*tmpLength*psd^3*asinh(rho*Bi.^2);
        % sample the total bandwidth
        Btotal(:, j) = sampleSumDistribution(distributionName, p1, p2, ...
            NumberOfDemandsOnLink(j), Nsamples);
        % sample XCI 
        tmpXCI(:, j) = 2*mu*tmpLength*psd^3*log((Btotal(:, j)+2*gb)./....
            (Bi+2*gb));
        % sample ASE
        tmpASE(:, j) = tmpLength*Nase;
    end
    sampleNoiseXCIPerLink(:, :, i) = tmpXCI;
    sampleNoiseSCIPerLink(:, :, i) = tmpSCI;
    sampleNoiseNLIPerLink(:, :, i) = tmpSCI+tmpXCI;
    sampleNoiseALLPerLink(:, :, i) = tmpSCI+tmpXCI+tmpASE;
end

SampleNoise = struct();
SampleNoise.XCIPerLink = permute(sampleNoiseXCIPerLink, [3, 2, 1]);
SampleNoise.SCIPerLink = permute(sampleNoiseSCIPerLink, [3, 2, 1]);
SampleNoise.NLIPerLink = permute(sampleNoiseNLIPerLink, [3, 2, 1]);
SampleNoise.ALLPerLink = permute(sampleNoiseALLPerLink, [3, 2, 1]);