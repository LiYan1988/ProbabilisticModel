function r=rank2(P, D)
N = size(D, 1);
r = rank1(P, D)+(N-1)*ramp(P, D);