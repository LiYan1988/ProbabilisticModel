% plot xci function
clc;
clear;
close all;

%% 
x = linspace(1.01, 10, 1000);

%%
y = log((x+1)./(x-1));
plot(x, y)

%% 
z = asinh(x);
plot(x, z)
hold on;
w = log(x+sqrt(1+x.^2));
plot(x, w, '--')