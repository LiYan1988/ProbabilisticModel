function dse_opt = updateSpectrumGN(idx, dataRates, bandwidths, distance, systemParameters)
% Update spectrum usage of demand idx with GN model, the demands have
% dataRates Gbps transmitting distance (#spans)

% About the speeds of the algorithms: sqp > active-set > interior-point

alpha = systemParameters.alpha;
beta = systemParameters.beta;
gamma = systemParameters.gamma;
Nase = systemParameters.Nase;

bandwidths = bandwidths/100;
dataRates = dataRates/100;
demandRate = dataRates(idx);
demandBandwidth = bandwidths(idx);
backgroundRate = sum(dataRates)-demandRate;
backgroundBandwidth = sum(bandwidths)-demandBandwidth;
Nspan = distance;
backgroundEfficiency = backgroundRate/backgroundBandwidth;
Nuser = 3;
psd = 15*ones(Nuser, 1); % mW/THz
demandEfficiency0 = demandRate/demandBandwidth; % initial spectral efficiency
t = [backgroundRate/2; demandRate; backgroundRate/2];

funobj = @(x) -x;
x0 = demandEfficiency0;
options = optimoptions('fmincon','Display','off','Algorithm','sqp');
dse_opt = fmincon(funobj,x0,[],[],[],[],[1],[12],@demandConstraint,options);

% z = (1:0.1:12);
% y = zeros(size(z));
% for i=1:length(z)
%     [a, ~] = demandConstraint(z(i));
%     y(i) = max(a);
% end
    function [cinq, ceq] = demandConstraint(dse)
        % function used for fmincon
        % x is the spectral efficiency of the demand
        
        db = demandRate/dse;
        x_c = [backgroundEfficiency; dse; backgroundEfficiency];
        x_f = [0; backgroundBandwidth/4+db/2; backgroundBandwidth/2+db];
        x = [x_c; x_f];
        cinq = nlcon(x, psd, t, Nspan, alpha, beta, gamma, Nase);
        ceq = [];
    end

end