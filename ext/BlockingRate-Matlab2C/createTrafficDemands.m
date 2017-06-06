function [SetOfDemandsOnLink, demandPaths, demandPathLinks, ...
    SetOfDemandsOnNode] = createTrafficDemands(TopologyStruct, Ndemands)
% create traffic demands for a network
% a2aFlag, true: generate all-to-all traffic, false: generate half traffic
% fixRouting, 0: dijstra shortest path, 1: min regen, 2: min distance,
%             3: min cost, 4: min distance min cost

NodeList = TopologyStruct.NodeList;
NNodes = TopologyStruct.NNodes;
NetworkCost = TopologyStruct.NetworkCost;
NetworkConnectivity = TopologyStruct.NetworkConnectivity;
LinkList = TopologyStruct.LinkList;
NLinks = TopologyStruct.NLinks;
LinkListIDs = TopologyStruct.LinkListIDs;
LinkLengths = TopologyStruct.LinkLengths;

NodePairs = zeros(NNodes*(NNodes-1)/2, 2);
n = 1;
for i = 1:NNodes-1
    for j = i+1:NNodes
        NodePairs(n, :) = [i, j];
    end
end
NodePairs = sortrows(NodePairs);

demandSourceDestinationPairs = NodePairs;

demandDataRate = randi([10, 100], [Ndemands, 1]);
demands = [demandSourceDestinationPairs, demandDataRate];

%%
demandsMatrix = zeros(Ndemands, NLinks+3);
demandsMatrix(:, 1:3) = demands;
demandPaths = cell(Ndemands, 1);
demandPathLinks = cell(Ndemands, 1);
demandPathLength = zeros(Ndemands, 1);
for n=1:Ndemands
    %     [shortestPath, pathLength] = dijkstra(NetworkCost, demands(n, 1), demands(n, 2));
    [shortestPath, pathLength] = loadFixedPath(demands(n, 1), ...
        demands(n, 2), NetworkCost);
    demandPaths{n} = shortestPath;
    demandPathLength(n) = pathLength;
    pathLinks = [shortestPath(1:end-1)', shortestPath(2:end)'];
    for m=1:NLinks
        if ismember(LinkList(m,:), pathLinks, 'rows')
            demandsMatrix(n, m+3) = 1;
        end
    end
    demandPathLinks{n} = find(demandsMatrix(n, 4:end));
end

SetOfDemandsOnLink = cell(NLinks, 1);
for m=1:NLinks
    SetOfDemandsOnLink{m} = find(demandsMatrix(:, m+3));
end

SetOfDemandsOnNode = cell(NNodes, 1);
for m=1:NNodes
    SetOfDemandsOnNode{m} = zeros(10, 1);
    k = 1;
    for i=1:Ndemands
        if ismember(m, demandPaths{i})
            if k>length(SetOfDemandsOnNode{m})
                tmp = SetOfDemandsOnNode{m};
                tmp = [tmp; zeros(10, 1)];
                SetOfDemandsOnNode{m} = tmp;
            end
            SetOfDemandsOnNode{m}(k) = i;
            k = k+1;
        end
    end
end

end

function [path, cost] = loadFixedPath(s, t, networkCostMatrix)
if t<s
    x=s;
    s=t;
    t=x;
end

[path, cost] = dijkstra(networkCostMatrix, s, t);
end
