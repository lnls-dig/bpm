close all
clear all

Fs = 100000;                    % Sampling frequency
T = 1/Fs;                     % Sample time
L = 100000;                     % Length of signal
t = (0:L-1)*T;                % Time vector
% Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
x = 0.7*exp(-20.*t).*sin(2*pi*50*t) + exp(-5.*(t-T*L/2)).*sin(2*pi*120*t);

%x(1:length(t)) = 1.*t;

y = x + 0.00022*randn(size(t));     % Sinusoids plus noise
plot(Fs*t(1:50),y(1:50))
title('Signal Corrupted with Zero-Mean Random Noise')
xlabel('time (milliseconds)')

NFFT = length(y); % Next power of 2 from length of y
Y = 2*fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

Y2=2*(Y(1:NFFT/2+1));

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1)))
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

y2=fourierseries2time(f,Y2,T*(L-1))

figure
plot(t,y2)
hold on
plot(t,y,'r')



