close all
clear all

physical_constants;

%Cables characteristics
Att1=0;                 % Attenuation of connectors and cables;

% FFT characteristics
dt = 0.5e-11;           % Time resolution [s]
N = 2e-9/dt;            % Number of points

% Accelerator characteristics
sirius_parameters;
sirius_bpmparameters;

% Test setup
x0=0;                           % X Beam position
y0=0;                           % Y Beam position

T = (N-1)*dt;                   % Max time
df = 1/T                        % Frequency resolution
t = dt*(0:N-1);                 % Time vector
f = df*(0:N-1);                 % Frequency vector
Fs = 1/dt;                      % Sampling frequency

R0 = bpm.pickup.button.R0;

beta = storagering.beta;        % Beam percentual speed (in relation to c)

frf = storagering.frf;          % RF frequency
Ib = 7e-3;                      % Single bunch current
T_r = storagering.h/frf;
tfinal = 1/storagering.frf;
bl = storagering.bunchLength;
Att = bpm.cable.attenuator;     % Attenuation of the cable
fe = bpm.cable.fe;
cablelength = bpm.cable.length;      % Cable length in meters
bd = button.diameter;           % Button diameter [m]
h=storagering.h;                %harmonic number

% Revolution frequency [Hz]
frev = frf/h;
t0=500e-12;

Q0 = Ib*T_r;

%Beam current (gaussian profile) TIME DOMAIN
Ibeam = Q0/(sqrt(2*pi)*bl)*exp(-(t-t0).^2/(2*bl^2));

%Calculations:
CovF = beamcoverage(bpm.pickup, [x0 y0]);    % Beam coverage factor

Cb = calccapacitance(bpm.pickup.button);    % Button capacitance

% Current at button 1 (negative x axis; positive y axis):
Iim = bd*CovF(1)/(beta*c)*diff(Ibeam)/dt;            % Button 1 - image current
Iim(length(Iim)+1) = Iim(length(Iim));

figure
plot(t*1e9,Ibeam)
xlabel('Time (ns)')
ylabel('Current (A)')
hold on
plot(t*1e9,Iim,'r')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Equivalent model for the button capacitance+50R impedance%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
buttonResponse = tf([R0],[Cb*R0 1]);
% Button voltage (time domain)
Vbutton = lsim(buttonResponse, Iim, t);

[VBUTTON,frequency]=positivefft(Vbutton,Fs);

figure
subplot 121
plot(t*1e9,Vbutton)
subplot 122
plot(frequency/1e9,abs(VBUTTON))

Vbutton2=N/2*ifft(VBUTTON,'symmetric');
figure
plot(2*t(1:N/2)*1e9,Vbutton2)

C=exp(-(1+j)*sqrt(frequency/fe)*cablelength/30.5);

% VCABLE = exp(-sqrt(abs(frequency)/fe)*cablelength/30.5).*exp(-sign(frequency).*1j.*sqrt(abs(frequency)/fe)*cablelength/30.5).*VBUTTON';
VCABLE = exp(-(1+j)*sqrt((frequency)/fe)*cablelength/30.5).*VBUTTON';

Vcable=N/2*ifft(VCABLE);
%
% Vbutton3=fourierseries2time(frequency,VCABLE,t(N));
%
% figure
% plot(1:length(Vbutton3),fliplr(Vbutton3))

Vcable=fliplr(Vcable);

figure
subplot 121
plot(t*1e9,Vbutton)
hold on
plot(2*t(1:N/2)*1e9,Vcable,'r')
subplot 122
plot(frequency/1e9,abs(VBUTTON))
hold on
plot(frequency/1e9,abs(VCABLE(1:N/2)),'r')
