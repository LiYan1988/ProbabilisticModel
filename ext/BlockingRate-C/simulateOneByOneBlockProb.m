function [ blockStatistics, blockHistory ] = ...
    simulateOneByOneBlockProb(systemParameters, ...
    TopologyStruct, DemandStruct, NMonteCarlo, ...
    SetOfDemandsOnLink, SetOfDemandsOnNode, demandPaths, demandPathLinks)
% simulate noise distribution by allocating demands one by one

% extract parameters
demandsMatrix = DemandStruct.demandsMatrix;
Ndemands = size(demandsMatrix, 1);

% Monte Carlo simulation
blockStatistics = zeros(Ndemands, NMonteCarlo);
blockHistory = zeros(Ndemands, NMonteCarlo);
for i=1:NMonteCarlo
    demandsOrder = randperm(Ndemands);
    fprintf('Simulation %d starts\n', i)
    [blockStatistics(:, i), blockHistory(:, i)] = ...
        allocateOneByOneBP(systemParameters, TopologyStruct, ...
        DemandStruct, demandsOrder, ...
        SetOfDemandsOnLink, SetOfDemandsOnNode, ...
        demandPaths, demandPathLinks);
    fprintf('Simulation %d is done.\n', i)
end