close all
clear all

nbunches=1;
beampos=[0 0];

Iavg=1;

physical_constants;

sirius_parameters
sirius_bpmparameters

h = storagering.h;
frf = storagering.frf;
bl = storagering.bunchLength;
beta = storagering.beta;
R0 = bpm.pickup.button.R0;
bd = bpm.pickup.button.diameter;
fe = bpm.cable.fe;
cablelength = bpm.cable.length;

nharmonicsRF=1500;

tfinal = 1/storagering.frf;

% Revolution frequency [Hz]
frev = frf/h;

% Filling ratio (0 <= dfill <= 1)
dfill = nbunches/h;

% m is the index of the beam revolution harmonics
m = 0:nharmonicsRF*h;

f = frev*m;
omega = 2*pi*f;

% Frequency and angular frequency vectors
f = frev*m;
omega = 2*pi*f;

% Calculate the charge [C] of each bunch based on average beam current
Q0 = Iavg/frev*nbunches;
t0=500e-12;
%Ibeam = Q0*exp(-2*pi^2*bl^2*f.^2).*exp(-1j*1/2/frf*f);
Ibeam = length(f)/2*Q0/sqrt(2*pi)*exp(-1/2*bl^2*(2*pi)^2.*f.^2-j*2*pi.*f*t0);

figure
plot(f,abs(Ibeam));
title('SignalCalculation')

CovF = beamcoverage(bpm.pickup, beampos, 500);

Iim = max(CovF)*bd/(beta*c)*(1j*omega).*Ibeam;

figure
plot(f,Iim)
ylabel('Corrente imagem SignalCalculation.m')

% Calculate button impedance
Cb = calccapacitance(bpm.pickup.button);
Z0 = R0*Cb;

% Button response (convert image current to voltage on button)
Vim = R0./(1j*omega*Z0 + 1).*Iim;

% Coaxial cable response
Vcable = exp(-sqrt(abs(f)/fe)*cablelength/30.5).*exp(-sign(f).*1j.*sqrt(abs(f)/fe)*cablelength/30.5).*Vim;

 signalVim = fourierseries2time(f, Vim, tfinal);
 [signalVcable, t] = fourierseries2time(f, Vcable, tfinal);

        figure
        subplot 121
        plot(t,signalVim)
        subplot 122
        plot(t,signalVcable)



NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
figure
plot(f,2*abs(Y(1:NFFT/2+1)))
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')


%         signalBDiameter = [signalBDiameter; signalVim];
%         signalMaxDiameter(i) = max(abs(signalVim));
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Equivalent model for the button capacitance+50R impedance%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% buttonResponse = tf([R0],[Cb*R0 1]);
% % Button voltage (time domain)
% Vbutton = lsim(buttonResponse, Iim, t);
%
% % Button voltage (frequency domain)
% VBUTTON = (fft(Vbutton));
%
% figure
% subplot 121
% plot(t,Vbutton)
% subplot 122
% plot(f,VBUTTON)
%
% %% A potencia em dBm deve ser baseado no c?lculo, usando freq = Fs*(0 : N/2) / N; e Ys=(2/N*abs(Y(1 : N/2+1)));
% VBUTTONdBm = volt2dbm(2/N*abs(VBUTTON(1 : N/2+1)), 50);
%
% % figure
% % subplot 121
% % plot(t,Vbutton)
% % subplot 122
% % plot(freq,VBUTTONdBm)
%
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %Equivalent model for the Coaxial cable, considering skin effect%
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% freq = Fs*(0 : N/2-1) / N;
% C=exp(-sqrt(abs(freq)/fe)*cablelength/30.5).*exp(-sign(freq).*1j.*sqrt(abs(freq)/fe)*cablelength/30.5);
% VCABLE = C'.*VBUTTON(1 : N/2);
%
% freq = Fs*(0 : N/2-1) / N;
% VCABLEsym=2/N*VCABLE(1 : N/2);
%
% VCABLEsym= N/2*[VCABLE fliplr(conj(VCABLE))];
% Vcable=ifft(VCABLEsym);
%
% figure
% subplot 122
% plot(f,VCABLE)
% subplot 121
% plot(t,Vcable)
%
% %% A potencia em dBm deve ser baseado no c?lculo, usando freq = Fs*(0 :
% %% N/2) / N; e Ys=(2/N*abs(Y(1 : N/2+1)));
% %FVim2dBm = volt2dbm(2/N*abs(FVim2), 50);
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%Equivalent model for the BandPass Filter%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rf=50;              %Second order BPF
% Rf1=10;
% Lf=0.1e-6;
% Cf=1e-12;
%
% sys3=tf([Rf/Lf 0],[1 (Rf+Rf1)/Lf 1/(Lf*Cf)]);
% %
% % Vim3 = lsim(sys3,abs(Vim2),t);
% % FVim3=fft(Vim3);
% %
% % %% A potencia em dBm deve ser baseado no c?lculo, usando freq = Fs*(0 :
% % %% N/2) / N; e Ys=(2/N*abs(Y(1 : N/2+1)));
% % FVim3dBm = volt2dbm(2/N*abs(fft(Vim3)), 50);
% %
% %
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %%%%%%%%%%%%Equivalent model for the Osciloscope - LPF%%%%%%%%%%%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % sys4=tf(1,[5e-11 1]);
% %
% % Vim4 = lsim(sys4, abs(Vim3), t);
% % Vim4=Vim4/(10^(2*Att1/10));
% %
% % FVim4=fft(Vim4);
% %
% %
% % %% A potencia em dBm deve ser baseado no c?lculo, usando freq = Fs*(0 :
% % %% N/2) / N; e Ys=(2/N*abs(Y(1 : N/2+1))); FVim4dBm = volt2dbm(2/N*abs(fft(Vim4)), 50);
% %
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %%%%%%%%%%%%Plot Results%%%%%%%%%%%%%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % figure
% % % plot(t*1e9,Ibeam,'Linewidth',3)
% % % xlabel('time(ns)')
% % % ylabel('Current (A)')
% % % title('Beam Current = Image Current')
% % % % axis([23 27 0 45])
% % % grid on
% % % grid minor
% %
% % % figure
% % % [AX,H1,H2]=plotyy(t*1e9,Vbutton,t*1e9,Iim);
% % % set(get(AX(1),'Ylabel'),'String','Button voltage(V)','FontSize',14)
% % % set(get(AX(2),'Ylabel'),'String','Button current(A)','FontSize',14)
% % % % set(H1,'Linewidth',3)
% % % % set(H2,'Linewidth',3)
% % % % set(AX(1),'YLim',[-100 250])
% % % % set(AX(1),'YTick',[-100:20:250])
% % % % set(AX(2),'YLim',[-15 15])
% % % % set(AX(2),'YTick',[-15:2:15])
% % % % % set(AX(1),'Xlim',[24.5 26]);
% % % % % set(AX(2),'Xlim',[24.5 26]);
% % % xlabel('time(ns)','FontSize',14)
% % % title('Voltage and Current onto the Button considering geometric parameters')
% % % grid on
% % % grid minor
% %
% % %%%%%%%%%
% %
% % %
% % % figure
% % % subplot(121)
% % % plot(t*1E9,Vbutton,'LineWidth',3)
% % % xlabel('time (ps)','FontSize',14)
% % % ylabel('Voltage Vbutton (Volts)','FontSize',14)
% % % title('Button Voltage')
% % % %axis([24 27 min(Vbutton) max(Vbutton)])
% % % grid on
% % % grid minor
% % % subplot(122)
% % % plot(f/1E9,FVbuttondBm,'LineWidth',2)
% % % %axis([-1 20 -70 15])
% % % xlabel('Frequency(GHz)','FontSize',14)
% % % ylabel('Power (dBm)','FontSize',14)
% % % title('Button Power Spectrum')
% % % grid on
% % % grid minor
% % %
% % % % %%%%%%%%%
% % % figure
% % % subplot(2,2,1)
% % % plot(t*1e9,Vbutton,'Linewidth',3)
% % xlabel('Time(ns)')
% % ylabel('Voltage Vbutton (V)')
% title('Button Signal')
% grid on
% grid minor
% subplot(2,2,2)
% plot(f/1E9,FVbuttondBm,'LineWidth',2)
% xlabel('Frequency (GHz)')
% ylabel('Power (dBm)')
% title('Button Signal')
% grid on
% grid minor
%
% subplot(2,2,3)
% plot(t*1e9,Vim2,'Linewidth',3)
% xlabel('Time(ns)')
% ylabel('Voltage Vim2 (V)')
% title('Signal After Cables')
% grid on
% grid minor
% subplot(2,2,4)
% plot(f/1E9,FVim2dBm,'LineWidth',2)
% xlabel('Frequency (GHz)')
% ylabel('Power (dBm)')
% title('Signal After Cables')
% grid on
% grid minor
%
% %%%%%%%
% figure
% subplot(2,2,1)
% plot(t*1e9,Vbutton,'Linewidth',3)
% xlabel('Time(ns)')
% ylabel('Voltage Vbutton(V)')
% title('Button Signal')
% grid on
% grid minor
% subplot(2,2,2)
% plot(f/1E9,FVbuttondBm,'LineWidth',2)
% xlabel('Frequency (GHz)')
% ylabel('Power (dBm)')
% title('Button Signal')
% grid on
% grid minor
%
% subplot(2,2,3)
% plot(t*1e9,Vim3,'Linewidth',3)
% xlabel('Time(ns)')
% ylabel('Voltage Vim3(V)')
% title('Signal After Cables and BPF')
% grid on
% grid minor
% subplot(2,2,4)
% plot(f/1E9,FVim3dBm,'LineWidth',2)
% xlabel('Frequency (GHz)')
% ylabel('Power (dBm)')
% title('Signal After Cables and BPF')
% grid on
% grid minor
%
%
% %%%%%%%%
% figure
% subplot(2,2,1)
% plot(t*1e9,Vbutton,'Linewidth',3)
% xlabel('Time(ns)')
% ylabel('Voltage Vbutton (V)')
% title('Button Signal')
% grid on
% grid minor
% subplot(2,2,2)
% plot(f/1E9,FVbuttondBm,'LineWidth',2)
% xlabel('Frequency (GHz)')
% ylabel('Power (dBm)')
% title('Button Signal')
% grid on
% grid minor
%
% subplot(2,2,3)
% plot(t*1e9,Vim4,'Linewidth',3)
% xlabel('Time(ns)')
% ylabel('Voltage Vim4 (V)')
% title('Signal After Cables and connectors')
% grid on
% grid minor
% subplot(2,2,4)
% plot(f/1E9,FVim4dBm,'LineWidth',2)
% xlabel('Frequency (GHz)')
% ylabel('Power (dBm)')
% title('Signal After Cables and connectors')
% grid on
% grid minor
