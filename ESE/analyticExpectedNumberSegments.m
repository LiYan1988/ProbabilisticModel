function exp = analyticExpectedNumberSegments(q, k, h)
% calculate the analytic expectation of the number of k-hop segments in a
% h-hop path with regeneration assignment probability q

exp = 0;
for i=0:h-k
    if i==0
        if k==h
            exp = prob8_4(q, i, h);
        end
    else
        tmp = expMKseg(k, i, h);
        exp = exp+tmp*prob8_4(q, i, h);
    end
end