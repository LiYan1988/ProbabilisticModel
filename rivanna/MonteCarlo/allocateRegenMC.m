function  allocateRegenMC(systemParameters, TopologyStruct, ...
    DemandStruct, SimulationParameters, demandsNoise, idMC)
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

CircuitWeight = SimulationParameters.CircuitWeight;
RegenWeight = SimulationParameters.RegenWeight;

NoiseMax = systemParameters.psd/...
    getfield(systemParameters.snrThresholds, systemParameters.modulationFormat);
bigM = 2*NoiseMax;
noisePerLinkDemand = demandsNoise(idMC).ALLPerLinkDemand{1};
Cmax = systemParameters.Cmax;

%% Create variables
% the noise at the input of node i along the path of demand d
Ndi = cell(Ndemands, 1);
% whether there is a circuit on node i for demand d
Cdi = cell(Ndemands, 1);
for d=1:Ndemands
    Ndi{d} = sdpvar(length(demandPaths{d}), 1);
    Ndi{d}(1) = 0; % the source node
    Cdi{d} = binvar(length(demandPaths{d}), 1);
end

% whether node i is a regen site
Ii = binvar(NNodes, 1);
% total number of regen sites
Itot = intvar(1);
% total number of circuits
Ctot = intvar(1);

%% Create constraints
Constraints = [];
for d=1:Ndemands
    Constraints = [Constraints; Ndi{d}(1)==0];
    idxLinks = demandPathLinks{d};
    for i=2:length(demandPaths{d})
        tmpNoise = noisePerLinkDemand(d, idxLinks(i-1));
        Constraints = [Constraints; NoiseMax>=Ndi{d}(i)>=0];
        Constraints = [Constraints; Ndi{d}(i)<=Ndi{d}(i-1)+...
            tmpNoise];
        Constraints = [Constraints; Ndi{d}(i)<=bigM*(1-Cdi{d}(i))];
        Constraints = [Constraints; Ndi{d}(i-1)+tmpNoise-Ndi{d}(i)<=...
            bigM*Cdi{d}(i)];
    end
end

slackC = cell(NNodes, 1);
for i=1:NNodes
    slackC{i} = intvar(length(SetOfDemandsOnNode{i}), 1);
    for d=1:length(SetOfDemandsOnNode{i})
        tmpDemand = SetOfDemandsOnNode{i}(d);
        if d>1
            fprintf('tmpDemand %d, d %d, i %d\n', tmpDemand, d, i);
            Constraints = [Constraints; Cdi{tmpDemand}(i)+slackC{i}(d-1)...
                <=slackC{i}(d)];
        else
            Constraints = [Constraints; Cdi{tmpDemand}(d)<=slackC{i}(d)];
        end
    end
    Constraints = [Constraints; slackC{i}(end)<=Cmax*Ii(i)];
end

Constraints = [Constraints; Itot==sum(Ii)];

slackCtot = intvar(NNodes, 1);
for i=1:NNodes
    if i>1
        Constraints = [Constraints; slackCtot(i-1)+slackC{i}(end)<=...
            slackCtot(i)];
    else
        Constraints = [Constraints; slackC{i}(end)<=slackCtot(i)];
    end
end

%% Create objective
Objective = CircuitWeight*slackCtot(end)+RegenWeight*Itot;

%% Optimize
optimize(Constraints,Objective)