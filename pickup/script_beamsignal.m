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
nbunches = 1; %700;
beampos = [0 0];
rffe_attval = 14;
% -----------------

sirius_bpmparameters;

% Calculate current and voltage signal spectra on BPM pick-up and BPM cable
[Ibeam, f] = bunchfseries(storagering, Iavg, nbunches, 1500);
[resp1, t] = bpm_resp(Ibeam, f, bpm, storagering, beampos);
[resp2, t] = rffe_v2_resp (resp1(end).signal_freq, f, rffe_attval, storagering.frf);
[resp3, t] = fmcadc130m_resp(resp2(end).signal_freq, f);

% Plot results
figure;
plot(t/1e-9, [resp1(1:2).signal_time]);
xlabel('Time (ns)');
ylabel('Current (A)');
title('Beam current and image current at button pick-up');
legend(resp1(1:2).name);
grid on;

figure;
plot(t/1e-9, [resp1(3:4).signal_time]);
xlabel('Time (ns)');
ylabel('Voltage (V)');
title('Voltage along signal path');
legend(resp1(3:4).name);
grid on;

figure;
plot(t/1e-9, [resp2(:).signal_time]);
xlabel('Time (ns)');
ylabel('Voltage (V)');
legend(resp2(:).name);
title('Voltage along signal path');
grid on;

figure;
plot(t/1e-9, [resp3(:).signal_time]);
xlabel('Time (ns)');
ylabel('Voltage (V)');
legend(resp3(:).name);
title('Voltage along signal path');
grid on;