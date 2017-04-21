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
bigM = 4*NoiseMax;
Cmax = systemParameters.Cmax;

Mbins = SampleNoise.Mbins;
Nbins = SampleNoise.Nbins;
Sbins = SimulationParameters.Sbins;
histPerLink = SampleNoise.histPerLink;
outageProb = systemParameters.outageProb;
sw = norminv(1-outageProb, 0, 1);

Mu = SampleNoise.histPerLinkMu;
Sigma = SampleNoise.histPerLinkSigma;

%% Create variables
% the noise of demand d at the input of node i
Ndim = sdpvar(Ndemands, NNodes);
Ndis = sdpvar(Ndemands, NNodes);
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
    fprintf('demand %d\n', d);
    tmpNodes = demandPaths{d};
    idxLinks = demandPathLinks{d};
    for i=1:NNodes
        if ~ismember(i, tmpNodes) || i==tmpNodes(1)
            Constraints = [Constraints; Ndim(d, i)==0; Ndis(d, i)==0; ...
                Cdi(d, i)==0];
        else
            Constraints = [Constraints; Ndis(d, i)>=0; ...
                Ndis(d, i)+sw*Ndim(d, i)<=NoiseMax];
        end
    end
    for i=2:length(tmpNodes)
        Constraints = [Constraints; Ndim(d, tmpNodes(i))<=...
            Ndim(d, tmpNodes(i-1))+Mu(tmpNodes(i))];
        Constraints = [Constraints; Ndim(d, tmpNodes(i))<=...
            bigM*(1-Cdi(d, tmpNodes(i)))];
        Constraints = [Constraints; ...
            Ndim(d, tmpNodes(i-1))+Mu(tmpNodes(i))-...
            Ndim(d, tmpNodes(i))<=bigM*Cdi(d, tmpNodes(i))];
        Constraints = [Constraints; Ndis(d, tmpNodes(i))<=...
            2/3*Ndis(d, tmpNodes(i-1))+Sigma(tmpNodes(i))];
        Constraints = [Constraints; Ndis(d, tmpNodes(i))<=...
            bigM*(1-Cdi(d, tmpNodes(i)))];
        Constraints = [Constraints; ...
            2/3*Ndis(d, tmpNodes(i-1))+Sigma(tmpNodes(i))-...
            Ndis(d, tmpNodes(i))<=bigM*Cdi(d, tmpNodes(i))];
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
Ndis = value(Ndis);
Ndim = value(Ndim);
Ii = value(Ii);
Ctot = value(Ctot);
Itot = value(Itot);

regenStruct = struct();
regenStruct.Cdi = Cdi;
regenStruct.Ndis = Ndis;
regenStruct.Ndim = Ndim;
regenStruct.Ii = Ii;
regenStruct.Ctot = Ctot;
regenStruct.Itot = Itot;
regenStruct.Ci = full(sum(Cdi, 1));
regenStruct.Constraints = Constraints;
regenStruct.Objective = Objective;