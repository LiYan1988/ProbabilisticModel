%% Test nlcon.m

clc;
clear;
close all;

%% Define fiber parameters
alpha = 0.22; % dB/km, attenuation of fiber, NOTE: alpha is positive!
alpha = alpha*1e-4*log(10); % 1/m
L = 100e3; % m, length of one span
h = 6.626e-34; % J*s, Plank's constant
niu = 193.548e12; % Hz, frequency of lightwave at 1550 nm
nsp = 10^(5.5/10)/2; % spontaneous emission factor
Nase = (exp(alpha*L)-1)*h*niu*nsp; % ASE per polarization per span
% W/Hz, signal side ASE noise spectral density
gamma = 1.32e-3; % 1/(W*m), nonlinear parameter
% gamma = 0;
beta = -2.1668e-26; % s^2/m, GVD parameter, D = 18 ps/(nm*km),
% beta = -D*lambda^2/(2*pi*c)
beta = abs(beta); % the absolute value is used in calculation

%% Input to nlcon
Nuser = 3;
t = ones(3, 1);
psd = 15*ones(3, 1); % mW/THz
Nspan = 10;
x_c = 2*ones(3, 1);
x_f = (0:Nuser-1)'*max(t)*2;
x = [x_c; x_f];
cinq = nlcon(x, psd, t, Nspan, alpha, beta, gamma, Nase);