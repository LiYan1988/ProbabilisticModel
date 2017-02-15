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

%% topology
NodeList = [1; 2; 3; 4];
NetworkCost = [[inf, 500, inf, inf]; [500, inf, 500, inf]; ...
    [inf, 500, inf, 500]; [inf, inf, 500, inf]];
NetworkConnectivity = 1-isinf(NetworkCost);
[i, j, s] = find(NetworkConnectivity);
LinkList = [i, j];
NLinks = size(LinkList, 1);
LinkListID = (1:size(NLinks, 1))';

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
for n=1:Ndemands
    [shortestPath, ~] = dijkstra(NetworkCost, demands(n, 1), demands(n, 2));
    demandPaths{n} = shortestPath;
    pathLinks = [shortestPath(1:end-1)', shortestPath(2:end)'];
    pathLinksID = zeros(1, NLinks);
    for m=1:NLinks
        if ismember(LinkList(m,:), pathLinks, 'rows')
            demandsMatrix(n, m+3) = 1;
        end
    end
end

demandsOnLink = sum(demandsMatrix(:, 4:end), 1)';
dataRateOnLink = zeros(NLinks, 1);
for m=1:NLinks
    idxs = find(demandsMatrix(:, m+3));
    dataRateOnLink(m) = sum(demandsMatrix(idxs, 3));
end

%%
