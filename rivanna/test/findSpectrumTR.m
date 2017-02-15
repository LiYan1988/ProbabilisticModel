function spectrumUsage = findSpectrumTR(dataRate, distance)
% find the spectrum usage of a demand with dataRate Gbps transmitting
% distance (#spans) in the transmission reach table
% output is bandwidth in GHz

load transmissionReach.mat

dataRate = ceil(dataRate); 
idx = 1; % index of the data rate
while idx<=length(bitRates)
    if bitRates(idx)>=dataRate
        break
    else
        idx = idx+1;
    end
end

jdx = 1; % index of the distance
while Nreach(idx, jdx)>=distance
    jdx = jdx+1;
end
jdx = jdx-1;
if jdx==0
    jdx = 1;
end
spectrumUsage = dataRate/spectralEfficiency(jdx);