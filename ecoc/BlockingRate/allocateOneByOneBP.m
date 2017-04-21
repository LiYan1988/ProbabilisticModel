function [blockStatistics, blockHistory] = ...
    allocateOneByOneBP(systemParameters, TopologyStruct, ...
    DemandStruct, demandOrder)
% allocate demands in network one by one
% Output:
% demandsFrequency: center/start/end frequency
%
%

% extract parameters
gb = systemParameters.gb;
freqMax = systemParameters.freqMax;

NLinks = TopologyStruct.NLinks;

demandsMatrix = DemandStruct.demandsMatrix;
Ndemands = size(demandsMatrix, 1);

% allocate demands one by one
blockHistory = zeros(Ndemands, 1);
blockStatistics = zeros(Ndemands, 1);
demandsFrequency = zeros(Ndemands, 3);
frequencySlotsAvailability = ones(freqMax, NLinks); % 1 is usable
demandsNoisePerLinkAll = zeros(Ndemands, NLinks);
for i=1:Ndemands
    % find frequency slots for the new demand
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
    % continue if there is no new demand
    if isempty(run_idx)
        % block demand i
        blockStatistics(idx) = 1;
        fprintf('Demand %d is blocked due to wavelength, block probability %.4e, %d allocated.\n', idx, sum(blockStatistics)/Ndemands, i);
        continue
    end
    % check noise for the new and exist demands
    slotStart = run_start(run_idx);
    [blockFlag, demandsNoisePerLinkAll, demandsFrequency] = ...
        checkBlock(idx, slotStart, demandsFrequency, ...
        demandsNoisePerLinkAll, systemParameters, TopologyStruct, ...
        DemandStruct);
    if ~blockFlag
        % if the demand is not blocked, allocate resource
        for j=1:length(linkUsed)
            frequencySlotsAvailability(run_start(run_idx):...
                run_start(run_idx)+demandsMatrix(idx, 3)-1+gb, ...
                linkUsed(j)) = 0;
        end
%         demandsFrequency(idx, 1) = run_start(run_idx)-1+demandsMatrix(idx, 3)/2;
%         demandsFrequency(idx, 2) = run_start(run_idx)-1;
%         demandsFrequency(idx, 3) = run_start(run_idx)-1+demandsMatrix(idx, 3);
    else
        % else block it
        blockStatistics(idx) = 1;
        blockHistory(i:end) = sum(blockStatistics)/Ndemands;
        fprintf('Demand %d is blocked due to SNR, block probability %.4e, %d allocated.\n', idx, sum(blockStatistics)/Ndemands, i);
    end
end

