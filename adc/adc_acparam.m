function result = adc_acparam(data, nbits, fs, fc, fsr)
%ADC_ACPARAM   Single-tone analysis of ADC dynamic parameters (SNR, SINAD,
%   SFDR, THD, ENOB) with coherent sampling method.
%
%   result = ADC_ACPARAM(data, nbits, fs, fc, fsr)
%
%   Inputs:
%       data: ADC raw data [counts]
%       nbits: ADC number of bits
%       fs: sampling frequency [Hz]
%       fc: carrier frequency [Hz]
%       fsr: full-scale range [Vpp]

%   Copyright (C) 2013 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)

if any(size(data) == 1)
    % Ensures data is a column vector
    data = data(:);
end

npts = size(data, 1);
DFT_PG = npts/2;
% lsb = fsr/(2^nbits);

df = fs/npts;
half_npts = ceil(npts/2+1);

% Process each dataset
empty_cell = cell(size(data,2),1);
result = struct(...
    'ADC_specs', empty_cell, ...
    'SNR_dBFS_theoretical', empty_cell, ...
    'SNR', empty_cell, ...
    'SNR_dBFS', empty_cell, ...
    'SFDR_dBc', empty_cell, ...
    'SFDR_dBFS', empty_cell, ...
    'f_max_spur_bin', empty_cell, ...
    'THD', empty_cell, ...
    'THD_dBc', empty_cell, ...
    'DFT_PG_dB', empty_cell, ...
    'SINAD', empty_cell, ...
    'SINAD_dBFS', empty_cell, ...
    'ENOB', empty_cell, ...
    'noisefloor_dBFS', empty_cell ...
);

for i=1:size(data,2)
    ADC_specs = struct(...
        'nbits', nbits, ...
        'fs', fs, ...
        'fc', fc(i), ...
        'fsr', fsr ...
    );

    % Find the 10 first harmonics bins (including carrier)
    fif = calcalias(fc(i), fs);
    F = fc(i)*(1:10);
    F = calcalias(F, fs);
    Fbins = findfreqbin(F, fs, npts);
    if Fbins(1) - floor(Fbins(1)) ~= 0
        error('The entered carrier frequency (column %d of ''data'') is not coherent with the sampling frequency and number of points.', i);
    end
    dft = abs(fft(data(:,i)));

    % 'fseries' is the single-sided Fourier series normalized to the full-scale
    fseries = dft(1:half_npts);
    if rem(npts,2) > 0
        fseries = [fseries(1); 2*fseries(2:end)];
    else
        fseries = [fseries(1); 2*fseries(2:end-1); fseries(end)];
    end
    fseries = fseries/(2^nbits)/DFT_PG;

    % Noise floor estimate
    noisefloor = mean(fseries(setdiff(1:half_npts, [1 Fbins])));

    % Signal
    S = fseries(Fbins(1));

    % Noise
    fseries_N = fseries(setdiff(1:half_npts, [1 Fbins]));
    N = sqrt(sum(fseries_N.^2));

    % Noise + harmonic distortion
    fseries_NAD = fseries(setdiff(1:half_npts, [1 Fbins(1)]));
    NAD = sqrt(sum(fseries_NAD.^2));

    % Harmonic distortion
    fseries_D = fseries(Fbins(2:end));
    fseries_D(fseries_D < sqrt(10)*noisefloor) = 0;
    D = sqrt(sum(fseries_D.^2));

    % Find worst-case spurious
    fseries_ac_nocarrier = fseries;
    fseries_ac_nocarrier([1 Fbins(1)]) = noisefloor;
    [spur f_max_spur_bin] = max(fseries_ac_nocarrier);

    % Theoretical SNR limit for full-scale signal
    SNR_dB_factor1 = 20*log10(2);
    SNR_dB_factor2 = 20*log10(sqrt(1.5));
    SNR_dBFS_theoretical = SNR_dB_factor1*nbits + SNR_dB_factor2;

    % 'FS_dB' is the signal/full-scale power ratio in dB
    FS_dB = 20*log10(S);

    % Calculate ADC AC characteristics
    SNR = 20*log10(S/N);
    SNR_dBFS = SNR - FS_dB;
    SINAD = 20*log10(S/NAD);
    SINAD_dBFS = SINAD - FS_dB;
    SFDR_dBc = 20*log10(S/spur);
    SFDR_dBFS = SFDR_dBc - FS_dB;
    THD = D/S;
    THD_dBc = 20*log10(THD);
    ENOB = (SINAD_dBFS - SNR_dB_factor2)/SNR_dB_factor1;
    noisefloor_dBFS = 20*log10(noisefloor);
    DFT_PG_dB = 10*log10(DFT_PG);

    % Store ADC AC characteristics for each run
    result(i).ADC_specs = ADC_specs;
    result(i).SNR_dBFS_theoretical = SNR_dBFS_theoretical;
    result(i).SNR = SNR;
    result(i).SNR_dBFS = SNR_dBFS;
    result(i).SFDR_dBc = SFDR_dBc;
    result(i).SFDR_dBFS = SFDR_dBFS;
    result(i).f_max_spur_bin = f_max_spur_bin;
    result(i).spur = spur;
    result(i).THD = THD;
    result(i).THD_dBc = THD_dBc;
    result(i).DFT_PG_dB = DFT_PG_dB;
    result(i).SINAD = SINAD;
    result(i).SINAD_dBFS = SINAD_dBFS;
    result(i).ENOB = ENOB;
    result(i).noisefloor_dBFS = noisefloor_dBFS;
end

% Show results
plot_adc_acparam(result, fseries, df, Fbins);
