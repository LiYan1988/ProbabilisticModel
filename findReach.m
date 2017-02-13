function Nspan = findReach(bitRate, spectralEfficiency, nChannels, psd, systemParameters)
% Calculate transmission reach of nChannels channels with bitRate Gbps, 
% and using modulation format with spectralEfficiency bit/s/Hz, with psd
% mW/THz

alpha = systemParameters.alpha;
beta = systemParameters.beta;
gamma = systemParameters.gamma;
Nase = systemParameters.Nase;

Nuser = nChannels;
t = bitRate*ones(Nuser, 1)/100;
psd = psd*ones(Nuser, 1); % mW/THz
x_c = spectralEfficiency*ones(Nuser, 1);
x_f = (0:Nuser-1)'*max(t/spectralEfficiency);
x = [x_c; x_f];

Nspan = 1;
cinq = nlcon(x, psd, t, Nspan, alpha, beta, gamma, Nase);
cinqmax = max(cinq);
while cinqmax<=1e-3
    Nspan = Nspan+1;
    cinq = nlcon(x, psd, t, Nspan, alpha, beta, gamma, Nase);
    cinqmax = max(cinq);
end
Nspan = Nspan-1;

