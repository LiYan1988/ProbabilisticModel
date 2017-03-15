function [DemandStruct] = createTrafficDemands(TopologyStruct, ...
    Ndemands, DataRateLowerBound, DataRateUpperBound, distribution)
% create traffic demands for a network

if nargin<5
    distribution = 'uniform';
end

if nargin<4
    DataRateLowerBound = 30;
    DataRateUpperBound = 100;
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


NodePairs = combnk(NodeList, 2);
NodePairs = [NodePairs; [NodePairs(:, 2), NodePairs(:, 1)]];
NodePairs = sortrows(NodePairs);

[demandSourceDestinationPairs, ~] = datasample(NodePairs, Ndemands, 1);
if strcmp(distribution, 'uniform')
    demandDataRate = randi([DataRateLowerBound, DataRateUpperBound], ...
        [Ndemands, 1]);
elseif strcmp(distribution, 'normal')
    % DataRateLowerBound is mean, DataRateUpperBound is std
    demandDataRate = round(normrnd(DataRateLowerBound, DataRateUpperBound, ...
        [Ndemands, 1]));
end
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
    for m=1:NLinks
        if ismember(LinkList(m,:), pathLinks, 'rows')
            demandsMatrix(n, m+3) = 1;
        end
    end
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
DemandStruct.distribution = distribution;
DemandStruct.distributionParameter1 = DataRateLowerBound;
DemandStruct.distributionParameter2 = DataRateUpperBound;
DemandStruct.NumberOfDemandsOnLink = zeros(NLinks, 1);
for i=1:NLinks
    DemandStruct.NumberOfDemandsOnLink(i) = length(SetOfDemandsOnLink{i});
end