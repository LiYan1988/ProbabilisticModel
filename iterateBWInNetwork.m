function [demandsBandwidths, demandsNoise, demandsSE] = iterateBWInNetwork(demandsBandwidths, TopologyStruct, DemandStruct, systemParameters, gb)
% Calculate demand bandwidths iteratively

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

for n=1:Ndemands
    noiseTemp = 0;
    % calculate noise on each link
    linkListTemp = [demandPaths{n}(1:end-1)', demandPaths{n}(2:end)'];
    [~, linkIDTemp] = ismember(linkListTemp, LinkList, 'rows');
    linkLengthTemp = LinkLengths(linkIDTemp); 
    nLinkTemp = length(linkLengthTemp);
    demandsOnLinkTemp = cell(nLinkTemp, 1);
    for l=1:nLinkTemp
        demandsTemp = SetOfDemandsOnLink{linkIDTemp(l)};
        idx = ismember(n, demandsTemp);
        noiseVectorTemp = zeros(length(demandsTemp), 1);
        noiseVectorTemp(idx) = noiseTemp;
        dataRatesTemp = demandsMatrix(demandsTemp, 3);
        [seTemp, nTemp] = updateSpectrumGN2(dataRatesTemp, linkLengthTemp(l), systemParameters, gb, noiseVectorTemp);
        noiseTemp = nTemp(idx);
    end
    demandsNoise(n) = noiseTemp;
    demandsSE(n) = seTemp(idx);
    demandsBandwidths(n) = demandsMatrix(n, 3)/demandsSE(n);
end