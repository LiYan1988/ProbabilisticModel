function [demandsBandwidths, demandsNoise, demandsSE, HistoryStruct] = ...
    solveBWNetwork(TopologyStruct, DemandStruct, ...
    systemParameters, nIter)
% calculate bandwidths of demands in a network

if nargin<4
    nIter = 1;
end

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

gb = systemParameters.gb;

Ndemands = size(demandsMatrix, 1);
demandsNoise = zeros(Ndemands, 1);
demandsSE = zeros(Ndemands, 1);

demandsBandwidths = zeros(Ndemands, 1);
for n=1:Ndemands
    demandsBandwidths(n) = initilizeSpectrumTR(demandsMatrix(n, 3), demandPathLength(n));
end

HistoryStruct = struct();
HistoryStruct.demandsBandwidths = cell(nIter, 1);
HistoryStruct.demandsNoise = cell(nIter, 1);
HistoryStruct.demandsSE = cell(nIter, 1);
HistoryStruct.demandsBandwidthsTR = demandsBandwidths;
nStep = 0;
while nStep<nIter
    [demandsBandwidths, demandsNoise, demandsSE] = ...
        iterateBWInNetwork(demandsBandwidths, TopologyStruct, DemandStruct, ...
        systemParameters);
    nStep = nStep+1;
    HistoryStruct.demandsBandwidths{nStep} = demandsBandwidths;
    HistoryStruct.demandsNoise{nStep} = demandsNoise;
    HistoryStruct.demandsSE{nStep} = demandsSE;
end