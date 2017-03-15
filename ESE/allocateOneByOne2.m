function [demandsFrequency, demandsNoisePerLink] = allocateOneByOne2(...
    systemParameters, TopologyStruct, DemandStruct, demandOrder)
% allocate demands in network one by one
% Output:
% demandsFrequency: center/start/end frequency
%
%

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
Ndemands = size(demandsMatrix, 1);

demandsFrequency = zeros(Ndemands, 3);
% availability of frequency slots, 1 means available
frequencySlotsAvailability = repmat([0, freqMax, freqMax], 1, 1, NLinks); 
for i=1:Ndemands
    idx = demandOrder(i);
    [~, linkUsed, ~] = find(demandsMatrix(idx, 4:end));
    temp1 = ones(freqMax, 1);
    for j=1:length(linkUsed)
        try
        temp1 = temp1.*frequencySlotsAvailability(:, linkUsed(j));
        catch
            disp();
        end
    end
    temp2 = [0; temp1; 0];
    temp2 = diff(temp2);
    run_start = find(temp2==1);
    run_end = find(temp2==-1);
    run_interval = run_end-run_start;
    run_idx = find(run_interval>=demandsMatrix(idx, 3)+gb, 1, 'first');
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

demandsNoisePerLinkASE = zeros(Ndemands, NLinks);
demandsNoisePerLinkSCI = zeros(Ndemands, NLinks);
demandsNoisePerLinkXCI = zeros(Ndemands, NLinks);
demandsNoisePerLinkALL = zeros(Ndemands, NLinks);
for i=1:NLinks
    demandsOnLink = SetOfDemandsOnLink{i};
    if isempty(demandsOnLink)
        continue;
    end
    demandsCenterFrequency = demandsFrequency(demandsOnLink, 1);
    demandsBandwidth = demandsMatrix(demandsOnLink, 3);
    demandsPSD = psd*ones(length(demandsOnLink), 1);
    [noise_all, noise_sci, noise_xci, noise_ase] = calculateNoise(...
        demandsBandwidth, demandsCenterFrequency, demandsPSD, ...
        LinkLengths(i), alpha, beta, gamma, Nase);
    demandsNoisePerLinkALL(demandsOnLink, i) = noise_all;
    demandsNoisePerLinkASE(demandsOnLink, i) = noise_ase;
    demandsNoisePerLinkSCI(demandsOnLink, i) = noise_sci;
    demandsNoisePerLinkXCI(demandsOnLink, i) = noise_xci;
end
demandsNoisePerLink = struct();
demandsNoisePerLink.ASE = demandsNoisePerLinkASE;
demandsNoisePerLink.SCI = demandsNoisePerLinkSCI;
demandsNoisePerLink.XCI = demandsNoisePerLinkXCI;
demandsNoisePerLink.ALL = demandsNoisePerLinkALL;