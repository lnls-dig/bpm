close all
clear all

physical_constants;
% Accelerator characteristics
sirius_parameters;
sirius_bpmparameters;

% Test setup
x0=0;                           % X Beam position
y0=0;                           % Y Beam position
nharmonics=1000;                % Number of harmonics that is used on calculations
t0=50e-12;                      % Initial time

R0 = bpm.pickup.button.R0;      % Real part of impedance

beta = storagering.beta;        % Beam percentual speed (in relation to c)

frf = storagering.frf;          % RF frequency
Ib = 1e-3;                      % Single bunch current
T_r = storagering.h/frf;        % revolution period
tfinal = 1/storagering.frf;     
bl = storagering.bunchLength;   % bunch length ()    
Att = bpm.cable.attenuator;     % Attenuation of the cable
fe = bpm.cable.fe;              % characteristic frequency for the LMR195, according to times microwave
cablelength = bpm.cable.length; % Cable length in meters
bd = button.diameter;           % Button diameter [m]
h=storagering.h;                %harmonic number

N=nharmonics*h;
% Revolution frequency [Hz]
Q0 = Ib*T_r;                    % bunch charge (single bunch)

%Calculations:
CovF = beamcoverage(bpm.pickup, [x0 y0]);    % Beam coverage factor
Cb = calccapacitance(bpm.pickup.button);    % Button capacitance

% m is the index of the beam revolution harmonics
m = 0:nharmonics*h;

% Frequency and angular frequency vectors
frev = frf/(h);                 % revolution frequency
f = frev*m;

Z=R0./(1+j*2*pi.*f*R0*Cb);

Ibeam=Ib.*exp(-(2*pi.*f).^2*bl^2/2-j*2*pi*f*t0);    % beam current in frequency domain 
Iim=max(CovF)*bd/(beta*c)*j*2*pi.*f.*Ibeam;         % image current on the vacuum chamber walls
Vbutton=Z.*Iim;                                     % button voltage

Ibeamt=N/2*ifft(Ibeam);                             % beam current - time domain    
Iimt=N/2*ifft(Iim);                                 % Image current - time domain

Vcable=exp(-(1+j).*sqrt(f./fe)).*Vbutton;           % Voltage at cable output. Model considering skin loss

H=(0.356859.*sqrt(f/1e6)+0.00047.*f/1e6)*25/(0.3048*100); % Loss @ coax cable according to Times microwave model for LMR195

VbuttondB=volt2dbm(Vbutton',R0);                    % Power spectrum at button
VcableTimes = VbuttondB'-H;                         % Power spectrum minus cable loss

Vbuttont=N/2*ifft(Vbutton,'symmetric');             % Button voltage - time domain
Vcablet=N/2*ifft(Vcable,'symmetric');               % Voltage at cable output - time domain
% VcabletTimes=N/2*ifft(VcableTimes,'symmetric');   % Times microwave modeling

Fs=f(end);                                          % sampling frequency
Ts=1/Fs;                                            % sampling period
time=(0:Ts:Ts*N);

% figure
% subplot 121
% plot(time*1e12', [Ibeamt' Iimt'],'Linewidth',3)
% xlabel('Time (ps)','fontsize',16)
% ylabel('Current (A)','fontsize',16);
% set(gca,'FontSize',16)
% grid on
% % axis([0 10 -100 -50])
% 
% subplot 122
% plot(f'/1e9,[abs(Ibeam') abs(Iim')],'Linewidth',3)
% xlabel('Frequency (GHz)','fontsize',16)
% ylabel('Amplitude (A)','fontsize',16);
% title('Horizontal Plane (K_x = 10 mm)', 'FontSize', 16, 'FontWeight', 'bold');
% 
% set(gca,'FontSize',16)
% grid on
% %axis([0 30 0 max(Ibeam)])

figure
subplot 211
plot(time'*1e12,[Vbuttont' Vcablet'],'Linewidth',3)
xlabel('Time (ps)','fontsize',16,'FontWeight', 'bold')
ylabel('Signal (V)','fontsize',16,'FontWeight', 'bold');
set(gca,'FontSize',12)
grid on
h=legend('Signal at BPM button','Signal after cables - RFFE input','After cables Times')
set(h, 'Fontsize',10)
axis([0 500 -10 40])
title('Button BPM, 2 mm thickness, 0.3 mm gap, 6 mm diameter', 'FontSize', 16, 'FontWeight', 'bold');

subplot 212
plot(time'*1e12,[Vcablet' Vcablet'],'Linewidth',3)
xlabel('Time (ps)','fontsize',16,'FontWeight', 'bold')
ylabel('Signal (V)','fontsize',16,'FontWeight', 'bold');
set(gca,'FontSize',12)
grid on
axis([0 500 -0.5 1.5])
title('Signal at RFFE input', 'FontSize', 16, 'FontWeight', 'bold');


figure
title('Button BPM, 2 mm thickness, 0.3 mm gap, 6 mm diameter', 'FontSize', 16, 'FontWeight', 'bold');
plot(time'*1e12,Vbuttont','Linewidth',3)
xlabel('Time (ps)','fontsize',16,'FontWeight', 'bold')
ylabel('Signal (V)','fontsize',16,'FontWeight', 'bold');
set(gca,'FontSize',12)
grid on
h=legend('Button','After cables','After cables Times')
set(h, 'Fontsize',10)
axis([0 500 -10 35])

figure
title('Button BPM, 2 mm thickness, 0.3 mm gap, 6 mm diameter', 'FontSize', 16, 'FontWeight', 'bold');
plot(time'*1e12,[Vcablet' Vcablet'],'Linewidth',3)
xlabel('Time (ps)','fontsize',16,'FontWeight', 'bold')
ylabel('Signal (V)','fontsize',16,'FontWeight', 'bold');
set(gca,'FontSize',12)
grid on
axis([0 1000 -0.5 1.5])

figure
plot(f'/1e9,[volt2dbm(abs(Vbutton'),R0) volt2dbm(abs(Vcable'),R0)],'Linewidth',3)
xlabel('Frequency (GHz)','fontsize',16,'FontWeight', 'bold')
ylabel('Signal (dBm)','fontsize',16,'FontWeight', 'bold');
grid on
set(gca,'FontSize',12)
h=legend('Button','After cables','After cables Times')
set(h, 'Fontsize',10)
axis([0 10 -90 -40])