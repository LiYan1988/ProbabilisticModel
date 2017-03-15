close all;
clear;
clc;

x = linspace(0, 1, 1000);
y = log((1+x)./(1-x));

figure; box on; hold on;
plot(x, y)
plot(x(1:end-1), diff(y)/(x(2)-x(1)))
