function [RS, Cdn, Cd, Cn, paths, demandCost] = barebone(networkCostMatrix, tr, c_r, c_m)

N = size(networkCostMatrix, 1); % number of nodes
C = 1:N;
Asap = graphallshortestpaths(sparse(networkCostMatrix)); % ASAP in #span

Eadj = Asap<=tr; % adjacent matrix of augment graph
Ecost = Eadj;
P = Eadj; % initial path matrix
RS = []; % regen sites
% tmp = networkCostMatrix;
tmp = Asap.*Eadj;
tmp(tmp==0) = inf;
newCost = c_r*Ecost+c_m*tmp;
newCost(isnan(newCost)) = 0;
newCost(isinf(newCost)) = 0; % for graphallshortestpaths
D = graphallshortestpaths(sparse(newCost)); % cost

RS = [];
Cdn = cell(N, N);
Cd = zeros(N);
Cn = zeros(N, 1);
while sum(P(:))<N*N && length(RS)<N && ~isempty(C)
    % select cb, the best node
    r = rank2(P, D);
    cb = find(r==max(r));
    [P, Cdn, Cd, Cn] = updateP(P, D, cb(1), Cdn, Cd, Cn);
    % update RS
    RS(end+1) = cb(1);
    % update C
    C(C==cb(1)) = [];
end

%% find shortest paths
load('CoronetASAP.mat')
paths = cell(N, N);
demandCost = zeros(N, N);
for s=1:N
    for t=1:N
        % find RS on path
        %         [tmppath, tmp] = dijkstra(newCost2, s, t);
        %         tmppath = tmppath(2:end-1);
        tmppath = Cdn{s, t};
        if s~=t
            demandCost(s, t) = D(s, t)-c_r; % only intermediate nodes are RS
        end
        if isempty(tmppath)
            % if no RS used, find all nodes on path
            paths{s, t} = ASAPpath{s, t};
            continue
        end
        % if RS used
        tmpInterPath = ASAPpath{s, tmppath(1)};
        paths{s, t} = tmpInterPath(1:end-1);
        for n=2:length(tmppath)
            tmpInterPath = ASAPpath{tmppath(n-1), tmppath(n)};
            paths{s, t}(end+1:end+length(tmpInterPath)-1) = tmpInterPath(1:end-1);
        end
        tmpInterPath = ASAPpath{tmppath(end), t};
        paths{s, t}(end+1:end+length(tmpInterPath)) = tmpInterPath;
    end
end

% RSonPath = cell(N, N);
% CostonPath = zeros(N, N);
% newCost2 = newCost;
% newCost2(newCost2==0) = inf;
% circuit = zeros(nchoosek(N, 2), N);
% nnn = 1;
% for s=1:N
%     for t=s+1:N
%         [tmppath, tmp] = dijkstra(newCost2, s, t);
%         RSonPath{s, t} = tmppath(2:end-1);
%         CostonPath(s, t) = tmp-c_r;
%         circuit(nnn, RSonPath{s, t}) = 1;
%         nnn = nnn+1;
%     end
% end