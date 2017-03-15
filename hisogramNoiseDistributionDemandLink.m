function [ALL, XCI, XCIUB, XCIPerLink, XCIUBPerLink] = ...
    hisogramNoiseDistributionDemandLink(idxDemand, idxLink, ...
    demandsNoise, pathName, Nbin)
% plot histogram of noise distribution for demand idxDemand on link idxLink

demandsNoiseXCIPerLink = demandsNoise.XCIPerLink;
demandsNoiseXCI = demandsNoise.XCI;
demandsNoiseALL = demandsNoise.ALL;
demandsNoiseXCIUB = demandsNoise.XCIUB;
demandsNoiseXCIUBPerLink = demandsNoise.XCIUBPerLink;
demandsNoiseALLUB = demandsNoise.ALLUB;

ALL = demandsNoiseALL(idxDemand, :);
XCI = demandsNoiseXCI(idxDemand, :);
XCIUB = demandsNoiseXCIUB(idxDemand, :);
XCIUBPerLink = squeeze(demandsNoiseXCIUBPerLink(idxDemand, idxLink, :));
XCIPerLink = squeeze(demandsNoiseXCIPerLink(idxDemand, idxLink, :));
ALLUB = demandsNoiseALLUB(idxDemand, :);

ALL(ALL==0) = [];
XCI(XCI==0) = [];
XCIUB(XCIUB==0) = [];
XCIUBPerLink(XCIUBPerLink==0) = [];
XCIPerLink(XCIPerLink==0) = [];
ALLUB(ALLUB==0) = [];

%%
figure1 = figure(1);
histogram(ALL, Nbin, 'normalization', 'probability')
hold on;
histogram(ALLUB, Nbin, 'normalization', 'probability')
grid on;
box on;
title('Total noise distribution')
xlabel('PSD (\muW/THz)')
ylabel('Probability')

set(gca, 'plotboxaspectratio', [7, 4, 1])
set(gca,'position',[0.1 -0 0.85 1],'units','normalized')
filename = sprintf('figures2/%s-noise-total.fig', pathName);
savefig(filename)
filename = sprintf('figures2/%s-noise-total.png', pathName);
rez=600; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file 

%%
figure2 = figure(2);
histogram(XCI, Nbin, 'normalization', 'probability')
hold on;
histogram(XCIUB, Nbin, 'normalization', 'probability')
grid on;
box on;
title('XCI distribution')
xlabel('PSD (\muW/THz)')
ylabel('Probability')

set(gca, 'plotboxaspectratio', [7, 4, 1])
set(gca,'position',[0.1 -0 0.85 1],'units','normalized')
filename = sprintf('figures2/%s-xci-total.fig', pathName);
savefig(filename)
filename = sprintf('figures2/%s-xci-total.png', pathName);
rez=600; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file 

%%
figure3 = figure(3);
h1 = histogram(XCIPerLink, Nbin, 'normalization', 'probability', 'displayname', 'Simulation');
hold on;
h2 = histogram(XCIUBPerLink, Nbin, 'normalization', 'probability', 'displayname', 'Upper bound');
grid on;
box on;
title('XCI per link distribution')
xlabel('PSD (\muW/THz)')
ylabel('Probability')
legend([h1, h2])
set(gca, 'plotboxaspectratio', [7, 4, 1])
set(gca,'position',[0.1 -0 0.85 1],'units','normalized')
filename = sprintf('figures2/%s-xci-per-link.fig', pathName);
savefig(filename)
filename = sprintf('figures2/%s-xci-per-link.png', pathName);
rez=600; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(f,filename,'-dpng',['-r',num2str(rez)],'-opengl') %save file 


