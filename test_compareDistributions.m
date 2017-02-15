clc;
close all;
clear;

load data/singleLink10User1e3_Length5_RandomDataRate30-400.mat
close all;

x = sum(dataRates)./sum(dataRates./seGN);
N = 1e5;
y1 = normrnd(100, 1, N, 1);
y2 = normrnd(10, 1, N, 1);
y = y1./y2;
histogram(y, 20, 'normalization', 'probability');
title('N(100, 1)/N(10, 1)')

save('figures/ratioOfNormalDistributions.fig')