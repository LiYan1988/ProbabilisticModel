clc;
clear;
close all;

Cnx = loadCnx();
Ii = Cnx>0;
nIi = sum(Ii, 1);

figure();
histogram(nIi, 'normalization', 'probability')
set(gca, 'fontsize', 14)
xlabel('Number of RS', 'fontsize', 16)
ylabel('Probability', 'fontsize', 16)
xlim([9, 17])

% save figure
set(gca, 'plotboxaspectratio', [7, 4, 1])
set(gca,'position',[0.12 -0 0.85 1],'units','normalized')

filename = sprintf('figures/PA_#RS_histogram.fig');
savefig(filename)
filename = sprintf('figures/PA_#RS_histogram.png');

rez=600; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file 
