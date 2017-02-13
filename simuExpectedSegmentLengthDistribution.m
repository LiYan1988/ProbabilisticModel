function ave = simuExpectedSegmentLengthDistribution(q, h, Nsimulations)
% Simulate the length distribution of transparent segment length for 
% regeneration assignment probabilities q on a h-hop path

r = binornd(1,q, [h-1, Nsimulations]);
t = zeros(h, Nsimulations);
x = 1:h-1;
x = x';
edges = (0:h)'+0.5;
for i=1:Nsimulations
    tmp = r(:, i);
    tmp = x.*tmp;
    tmp(tmp==0) = [];
    tmp = [0; tmp; h];
    tmp = diff(tmp);
    t(:, i) = histcounts(tmp, edges)';
end
ave = mean(t, 2);