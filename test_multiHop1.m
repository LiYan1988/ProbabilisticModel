% test the multi hop scenario

clc;
clear;
close all;

rng(0);

%% Define fiber parameters
alpha = 0.22; % dB/km, attenuation of fiber, NOTE: alpha is positive!
alpha = alpha*1e-4*log(10); % 1/m
L = 100e3; % m, length of one span
h = 6.626e-34; % J*s, Plank's constant
niu = 193.548e12; % Hz, frequency of lightwave at 1550 nm
nsp = 10^(5.5/10)/2; % spontaneous emission factor
Nase = (exp(alpha*L)-1)*h*niu*nsp; % ASE per polarization per span
% W/Hz, signal side ASE noise spectral density
gamma = 1.32e-3; % 1/(W*m), nonlinear parameter
% gamma = 0;
beta = -2.1668e-26; % s^2/m, GVD parameter, D = 18 ps/(nm*km),
% beta = -D*lambda^2/(2*pi*c)
beta = abs(beta); % the absolute value is used in calculation

systemParameters = struct();
systemParameters.alpha = alpha;
systemParameters.beta = beta;
systemParameters.gamma = gamma;
systemParameters.Nase = Nase;

gb = 200; % the guardband 

%% topology
NodeList = [1; 2; 3; 4];
NNodes = length(NodeList);
NetworkCost = [[inf, 5, inf, inf]; [5, inf, 5, inf]; ...
    [inf, 5, inf, 5]; [inf, inf, 5, inf]]; % unit is the number of spans
NetworkConnectivity = 1-isinf(NetworkCost);
tmpNetworkCost = NetworkConnectivity.*NetworkCost;
tmpNetworkCost(isnan(tmpNetworkCost)) = 0;
[i, j, s] = find(tmpNetworkCost);
LinkList = [i, j];
NLinks = size(LinkList, 1);
LinkListIDs = (1:NLinks)';
LinkLengths = s;

LinksTable = table(LinkListIDs, LinkList(:, 1), LinkList(:, 2), ...
    LinkLengths, 'variablenames', {'LinkID', 'Source', 'Destination', ...
    'LinkLength'});

%% generate traffic demands
NodePairs = combnk(NodeList, 2);
NodePairs = [NodePairs; [NodePairs(:, 2), NodePairs(:, 1)]];
NodePairs = sortrows(NodePairs);
Ndemands = 100;
[demandSourceDestinationPairs, ~] = datasample(NodePairs, Ndemands, 1);
demandDataRate = randi([30, 400], [Ndemands, 1]);
demands = [demandSourceDestinationPairs, demandDataRate];

demandsMatrix = zeros(Ndemands, NLinks+3);
demandsMatrix(:, 1:3) = demands;
demandPaths = cell(Ndemands, 1);
demandPathLength = zeros(Ndemands, 1);
for n=1:Ndemands
    [shortestPath, pathLength] = dijkstra(NetworkCost, demands(n, 1), demands(n, 2));
    demandPaths{n} = shortestPath;
    demandPathLength(n) = pathLength;
    pathLinks = [shortestPath(1:end-1)', shortestPath(2:end)'];
    pathLinksID = zeros(1, NLinks);
    for m=1:NLinks
        if ismember(LinkList(m,:), pathLinks, 'rows')
            demandsMatrix(n, m+3) = 1;
        end
    end
end

NumberOfDemandsOnLink = sum(demandsMatrix(:, 4:end), 1)';
TotalDataRateOnLink = zeros(NLinks, 1);
for m=1:NLinks
    idxs = find(demandsMatrix(:, m+3));
    TotalDataRateOnLink(m) = sum(demandsMatrix(idxs, 3));
end

SetOfDemandsOnLink = cell(NLinks, 1);
for m=1:NLinks
    SetOfDemandsOnLink{m} = find(demandsMatrix(:, m+3));
end

% finally convert demandsMatrix to a table and give each column meaningful
% names
nameCells = cell(NLinks+3, 1);
nameCells{1} = 'Source';
nameCells{2} = 'Destination';
nameCells{3} = 'DataRate';
for l=1:NLinks
    nameCells{l+3} = sprintf('Link%dfrom%dto%dspans%d', LinkListIDs(l),...
        LinkList(l, 1), LinkList(l, 2), LinkLengths(l));
end
demandsTable = array2table(demandsMatrix, 'VariableNames', nameCells);
%% calculate initial bandwidths using TR model
demandsBandwidths = zeros(Ndemands, 1);
for n=1:Ndemands
    demandsBandwidths(n) = initilizeSpectrumTR(demandsMatrix(n, 3), demandPathLength(n));
end

%% calculate noise based on bandwidths
demandsNoise = zeros(Ndemands, 1);
demandsSE = zeros(Ndemands, 1);
for n=1:Ndemands
    noiseTemp = 0;
    % calculate noise on each link
    linkListTemp = [demandPaths{n}(1:end-1)', demandPaths{n}(2:end)'];
    [~, linkIDTemp] = ismember(linkListTemp, LinkList, 'rows');
    linkLengthTemp = LinkLengths(linkIDTemp); 
    nLinkTemp = length(linkLengthTemp);
    demandsOnLinkTemp = cell(nLinkTemp, 1);
    for l=1:nLinkTemp
        demandsTemp = SetOfDemandsOnLink{linkIDTemp(l)};
        idx = ismember(n, demandsTemp);
        noiseVectorTemp = zeros(length(demandsTemp), 1);
        noiseVectorTemp(idx) = noiseTemp;
        dataRatesTemp = demandsMatrix(demandsTemp, 3);
        [seTemp, nTemp] = updateSpectrumGN2(dataRatesTemp, linkLengthTemp(l), systemParameters, gb, noiseVectorTemp);
        noiseTemp = nTemp(idx);
    end
    demandsNoise(n) = noiseTemp;
    demandsSE(n) = seTemp(idx);
    demandsBandwidths(n) = demandsMatrix(n, 3)/demandsSE(n);
end