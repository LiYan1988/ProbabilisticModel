% Simulate the distribution of OVERALL spectrum efficiency as a function of
% random variable L on a single link, L is the link length

% Only the data rate is random variables

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
Nsimu = 1e3;
Nuser = 10;
seGN = zeros(Nuser, Nsimu);
noise = zeros(Nuser, Nsimu);
dataRates = randi([30, 400], [Nuser, Nsimu]);
distance = randi([5, 5], [1, Nsimu]);
tic;
for i=1:Nsimu
    [seGN(:, i), noise(:, i)] = updateSpectrumGN2(dataRates(:, i), distance(i), systemParameters);
%     seGN(i) = seSingleLink(dataRates(:, i), distance(i), systemParameters, 'GN');
%     seTR(i) = seSingleLink(dataRates(:, i), distance(i), systemParameters, 'TR');
    if mod(i, 100)==0
        disp(i)
    end
end
runtime = toc;

%%
figure1 = figure; hold on; box on;
h = [];
h(1) = histogram(mean(seGN, 1), 20, 'displayname', 'GN', 'normalization', 'probability');
% h(2) = histogram(seTR, 'displayname', 'TR');
legend(h)
xlabel('Effective spectrum efficiency (bit/Hz)')
ylabel('Probability')
figureName = sprintf('figures/singleLink10User1e3_Length%d_RandomDataRate30-400.fig', distance(1));
savefig(figure1, figureName)
dataName = sprintf('data/singleLink10User1e3_Length%d_RandomDataRate30-400.mat', distance(1));
save(dataName)