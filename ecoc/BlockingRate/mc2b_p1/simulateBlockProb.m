function [ blockNum, blockHistory, runtime ] = simulateBlockProb(systemParameters, ...
    TopologyStruct, SimulationParameters, DemandStructTemplate)
% simulate noise per link with Monte Carlo

NMonteCarlo = SimulationParameters.NMonteCarlo;

tic;
DemandStruct = modifyDemandStruct(DemandStructTemplate);
[blockNum, blockHistory] = simulateOneByOneBlockProb(systemParameters, TopologyStruct, ...
    DemandStruct, NMonteCarlo);
runtime = toc;
