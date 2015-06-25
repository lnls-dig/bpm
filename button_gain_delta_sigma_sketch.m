%% Script to ilustrate delta/sigma button gain

close all;
clear all;

t = 0:0.01:1;

aw = 0.25*square(2*pi*3.5*t)+0.5;

cw = 0.25*square(2*pi*3.5*t)-0.5;


plot(t,aw,t,cw)
% axis([-1 1 -1 1])