function [ DemandStruct ] = modifyDemandStruct(DemandStruct)
% Create DemandStruct is too long for large networks. So we create it once
% and modify it when it is needed. The node pairs will not be changed, only
% the bandwidth requirement will be changed.
% 

% Generate new traffic demands
Ndemands = size(DemandStruct.demandsMatrix, 1);

demandDataRate = zeros(Ndemands, 1);
if strcmp(DemandStruct.distribution, 'uniform')
    demandDataRate = randi([DemandStruct.distributionParameter1, ...
        DemandStruct.distributionParameter2], ...
        [Ndemands, 1]);
elseif strcmp(DemandStruct.distribution, 'normal')
    % DataRateLowerBound is mean, DataRateUpperBound is std
    demandDataRate = round(normrnd(DemandStruct.distributionParameter1, ...
        DemandStruct.distributionParameter2, ...
        [Ndemands, 1]));
end
DemandStruct.demandsMatrix(:, 3) = demandDataRate;
% DemandStruct.demandsTable.DataRate = demandDataRate;
