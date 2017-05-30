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