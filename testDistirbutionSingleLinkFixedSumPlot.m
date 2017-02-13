% plot results in testDistirbutionSingleLinkFixedSum.m

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

%% load data
Nsimu = 1e3;
Nuser = 10;
lb = 50;
ub = 350;
seAveMatrix = zeros(96, 10);
seStdMatrix = zeros(96, 10);
seMatrixAt10 = zeros(1000, 10);

figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
box on; grid on;
figure2 = figure;
axes2 = axes('Parent',figure2);
hold(axes2,'on');
box on; grid on;
figure3 = figure;
axes3 = axes('Parent', figure3);
hold(axes3,'on');
box on; grid on;

h = [];
p = [];
o = [];
k = 1;
for Nuser = 5:5:50
    totalRate = (lb+ub)/2*Nuser;
    filename = sprintf('data/singleLink%dUser1e3_SweepLength_RandomDataRate50-350_FixedSum.mat', Nuser);
    load(filename)
    seAveMatrix(:, k) = seAve;
    seStdMatrix(:, k) = seStd;
    seMatrixAt10(:, k) = seGN(:, 6);
    legendStr = sprintf('%d users', Nuser);
    h(k) = errorbar(axes1, distance, seAveMatrix(:, k), seStdMatrix(:, k), 'displayname', legendStr);
    if mod(k, 4)==1
        p(k) = histogram(axes2, seMatrixAt10(:, k), linspace(8.4, 8.52, 31), 'displayname', legendStr, 'normalization', 'probability');
    end
    o(k) = plot(axes3, distance, seStdMatrix(:, k), 'displayname', legendStr);
    k = k+1;
end
tr = zeros(1000, 96);
distance=5:100;
for m=1:size(tr, 1)
    for n=1:96
        tr(m, n) = seSingleLink(dataRates(:, m), distance(n), systemParameters, 'TR');
    end
    fprintf('%d is done\n', m)
end

h(end+1) = plot(axes1, distance, mean(tr, 1), 'displayname', 'TR');
legend(axes1, 'show');
xlabel(axes1, 'distance (100 km)')
ylabel(axes1, 'ESE (bit/Hz)')

legend(axes2, 'show');
xlabel(axes2, 'ESE (bit/Hz)')
ylabel(axes2, 'Probability')
legend(axes3, 'show');
xlabel(axes3, 'distance (100 km)')
ylabel(axes3, 'ESE (bit/Hz)');

savefig(figure1, 'figures/singleLinkSweepLength_RandomDataRate50-350_FixedSum_ESEvsDistance.fig')
savefig(figure2, 'figures/singleLinkSweepLength_RandomDataRate50-350_FixedSum_ESEHistogram.fig')