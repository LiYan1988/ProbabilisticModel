function [dse_opt, finalNoise] = updateSpectrumGN2(dataRates, Nspan, systemParameters, gb, accumulateNoise)
% Update spectrum usage of all the demands with GN model, the demands have
% dataRates Gbps transmitting distance (#spans)

% difference between updateSpectrumGN:
% updateSpectrumGN update demands one by one, this function update demands
% all together

alpha = systemParameters.alpha;
beta = systemParameters.beta;
gamma = systemParameters.gamma;
Nase = systemParameters.Nase;

if nargin<4
    gb = 0;
    accumulateNoise = zeros(size(dataRates));
end

x0 = dataRates./initilizeSpectrumTR(dataRates, Nspan);
Nuser = length(dataRates);
psd0 = 15;
totalDataRate = sum(dataRates);

%%
funobj = @(x) -sum(x);
options = optimoptions('fmincon','Display','off','Algorithm','sqp');
dse_opt = fmincon(funobj,x0,[],[],[],[],ones(Nuser, 1),12*ones(Nuser, 1),@demandConstraint,options);
finalNoise = calcNoise(dse_opt);

    function [cinq, ceq] = demandConstraint(x)
        % function used for fmincon
        % x is the spectral efficiency of the demand
        cinq = zeros(Nuser*5, 1);
        totalBandwidth = sum(dataRates./x);
        for j=1:Nuser
            bw = dataRates(j)/x(j);
            backgroundBandwidth = totalBandwidth-bw;
            backgroundDataRate = sum(totalDataRate)-dataRates(j);
            t = [backgroundDataRate/2; dataRates(j); backgroundDataRate/2]/100;
            backgroundEfficiency = backgroundDataRate/backgroundBandwidth;
            x_c = [backgroundEfficiency; x(j); backgroundEfficiency];
            x_f = [0; backgroundBandwidth/4+bw/2; backgroundBandwidth/2+bw]/100;
            x_in = [x_c; x_f];
            psd = psd0*ones(3, 1);
            tmpNoise = [0; accumulateNoise(j); 0];
            cinq((j-1)*5+1:j*5) = nlcon(x_in, psd, t, Nspan, alpha, beta, gamma, Nase, gb, tmpNoise);
        end
        ceq = [];
    end

    function finalNoise = calcNoise(x)
       % calculate the noise of the final solution
        finalNoise = zeros(Nuser, 1);
        totalBandwidth = sum(dataRates./x);
        for j=1:Nuser
            bw = dataRates(j)/x(j);
            backgroundBandwidth = totalBandwidth-bw;
            backgroundDataRate = sum(totalDataRate)-dataRates(j);
            t = [backgroundDataRate/2; dataRates(j); backgroundDataRate/2]/100;
            backgroundEfficiency = backgroundDataRate/backgroundBandwidth;
            x_c = [backgroundEfficiency; x(j); backgroundEfficiency];
            x_f = [0; backgroundBandwidth/4+bw/2; backgroundBandwidth/2+bw]/100;
            x_in = [x_c; x_f];
            psd = psd0*ones(3, 1);
            tmpNoise = [0; accumulateNoise(j); 0];
            tmp = nlcon(x_in, psd, t, Nspan, alpha, beta, gamma, Nase, gb, tmpNoise);
            finalNoise(j) = (tmp(2)*1e-17+psd0*1e-15/Nspan)/snrfcn(x(j));
        end
    end
end

function y = snrfcn(x)
% relaxed snr function
y = 2.209*exp(0.3392*x)-0.6598;
end