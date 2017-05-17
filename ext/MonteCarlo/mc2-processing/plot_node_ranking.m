clc;
clear;
close all;

Cnx = loadCnx('Cnx.csv');
Ii = Cnx>0;
Ii_prob = mean(Ii, 2);
[Ii_sort_prob, Ii_sort_idx] = sort(Ii_prob, 'descend');

Cn_prob = Cnx./repmat(sum(Cnx, 1), 75, 1);
Cn_prob = mean(Cn_prob, 2);
[Cn_sort_prob, Cn_sort_idx] = sort(Cn_prob, 'descend');

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

%% sorted probability
figure();
hold on; box on;
plot(Ii_sort_prob./sum(Ii_sort_prob), 'linewidth', 1, ...
    'displayname', 'RS based', 'linestyle', '-.')
plot(Cn_sort_prob./sum(Cn_sort_prob), 'linewidth', 1, ...
    'displayname', 'RC based', 'linestyle', '--')
plot(sort(NodeProbRO, 'descend'), 'linewidth', 1, ...
    'displayname', 'Routing only$^{1}$', 'linestyle', '-')
set(gca, 'fontsize', 14)
% xlabel('Sorted node index', 'fontsize', 16)
% ylabel('Relative frequency', 'fontsize', 16)
legend('show')
xlim([1, 75])
set(gca, 'ytick', [0, 0.1, 0.2])
h = legend('show');
h.Interpreter = 'latex';

%%
set(gca,'yticklabel',[], 'xticklabel', []) %Remove tick labels
% Get tick mark positions
yTicks = get(gca,'ytick');
xTicks = get(gca, 'xtick');
ax = axis; %Get left most x-position
HorizontalOffset = 1;
% Reset the ytick labels in desired font
for i = 1:length(yTicks)
%Create text box and set appropriate properties
     text(ax(1) - HorizontalOffset,yTicks(i),['$' num2str( yTicks(i)) '$'],...
         'HorizontalAlignment','Right','interpreter', 'latex', ...
         'fontsize', 14);   
end
% Reset the xtick labels in desired font 
minY = min(yTicks);
verticalOffset = 0.018;
for xx = 1:length(xTicks)
%Create text box and set appropriate properties
     text(xTicks(xx)+1.5, minY - verticalOffset, ['$' num2str( xTicks(xx)) '$'],...
         'HorizontalAlignment','Right','interpreter', 'latex', ...
         'fontsize', 14);   
end

%%
xlabel('Sorted node index', 'interpreter', 'latex', ...
    'Position', [38 -0.025 0], 'fontsize', 16);
ylabel('Normalized frequency', 'interpreter', 'latex', 'Position', ...
    [-4 0.1 0], 'fontsize', 16);

set(gca, 'plotboxaspectratio', [7, 3, 1])

%% save figure
filename = sprintf('figures/NodeRankingRS.fig');
savefig(filename)
filename = sprintf('figures/NodeRankingRS.pdf');

rez=600; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(f, filename,'-dpdf') %save file 
