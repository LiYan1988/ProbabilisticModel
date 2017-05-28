clc;
close all;
clear;

%% Load processed data
clc;
close all;
clear;
load('results.mat')

%% Compare average and confidence interval
bm_rv = bpBenchmark_ci./bpBenchmark;
p1_rv = bpProposed1_ci./bpProposed1;
p2_rv = bpProposed2_ci./bpProposed2;

% The confidence interval is relative small, to decrease the simulation
% complexity, we can use 10 Monte Carlo simulations per traffic matrix
% instead of 100.