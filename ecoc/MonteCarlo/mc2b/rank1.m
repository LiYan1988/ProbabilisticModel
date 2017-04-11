function r = rank1(P, D)
N = size(P, 1);
r = zeros(N, 1);
for v=1:N
    for i=1:N
        for j=1:N
            if (v~=i) && (v~=j) && (P(i, j)==0) && (D(i, v)+D(v, j)==D(i, j))
                r(v) = r(v)+1;
            end
        end
    end
end