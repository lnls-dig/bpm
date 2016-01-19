function [resp, t] = rffe_v2_resp(input_signal, f, att1_val, frf)

f = f(:);
input_signal = input_signal(:);

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
amp_gain = 10;
amp_nonlinearity = [-0.048634 1 0];

% Attenuator (Mini-circuits DAT-31R5-SP)
att1 = 10^(-1.5/20)*10^(-att1_val/20);

% RFFE-FMC ADC coaxial cable
cable_il = 10^(-0.5/20);

% Build frequency responses along signal path
names = {'RFFE input', 'RFFE LPF #1', 'RFFE BPF #1', 'RFFE Amp #1', 'RFFE Att #1', 'RFFE LPF #2', 'RFFE Amp #2', 'RFFE LPF #3', 'RFFE-FMC ADC coax. cable'};
freqresps = {ones(size(f)), LPF, BPF, amp_gain, att1, LPF, amp_gain, LPF, cable_il};
nonlinearities = {[], [], [],  amp_nonlinearity,[], [], amp_nonlinearity, [], []};

[resp, t] = buildresp(input_signal, f, names, freqresps, nonlinearities);