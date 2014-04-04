close all
clear all

N = 1e5;        % Number of points
df = 10e6;      % Frequency resolution [Hz]
f = df*(0:N-1);

physical_constants;

%Cables characteristics
Att1=0;                 % Attenuation of connectors and cables;

% FFT characteristics
dt = 0.5E-12;           % Time resolution [s]
N = 2^12+1e5;           % Number of points

% Accelerator characteristics
sirius_parameters;
sirius_bpmparameters;

% Test setup
x0=0;                           % X Beam position
y0=0;                           % Y Beam position

T = (N-1)*dt;                   % Max time
df = 1/T;                       % Frequency resolution
t = dt*(0:N-1);                 % Time vector
f = df*(0:N-1);                 % Frequency vector
Fs = 1/dt;                      % Sampling frequency

vin(1:(length(f)/2))=0;
vin(length(f)/2)=1;
vin(length(f)/2+1:length(f))=0;
figure
plot(f,vin)

sirius_bpmparameters;
% 
% Attcable=0.356859.*sqrt(f/1e6)+4.7e-4.*f/1e6;
% 
% figure
% plot(f/1e6,Attcable)


% CoaxialCable
fe=bpm.cable.fe;            % Cable characteristic frequency
Lcable=bpm.cable.length;    % Cable length [m]

C1=sqrt(abs(exp(-(1+j).*sqrt(f./fe).*Lcable/30.5)));

vout = lsim(C1, vin, t);  


%C1=real(exp(-(1+1i)*sqrt(f/fe)*Lcable/30.5));

figure
loglog(f/1e6,C1)
grid minor

figure
plot(f,vout)



