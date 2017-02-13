% Simulate the distribution of OVERALL spectrum efficiency as a function of
% random variable L on a single link, L is the link length

% Both the link length and user data rates are random variables

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

%% test initilizeSpectrumTR.m, 100000 samples
% Nsimu = 100000;
% seGN = zeros(Nsimu, 1);
% seTR = zeros(Nsimu, 1);
% Nuser = 10;
% dataRates = randi([30, 400], [Nuser, Nsimu]);
% distance = randi([5, 100], [1, Nsimu]);
% parfor i=1:Nsimu
%     seGN(i) = seSingleLink(dataRates(:, i), distance(i), systemParameters, 'GN');
% %     seTR(i) = seSingleLink(dataRates(:, i), distance(i), systemParameters, 'TR');
% end
% 
% figure; hold on; box on;
% h = [];
% h(1) = histogram(seGN, 'displayname', 'GN', 'normalization', 'probability');
% % h(2) = histogram(seTR, 'displayname', 'TR');
% legend(h)
% xlabel('Effective spectrum efficiency (bit/Hz)')
% ylabel('Probability')

%% test initilizeSpectrumTR.m, 10000 samples
Nsimu = 1e5;
seGN = zeros(Nsimu, 1);
seTR = zeros(Nsimu, 1);
Nuser = 10;
dataRates = randi([30, 400], [Nuser, Nsimu]);
distance = randi([5, 100], [1, Nsimu]);
tic
for i=1:Nsimu
    seGN(i) = seSingleLink(dataRates(:, i), distance(i), systemParameters, 'GN');
%     seTR(i) = seSingleLink(dataRates(:, i), distance(i), systemParameters, 'TR');
    if mod(i, 100)==0
        disp(i)
    end
end
runtime = toc;

figure; hold on; box on;
h = [];
h(1) = histogram(seGN, 20, 'displayname', 'GN', 'normalization', 'probability');
% h(2) = histogram(seTR, 'displayname', 'TR');
legend(h)
xlabel('Effective spectrum efficiency (bit/Hz)')
ylabel('Probability')

save('data/singleLink10User1e5Simulations.mat')