function calcESEGN(dataRates, Nspan, gb, accumulateNoise, systemParameters)
% calculate the effective spectral efficiency (ESE) from data rates and
% number of spans, on one single link
% accumulateNoise is the accumulated noise from the previous link travelled by
% the demand
% gb is the guardband between neighboring channels
% Outputs are the spectral efficiencies of each traffic demands, and their
% noise estimation

se = updateSpectrumGN2(dataRates, Nspan, gb, accumulateNoise, systemParameters);


