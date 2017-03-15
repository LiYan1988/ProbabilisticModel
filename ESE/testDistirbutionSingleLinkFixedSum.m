% Simulate the distribution of OVERALL spectrum efficiency as a function of
% random variable L on a single link, L is the link length

% Only the data rate is random variables
% the sum of all users' data rates is a constant
% then vary the distance, the number of users

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
lb = 50;
ub = 350;
for Nuser = 5:5:50
    totalRate = (lb+ub)/2*Nuser;
    [dataRates, v] = uniformRandomFixedSum(Nuser, Nsimu, totalRate, lb, ub);
    distance = 5:100;
    seGN = zeros(Nsimu, length(distance));
    seAve = zeros(length(distance), 1);
    seStd = zeros(length(distance), 1);
    
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
    filename = sprintf('data/singleLink%dUser1e3_SweepLength_RandomDataRate50-350_FixedSum.mat', Nuser);
    save(filename)
end