function demandsFrequency = allocateOneByOne(systemParameters, ...
    TopologyStruct, DemandStruct, demandOrder)
% allocate demands in network one by one
alpha = systemParameters.alpha;
beta = systemParameters.beta;
gamma = systemParameters.gamma;
Nase = systemParameters.Nase;
gb = systemParameters.gb; 
freqMax = systemParameters.freqMax;

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
Ndemands = size(demandsMatrix, 1);

demandsFrequency = zeros(Ndemands, 3);
frequencySlotsAvailability = ones(freqMax, NLinks); % 1 is usable
for i=1:Ndemands
    idx = demandOrder(i);
    [~, linkUsed, ~] = find(demandsMatrix(idx, 4:end));
    temp1 = ones(freqMax, 1);
    for j=1:length(linkUsed)
        temp1 = temp1.*frequencySlotsAvailability(:, linkUsed(j));
    end
    temp2 = [0; temp1; 0];
    temp2 = diff(temp2);
    run_start = find(temp2==1);
    run_end = find(temp2==-1);
    run_interval = run_end-run_start;
    run_idx = find(run_interval>=demandsMatrix(idx, 3), 1, 'first');
    if isempty(run_idx)
        continue
    end
    for j=1:length(linkUsed)
        frequencySlotsAvailability(run_start(run_idx):...
            run_start(run_idx)+demandsMatrix(idx, 3)-1+gb, ...
            linkUsed(j)) = 0;
    end
    demandsFrequency(i, 1) = run_start(run_idx)-1+demandsMatrix(idx, 3)/2;
    demandsFrequency(i, 2) = run_start(run_idx)-1;
    demandsFrequency(i, 3) = run_start(run_idx)-1+demandsMatrix(idx, 3);
end
