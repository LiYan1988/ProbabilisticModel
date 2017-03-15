% test for probabilities related to modulation converter

clc;
clear;
close all;

%% test expected number of k-hop segments
q = 0.5;
h = 10;
exp = zeros(h, 1);
for k=1:h
    exp(k) = analyticExpectedNumberSegments(q, k, h);
end

%% test simulation segment length distribution
q = 0.5;
h = 10;
Nsimulations = 100000;
t = simuExpectedSegmentLengthDistribution(q, h, Nsimulations);

figure; hold on;
plot(exp)
plot(t)

%% test probMKseg.m
% k = 5;
% i = 8;
% h = 30;
% m = zeros(floor(h/k)+1, 1);
% for j=1:length(m)
%     m(j) = probMKseg(j-1, k, i, h);
% end
% 
% plot(m)