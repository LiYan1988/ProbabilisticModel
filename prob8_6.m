function p = prob8_6(k, h, i)
% the probability that the mth segment has k hops in a h-hop path with i+1
% segments
p = nchoosek(h-1-i, k-1)*(1/(i+1))^(k-1)*(i/(i+1))^(h-i-k);