function [RS, Rp, Cd] = barebone(networkCostMatrix, tr, c_r, c_m)

N = size(networkCostMatrix, 1); % number of nodes
C = 1:N;
Asap = graphallshortestpaths(sparse(networkCostMatrix)); % ASAP in #span

Eadj = Asap<=tr; % adjacent matrix of augment graph
Ecost = Eadj;
P = Eadj; % initial path matrix
RS = []; % regen sites
tmp = networkCostMatrix;
tmp(isinf(tmp)) = 0;
newCost = c_r*Ecost+c_m*tmp;
newCost(isnan(newCost)) = 0;
D = graphallshortestpaths(sparse(newCost)); % cost

Rp = [];
for i=1:N
    tmpAsap = D;
    tmpAsap(i, :) = [];
    tmpAsap(:, i) = [];
    tmpCost = newCost;
    tmpCost(i, :) = [];
    tmpCost(:, i) = [];
    rmvAsap = graphallshortestpaths(sparse(tmpCost));
    aaa = tmpAsap-rmvAsap;
    Eadjtmp = Eadj;
    Eadjtmp(i, :) = [];
    Eadjtmp(:, i) = [];
    bbb = aaa.*(1-Eadjtmp);
    if min(bbb(:))<0
        Rp(end+1) = i;
    end
    %     flag = true;
    %     for s=1:N-1
    %         for t=1:N-1
    %             if Eadjtmp(s, t)==0 && aaa(s, t)==0
    %                 flag = false;
    %                 break
    %             end
    %         end
    %         if ~flag
    %             break
    %         end
    %     end
    %     if flag
    %         Rp(end+1) = i;
    %     end
end

C(Rp) = [];
for i=1:length(Rp)
    P = updateP(P, D, Rp(i));
end
RS = Rp;

while sum(P(:))<N*N && length(RS)<N && ~isempty(C)
    % select cb, the best node
    r = rank2(P, D);
    cb = find(r==max(r));
    P = updateP(P, D, cb(1));
    % update RS
    RS(end+1) = cb(1);
    % update C
    C(C==cb(1)) = [];
end

newCost2 = newCost;
newCost2(newCost2==0) = inf;
Cd = zeros(nchoosek(N, 2), N);
n = 1;
for s=1:N
    for t=s+1:N
        [path, ~] = dijkstra(newCost2, s, t);
        for i=2:length(path)-1
            if ismember(path(i), RS)
                Cd(n, path(i)) = 1;
            end
        end
        n = n+1;
    end
end