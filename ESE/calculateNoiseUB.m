function [ noise_all, noise_sci, noise_xci, noise_ase ] = ...
    calculateNoiseUB(demandsBandwidth, demandsCenterFrequency, psd, ...
    Nspan, alpha, beta, gamma, Nase, gb)
% Calculate noise for all demands on a single link using approximated GN
% model.

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

bandwidth_total = sum(x_b);
noise_xci_ub = 2*mu*Nspan*log(bandwidth_total./x_b)*(psd.').^2*psd;