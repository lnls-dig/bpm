%% Parameters
sirius_parameters;
sirius_acquisitionparameters;

fixed_point_sim = false;            % Selects type of simulation (floating point or fixed point)
fwidth = 24;                        % [number of bits]
adc_res = adc.resolution;           % AD resolution [bits]
duration = 60e-3;                   % Duration of simulation [s]
h = storagering.h;                  % Accelerator's harmonic number (number of buckets)
adch = adc.h;                       % ADC sampling harmonic
R = 1112;                           % FOFB decimation rate (in relation to ADC sampling frequency)
fswR = 1112;                        % Switching rate (in relation to ADC sampling frequency)
posh = 10;                          % Position signal frequency (in relation to FOFB data rate)
max_pos = 10e-6;                    % Position signal amplitude [m]
K = 8.5e-3;                         % Difference-over-sum gain [m]
noise = 3e-3;                       % AWGN amplitude, relative to carrier

% CIC filter parameters
cic_ndiff = 1;                      % Number of differential delays
cic_nsec = 2;                       % Number of sections
cic_iwl = 24;                       % Input word length [number of bits]
cic_owl = 32;                       % Input word length [number of bits]

% Frequencies
fbeam = storagering.frf;            % Beam carrier frequency [Hz]
fadc = adch/h*fbeam;                % ADC sampling frequency [S/s]
fsw = fadc/fswR;                    % RF channel switching frequency (toggle) [Hz]
Ffofb = fadc/R;                     % FOFB data rate [S/s]
fposition = Ffofb/posh;             % Beam position modulation signal [Hz]

% Switching parameters
sw_transition = rffe.sw_transition; % Switching transition time [s]
ch2_gain = rffe.ch2_gain;           % Gain unbalance in crossed configuration [dB]
ch2_phase = rffe.ch2_phase;         % Phase unbalance in crossed configuration [rad]

% Windowing parameters
windowfcn = @tukeywin2;              % Compensating window function


% Insert file names if you want to print samples for simulation
%adc_file = 'samples.dat'

%%% ----
if fixed_point_sim
    fp = fipref;
    fp.LoggingMode = 'On';

    f = fimath( 'roundmode', 'floor',         ...
                'overflowmode', 'saturate',   ...
                'productmode', 'keepmsb',     ...
                'productwordlength', cic_iwl);
    globalfimath(f);
end

% Calculate precise simulation duration to provide integer number of beam
% singal and switching cycles
duration = ceil(duration*fadc/adch/fswR/posh)*posh*fswR*adch/fadc;

% Build time vector
Ts = 1/fadc;
t = 0:Ts:duration-Ts;

% Beam position vector
position = max_pos*(cos(2*pi*fposition*t)); %max_pos*(cos(2*pi*fp*t) +0.4*cos(2*pi*2*fp*t)+0.75*cos(2*pi*3*fp*t));

%% Analog  and acquired signal simulation
[adc_a, adc_c] = bpm_signal(position, t, fbeam, fadc, fswR, sw_transition, ...
                            ch2_gain, ch2_phase, K, noise);%, adc_file);

if fixed_point_sim == true
    adc_af = sfi(adc_a,adc_res,adc_res-2);
    adc_cf = sfi(adc_c,adc_res,adc_res-2);
end

% Windowing
swindow = repmat(windowfcn(fadc/fsw)',1,round(fsw*duration));
a_windowed = swindow.*adc_a;
c_windowed = swindow.*adc_c;

if fixed_point_sim == true
    swindowf = sfi(swindow,fwidth,fwidth-2);
    a_windowedf = swindowf.*adc_af;
    c_windowedf = swindowf.*adc_cf;
end

%% Digital downconversion
Tfofb = 1/Ffofb;
tfofb = 0 : Tfofb : duration - Tfofb;

cic_f = mfilt.cicdecim(R, cic_ndiff, cic_nsec, cic_iwl, cic_owl);
inv_gain = dfilt.scalar(1/gain(cic_f)); %normalize the CIC
cic_norm = cascade(cic_f,inv_gain);

fif = calcalias(fbeam,fadc);
mix_cos = cos(2*pi*fif*t+pi/30); %a bit displaced to avoid underflow warnings
mix_sin = sin(2*pi*fif*t+pi/30);

if fixed_point_sim == true
    mix_cosf = sfi(mix_cos,fwidth,fwidth-2);
    mix_sinf = sfi(mix_sin,fwidth,fwidth-2);
end

if fixed_point_sim == false
    a_ff_w = downconv(a_windowed, cic_norm, mix_sin, mix_cos);
    a_ff_s = downconv(adc_a,      cic_norm, mix_sin, mix_cos);

    c_ff_w = downconv(c_windowed, cic_norm, mix_sin, mix_cos);
    c_ff_s = downconv(adc_c,      cic_norm, mix_sin, mix_cos);

    a_mag = abs(double(a_ff_w));
    c_mag = abs(double(c_ff_w));
    a_mag_s = abs(double(a_ff_s));
    c_mag_s = abs(double(c_ff_s));

else
    a_ff_wf = downconv(a_windowedf, cic_norm, mix_sinf, mix_cosf);
    a_ff_sf = downconv(adc_af,      cic_norm, mix_sinf, mix_cosf);

    c_ff_wf = downconv(c_windowedf, cic_norm, mix_sinf, mix_cosf);
    c_ff_sf = downconv(adc_cf,      cic_norm, mix_sinf, mix_cosf);

    a_mag = abs(double(a_ff_wf));
    c_mag = abs(double(c_ff_wf));
    a_mag_s = abs(double(a_ff_sf));
    c_mag_s = abs(double(c_ff_sf));
end

% Beam position calculation
calc_pos = K*(a_mag-c_mag)./(a_mag+c_mag);
calc_pos_s = K*(a_mag_s-c_mag_s)./(a_mag_s+c_mag_s);

%% Plotting
% Compute FFTs
[MAF_a_mag, ff_a_mag] = fourierseries(a_mag(50:end), Ffofb, @nuttallwin);
[MAF_c_mag, ff_c_mag] = fourierseries(c_mag(50:end), Ffofb, @nuttallwin);
[MAF_a_mag_s, ff_a_mag_s] = fourierseries(a_mag_s(50:end), Ffofb, @nuttallwin);
[MAF_c_mag_s, ff_c_mag_s] = fourierseries(c_mag_s(50:end), Ffofb, @nuttallwin);

% Ignore the first samples to avoid filter transient
[MAF_calc_pos, ff_calc_pos] = fourierseries(calc_pos(50:end), Ffofb, @nuttallwin);
[MAF_calc_pos_s, ff_calc_pos_s] = fourierseries(calc_pos_s(50:end), Ffofb, @nuttallwin);

% General coloring rules: unswitched signal : green, switched: red,
% sausaged: blue. If overplotting, the second color may be yellow,
% magenta and cyan, respectively.

fig_fft = figure('name','a, c FFT');
plot(ff_a_mag, 20*log10(MAF_a_mag),'b.'); hold on
plot(ff_c_mag, 20*log10(MAF_c_mag),'c.'); hold on
plot(ff_a_mag_s, 20*log10(MAF_a_mag_s),'r.'); hold on
plot(ff_c_mag_s, 20*log10(MAF_c_mag_s),'m.'); hold on
title('FFT for a and c magnitude after filtering');
legend('windowed a', 'windowed c', 'switched a', 'switched c');

fig_pos = figure('name', 'Beam position');
plot(t, position,'g'); hold on;
plot(tfofb, calc_pos(1:length(tfofb)),'b'); hold on;
plot(tfofb, calc_pos_s(1:length(tfofb)),'r'); hold on;
title('Beam position');
legend('original', 'windowed', 'switched');

fig_pfft = figure('name','Beam position FFT');
plot(ff_calc_pos, 20*log10(MAF_calc_pos),'c'); hold on;
plot(ff_calc_pos_s, 20*log10(MAF_calc_pos_s),'r'); hold on;
title('FFT for calculated beam position.');
legend('windowed', 'switched');
