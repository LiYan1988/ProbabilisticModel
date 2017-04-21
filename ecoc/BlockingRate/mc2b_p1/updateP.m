function [P, Cdn, Cd, Cn]=updateP(P, D, cb, Cdn, Cd, Cn)

N = size(P, 1);
for i=1:N
    for j=1:N
        if (j~=cb) && (i~=cb) && (P(i, j)==0) && (P(i, cb)==1) && (P(cb, j)==1) && (D(i, cb)+D(cb, j)==D(i, j))
            P(i, j) = 1;
            Cdn{i, j} = [Cdn{i, cb}, cb, Cdn{cb, j}];
            Cd(i, j) = length(Cdn{i, j});
            Cn(Cdn{i, j}) = Cn(Cdn{i, j}) + 1;
        end
    end
end