close all
clear all

Fs=1e2;
Ts=1/Fs;
f0=1;

t=[0:Ts:4*pi];

x=sin(2*pi*f0.*t)

figure
plot(t,x)

[X,frequency]=positivefft(x,Fs)

figure
subplot 121
plot(t,x)
subplot 122
stem(frequency,abs(X))

