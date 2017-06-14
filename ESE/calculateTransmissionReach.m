%% Calculate transmission reach

clc;
clear;
close all;

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

%% Calculate transmission reaches
bitRates = (100:50:2000)'; % Gbps
spectralEfficiency = (2:2:12)';
Nreach = zeros(length(bitRates), length(spectralEfficiency));
tic;
for i=1:length(bitRates)
    bitRate = bitRates(i);
    parfor j=1:length(spectralEfficiency)
        nChannels = floor(4000/(bitRate/spectralEfficiency(j)));
        Nreach(i, j) = findReach(bitRate, spectralEfficiency(j), nChannels, 15, systemParameters);
    end
    fprintf('%d is finished\n', i);
end
runtime = toc;

save('transmissionReach.mat', 'Nreach', 'bitRates', 'spectralEfficiency')