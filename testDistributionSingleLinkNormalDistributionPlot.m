% plot ESE vs distance, and ESE histogram for normal distribution single
% link results, and compare with other distributions

clc;
clear;
close all;

distIdx = 26;

%% normal distribution
load('data/singleLink10User1e3_SweepLength_NormalDistribution.mat')
seGN = squeeze(seGNAll(:, distIdx, :))';
ese = sum(dataRates, 1)./sum(dataRates./seGN, 1);

figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');
box on; grid on;
histogram(axes1, ese, linspace(min(ese), max(ese), 20), 'normalization', 'probability', 'displayname', 'normal distribution')

%% uniform distribution
load('data/singleLink10User1e3_SweepLength_RandomDataRate30-400.mat')
seGN = squeeze(seGNAll(:, distIdx, :))';
ese = sum(dataRates, 1)./sum(dataRates./seGN, 1);

histogram(axes1, ese, linspace(min(ese), max(ese), 20), 'normalization', 'probability', 'displayname', 'uniform distribution')

%% multimodual distribution
load('data/singleLink10User1e3_SweepLength_MultiModuleDistribution.mat')
seGN = squeeze(seGNAll(:, distIdx, :))';
ese = sum(dataRates, 1)./sum(dataRates./seGN, 1);

histogram(axes1, ese, linspace(min(ese), max(ese), 20), 'normalization', 'probability', 'displayname', 'multimodal distribution')

legend('show', 'location', 'northwest')
xlabel('ESE (bit/Hz)')
ylabel('Probability')
title(sprintf('Link length %d km', (distIdx+4)*100))

figureName = sprintf('figures/singleLink10UserCompareDifferentDistributionsAt%dspan.fig', distIdx+4);
savefig(figure1, figureName);

%% 
figure2 = figure;
axes2 = axes('Parent',figure2);
hold(axes2,'on');
box on; grid on;

load('data/singleLink10User1e3_SweepLength_NormalDistribution.mat')
errorbar(axes2, distance, seAve, seStd, 'displayname', 'normal distribution')

load('data/singleLink10User1e3_SweepLength_RandomDataRate30-400.mat')
errorbar(axes2, distance, seAve, seStd, 'displayname', 'uniform distribution')

load('data/singleLink10User1e3_SweepLength_MultiModuleDistribution.mat')
errorbar(axes2, distance, seAve, seStd, 'displayname', 'multimodal distribution')

legend('show')
xlabel('distance (100 km)')
ylabel('ESE (bit/Hz)')
figureName = sprintf('figures/singleLink10UserCompareDifferentDistributionsESEvsDistance.fig');
savefig(figure2, figureName);
