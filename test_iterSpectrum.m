%% Simulate the iterative method to calculate spectrum usage of multiple demands

clc;
clear;
close all;

rng(0)

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

%% test findSpectrumTR.m
dataRate = 400;
distance = 10; 
spectrumUsage = findSpectrumTR(dataRate, distance);

%% test updateSpectrumGN.m
dataRates = ones(10, 1);
bandwidths = ones(10, 1);
idx = 1;
distance = 10;
dse_opt = updateSpectrumGN(idx, dataRates, bandwidths, distance, systemParameters);

%% test initilizeSpectrumTR.m
Nuser = 10;
dataRates = randi([30, 400], [Nuser, 1]);
distance = 20;
bandwidths = initilizeSpectrumTR(dataRates, distance);

%% test updateSpectrumBatchGN.m
bandwidthsNew = updateSpectrumBatchGN(bandwidths, dataRates, distance, systemParameters);
bandwidthsNew1 = updateSpectrumBatchGN(bandwidthsNew, dataRates, distance, systemParameters);
bandwidthsNew2 = updateSpectrumBatchGN(bandwidthsNew1, dataRates, distance, systemParameters);
figure;
hold on;
plot(bandwidths)
plot(bandwidthsNew)
plot(bandwidthsNew1)
plot(bandwidthsNew2)

%% test iterateSpectrumBatchGN.m
bandwidthsIter = iterateSpectrumBatchGN(dataRates, distance, 2, systemParameters);
plot(bandwidthsIter, '--')

%% test updateSpectrumGN2.m
[dse_opt, finalNoise] = updateSpectrumGN2(dataRates, distance, systemParameters);
bandwidthsUpdate = dataRates./dse_opt;
plot(bandwidthsUpdate, '-.')