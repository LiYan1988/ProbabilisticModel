% test probability formula
% won't continue Xu's approach
clc;
clear;
close all;

%% test (8.3)
% h = 30;
% i = 5;
% p = zeros(h, 1);
% for k=1:h
%     p(k) = prob8_3(k, i, h);
% end
% plot(1:h, p)

%% test (8.4)
% h = 30;
% p = zeros(h, 1);
% q = 0.5;
% for i=1:h
%     p(i) = prob8_4(q, i-1, h);
% end
% plot(1:h, p)

%% test probKSegment.m
% h = 30;
% p = zeros(h, 1);
% q = 0.5;
% for k=1:h
%     p(k) = probKSegment(q, k, h);
% end
% plot(1:h, p)

%% test (8.5)
% h = 10;
% q = (0:0.01:1);
% exp = zeros(size(q));
% for i=1:length(q)
%     exp(i) = prob8_5(q(i), h);
% end
% plot(q, exp)

%% simulations
% q = 0.5;
% h = 10;
% Nsimulations = 10;
% t = simuExpectedLongestSegment(q, h, Nsimulations);

%% compare simulation and analytical result
% h = 10;
% q = (0:0.1:1);
% analytic = zeros(size(q));
% simulationA = zeros(size(q));
% simulationB = zeros(size(q));
% simulationC = zeros(size(q));
% tic;
% for i=1:length(q)
%     analytic(i) = prob8_5(q(i), h);
% end
% runtimeAnalytic = toc;
% tic;
% for i=1:length(q)
%     simulationA(i) = simuExpectedLongestSegment(q(i), h, 10);
% end
% runtimeSimuA = toc;
% tic;
% for i=1:length(q)
%     simulationB(i) = simuExpectedLongestSegment(q(i), h, 1000);
% end
% runtimeSimuB = toc;
% tic;
% for i=1:length(q)
%     simulationC(i) = simuExpectedLongestSegment(q(i), h, 10000);
% end
% runtimeSimuC = toc;
% figure; hold on;
% plot(q, analytic, '--')
% plot(q, simulationA, 'marker', '^')
% plot(q, simulationB, 'marker', 'v')
% plot(q, simulationC, 'marker', 's')

%% test the original (8.3), which is wrong
% h = 30;
% i = 5;
% p = zeros(h, 1);
%
% for k=1:h
%     p(k) = fcn(k, i, h);
% end
%
% plot(p)
%
% function p = fcn(k, i, h)
% jmax=i+1;
% p = 0;
% for j=0:jmax
%     p = p+(-1)^j*nchoosek(i+1, j)*nchoosek(h-1+(k-1)*j, i);
%     disp(p)
% end
% p = p/nchoosek(h-1+i, i);
% end