function  [regenStruct] = allocateRegenMC(systemParameters, TopologyStruct, ...
    DemandStruct, demandsNoise, idMC)
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
    getfield(systemParameters.snrThresholds, systemParameters.modulationFormat);
bigM = 2*NoiseMax;
noisePerLinkDemand = demandsNoise.ALLPerLinkDemand{idMC};
Cmax = systemParameters.Cmax;

%% Create variables
% the noise of demand d at the input of node i
Ndi = sdpvar(Ndemands, NNodes);
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
            Constraints = [Constraints; Ndi(d, i)==0; Cdi(d, i)==0];
        else
            Constraints = [Constraints; Ndi(d, i)>=0];
        end
    end
    for i=2:length(tmpNodes)
        tmpNoise = noisePerLinkDemand(d, idxLinks(i-1));
        Constraints = [Constraints; Ndi(d, tmpNodes(i))<=...
            Ndi(d, tmpNodes(i-1))+tmpNoise];
        Constraints = [Constraints; Ndi(d, tmpNodes(i))<=...
            bigM*(1-Cdi(d, tmpNodes(i)))];
        Constraints = [Constraints; Ndi(d, tmpNodes(i-1))+tmpNoise-...
            Ndi(d, tmpNodes(i))<=bigM*Cdi(d, tmpNodes(i))];
        Constraints = [Constraints; Ndi(d, tmpNodes(i-1))+tmpNoise...
            <=NoiseMax];
    end
end

Constraints = [Constraints; sum(Cdi, 1)<=Cmax*Ii];

Constraints = [Constraints; Ctot==sum(sum(Cdi))];

Constraints = [Constraints; Itot==sum(Ii)];

%% Create objective
Objective = CircuitWeight*Ctot+RegenWeight*Itot;

%% Optimize
options = sdpsettings('solver', 'gurobi', 'gurobi.symmetry', 1, ...
'gurobi.mipfocus', 1, 'gurobi.timelimit', 300, 'gurobi.mipgap', 0.001, ...
'debug', 0);
% options = sdpsettings('solver', 'intlinprog');
optimize(Constraints,Objective, options)

Cdi = sparse(value(Cdi));
Ndi = sparse(value(Ndi));
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