function simulateNoiseRandomDemand(systemParameters, TopologyStruct, ...
    SimulationParameters, simuID)
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
    tic;
    DemandStruct = createTrafficDemands(TopologyStruct, Ndemands, ...
        p1, p2, distributionName, ndprob, ndmax);
    demandsNoise = simulateOneByOne(systemParameters, TopologyStruct, ...
        DemandStruct, NMonteCarlo);
    runtimeRepeat = toc;
    save(sprintf('simuResults_%d_%d.mat', simuID, i));
    if mod(i, 2)
        fprintf('Simulation %d is finished\n', i)
    end
end