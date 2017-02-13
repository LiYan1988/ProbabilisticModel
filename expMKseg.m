function exp = expMKseg(k, i, h)
% the expectation value of the number of k-hop segments in an h-hop path
% with i regenerators

s = min(floor(h/k), i+1); % max number of k-hop segments
m = zeros(s, 1);
for j=1:s
    try
    m(j) = probMKseg(j, k, i, h)*j;
    catch
        disp(j, k, i, h)
    end
end
exp = sum(m);