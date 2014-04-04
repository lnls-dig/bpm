close all
clear all

physical_constants;
% Accelerator characteristics
sirius_parameters;
sirius_bpmparameters;

R0 = bpm.pickup.button.R0;      % Real part of impedance

beta = storagering.beta;        % Beam percentual speed (in relation to c)

frf = storagering.frf;          % RF frequency

bd = button.diameter;           % Button diameter [m]
cr=chamber.radius;               %chamber radius

c=3e8;

Iavg=[0.001:0.001:0.5];%Average current on the machine

Power=10.*log10( 1000*2*pi^2*(bd/2)^4./(cr^2*beta^2*c^2)*R0*frf^2.*Iavg.^2);

figure
plot(Iavg*1000,Power,'Linewidth',3)

xlabel('Current (mA)','fontsize',16,'FontWeight', 'bold')
ylabel('Signal (dBm)','fontsize',16,'FontWeight', 'bold');
grid on
set(gca,'FontSize',12)
title('500 MHz signal at BPM button', 'FontSize', 16, 'FontWeight', 'bold');
