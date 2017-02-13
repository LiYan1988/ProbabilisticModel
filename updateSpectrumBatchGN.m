function bandwidthsNew = updateSpectrumBatchGN(bandwidthsOld, dataRates, distance, systemParameters)
% Update spectrum usage for all the demands by calling updaeSpectrumGN

bandwidthsNew = zeros(size(bandwidthsOld));
for i=1:length(bandwidthsNew)
    bandwidthsNew(i) = dataRates(i)/updateSpectrumGN(i, dataRates, bandwidthsOld, distance, systemParameters);
end
