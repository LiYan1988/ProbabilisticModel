clc;
clear;
close all;

Cnx = loadCnx('Cnx.csv');
Cn_prob = Cnx./sum(Cnx, 1);
Cn_prob = mean(Cn_prob, 2);
[Cn_sort_prob, Cn_sort_idx] = sort(Cn_prob, 'descend');

templateDataStruct = load('../templateDemandStruct.mat');
DemandStructMD = templateDataStruct.DemandStructMD;
N = 75;
pathOnNode = zeros(N, 1);
for i=1:N
    pathOnNode(i) = length(DemandStructMD.SetOfDemandsOnNode{i});
end

pathOnNode = pathOnNode-2;
NodeProbRO = pathOnNode./sum(pathOnNode);

%%
Nsimu = size(Cnx, 2);
M = 50;
M0 = 1;
bhRS = [33 19 71 3 9 45 56 8 52 15 7 37 17 5 27 43 28 6 50 23];
outageProb = zeros(Nsimu, M);
for th=M0:M0+M-1
    RStmp = Cn_sort_idx(1:th);
    for n=1:Nsimu
        Iitmp = find(Cnx(:, n));
        outageRS = setdiff(Iitmp, RStmp);
        outageProb(n, th-M0+1) = sum(NodeProbRO(outageRS));
    end
    fprintf('%d okay\n', th)
end
outageProb = mean(outageProb, 1);
save('probability_outage2.mat')
%%
% outageProb2 = zeros(Nsimu, 1);
% for n=1:Nsimu
%     Iitmp = find(Cnx(:, n));
%     outage2 = setdiff(Iitmp, bhRS);
%     outageProb2(n) = sum(NodeProbRO(outageRS));
% end
% outageProb2 = mean(outageProb2);
%% sorted probability
figure();
box on;
semilogy(M0:M0+M-1, outageProb, 'linewidth', 1, ...
    'displayname', 'Proposed algorithm')
set(gca, 'fontsize', 14)
xlabel('Number of RSs', 'fontsize', 16)
ylabel('Blocking probability', 'fontsize', 16)
set(gca, 'plotboxaspectratio', [7, 4, 1],'XGrid','on','YGrid',...
    'on','YMinorTick','on','YScale','log')
set(gca,'position',[0.15 -0 0.80 1],'units','normalized')

filename = sprintf('figures/probability_outage2.fig');
savefig(filename)
filename = sprintf('figures/probability_outage2.png');

rez=600; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file

%%
a = load('probability_outage1.mat');
outageProb1 = a.outageProb;
box on;
semilogy(M0:M0+M-1, outageProb1, 'linewidth', 1, ...
    'displayname', 'Prob.-RS')
hold on;
semilogy(M0:M0+M-1, outageProb, 'linewidth', 1, ...
    'displayname', 'Prob.-Regenerator')
legend('show')
set(gca, 'fontsize', 14)
xlabel('Number of RSs', 'fontsize', 16)
ylabel('Blocking probability', 'fontsize', 16)
set(gca, 'plotboxaspectratio', [7, 4, 1],'XGrid','on','YGrid',...
    'on','YMinorTick','on','YScale','log')
set(gca,'position',[0.15 -0 0.80 1],'units','normalized')

filename = sprintf('figures/probability_outage_compare.fig');
savefig(filename)
filename = sprintf('figures/probability_outage_compare.png');

rez=600; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file
