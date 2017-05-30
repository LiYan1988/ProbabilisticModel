clc;
clear;
close all;

randomSeed = 312;
simuID = 1;
modulationFormat = 'PM_QPSK';
RoutingScheme = 'MD';
alg = 'benchmark_Bathula_MD_subopt';
nRS = 20;
simulationName = 'testbench';
[blockStatistics, blockHistory] = simulateBP(randomSeed, ...
    simuID, modulationFormat, RoutingScheme, alg, nRS, simulationName);