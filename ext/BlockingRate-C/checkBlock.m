function [blockFlag, demandsNoisePerLinkAll, demandsFrequency] = ...
    checkBlock(idx, slotStart, demandsFrequency, ...
    demandsNoisePerLinkAll, systemParameters, TopologyStruct, ...
    DemandStruct, SetOfDemandsOnLink, SetOfDemandsOnNode, ...
    demandPaths, demandPathLinks)
% Check if the new demand causes higher than threshold noie to existing
% demands or itself.

alpha = systemParameters.alpha;
beta = systemParameters.beta;
gamma = systemParameters.gamma;
Nase = systemParameters.Nase;
gb = systemParameters.gb;
psd = systemParameters.psd;
modulationFormat = systemParameters.modulationFormat;
NoiseMax = systemParameters.psd/systemParameters.snrThresholds.(modulationFormat);

LinkLengths = TopologyStruct.LinkLengths;
RS = TopologyStruct.RegenSites;

demandsMatrix = DemandStruct.demandsMatrix;
demandPathNodes = demandPaths;

% pretend the new demand is allocated
demandsFrequencyTmp = demandsFrequency;
demandsFrequencyTmp(idx, 1) = slotStart-1+demandsMatrix(idx, 3)/2;
demandsFrequencyTmp(idx, 2) = slotStart-1;
demandsFrequencyTmp(idx, 3) = slotStart-1+demandsMatrix(idx, 3);

demandsNoisePerLinkAllTmp = demandsNoisePerLinkAll;

% calculate the noise on each link used by the new demand
demandsInvoled = []; % the demands need to check
linksUsed = demandPathLinks{idx};
for i=1:length(linksUsed)
    demandsOnLink = SetOfDemandsOnLink{linksUsed(i)};
    if isempty(demandsOnLink)
        continue;
    end
    % remove demands that do not use this link
    for j=1:length(demandsOnLink)
        if demandsFrequencyTmp(demandsOnLink(j), 3)==0
            demandsOnLink(j) = -1;
        end
    end
    demandsOnLink(demandsOnLink==-1) = [];
    if isempty(demandsOnLink)
        continue;
    end
    demandsInvoled = union(demandsInvoled, demandsOnLink);
    
    demandsCenterFrequency = demandsFrequencyTmp(demandsOnLink, 1);
    demandsBandwidth = demandsMatrix(demandsOnLink, 3);
    demandsPSD = psd*ones(length(demandsOnLink), 1);
    [noise_all, noise_sci, noise_xci, noise_ase, noise_xci_ub] = ...
        calculateNoise(demandsBandwidth, demandsCenterFrequency, ...
        demandsPSD, LinkLengths(i), alpha, beta, gamma, Nase, gb);
    demandsNoisePerLinkAllTmp(demandsOnLink, linksUsed(i)) = noise_all;
end

% check if any demand is worse than nosie threshold
blockFlag = false;
for d=1:length(demandsInvoled)
    linkTmp = demandPathLinks{demandsInvoled(d)};
    nodeTmp = demandPathNodes{demandsInvoled(d)};
    noiseTmp = 0; % accumulated noie
    for l=1:length(linkTmp)
        noiseTmp = noiseTmp+demandsNoisePerLinkAllTmp(demandsInvoled(d), linkTmp(l));
        if noiseTmp > NoiseMax
            blockFlag = true;
            break
        end
        if ismember(nodeTmp(l+1), RS)
            noiseTmp = 0;
        end
    end
    if blockFlag
        break
    end
end

if ~blockFlag
    demandsNoisePerLinkAll = demandsNoisePerLinkAllTmp;
    demandsFrequency = demandsFrequencyTmp;
end