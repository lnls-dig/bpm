%% Script to ilustrate delta/sigma button gain

close all;
clear all;

t = -0.5:0.0001:1;

al = 0.25;
aw = 0.125*square(2*pi*3.5/2*t)+al;

cl = -0.25;
cw = 0.125*square(2*pi*3.5/2*t+pi)+cl;

plot(t,aw,t,cw,[t(1) t(end)*1.2],[al al],'r--',[t(1) t(end)*1.2],[cl cl],'r--')
axis equal
axis([-1 1.2 -0.6 0.6])
set(gca,'xtick',[],'ytick',[])
