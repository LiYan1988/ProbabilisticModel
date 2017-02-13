% Simulate the distribution of OVERALL spectrum efficiency as a function of
% random variable L on a single link, L is the link length

% Only the data rate is random variables
% record the mean and variance as functions of link length

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

%% 10 users, 100 Gbps
Nsimu = 2e4;
distance = 5:100;
seGN = zeros(Nsimu, length(distance));
seAve = zeros(length(distance), 1);
seStd = zeros(length(distance), 1);
Nuser = 10;
dataRates = randi([30, 400], [Nuser, Nsimu]);
tic;
for l=1:length(distance)
    for i=1:Nsimu
        seGN(i, l) = seSingleLink(dataRates(:, i), distance(l), systemParameters, 'GN');
    end
    seAve(l) = mean(seGN(:, l));
    seStd(l) = std(seGN(:, l));
    fprintf('Distance %d is done!\n', distance(l))
end
runtime = toc;

%%
figure; hold on; box on;
errorbar(distance, seAve, seStd)
xlabel('Link length (100 km)')
ylabel('ESE')
savefig('figures/singleLink10User2e4_SweepLength_RandomDataRate30-400.fig')
save('data/singleLink10User2e4_SweepLength_RandomDataRate30-400.mat')