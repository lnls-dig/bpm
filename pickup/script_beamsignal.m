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
r = bunchfseries(storagering, bpm, Iavg, nbunches, beampos, 1500);

[~ , rffer] = rffe_resp(storagering.frf, r.freq, rffe_attval);
rffe_Vlpf1 = r.Vcable.*rffer.lpf1;
rffe_Vbpf1 = r.Vcable.*rffer.bpf1;
rffe_Vamp1 = r.Vcable.*rffer.amp1;
rffe_Vatt1 = r.Vcable.*rffer.att1;
rffe_Vlpf2 = r.Vcable.*rffer.lpf2;
rffe_Vamp2 = r.Vcable.*rffer.amp2;
rffe_Vlpf3 = r.Vcable.*rffer.lpf3;

[~ , rffeadcr] = rffeadc_resp(r.freq);
rffeadc_Vcable = rffe_Vlpf3.*rffeadcr.cable;

[~ , adcr] = adc_resp(r.freq);
adc_Vafe = rffe_Vlpf3.*adcr.afe;

% BPM time-domain signals
[signal_bpm_Ibeam, t]      = fourierseries2time(abs(r.Ibeam),    angle(r.Ibeam),    r.freq);
[signal_bpm_Iim,   t]      = fourierseries2time(abs(r.Iim),      angle(r.Iim),      r.freq);
[signal_bpm_Vim,   t]      = fourierseries2time(abs(r.Vim),      angle(r.Vim),      r.freq);
[signal_bpmrffe_Vcable, t] = fourierseries2time(abs(r.Vcable),   angle(r.Vcable),   r.freq);
[signal_rffe_Vlpf1, t]     = fourierseries2time(abs(rffe_Vlpf1), angle(rffe_Vlpf1), r.freq);
[signal_rffe_Vbpf1, t]     = fourierseries2time(abs(rffe_Vbpf1), angle(rffe_Vbpf1), r.freq);
[signal_rffe_Vamp1, t]     = fourierseries2time(abs(rffe_Vamp1), angle(rffe_Vamp1), r.freq);
[signal_rffe_Vatt1, t]     = fourierseries2time(abs(rffe_Vatt1), angle(rffe_Vatt1), r.freq);
[signal_rffe_Vlpf2, t]     = fourierseries2time(abs(rffe_Vlpf2), angle(rffe_Vlpf2), r.freq);
[signal_rffe_Vamp2, t]     = fourierseries2time(abs(rffe_Vamp2), angle(rffe_Vamp2), r.freq);
[signal_rffe_Vlpf3, t]     = fourierseries2time(abs(rffe_Vlpf3), angle(rffe_Vlpf3), r.freq);
[signal_rffeadc_Vcable, t] = fourierseries2time(abs(rffeadc_Vcable), angle(rffeadc_Vcable), r.freq);
[signal_adc_Vafe,   t]     = fourierseries2time(abs(adc_Vafe),   angle(adc_Vafe),   r.freq);

% Plot results
figure;
plot(t/1e-9, [signal_bpm_Ibeam signal_bpm_Iim]);
xlabel('Time (ns)');
ylabel('Current (A)');
title('Beam current and image current at button pick-up');
legend('Beam current','Image current');
grid on;

figure;
plot(t/1e-9, [signal_bpm_Vim signal_bpmrffe_Vcable]);
xlabel('Time (ns)');
ylabel('Voltage (V)');
legend('BPM button', 'BPM-RFFE cable');
title('Voltage along signal path');
grid on;

figure;
plot(t/1e-9, [signal_bpmrffe_Vcable signal_rffe_Vlpf1 signal_rffe_Vbpf1 signal_rffe_Vamp1 signal_rffe_Vatt1 signal_rffe_Vlpf2 signal_rffe_Vamp2 signal_rffe_Vlpf3]);
xlabel('Time (ns)');
ylabel('Voltage (V)');
legend('BPM-RFFE cable', 'RFFE LPF #1', 'RFFE BPF #1', 'RFFE Amp #1', 'RFFE Att #1', 'RFFE LPF #2', 'RFFE Amp #2', 'RFFE LPF #3');
title('Voltage along signal path');
grid on;

figure;
plot(t/1e-9, [signal_rffe_Vlpf3 signal_rffeadc_Vcable signal_adc_Vafe]);
xlabel('Time (ns)');
ylabel('Voltage (V)');
legend('RFFE output', 'RFFE-ADC cable', 'ADC front-end');
title('Voltage along signal path');
grid on;

function legend_labels = buildlegend(text, variables)

if any(size(variables) == 1)
    variables = variables(:);
end

legend_labels = cell(size(variables,1),1);
for i=1:size(variables,1)
    legend_labels{i} = sprintf(text, variables(i,:));
end

function [freqresp info] = rffe_resp(frf, f, att1_val)

% Bandpass filter
% Based on Mini-circuits LFCN-530 (https://www.minicircuits.com/pdfs/LFCN-530.pdf)
%flpf_spec = 1e6*[0 1 100 500 530 670 700 815 820 945 1315 2140 3000 3640 4910 6000 Inf];
%Glpf_spec = [0 -0.05 -0.22 -0.73 -0.81 -1.95 -2.89 -26.41 -28.41 -44.98 -39.77 -57.51 -47.94 -42.84 -18.81 -24.8 -24.8];
flpf_spec = 1e6*[0 1 100 500 530 670 700 815 820 945 1315 2140 3000 Inf];
Glpf_spec = [0 -0.05 -0.22 -0.73 -0.81 -1.95 -2.89 -26.41 -28.41 -44.98 -39.77 -57.51 -60 -60];
Glpf = interp1(flpf_spec, Glpf_spec, f);
Glpf = 10.^(Glpf/20);
LPF = mps(Glpf);

% Bandpass filter
% Based on TAI-SAW TA1113A (http://www.taisaw.com/upload/product/TA1113A%20_Rev.1.0_.pdf)
%fbpf_spec = [0 300e3 100e6 200e6 300e6 (frf-20e6) (frf-10e6) (frf+10e6) (frf+40e6) (frf+40e6+2500e6) Inf];
%Gbpf_spec = [-80 -80 -70 -60 -55 -52 -2 -2 -55 0 0];
fbpf_spec = [0 300e3 100e6 200e6 300e6 (frf-20e6) (frf-10e6) (frf+10e6) (frf+40e6) Inf];
Gbpf_spec = [-80 -80 -70 -60 -55 -52 -2 -2 -55 -55];
Gbpf = interp1(fbpf_spec, Gbpf_spec, f);
Gbpf = 10.^(Gbpf/20);
BPF = mps(Gbpf);

% RF amplifier (Mini-circuits TAMP-72LN)
amp1_gain = 10;

% Attenuator (Mini-circuits DAT-31R5-SP)
att1_il = 10^(-1.5/20);

% Build frequency responses along signal path
info.lpf1 = LPF;
info.bpf1 = info.lpf1.*BPF;
info.amp1 = info.bpf1.*amp1_gain;
info.att1 = info.amp1.*att1_il*10^(-att1_val/20);
info.lpf2 = info.att1.*LPF;
info.amp2 = info.lpf2.*amp1_gain;
info.lpf3 = info.amp2.*LPF;

freqresp = info.lpf3;

function [freqresp info] = adc_resp(f)

il = 10^(-2.5/20);

info.afe = il;
freqresp = il;

function [freqresp info] = rffeadc_resp(f)

il = 10^(-0.5/20);

info.cable = il;
freqresp = il;