sirius_parameters;
sirius_acquisitionparameters;

reset(RandStream.getGlobalStream, floor((2^32-1)*rand));

datarates.fofb = datarates.fofb/5*2;

% Parameters
tsim = 0.005;
vco_modelname = 'si571'; % cvhd950, si571
clkdist_modelname = 'ad9510_clkdist';
gains_abcd_d = db2mag(0.5*rand(1,4));
gains_cdab_c = db2mag(0.5*rand(1,4));
phases_abcd_d = 30*rand(1,4);
phases_cdab_c = 30*rand(1,4);
decimation_rate = 'fofb';
cic_nsecs = 2;
cic_ndlys = 1;
gain_compensation = true;
phase_compensation = true;
sausaging = false;
sw_toggle_period = datarates.fofb;
sw_ovlp = 12;
sw_window = [tukeywin(sw_toggle_period+sw_ovlp, 0.03); zeros(sw_toggle_period-sw_ovlp,1)];
sw_phase = floor(sw_toggle_period/2);
desw_phase = sw_phase;
vco_noise = true;
clkdist_noise = false;
Kx = 10e6;
Ky = 10e6;

% Frequencies and numerology
frf = storagering.frf;
h = storagering.h;
hadc = adc.h;
fs = frf*hadc/h;
fif = calcalias(frf, fs);
fsw = 1/2/sw_toggle_period*fs;
npts = floor(tsim*fs/hadc)*hadc;

if size(gains_abcd_d, 1) < 2
    gains_abcd_d = repmat(gains_abcd_d, npts, 1);
end
if size(gains_cdab_c, 1) < 2
    gains_cdab_c = repmat(gains_cdab_c, npts, 1);
end
if size(phases_abcd_d, 1) < 2
    phases_abcd_d = phases_abcd_d*pi/180;
    phases_abcd_d = repmat(phases_abcd_d, npts, 1);
end
if size(phases_cdab_c, 1) < 2
    phases_cdab_c = phases_cdab_c*pi/180;
    phases_cdab_c = repmat(phases_cdab_c, npts, 1);
end

% Build time and amplitudes (A,B,C,D) vectors
t = (0:npts-1)'/fs;

% ABCD signals passing through direct path
abcd_d = gains_abcd_d.*exp(1j*(repmat(2*pi*frf*t, 1, 4) + phases_abcd_d));

% ABCD signals passing through crossed path
cdab_c = gains_cdab_c.*exp(1j*(repmat(2*pi*frf*t, 1, 4) + phases_cdab_c));

% RF channels switching
if sw_toggle_period > 0
    abcd = swap(abcd_d, cdab_c, sw_window, sw_phase);
else
    abcd = abcd_d;
end

% Band-pass filter signals after switching
bpf_filter = design(fdesign.bandpass('N,F3dB1,F3dB2', 10, 0.4, 0.6), 'butter');
abcd_filt_complex = filter(bpf_filter, abcd);

abcd_jitter_complex = abcd_filt_complex;

% Add phase noise to signals due to ADC clock (100% noise correlation)
if vco_noise
    [pn_P, pn_f] = pnmodel(vco_modelname);
    abcd_jitter_complex = addpn(abcd_jitter_complex, frf, fs, pn_P, pn_f, true);
 end

% Add phase noise to signals due to ADC clock distribution (uncorrelated)
if clkdist_noise
    [pn_P, pn_f] = pnmodel(clkdist_modelname);
    abcd_jitter_complex = addpn(abcd_jitter_complex, frf, fs, pn_P, pn_f, false);
end

% De-switching
abcd_deswitched_jitter_complex = swap(abcd_jitter_complex, abcd_jitter_complex(:,[3 4 1 2]), sw_toggle_period, desw_phase);%, tukeywin(sw_toggle_period, 1));

% Build low-pass filter for downconversion
if strcmpi(decimation_rate, 'adc')
    decim = 1;
elseif strcmpi(decimation_rate, 'tbt')
    decim = hadc;
elseif strcmpi(decimation_rate, 'fofb')
    decim = datarates.fofb;
elseif strcmpi(decimation_rate, 'monit')
    decim = datarates.monit;
end

if decim > 1
    lpf_filter = mfilt.cicdecim(decim, cic_ndlys, cic_nsecs);
    ndiscard = cic_nsecs*cic_ndlys;
else
    n = 6;
    [b,a] = butter(n, 2*fif/fs);
    lpf_filter = dfilt.df1(b,a);
    ndiscard = floor(fs/fif*n);
end

% Digital downconversion
abcd_real = real(abcd_deswitched_jitter_complex);
nco = repmat(exp(1j*2*pi*fif/fs*(0:npts-1)'), 1, size(abcd, 2));
if gain_compensation
    nco = nco.*swap(1./gains_abcd_d, 1./gains_cdab_c(:,[3 4 1 2]), sw_toggle_period, desw_phase);
end
if phase_compensation
    nco = nco.*exp(1j*swap(phases_abcd_d, phases_cdab_c(:,[3 4 1 2]), sw_toggle_period, desw_phase));
end
if sausaging
    nco = swap(nco, nco, [2*hamming(sw_toggle_period); zeros(sw_toggle_period, 1)], desw_phase);
end
abcd_baseband_complex = ddc(abcd_real, nco, lpf_filter);

% Crop data to avoid DDC low-pass filter transients
abcd_baseband_complex = abcd_baseband_complex(ndiscard+1:end, :);

% Crop data to have exact number of points enabling coherent sampling FFT
npts_decim = size(abcd_baseband_complex,1);
if sw_toggle_period > 0
    npts_decim = floor(npts_decim/2/sw_toggle_period)*2*sw_toggle_period;
end
abcd_baseband_complex = abcd_baseband_complex(1:npts_decim, :);

% Force resulting signals to be floating point as it makes magnitude and
% phase calculation more efficient
abcd_baseband_complex_dbl = double(abcd_baseband_complex);

% Extract magnitude and phase information
abcd_baseband_mag = abs(abcd_baseband_complex_dbl);
abcd_baseband_phase = unwrap(angle(abcd_baseband_complex_dbl));

% Calculate position
xy = calcpos(abcd_baseband_mag, Kx, Ky);

% Calculate RMS of position vector
rmsxy = std(xy);

% Calculate RMS of position vector within 0-1kHz bandwidth
rmsxy_1k = psdrms(xy, fs/decim, 0, 1e3, [], [], [], 'rms');
rmsxy_1k = rmsxy_1k(end, :);

% Plot ABCD spectrum
%[mag, f] = fourierseries(real(double(abcd_baseband_complex)), fs/decim, hanning(npts_decim));
%figure; plot(f/1e3, 20*log10(mag));

%figure; plot([abcd_baseband_mag(200:800,:),abcd_baseband_phase(200:800,:)])