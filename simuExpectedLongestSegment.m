function ave = simuExpectedLongestSegment(q, h, Nsimulations)
% Simulate the expected longest transparent segment length for 
% regeneration assignment probabilities q on a h-hop path

r = binornd(1,q, [h-1, Nsimulations]);
t = zeros(Nsimulations, 1);
x = 1:h-1;
x = x';
for i=1:Nsimulations
    tmp = r(:, i);
    tmp = x.*tmp;
    tmp(tmp==0) = [];
    tmp = [0; tmp; h];
    tmp = diff(tmp);
    t(i) = max(tmp);
end
ave = mean(t);