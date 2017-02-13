function exp = prob8_5(q, h)
% calculate the expectation of the length of the longest transparent
% segment in a h-hop path

exp = 0;
for k=1:h
    exp = exp+k*probKSegment(q, k, h);
end

