%ACQUSITION_PARAMETERS
%
%   Type "edit acquisition_parameters" to edit parameters.

adc = struct( ...
            'resolution', 16, ... % AD resolution [bits]
            'h', 203, ...       % ADC sampling harmonic
            'noise', 3e-3);        % AWGN amplitude, relative to carrier);
        
rffe = struct( ...
                'sw_transition',  0e-9,  ... % Switching transition time [s]
                'ch2_gain',      -0.25,  ... % Gain unbalance in crossed configuration [dB]
                'ch2_phase',     pi/10);      % Phase unbalance in crossed configuration [rad] 