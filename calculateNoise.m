function [ noise_all, noise_sci, noise_xci, noise_ase ] = ...
    calculateNoise(demandsBandwidth, demandsCenterFrequency, psd, ...
    Nspan, alpha, beta, gamma, Nase)
% Calculate NLI noise for all the demands on a single link, according to 
% the PTL paper.
%
% Units of input parameters:
% psd: muW/GHz ~ 10e-15 W/Hz, typical value: 15 muW/GHz
% bandwidth and center frequency: GHz, typical value: 100 GHz
% 
% Corresponding constants:
% mu: 7.58e-7 (muW/GHz)^(-2)
% rho: 2.11e-3 (GHz)^(-2)
% Nase: 3.58e-2 (muW/GHz)

Nuser = length(demandsBandwidth);
x_b = demandsBandwidth;
x_f = demandsCenterFrequency;
x_psd = psd; % convert mW/THz to W/Hz

mu = 3*gamma^2/(2*pi*alpha*abs(beta));
rho = pi^2*abs(beta)/(2*alpha);
mu = mu*1e-30;
rho = rho*1e18;
Nase = Nase*1e15;

% ASE noise
noise_ase = Nspan*Nase;

% SCI component: noise_sci(i) = psd_i^2*asinh(rho*Df_i^2)
noise_sci = Nspan*mu*psd.^3.*asinh(rho*x_b.^2);

% XCI component
f_mat = repmat(x_f.', Nuser, 1); % f_mat_{i, j} = f_j
f_mat = abs(f_mat.'-f_mat); % f_mat_{i, j} = |f_i-f_j|
xci_numerator = f_mat+0.5*repmat(x_b.', Nuser, 1);
% |f_j-f_i|+0.5*Df_j
xci_denominator = f_mat-0.5*repmat(x_b.', Nuser, 1);
% |f_j-f_i|-0.5*Df_j
p_mat = repmat((x_psd.').^2, Nuser, 1).*...
    log(abs(xci_numerator./xci_denominator));
% p_mat(i, j) = psd_j^2*log((|f_j-f_i|+0.5*Df_j)/(|f_j-f_i|-0.5*Df_j))
noise_xci = Nspan*mu*psd.*sum(p_mat, 2);

noise_all = noise_ase+noise_sci+noise_xci;
