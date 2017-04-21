function [blockNum] = untitled7(systemParameters, ...
    TopologyStruct, DemandStruct, demandOrder)
% allocate demands in network one by one
% Output:
% demandsFrequency: center/start/end frequency
%
%

% extract parameters
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

% allocate demands one by one
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
    run_idx = find(run_interval>=demandsMatrix(idx, 3)+gb, 1, 'first');
    if isempty(run_idx)
        continue
    end
    % check noise is less than threshold for new and exist demands
    startSlot = run_start(run_idx);
    flag = checkBlock(demandsFrequency, linkUsed, startSlot, demandsMatrix(idx, 3), RS);
    if flag
        for j=1:length(linkUsed)
            frequencySlotsAvailability(run_start(run_idx):...
                run_start(run_idx)+demandsMatrix(idx, 3)-1+gb, ...
                linkUsed(j)) = 0;
        end
        demandsFrequency(idx, 1) = run_start(run_idx)-1+demandsMatrix(idx, 3)/2;
        demandsFrequency(idx, 2) = run_start(run_idx)-1;
        demandsFrequency(idx, 3) = run_start(run_idx)-1+demandsMatrix(idx, 3);
    end
end

% calculate noise
demandsNoisePerLinkASE = zeros(Ndemands, NLinks);
demandsNoisePerLinkSCI = zeros(Ndemands, NLinks);
demandsNoisePerLinkXCI = zeros(Ndemands, NLinks);
demandsNoisePerLinkALL = zeros(Ndemands, NLinks);
demandsNoisePerLinkXCIUB = zeros(Ndemands, NLinks);
demandsNoisePerLinkALLUB = zeros(Ndemands, NLinks);
for i=1:NLinks
    demandsOnLink = SetOfDemandsOnLink{i};
    if isempty(demandsOnLink)
        continue;
    end
    for j=1:length(demandsOnLink)
        if demandsFrequency(demandsOnLink(j), 3)==0
            demandsOnLink(j) = -1;
        end
    end
    demandsOnLink(demandsOnLink==-1) = [];
    if isempty(demandsOnLink)
        continue;
    end
    demandsCenterFrequency = demandsFrequency(demandsOnLink, 1);
    demandsBandwidth = demandsMatrix(demandsOnLink, 3);
    demandsPSD = psd*ones(length(demandsOnLink), 1);
    [noise_all, noise_sci, noise_xci, noise_ase, noise_xci_ub] = calculateNoise(...
        demandsBandwidth, demandsCenterFrequency, demandsPSD, ...
        LinkLengths(i), alpha, beta, gamma, Nase, gb);
    demandsNoisePerLinkALL(demandsOnLink, i) = noise_all;
    demandsNoisePerLinkASE(demandsOnLink, i) = noise_ase;
    demandsNoisePerLinkSCI(demandsOnLink, i) = noise_sci;
    demandsNoisePerLinkXCI(demandsOnLink, i) = noise_xci;
    demandsNoisePerLinkXCIUB(demandsOnLink, i) = noise_xci_ub;
    demandsNoisePerLinkALLUB(demandsOnLink, i) = ...
        noise_ase+noise_sci+noise_xci_ub;
end
demandsNoisePerLink = struct();
demandsNoisePerLink.ASE = demandsNoisePerLinkASE;
demandsNoisePerLink.SCI = demandsNoisePerLinkSCI;
demandsNoisePerLink.XCI = demandsNoisePerLinkXCI;
demandsNoisePerLink.NLI = demandsNoisePerLinkSCI+demandsNoisePerLinkXCI;
demandsNoisePerLink.ALL = demandsNoisePerLinkALL;
demandsNoisePerLink.XCIUB = demandsNoisePerLinkXCIUB;
demandsNoisePerLink.ALLUB = demandsNoisePerLinkALLUB;