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

%% plotting
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
figure4 = figure;
axes4 = axes('Parent', figure4);
hold(axes4,'on');
box on; grid on;
figure5 = figure;
axes5 = axes('Parent', figure5);
hold(axes5,'on');
box on; grid on;

plotIdx = 6;
plotSpan = plotIdx+4;
h = [];
p = [];
o = [];
n = [];
r = [];
k = 1;
for Nuser = 5:5:50
    totalRate = (lb+ub)/2*Nuser;
    filename = sprintf('data/singleLink%dUser1e3_SweepLength_RandomDataRate30-400_FixedUserNumber.mat', Nuser);
    try
        load(filename)
        noiseTemp = shiftdim(noiseAll, 1);
        noiseTemp2 = zeros(size(noiseTemp, 1), size(noiseTemp, 2)*size(noiseTemp, 3));
        for tmpdist=1:size(noiseTemp2, 1)
            noiseTemp2(tmpdist, :) = reshape(noiseTemp(tmpdist, :, :), 1, []);
        end
        noiseAve = mean(noiseTemp2, 2);
        noiseStd = std(noiseTemp2, [], 2);
        seAveMatrix(:, k) = seAve;
        seStdMatrix(:, k) = seStd;
        ese = sum(dataRates, 1)./sum(dataRates./squeeze(seGNAll(:, plotIdx, :))', 1);
        seMatrixAt10(:, k) = ese';
        legendStr = sprintf('%d users', Nuser);
        n(k) = errorbar(axes4, distance, noiseAve, noiseStd, 'displayname', legendStr);
        if mod(k, 2)==0
            p(k) = histogram(axes2, seMatrixAt10(:, k), linspace(min(seMatrixAt10(:, k)), max(seMatrixAt10(:, k)), 21), 'displayname', legendStr, 'normalization', 'probability');
            h(k) = errorbar(axes1, distance, seAveMatrix(:, k), seStdMatrix(:, k), 'displayname', legendStr);
            r(k) = histogram(axes5, noiseTemp2(plotIdx,:), linspace(min(noiseTemp2(plotIdx,:)), max(noiseTemp2(plotIdx,:)), 21), 'displayname', legendStr, 'normalization', 'probability');
        end
        o(k) = plot(axes3, distance, seStdMatrix(:, k), 'displayname', legendStr);
        k = k+1;
    catch
        fprintf('%d-Nuser not finished yet!\n', Nuser)
    end
end
% tr = zeros(1000, 96);
% for m=1:1000
%     for n=1:96
%         tr(m,n) = seSingleLink(dataRates(:, m), distance(n), systemParameters, 'TR');
%     end
% end
load('data/testDistirbutionSingleLinkFixedSumPlot.mat', 'tr')
plot(axes1, distance, mean(tr, 1), 'linewidth', 1, 'displayname', 'TR')

legend(axes1, 'show');
xlabel(axes1, 'distance (100 km)')
ylabel(axes1, 'ESE (bit/Hz)')
legend(axes2, 'show');
xlabel(axes2, 'ESE (bit/Hz)')
ylabel(axes2, 'Probability')
legend(axes3, 'show');
xlabel(axes3, 'distance (100 km)')
ylabel(axes3, 'ESE (bit/Hz)');
legend(axes4, 'show', 'location', 'northwest');
xlabel(axes4, 'distance (100 km)')
ylabel(axes4, 'noise PSD (W/Hz)');
legend(axes5, 'show');
xlabel(axes5, 'noise PSD (W/Hz)');
ylabel(axes5, 'Probability');

figureName1 = sprintf('figures/singleLink%dUser1e3_SweepLength_RandomDataRate30-400_FixedUserNumber_DistancePlot.fig', Nuser);
savefig(figure1, figureName1)
figureName2 = sprintf('figures/singleLink%dUser1e3_SweepLength_RandomDataRate30-400_FixedUserNumber_HistogramPlotAt%dSpan.fig', Nuser, plotSpan);
savefig(figure2, figureName2)
figureName4 = sprintf('figures/singleLink%dUser1e3_SweepLength_RandomDataRate30-400_FixedUserNumber_NoiseDistancePlot.fig', Nuser);
savefig(figure4, figureName4)
figureName5 = sprintf('figures/singleLink%dUser1e3_SweepLength_RandomDataRate30-400_FixedUserNumber_NoiseHistogramAt%dSpan.fig', Nuser, plotSpan);
savefig(figure5, figureName5)