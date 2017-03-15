% Simulate the distribution of OVERALL spectrum efficiency as a function of
% random variable L on a single link, L is the link length

% fix the number of users
% each user's data rate is a uniform random variable
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
lb = 30;
ub = 400;
for Nuser = 15:20:50
    totalRate = (lb+ub)/2*Nuser;
%     [dataRates, v] = uniformRandomFixedSum(Nuser, Nsimu, totalRate, lb, ub);
    dataRates = randi([lb, ub], [Nuser, Nsimu]);
    distance = 5:100;
    seGNAll = zeros(Nsimu, length(distance), Nuser);
    noiseAll = zeros(Nsimu, length(distance), Nuser);
    seGN = zeros(Nsimu, length(distance));
    seAve = zeros(length(distance), 1);
    seStd = zeros(length(distance), 1);
    
    tic;
    for l=1:length(distance)
        tmpDist = distance(l);
        for i=1:Nsimu
            [seGNAll(i, l, :), noiseAll(i, l, :)] = updateSpectrumGN2(dataRates(:, i), tmpDist, systemParameters);
            seGN(i, l) = mean(seGNAll(i, l, :));
        end
        seAve(l) = mean(seGN(:, l));
        seStd(l) = std(seGN(:, l));
    end
    runtime = toc;
    filename = sprintf('data/singleLink%dUser1e3_SweepLength_RandomDataRate30-400_FixedUserNumber.mat', Nuser);
    save(filename)
    fprintf('%d-users is done!\n', Nuser)
end