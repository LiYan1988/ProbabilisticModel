function [ cinq ] = nlcon( x, psd, t, Nspan, alpha, beta, gamma, Nase, gb, accumulateNoise )
% Evaluate GN model, calculate equation (6) in the PTL paper.
% Input parameters:
%   1. t: bit rate requests for all demands, unit is 100 GHz, 0.1 is 10 GHz
%   2. psd: PSD for all demands, unit is W/Hz
%   3. Nspan: number of fiber spans
%   4. x(1:Nuser): modulation formats for all demands, it's continuous
%   5. x(Nuser+1:2*Nuser): center frequencies for all demands

if nargin<9
    gb = 0;
    accumulateNoise = zeros(size(psd));
end

Nase0 = Nase;
% make all input vectors as column vectors
r_x = size(x, 1);
if r_x == 1
    x = x.';
end
r_t = size(t, 1);
if r_t == 1
    t = t.';
end
Nuser = length(t);
x_c = x(1:Nuser);
x_f = x(Nuser+1:2*Nuser);
x_psd = psd*10^(-15); % convert mW/THz to W/Hz

%
mu = 3*gamma^2/(2*pi*alpha*abs(beta));
rho = pi^2*t.^2*abs(beta)/(2*alpha);
rho = rho*1e22; % scale variables f, so that the unit of f is 100 GHz


% ASE component
psnr = snrfcn(x_c);
t_ase = Nase0*psnr;


% SCI component
pnl = mu*x_psd.*psnr;
% t_sci = pnl.*asinh(rho.*x_c.^-2);


% XCI component
f_mat = repmat(x_f.', Nuser, 1); % f_mat_{i, j} = f_j
f_mat = abs(f_mat-f_mat.'); % f_mat_{i, j} = |f_j-f_i|
pxci_numerator = 2*f_mat.*repmat(x_c, 1, Nuser)+repmat(t, 1, Nuser);
% 2*|f_j-f_i|*x_i+t_i
pxci_denominator = 2*f_mat.*repmat(x_c, 1, Nuser)-repmat(t, 1, Nuser);
% 2*|f_j-f_i|*x_i-t_i
p_mat = repmat(x_psd.^2, 1, Nuser).*log(abs(pxci_numerator./pxci_denominator));
% pxci_mat(i, j) = psd_i^2*log((2*|f_j-f_i|*x_i+t_i)/(2*|f_j-f_i|*x_i-t_i))
p_mat = p_mat+diag(x_psd.^2.*asinh(rho.*x_c.^-2));
t_nl = pnl.*(sum(p_mat, 1).');
% pnl*(sum_i{log((2*(f_j-f_i)*x_i+t_i)/(2*(f_j-f_i)*x_i-t_i))})


% SNR constraints
cinq_snr = accumulateNoise+t_ase+t_nl-x_psd/Nspan;
cinq_snr = cinq_snr*1e17; % rescale value of snr constraints


% nonoverlap constraints
BD1 = sparse(diag(ones(Nuser, 1))+diag(ones(Nuser-1, 1), 1));
BD1 = BD1(1:Nuser-1, :);
BD2 = sparse(diag(ones(Nuser, 1))-diag(ones(Nuser-1, 1), 1));
BD2 = BD2(1:Nuser-1, :);
% guardband = 0.1; % insert 10 GHz guard band between neighboring channels
cinq_bd = 0.5*BD1*(t./x_c)+BD2*x_f+gb;

cinq = [cinq_snr; cinq_bd];

end

function y = snrfcn(x)
% relaxed snr function
y = 2.209*exp(0.3392*x)-0.6598;
end