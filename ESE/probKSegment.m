function p = probKSegment(q, k, h)
% calculate the probability that the longest transparent segment has exact
% k hops in a h-hop path

p = 0;
for i=0:h-1
    tmp = prob8_3(k, i, h)-prob8_3(k-1, i, h);
    tmp = tmp*prob8_4(q, i, h);
    p = p+tmp;
end