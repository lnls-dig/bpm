function [X,freq]=positivefft(x,Fs)

N=length(x);
k=0:N-1;
T=N/Fs;
freq=k/T; %create the frequency range
X=fft(x)/N; % normalize the data
cutOff = ceil(N/2);
X = X(1:cutOff);
freq = freq(1:cutOff);