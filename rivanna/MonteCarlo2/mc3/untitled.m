clc;
close all;
clear;

%%
M = 10;
mu1 = 5;
sigma1 = 1;
N = 10000;
n1 = normrnd(mu1, sigma1, N, 1);

edges = linspace(0, 10, M+1);
hist1 = histcounts(n1, edges, 'normalization', 'probability')';

%% 
mu2 = 3;
sigma2 = 0.5;
n2 = normrnd(mu2, sigma2, N, 1);

hist2 = histcounts(n2, edges, 'normalization', 'probability')';

hist3 = conv(hist1, hist2);

hist1A = convmtx(hist1, length(hist2));
hist1B = hist1A;
hist1B(M, :) = sum(hist1A(M:end, :), 1);
hist1B(M+1:end, :) = [];
hist4 = hist1A*hist2;
hist5 = hist1B*hist2;

%% 
figure; 
hold on;
grid on; 
box on;

edges3 = linspace(min(edges)*2, max(edges)*2, 2*M+1);

plot(edges3(1:end-2), hist3, 'displayname', 'hist3', 'linewidth', 1, 'linestyle', '-')
plot(edges3(1:end-2), hist4, 'displayname', 'hist4', 'linewidth', 1, 'linestyle', '--')
plot(edges(1:M), hist5, 'displayname', 'hist5', 'linewidth', 2, 'linestyle', ':')
legend('show')

n3 = n1+n2;
edgesnew = linspace(0, 15, M+1);
% edgesnew(end) = 10;
histogram(n3, edgesnew, 'normalization', 'probability', 'edgecolor', 'none')

%% 
% hist5A = 