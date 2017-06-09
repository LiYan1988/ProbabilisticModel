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
    demandsOrder = 1:Ndemands;
    fprintf('Simulation %d starts\n', i)
    [blockStatistics(:, i), blockHistory(:, i)] = ...
        allocateOneByOneBP(systemParameters, TopologyStruct, ...
        DemandStruct, demandsOrder);
    fprintf('Simulation %d is done.\n', i)
end
