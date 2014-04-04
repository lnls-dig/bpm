nbits = 16;
fsr = 2;

% 130 MS/s ADC (204/864*500 MHz = ~118.055 MHz)
fs = 900*131071; % 117963900 Hz
fc = 900*555119; % 499607100 Hz
npts = 131071;

% % 250 MS/s ADC (380/864*500 MHz = ~219.907 MHz)
% fs = 1677*131071; % 219806067 Hz
% fc = 1677*298013; % 499767801 Hz
% npts = 131071;

% % 250 MS/s ADC (376/864*500 MHz = ~217.593 MHz)
% fs = 1660*131071; % 217577860 Hz
% fc = 1660*301183; % 499963780 Hz
% npts = 131071;

A = fsr/2;
dc = A;
noiserms = fsr/1e4;

t = (0:npts-1)/fs;

%sigmf_coeff = 2;

signal_linear = sin(2*pi*fc*t);
%signal_nonlinear = (2*sigmf(signal_linear,[sigmf_coeff 0])-1);
signal = signal_linear;
noise = noiserms*randn(1,npts);

data_analog_ac = A*signal + noise;
data_analog = data_analog_ac + dc;
lsb = fsr/((2^nbits));
data = fix(data_analog/lsb);

% Clip
data(data > (2^nbits)-1) = (2^nbits)-1;
data(data < 0) = 0;

adc_acparam(data, nbits, fs, fc, fsr);