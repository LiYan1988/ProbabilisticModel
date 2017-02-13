function p = prob8_3(k, i, h)
% calculate equation (8.3), the longest transparent segment has at most k
% hops given there are i regenerators on a h-hop path

rmax = min(i+1, floor((h-i-1)/k));
p = 0;
for r=0:rmax
    p = p+(-1)^r*nchoosek(i+1, r)*nchoosek(h-1-k*r, i);
end
p = p/nchoosek(h-1, i);
end