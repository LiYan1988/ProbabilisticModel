function [DemandStruct] = createFixedTrafficDemands(TopologyStruct, ...
    demandSourceDestinationPairs, randomSeed, DataRateLowerBound, DataRateUpperBound)
% create traffic demands for a network

if nargin<5
    DataRateLowerBound = 30;
    DataRateUpperBound = 400;
end

if nargin<3
    randomSeed = 0;
end
rng(randomSeed);

NodeList = TopologyStruct.NodeList;
NNodes = TopologyStruct.NNodes;
NetworkCost = TopologyStruct.NetworkCost;
NetworkConnectivity = TopologyStruct.NetworkConnectivity;
LinkList = TopologyStruct.LinkList;
NLinks = TopologyStruct.NLinks;
LinkListIDs = TopologyStruct.LinkListIDs;
LinkLengths = TopologyStruct.LinkLengths;
LinksTable = TopologyStruct.LinksTable;


NodePairs = combnk(NodeList, 2);
NodePairs = [NodePairs; [NodePairs(:, 2), NodePairs(:, 1)]];
NodePairs = sortrows(NodePairs);

Ndemands = size(demandSourceDestinationPairs, 1);
demandDataRate = randi([DataRateLowerBound, DataRateUpperBound], ...
    [Ndemands, 1]);
demands = [demandSourceDestinationPairs, demandDataRate];

demandsMatrix = zeros(Ndemands, NLinks+3);
demandsMatrix(:, 1:3) = demands;
demandPaths = cell(Ndemands, 1);
demandPathLength = zeros(Ndemands, 1);
for n=1:Ndemands
    [shortestPath, pathLength] = dijkstra(NetworkCost, demands(n, 1), demands(n, 2));
    demandPaths{n} = shortestPath;
    demandPathLength(n) = pathLength;
    pathLinks = [shortestPath(1:end-1)', shortestPath(2:end)'];
    pathLinksID = zeros(1, NLinks);
    for m=1:NLinks
        if ismember(LinkList(m,:), pathLinks, 'rows')
            demandsMatrix(n, m+3) = 1;
        end
    end
end

NumberOfDemandsOnLink = sum(demandsMatrix(:, 4:end), 1)';
TotalDataRateOnLink = zeros(NLinks, 1);
for m=1:NLinks
    idxs = find(demandsMatrix(:, m+3));
    TotalDataRateOnLink(m) = sum(demandsMatrix(idxs, 3));
end

SetOfDemandsOnLink = cell(NLinks, 1);
for m=1:NLinks
    SetOfDemandsOnLink{m} = find(demandsMatrix(:, m+3));
end

% finally convert demandsMatrix to a table and give each column meaningful
% names
nameCells = cell(NLinks+3, 1);
nameCells{1} = 'Source';
nameCells{2} = 'Destination';
nameCells{3} = 'DataRate';
for l=1:NLinks
    nameCells{l+3} = sprintf('Link%dfrom%dto%dspans%d', LinkListIDs(l),...
        LinkList(l, 1), LinkList(l, 2), LinkLengths(l));
end
demandsTable = array2table(demandsMatrix, 'VariableNames', nameCells);

DemandStruct = struct();
DemandStruct.demandsMatrix = demandsMatrix;
DemandStruct.demandsTable = demandsTable;
DemandStruct.SetOfDemandsOnLink = SetOfDemandsOnLink;
DemandStruct.demandPathLength = demandPathLength;
DemandStruct.demandPaths = demandPaths;