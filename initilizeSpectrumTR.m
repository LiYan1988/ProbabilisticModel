function bandwidths = initilizeSpectrumTR(dataRates, distance)
% calculate initial spectrum usage by transmission reach mdoel
bandwidths = zeros(size(dataRates));
for i=1:length(dataRates)
    bandwidths(i) = findSpectrumTR(dataRates(i), distance);
end