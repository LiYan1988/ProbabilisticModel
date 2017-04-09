function [P, Cd]=updateP(P, D, cb, Cd)

N = size(P, 1);
n = 1;
for i=1:N
    for j=1:N
        if (j~=cb) && (i~=cb) && (P(i, j)==0) && (P(i, cb)==1) && (P(cb, j)==1) && (D(i, cb)+D(cb, j)==D(i, j))
            P(i, j) = 1;
            Cd(n, cb) = 1;
        end
        n = n+1;
    end
end