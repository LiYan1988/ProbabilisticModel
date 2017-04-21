function [ blockStatistics, blockHistory ] = ...
    simulateOneByOneBlockProb(systemParameters, ...
    TopologyStruct, DemandStruct, NMonteCarlo)
% simulate noise distribution by allocating demands one by one

% extract parameters
demandsMatrix = DemandStruct.demandsMatrix;
Ndemands = size(demandsMatrix, 1);

% Monte Carlo simulation
blockStatistics = zeros(Ndemands, NMonteCarlo);
blockHistory = zeros(Ndemands, NMonteCarlo);
for i=1:NMonteCarlo
    demandsOrder = randperm(Ndemands);
    [blockStatistics(:, i), blockHistory(:, i)] = ...
        allocateOneByOneBP(systemParameters, TopologyStruct, ...
        DemandStruct, demandsOrder);
end
