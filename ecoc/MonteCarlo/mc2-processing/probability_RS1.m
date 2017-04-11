clc;
clear;
close all;

Cnx = loadCnx('Cnx.csv');
Ii = Cnx>0;
Ii_prob = mean(Ii, 2);
[Ii_sort_prob, Ii_sort_idx] = sort(Ii_prob, 'descend');

% load routing
templateDataStruct = load('../templateDemandStruct.mat');
DemandStructMD = templateDataStruct.DemandStructMD;
N = 75;
pathOnNode = zeros(N, 1);
for i=1:N
    pathOnNode(i) = length(DemandStructMD.SetOfDemandsOnNode{i});
end

pathOnNode = pathOnNode-2;
NodeProbRO = pathOnNode./sum(pathOnNode);

%% scatter of RS prob. vs node prob. estimated by the routing scheme
% figure();
% hold on;
% plot(NodeProbRO, Ii_prob./sum(Ii_prob), 'o')
% plot([0, .06], [0, .06])


%% sorted probability
figure();
hold on; box on;
plot(Ii_sort_prob./sum(Ii_sort_prob), 'linewidth', 1, ...
    'displayname', 'Proposed algorithm')
plot(sort(NodeProbRO, 'descend'), 'linewidth', 1, ...
    'displayname', 'Routing only')
legend('show')
set(gca, 'fontsize', 14)
xlabel('Sorted node index', 'fontsize', 16)
ylabel('Probability of RS', 'fontsize', 16)
set(gca, 'plotboxaspectratio', [7, 4, 1])
set(gca,'position',[0.15 -0 0.80 1],'units','normalized')

filename = sprintf('figures/PA_RSprob_vs_routing_only.fig');
savefig(filename)
filename = sprintf('figures/PA_RSprob_vs_routing_only.png');

rez=600; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file 

%%
% set(gca, 'fontsize', 14)
% xlabel('Number of RS', 'fontsize', 16)
% ylabel('Probability', 'fontsize', 16)
% xlim([9, 17])
% 
% % save figure
% set(gca, 'plotboxaspectratio', [7, 4, 1])
% set(gca,'position',[0.12 -0 0.85 1],'units','normalized')
% 
% filename = sprintf('figures/PA_#RS_histogram.fig');
% savefig(filename)
% filename = sprintf('figures/PA_#RS_histogram.png');
% 
% rez=600; %resolution (dpi) of final graphic
% f=gcf; %f is the handle of the figure you want to export
% figpos=getpixelposition(f); %dont need to change anything here
% resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
% set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
% print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file 
