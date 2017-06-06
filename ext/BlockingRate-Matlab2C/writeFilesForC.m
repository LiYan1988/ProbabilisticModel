clc;
clear;
close all;
% Prepare csv files for C++

cost = csvread('CoronetCostMatrix.csv');
A = graph(cost);
dist = distances(A);
spap = csvread('SPAP_length.csv');
norm(dist-spap)/norm(dist)