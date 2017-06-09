function [ blockNum, blockHistory ] = simulateBlockProb(systemParameters, ...
    TopologyStruct, SimulationParameters, DemandStructTemplate)
% simulate noise per link with Monte Carlo

NMonteCarlo = SimulationParameters.NMonteCarlo;

DemandStruct = modifyDemandStruct(DemandStructTemplate);
[blockNum, blockHistory] = simulateOneByOneBlockProb(systemParameters, TopologyStruct, ...
    DemandStruct, NMonteCarlo);
