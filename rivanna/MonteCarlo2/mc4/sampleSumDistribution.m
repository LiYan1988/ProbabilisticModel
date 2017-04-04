function r = sampleSumDistribution(distributionName, p1, p2, M, Nsamples)
% use Monte Carlo to generate the distribution of a distribution which is
% the sum of multiple iid distributions
% distributionname: 'normal' or 'uniform'
% p1: mean of normal or lower bound of uniform
% p2: std of normal, or upper bound of uniform
% p3: number of iid distribution
% M: number of demands on the link
% Nsamples: number of samples

if strcmp(distributionName, 'uniform')
    r = max(0, unifrnd(p1, p2, [Nsamples, M]));
elseif strcmp(distributionName, 'normal')
    r = max(0, normrnd(p1, p2, [Nsamples, M]));
end
r = sum(r, 2);
