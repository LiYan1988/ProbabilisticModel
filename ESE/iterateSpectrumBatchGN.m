function bandwidths = iterateSpectrumBatchGN(dataRates, distance, niter, systemParameters)
% calculate bandwidth usage iteratively using GN model
bandwidths = initilizeSpectrumTR(dataRates, distance);

nstep = 0;
while nstep<niter
    bandwidths = updateSpectrumBatchGN(bandwidths, dataRates, distance, systemParameters);
    nstep = nstep+1;
end