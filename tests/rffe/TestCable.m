close all
clear all

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

Z0 = bpm.pickup.button.R0;

beta = storagering.beta;        % Beam percentual speed (in relation to c)

frf = storagering.frf;          % Revolution frequency
Ib = 1e-3;                      % Single bunch current
T_r = storagering.h/frf;
BL = storagering.bunchLength;
Att = bpm.cable.attenuator;     % Attenuation of the cable
fe = bpm.cable.fe;
Lcable = bpm.cable.length;      % Cable length in meters
bd = button.diameter;           % Button diameter [m]

radius=bpm.cable.radius;
mu=bpm.cable.mu;
sigma=bpm.cable.sigma;
Cap=bpm.cable.Ccab;
Ind=bpm.cable.Icab;


Q0 = Ib*T_r;

% "BPM Engineering" example
% bd = 15e-3;
% bpm.pickup.chamber.radius = 44e-3;
% bpm.pickup.button.gap = 0.4e-3;
% %bpm.pickup.button.thickness = 0.1e-3;
% BL =  3.3356e-011;
% Ne = 8e10;                       % Number of electrons on the bunch
% Q0 = Ne*e;
% Att = 0;

%Beam current (gaussian profile)
Ibeam = Q0/(sqrt(2*pi)*BL)*exp(-(t-1.5e-8).^2/(2*BL^2));

%Calculations:
CovF = beamcoverage(bpm.pickup, [x0 y0]);    % Beam coverage factor
Cb = calccapacitance(bpm.pickup.button);    % Button capacitance

% Current at button 1 (negative x axis; positive y axis):
Iim = bd*CovF(1)/(beta*c)*diff(Ibeam)/dt;            % Button 1 - image current
Iim(length(Iim)+1) = Iim(length(Iim));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Equivalent model for the button capacitance+50R impedance%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

buttonResponse = tf([Z0],[Cb*Z0 1]);             
% Button voltage (time domain)
Vim1 = lsim(buttonResponse, Iim, t)/(10^(2*Att/10));                          
% Button voltage (frequency domain)

FVim1 = 2/N*(fft(Vim1)); 
FVim1dBm = volt2dbm(FVim1, 50);
FVim1 = fft(Vim1); 

Vim1(1:(length(f)/2))=0;
Vim1(length(f)/2:length(f)/2+10000)=1;
Vim1(length(f)/2+10000:length(f))=0;
FVim1 = fft(Vim1);                       
% Button voltage (frequency domain)

figure
subplot 121
plot(t,Vim1)
Vim1 = ifft(FVim1,'symmetric');
subplot 122
plot(t,Vim1)


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %Equivalent model for the Coaxial cable, considering skin effect%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% C = exp(-sqrt(abs(f)/fe)*Lcable/30.5).*exp(-sign(f).*1j.*sqrt(abs(f)/fe)*Lcable/30.5) + exp(-sqrt(abs(Fs-f)/fe)*Lcable/30.5).*exp(-sign(Fs-f).*1j.*sqrt(abs(Fs-f)/fe)*Lcable/30.5);     %Frequency response of the Cable considering Skin effect. ?? change to attenuation as a function of the cabel size???

%C=sqrt(abs(exp(-(1+j)).*sqrt(f./fe).*Lcable/30.5)));


K=1/(2*pi*radius)*sqrt(mu/sigma);

Coax=exp(-Lcable*sqrt(-4*pi^2*f.^2*Ind*Cap+j*2*pi.*f*Cap*K.*sqrt(j*2*pi.*f)));


sys=tf(1,[5e-11 1]);

Vim2 = lsim(sys, Vim1, t);
FVim2 = fft(Vim2);    

% figure
% subplot 121
% loglog(f,abs(Coax))
% hold on
% loglog(f,Fsys)
% subplot 122
% plot(f,(180/pi*angle(Coax)))

%Vim2 = ifft(FVim2,'symmetric');

figure
subplot 121
plot(t,Vim1)
subplot 122
plot(f,abs(FVim1))

figure
subplot 121
plot(t,Vim2)
subplot 122
plot(f,abs(FVim2))

