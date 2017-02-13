function se = seSingleLink(dataRates, distance, systemParameters, method)
% calculate the overall average spectrum efficiency given dataRates and
% length of the single link fiber
if strcmp(method, 'GN')
    bd = iterateSpectrumBatchGN(dataRates, distance, 1, systemParameters);
elseif strcmp(method, 'TR')
    bd = initilizeSpectrumTR(dataRates, distance);
end
se = sum(dataRates)/sum(bd);
