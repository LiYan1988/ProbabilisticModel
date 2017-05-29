% Simulate BP for the journal paper on Rivanna
% Assumptions:
% 1. Uniform PSD = 15 \muW/GHz
% 2. Average traffic bandwidth demand: 200 GHz
% 3. Modulation format is PM-QPSK, SNR threshold is 7.03
% 4. Given the average bandwidth demand, the transmission reach is 26 spans
% 5. The procedure of simulation:
%   a. Monte Carlo simulations to allocate demands and calculate noise by
%   Matlab
%   b. Solve MILP to allocate regen sites by python
%   c. Monte Carlo simulations to test blocking probability by Matlab
% 
% New features:
% 1. The RSs of benchmark algorithms are given by the MILPs, various costs
% are considered.
% 

% Simulations:
% 1. gain_over_bathula_mindist_1_16/ and gain_over_bathula_mindist_2_16/
% simulate the gains of RS and RC ranking with 0% noise tolerance MILP over
% the Bathula benchmark. Min-Distance routing is used, which has 16 RSs.
% There are totally 70 traffic matrices in the two folders, each with 50
% random shuffles. 