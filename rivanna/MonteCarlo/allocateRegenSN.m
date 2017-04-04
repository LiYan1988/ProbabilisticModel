function  [regenStruct] = allocateRegenSN(systemParameters, TopologyStruct, ...
    SimulationParameters, SampleNoise)
% solve the regenerater allocation problem with ILP for Monte Carlo
% simulations

% Since demandsNoise is a structure storing many results from many Monte
% Carlo simulations, we use idMC to indicate which Monte Carlo simulation
% is refered to.

NodeList = TopologyStruct.NodeList;
NNodes = TopologyStruct.NNodes;
NetworkCost = TopologyStruct.NetworkCost;
NetworkConnectivity = TopologyStruct.NetworkConnectivity;
LinkList = TopologyStruct.LinkList;
NLinks = TopologyStruct.NLinks;
LinkListIDs = TopologyStruct.LinkListIDs;
LinkLengths = TopologyStruct.LinkLengths;
LinksTable = TopologyStruct.LinksTable;

p1 = SimulationParameters.p1;
p2 = SimulationParameters.p2;
ndprob = SimulationParameters.ndprob;
ndmax = SimulationParameters.ndmax;
distributionName = SimulationParameters.distributionName;
NMonteCarlo = SimulationParameters.NMonteCarlo;
Repeat = SimulationParameters.Repeat;
Ndemands = SimulationParameters.Ndemands;
Nsamples = SimulationParameters.Nsamples;
Nbins = SimulationParameters.Nbins;

DemandStruct = createTrafficDemands(TopologyStruct, Ndemands, ...
    p1, p2, distributionName, 1, ndmax);
demandsMatrix = DemandStruct.demandsMatrix;
demandsTable = DemandStruct.demandsTable;
SetOfDemandsOnLink = DemandStruct.SetOfDemandsOnLink;
demandPathLength = DemandStruct.demandPathLength;
demandPaths = DemandStruct.demandPaths;
NumberOfDemandsOnLink = DemandStruct.NumberOfDemandsOnLink;
distributionName = DemandStruct.distribution;
p1 = DemandStruct.distributionParameter1;
p2 = DemandStruct.distributionParameter2;
Ndemands = size(demandsMatrix, 1);
demandPathLinks = DemandStruct.demandPathLinks;
SetOfDemandsOnNode = DemandStruct.SetOfDemandsOnNode;

CircuitWeight = systemParameters.CircuitWeight;
RegenWeight = systemParameters.RegenWeight;

NoiseMax = systemParameters.psd/...
    getfield(systemParameters.snrThresholds, ...
    systemParameters.modulationFormat);
bigM = 2;
Cmax = systemParameters.Cmax;

Mbins = SampleNoise.Mbins;
Nbins = SampleNoise.Nbins;
Sbins = SimulationParameters.Sbins;
histPerLink = SampleNoise.histPerLink;
outageProb = systemParameters.outageProb;

%% Create variables
% the noise of demand d at the input of node i
Ndi = sdpvar(Nbins, Ndemands, NNodes);
% whether there is a circuit on node i for demand d
Cdi = binvar(Ndemands, NNodes);

% whether node i is a regen site
Ii = binvar(1, NNodes);
% total number of regen sites
Itot = intvar(1);
% total number of circuits
Ctot = intvar(1);

%% Create constraints
Constraints = [];
for d=1:Ndemands
    tmpNodes = demandPaths{d};
    idxLinks = demandPathLinks{d};
    for i=1:NNodes
        if ~ismember(i, tmpNodes) || i==tmpNodes(1)
            Constraints = [Constraints; Ndi(2:Nbins, d, i)==0; ...
                Cdi(d, i)==0];
        else
            Constraints = [Constraints; Ndi(:, d, i)>=0; ...
                sum(Ndi(:, d, i))==1];
        end
    end
    for i=2:length(tmpNodes)
        tmpNoise = histPerLink(:, idxLinks(i-1));
        tmpNoiseA = convmtx(tmpNoise, Nbins);
        tmpNoiseA(Nbins, :) = sum(tmpNoiseA(Nbins:end, :), 1);
        tmpNoiseA(Nbins+1:end, :) = [];
        Constraints = [Constraints; Ndi(2:Nbins, d, tmpNodes(i))<=...
            tmpNoiseA(2:Nbins, :)*Ndi(:, d, tmpNodes(i-1))];
        Constraints = [Constraints; Ndi(2:Nbins, d, tmpNodes(i))<=...
            bigM*(1-Cdi(d, tmpNodes(i)))];
        Constraints = [Constraints; ...
            tmpNoiseA(2:Nbins, :)*Ndi(:, d, tmpNodes(i-1))-...
            Ndi(2:Nbins, d, tmpNodes(i))<=bigM*Cdi(d, tmpNodes(i))];
        Constraints = [Constraints; ...
            sum(tmpNoiseA(Mbins-Sbins:Nbins,:)*Ndi(:, d, tmpNodes(i-1)))<=outageProb];
    end
end

Constraints = [Constraints; sum(Cdi, 1)<=Cmax*Ii];

Constraints = [Constraints; Ctot==sum(sum(Cdi))];

Constraints = [Constraints; Itot==sum(Ii)];

%% Create objective
Objective = CircuitWeight*Ctot+RegenWeight*Itot;

%% Optimize
options = sdpsettings('solver', 'gurobi', 'gurobi.symmetry', 1, ...
'gurobi.mipfocus', 1, 'gurobi.timelimit', 300, 'gurobi.mipgap', 0.001);
optimize(Constraints,Objective, options)

Cdi = sparse(value(Cdi));
Ndi = value(Ndi);
Ii = value(Ii);
Ctot = value(Ctot);
Itot = value(Itot);

regenStruct = struct();
regenStruct.Cdi = Cdi;
regenStruct.Ndi = Ndi;
regenStruct.Ii = Ii;
regenStruct.Ctot = Ctot;
regenStruct.Itot = Itot;
regenStruct.Ci = full(sum(Cdi, 1));
regenStruct.Constraints = Constraints;
regenStruct.Objective = Objective;