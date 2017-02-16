clc;
close all;
clear;

load('data/singleLink10User1e5Simulations.mat')
ese = sum(dataRates, 1)./sum(dataRates./seGN, 1);
figure; hold on; box on;
h = [];
h(1) = histogram(ese, 20, 'displayname', 'GN', 'normalization', 'probability');
% h(2) = histogram(seTR, 'displayname', 'TR');
legend(h)
xlabel('Effective spectrum efficiency (bit/Hz)')
ylabel('Probability')

save('data/singleLink10User1e5Simulations.mat')