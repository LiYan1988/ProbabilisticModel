clc;
close all;
clear;
% how to generate the correct pdf for NLI?

% N = 3;
% Nsamples = 1000000;
% gb = 10;
% Btotal1 = sampleSumDistribution('normal', 100, 10, N, Nsamples);
% Bi = sampleSumDistribution('normal', 100, 10, 1, Nsamples);
% y1 = log((Btotal1+2*gb)./(Bi+2*gb));
%
% Btotal2 = sampleSumDistribution('normal', 100, 10, N-1, Nsamples);
% y2 = log((Btotal2+Bi+2*gb)./(Bi+2*gb));
%
% figure;
% histogram(y1, 200, 'normalization', 'probability', 'edgecolor', 'none')
% hold on;
% histogram(y2, 200, 'normalization', 'probability', 'edgecolor', 'none')

for i=1:10
    if i==1
        out = dummy();
    else
        out(end+1) = dummy();
    end
end

function [out] = dummy()
out = struct();
out.a = 1;
out.b = 2;
end