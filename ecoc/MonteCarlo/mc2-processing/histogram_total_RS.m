clc;
clear;
close all;

Cnx = loadCnx('Cnx.csv');
Ii = Cnx>0;
nIi = sum(Ii, 1);

figure();
histogram(nIi, 'normalization', 'probability')
set(gca, 'fontsize', 14)
xlabel('Number of RS', 'fontsize', 16)
ylabel('Probability', 'fontsize', 16)
xlim([9, 17])

%%
set(gca,'yticklabel',[], 'xticklabel', []) %Remove tick labels
% Get tick mark positions
yTicks = get(gca,'ytick');
xTicks = get(gca, 'xtick');
ax = axis; %Get left most x-position
HorizontalOffset = 0.1;
% Reset the ytick labels in desired font
for i = 1:length(yTicks)
%Create text box and set appropriate properties
     text(ax(1) - HorizontalOffset,yTicks(i),['$' num2str( yTicks(i)) '$'],...
         'HorizontalAlignment','Right','interpreter', 'latex', ...
         'fontsize', 14);   
end
% Reset the xtick labels in desired font 
minY = min(yTicks);
verticalOffset = 0.03;
for xx = 1:length(xTicks)
%Create text box and set appropriate properties
     text(xTicks(xx)+0.15, minY - verticalOffset, ['$' num2str( xTicks(xx)) '$'],...
         'HorizontalAlignment','Right','interpreter', 'latex', ...
         'fontsize', 14);   
end

%%
xlabel('Number of RSs', 'interpreter', 'latex', ...
    'Position', [13 -0.045 0], 'fontsize', 16);
ylabel('Probability', 'interpreter', 'latex', 'Position', ...
    [8.4 0.2 0], 'fontsize', 16);

set(gca, 'plotboxaspectratio', [7, 3, 1])

%% save figure
filename = sprintf('figures/PA_#RS_histogram.fig');
savefig(filename)
filename = sprintf('figures/PA_#RS_histogram.pdf');

rez=600; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(f, filename,'-dpdf') %save file 
