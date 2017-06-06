clc;
clear;
close all;
x = 1;
coronet = load('CoronetTopology.mat');
NetworkCost = coronet.networkCostMatrix;
clear coronet

filename = 'NetworkCost.dat';
CWrite(filename, NetworkCost);
NetworkCost1 = CRead(filename, size(NetworkCost));