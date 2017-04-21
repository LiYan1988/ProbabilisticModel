% This folder contains files for Monte Carlo simulations on Rivanna.
% It is for the proposed method in ECOC 2017 paper. 
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