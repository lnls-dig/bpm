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
beampos = [0 0];
rffe_attval = 14;
% -----------------

sirius_bpmparameters;

% Calculate current and voltage signal spectra on BPM pick-up and BPM cable
%[Ibeam, f] = beamsignal(storagering, storagering.beamCurrentSB, 1, 1500);
%[Ibeam, f] = beamsignal(storagering, [storagering.beamCurrent/648*ones(1,648) zeros(1,216)], 0, 1500);
[Ibeam, f] = beamsignal(storagering, [50e-3/648*ones(1,648) zeros(1,216)], 0, 1500);
%[Ibeam, f] = beamsignal(storagering, [storagering.beamCurrent/648*ones(1,648) zeros(1,107) storagering.beamCurrentSB zeros(1,108)], 0, 1500);
[resp, t] = sirius_button_bpm_resp(Ibeam, f, beampos, rffe_attval);

% Plot results
figure;
plot(t/1e-9, [resp(1:2).signal_time]);
xlabel('Time (ns)');
ylabel('Current (A)');
%title('Beam current and image current at button pick-up');
legend(resp(1:2).name);
grid on;

figure;
plot(t/1e-9, [resp(3:4).signal_time]);
xlabel('Time (ns)');
ylabel('Voltage (V)');
title('Voltage along signal path (BPM pick-up)');
legend(resp(3:4).name);
grid on;

figure;
plot(t/1e-9, [resp(5:11).signal_time]);
xlabel('Time (ns)');
ylabel('Voltage (V)');
legend(resp(5:11).name);
title('Voltage along signal path (RFFE)');
grid on;

figure;
plot(t/1e-9, [resp(12:14).signal_time]);
xlabel('Time (ns)');
ylabel('Voltage (V)');
legend(resp(12:14).name);
title('Voltage along signal path (FMC ADC)');
grid on;
