function p = probMKseg(m, k, i, h)
% calculate the probability of having m k-hop segments in an h-hop path
% with i regenerators

cnt = 0; % count the number of such cases 
s = h-(k-1)*m-i-1; % sum of all indexes
tmax = floor(s/k);
for t=0:tmax
    rmax = min(floor((s-t*k)/(k-1)), i+1-m-t);
    for r=0:rmax
        j = s-t*k-r*(k-1);
        cnt = cnt+(-1)^(r)*nchoosek(i+j-m,j)*factorial(i+1-m)/...
            (factorial(r)*factorial(t)*factorial(i+1-m-r-t));
    end
end

p = cnt/nchoosek(h-1, i)*nchoosek(i+1, m);