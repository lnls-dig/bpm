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
%bd_sweep = 3e-3:1e-3:7e-3;              % Uncomment/Comment this line to use/unuse sweep
%gap_sweep = 0.1e-3:0.1e-3:0.4e-3;       % Uncomment/Comment this line to use/unuse sweep
%thickness_sweep = 2e-3:1e-3:5e-3;       % Uncomment/Comment this line to use/unuse sweep
% -----------------

sirius_bpmparameters;

% Sweep of button diameter
bpm_ = bpm;
if exist('bd_sweep', 'var') && ~isempty(bd_sweep)
    signalBDiameter = [];
    signalMaxDiameter = zeros(length(bd_sweep),1);
    for i = 1:length(bd_sweep)
        bpm_.pickup.button.diameter = bd_sweep(i);

        % Calculate current and voltage signal spectra on BPM pick-up and BPM cable
        r = bunchfseries(storagering, bpm, Iavg, nbunches, beampos, 1500);

        % Convert spectra to time-domain representation
        signal_bpm_Vim = fourierseries2time(abs(r.Vim), angle(r.Vim), r.freq);
        [signal_bpmrffe_Vcable, t] = fourierseries2time(abs(r.Vcable), angle(r.Vcable), r.freq);

        signalBDiameter = [signalBDiameter signal_bpm_Vim];
        signalMaxDiameter(i) = max(abs(signal_bpm_Vim));
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
bpm_ = bpm;
if exist('gap_sweep', 'var') && ~isempty(gap_sweep)
    signalBGap = [];
    signalMaxGap = zeros(length(gap_sweep),1);
    for i = 1:length(gap_sweep)
        bpm_.pickup.button.gap = gap_sweep(i);

        % Calculate current and voltage signal spectra on BPM pick-up and BPM cable
        r = bunchfseries(storagering, bpm, Iavg, nbunches, beampos, 1500);

        % Convert spectra to time-domain representation
        signal_bpm_Vim = fourierseries2time(abs(r.Vim), angle(r.Vim), r.freq);
        [signal_bpmrffe_Vcable, t] = fourierseries2time(abs(r.Vcable), angle(r.Vcable), r.freq);

        signalBGap = [signalBGap signal_bpm_Vim];
        signalMaxGap(i) = max(abs(signal_bpm_Vim));
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
bpm_ = bpm;
if exist('thickness_sweep', 'var') && ~isempty(thickness_sweep)
    signalBThickness = [];
    signalMaxThickness = zeros(length(thickness_sweep),1);
    for i=1:length(thickness_sweep)
        bpm_.pickup.button.thickness = thickness_sweep(i);

        % Calculate current and voltage signal spectra on BPM pick-up and BPM cable
        r = bunchfseries(storagering, bpm, Iavg, nbunches, beampos, 1500);

        % Convert spectra to time-domain representation
        signal_bpm_Vim = fourierseries2time(abs(r.Vim), angle(r.Vim), r.freq); 
        [signal_bpmrffe_Vcable, t] = fourierseries2time(abs(r.Vcable), angle(r.Vcable), r.freq);

        signalBThickness = [signalBThickness signal_bpm_Vim];
        signalMaxThickness(i) = max(abs(signal_bpm_Vim));
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