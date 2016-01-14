%SCRIPT_BEAMSIGNAL Analysis of voltage signals at the RF front-end input
%   and internal signal path.
%
%   Edit the script file to choose the following parameters:
%       Iavg: average beam current [A]
%       tfinal: final time instant for time-domaion simulations [s]
%       beampos: horizontal and vertical beam position [m]

%   Copyright (C) 2012 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)

function script_beamsignal

% -----------------
% Script parameters
% -----------------
sirius_parameters;
Iavg = storagering.beamCurrentSB;
tfinal = 1/storagering.frf;
beampos = [0 0];
bd_sweep = 3e-3:1e-3:7e-3;              % Uncomment/Comment this line to use/unuse sweep
gap_sweep = 0.1e-3:0.1e-3:0.4e-3;       % Uncomment/Comment this line to use/unuse sweep
thickness_sweep = 2e-3:1e-3:5e-3;       % Uncomment/Comment this line to use/unuse sweep
% -----------------

% Sweep of button diameter
if exist('bd_sweep', 'var') && ~isempty(bd_sweep)
    sirius_bpmparameters;
    signalBDiameter = [];
    signalMaxDiameter = zeros(length(bd_sweep),1);
    for i = 1:length(bd_sweep)
        bpm.pickup.button.diameter = bd_sweep(i);

        % Calculate current and voltage signal spectra on BPM pick-up and BPM cable
        r = bunchfseries(storagering, bpm, Iavg, 1, beampos, 1500);

        % Convert spectra to time-domain representation
        signalVim = fourierseries2time(abs(r.Vim), angle(r.Vim), r.freq);
        [signalVcable, t] = fourierseries2time(abs(r.Vcable), angle(r.Vcable), r.freq);

        signalBDiameter = [signalBDiameter; signalVim];
        signalMaxDiameter(i) = max(abs(signalVim));
    end

    % Plot results
    figure;
    subplot(121)
    plot(t/1e-9,signalBDiameter);
    xlabel('Time (ns)');
    ylabel('Voltage (V)');
    title(sprintf('Voltage at button for a %0.2f mm gap, %0.2f mm thick button', bpm.pickup.button.gap*1e3, bpm.pickup.button.thickness*1e3));
    legend(buildlegend('\\phi = %0.2f mm', bd_sweep*1e3));
    grid on
    subplot(122)
    plot(bd_sweep*1e3,signalMaxDiameter)
    xlabel('Button diameter (mm)');
    ylabel('Peak Voltage (V)');
    title(sprintf('Peak Voltage at button as function of button diameter for a %0.2f mm gap, %0.2f mm thick', bpm.pickup.button.gap*1e3, bpm.pickup.button.thickness*1e3));
    grid on
end

% Sweep of button gap
if exist('gap_sweep', 'var') && ~isempty(gap_sweep)
    sirius_bpmparameters;
    signalBGap = [];
    signalMaxGap = zeros(length(gap_sweep),1);
    for i = 1:length(gap_sweep)
        bpm.pickup.button.gap = gap_sweep(i);

        % Calculate current and voltage signal spectra on BPM pick-up and BPM cable
        r = bunchfseries(storagering, bpm, Iavg, 1, beampos, 1500);

        % Convert spectra to time-domain representation
        signalVim = fourierseries2time(abs(r.Vim), angle(r.Vim), r.freq);
        [signalVcable, t] = fourierseries2time(abs(r.Vcable), angle(r.Vcable), r.freq);

        signalBGap = [signalBGap; signalVim];
        signalMaxGap(i) = max(abs(signalVim));
    end

    % Plot results
    figure;
    subplot(121)
    plot(t/1e-9,signalBGap);
    xlabel('Time (ns)');
    ylabel('Voltage (V)');
    title(sprintf('Voltage at button for a %0.2f mm diameter, %0.2f mm thick button', bpm.pickup.button.diameter*1e3, bpm.pickup.button.thickness*1e3));
    legend(buildlegend('gap = %0.2f mm', gap_sweep*1e3));
    grid on
    subplot(122)
    plot(gap_sweep*1e3,signalMaxGap)
    xlabel('Button gap (mm)');
    ylabel('Peak Voltage (V)');
    title(sprintf('Peak Voltage at button for a %0.2f mm diameter, %0.2f mm thick button', bpm.pickup.button.diameter*1e3, bpm.pickup.button.thickness*1e3));
    grid on
end

% Sweep of button thickness
if exist('thickness_sweep', 'var') && ~isempty(thickness_sweep)
    sirius_bpmparameters;
    signalBThickness = [];
    signalMaxThickness = zeros(length(thickness_sweep),1);
    for i=1:length(thickness_sweep)
        bpm.pickup.button.thickness = thickness_sweep(i);

        % Calculate current and voltage signal spectra on BPM pick-up and BPM cable
        r = bunchfseries(storagering, bpm, Iavg, 1, beampos, 1500);

        % Convert spectra to time-domain representation
        signalVim = fourierseries2time(abs(r.Vim), angle(r.Vim), r.freq); 
        [signalVcable, t] = fourierseries2time(abs(r.Vcable), angle(r.Vcable), r.freq);

        signalBThickness = [signalBThickness; signalVim];
        signalMaxThickness(i) = max(abs(signalVim));
    end

    % Plot results
    figure;
    subplot(121)
    plot(t/1e-9,signalBThickness);
    xlabel('Time (ns)');
    ylabel('Voltage (V)');
    title(sprintf('Voltage at button for a %0.2f mm diameter, %0.2f mm gap button', bpm.pickup.button.diameter*1e3, bpm.pickup.button.gap*1e3));
    legend(buildlegend('thick = %0.2f mm', thickness_sweep*1e3));
    grid on
    subplot(122)
    plot(thickness_sweep*1e3,signalMaxThickness)
    xlabel('Button thickness (mm)');
    ylabel('Peak Voltage (V)');
    title(sprintf('Peak Voltage at button for a %0.2f mm diameter, %0.2f mm gap button', bpm.pickup.button.diameter*1e3, bpm.pickup.button.gap*1e3));
    grid on
end

sirius_bpmparameters;
% Calculate current and voltage signal spectra on BPM pick-up and BPM cable
r = bunchfseries(storagering, bpm, Iavg, 1, beampos, 1500);

% Convert spectra to time-domain representation
signalVim = fourierseries2time(abs(r.Vim), angle(r.Vim), r.freq);
signalIbeam = fourierseries2time(abs(r.Ibeam), angle(r.Ibeam), r.freq);
signalIim = fourierseries2time(abs(r.Iim), angle(r.Iim), r.freq);
[signalVcable, t] = fourierseries2time(abs(r.Vcable), angle(r.Vcable), r.freq);

% Bandpass filtering on the RF front-end
% Second order BPF
Rf = 50;
Rf1 = 10;
Lf = 0.1e-6;
Cf = 1e-12;
sys_bpf = tf([Rf/Lf 0],[1 (Rf+Rf1)/Lf 1/(Lf*Cf)]);
signalVbpf = lsim(sys_bpf, signalVcable, t)';

% Plot results
figure;
plot(t/1e-9, [signalIbeam(:) signalIim(:)]);
xlabel('Time (ns)');
ylabel('Current (A)');
title('Beam current and image current at button (nominal button parameters)');
legend('Beam current','Image current');
grid on

figure;
plot(t/1e-9, [signalVim(:) signalVcable(:)]);
xlabel('Time (ns)');
ylabel('Voltage (V)');
legend('Voltage at button', 'Voltage at RF front-end input');
title('RF front-end voltages (nominal button parameters)');
grid on

figure;
plot(t/1e-9,[signalVcable(:) signalVbpf(:)]);
xlabel('Time (ns)');
ylabel('Voltage (V)');
title('RF front-end voltages (nominal button parameters)');
legend('RF front-end input voltage', 'RF front-end BPF output voltage');
grid on














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
% 
% figure
% title('Button BPM, 2 mm thickness, 0.3 mm gap, 6 mm diameter', 'FontSize', 16, 'FontWeight', 'bold');
% plot(time'*1e12,[Vbuttont' Vcablet'],'Linewidth',3)
% xlabel('Time (ps)','fontsize',16,'FontWeight', 'bold')
% ylabel('Signal (V)','fontsize',16,'FontWeight', 'bold');
% set(gca,'FontSize',12)
% grid on
% h=legend('Button','After cables - RFFE input');
% set(h, 'Fontsize',10)
% axis([0 500 -10 40])
% 
% figure
% plot(f'/1e9,[volt2dbm(abs(Vbutton'),R0) volt2dbm(abs(Vcable'),R0)],'Linewidth',3)
% xlabel('Frequency (GHz)','fontsize',16,'FontWeight', 'bold')
% ylabel('Signal (dBm)','fontsize',16,'FontWeight', 'bold');
% grid on
% set(gca,'FontSize',12)
% h=legend('Button','After cables');
% set(h, 'Fontsize',10)
% axis([0 10 -90 0])

function legend_labels = buildlegend(text, variables)

if any(size(variables) == 1)
    variables = variables(:);
end

legend_labels = cell(size(variables,1),1);
for i=1:size(variables,1)
    legend_labels{i} = sprintf(text, variables(i,:));
end