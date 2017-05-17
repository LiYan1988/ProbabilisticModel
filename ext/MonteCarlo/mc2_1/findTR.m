function [tr] = findTR(bandwidth, se)
% find the transmission reach for given modulation formats
if nargin<2
    se = [2, 4, 6, 8, 10, 12];
end

load('transmissionReach.mat')
seidx = zeros(1, length(se));
for i=1:length(se)
    seidx(i) = find(spectralEfficiency==se(i));
end
bridx = min(bandwidth*se/10, 200);
tr = Nreach(bridx, seidx);
tr = diag(tr);
