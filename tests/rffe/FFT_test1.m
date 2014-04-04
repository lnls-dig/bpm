close all
clear all

sirius_parameters;
sirius_bpmparameters;
physicalconstants;

%Sampling Characteristics
Ts=1e-13;
dt=Ts;
Fs=1/Ts;
N=2e-9/Ts;

t=Ts*(0:N-1);

t0=1000e-12;     %Initial time
Ib=1e-3;        %Beam current

bl = storagering.bunchLength;  %Bunch length
bd = button.diameter;           % Button diameter [m]
frf = storagering.frf;          % RF frequency
beta = storagering.beta;        % Beam percentual speed (in relation to c)
fe = bpm.cable.fe;
cablelength = bpm.cable.length;      % Cable length in meters
x0=0;
y0=0;
T_r = storagering.h/frf;
Q0 = Ib*T_r;

%Beam current (gaussian profile) TIME DOMAIN
Ibeam = Q0/(sqrt(2*pi)*bl)*exp(-(t-t0).^2/(2*bl^2));
Iwindow=[zeros(1,length(t)/4) ones(1,length(t)/2) zeros(1,length(t)/4)];
Ibeam=Ibeam.*Iwindow;
figure
plot(Iwindow)

%Calculations:
CovF = beamcoverage(bpm.pickup, [x0 y0]);    % Beam coverage factor

Cb = calccapacitance(bpm.pickup.button);    % Button capacitance
R0=bpm.pickup.button.R0;

% Current at button 1 (negative x axis; positive y axis):
Iim = bd*CovF(1)/(beta*c)*diff(Ibeam)/dt;            % Button 1 - image current
Iim(length(Iim)+1) = Iim(length(Iim));

figure
plot(t,Iim)
hold on
plot(t,Ibeam, 'r')

buttonResponse = tf([R0],[Cb*R0 1]);
% Button voltage (time domain)
Vbutton = lsim(buttonResponse, Iim, t);

[VBUTTON,freq]=positivefft(Vbutton,Fs);

Vbutton1=fourierseries2time(freq',VBUTTON',Ts*(N+1));

COAXIAL=(exp(-(1+j).*sqrt((freq)/fe)*cablelength/30.5));
figure
subplot 121
plot(freq,angle(COAXIAL))
subplot 122
plot(freq,abs(COAXIAL))

VCABLE1=COAXIAL'.*VBUTTON;

Coaxial=fourierseries2time(freq',(COAXIAL),Ts*(N+1));

Vcable1=fourierseries2time(freq',VCABLE1',Ts*(N+1));

Vcable = conv(Coaxial,Vbutton);

[VCABLE,freq1]=positivefft(Vcable,Fs);

% Vcable=fourierseries2time(freq',(VCABLE),Ts*(N+1));

% syms x y
% a=5;
% f = exp(-a*x^2);
% fourier(f, x, y)
%
% syms t f
% Ibeam = Q0/(sqrt(2*pi)*bl)*exp(-(t-t0).^2/(2*bl^2));
% IBEAM=fourier(Ibeam,t , y);




figure
subplot 121
plot(t,Vbutton)
hold on
subplot 122
plot(freq,abs(VBUTTON))
hold on
subplot 121
plot(t,fliplr(Vcable1))
subplot 122
plot(freq',abs(VCABLE1))
