function p = prob8_4(q, i, h)
% calculate the probability that there are i regenerators in a h-hop path
p = q^i*(1-q)^(h-1-i)*nchoosek(h-1, i);
end