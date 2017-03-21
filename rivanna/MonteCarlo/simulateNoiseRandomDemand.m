function [ demandsNoise ] = simulateNoiseRandomDemand(systemParameters, ...
    TopologyStruct, SimulationParameters)
% simulate noise per link with Monte Carlo 

p1 = SimulationParameters.p1;
p2 = SimulationParameters.p2;
ndprob = SimulationParameters.ndprob;
ndmax = SimulationParameters.ndmax;
distributionName = SimulationParameters.distributionName;
NMonteCarlo = SimulationParameters.NMonteCarlo;
Repeat = SimulationParameters.Repeat;
Ndemands = SimulationParameters.Ndemands;

for i=1:Repeat
    DemandStruct = createTrafficDemands(TopologyStruct, Ndemands, ...
        p1, p2, distributionName, ndprob, ndmax);
    if i>1
        demandsNoise(end+1) = simulateOneByOne(systemParameters, TopologyStruct, ...
            DemandStruct, NMonteCarlo);
    else
        demandsNoise = simulateOneByOne(systemParameters, TopologyStruct, ...
            DemandStruct, NMonteCarlo);
    end
    if mod(i, 2)
        fprintf('Simulation %d is finished\n', i)
    end
end