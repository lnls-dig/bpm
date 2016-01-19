function [resp, t] = bpm_resp(input_signal, f, bpm, accelerator, beampos)

physical_constants;

fe = bpm.cable.fe;
cablelength = bpm.cable.length;
beta = accelerator.beta;
R0 = bpm.pickup.button.R0;
bd = bpm.pickup.button.diameter;

f = f(:);
input_signal = input_signal(:);

% Beam current to image current (choose button with the highest signal)
CovF = beamcoverage(bpm.pickup, beampos, 500);
beam2bpm_current = max(CovF)*bd/(beta*c)*(1j*2*pi*f);

% Button impedance (response from image current to voltage on button)
Cb = calccapacitance(bpm.pickup.button);
Zbutton = R0./(1+1j*2*pi*f*R0*Cb);

% Coaxial cable response (LMR195)
Zcable = exp(-(1+sign(f).*1j).*sqrt(abs(f)/fe)*cablelength/30.5);

names = {'Beam current', 'BPM button current', 'BPM button voltage', 'Coax. cable (BPM to RFFE)'};
freqresps = {ones(size(f)), beam2bpm_current, Zbutton, Zcable};
nonlinearities = {[], [], [], []};

[resp, t] = buildresp(input_signal, f, names, freqresps, nonlinearities);