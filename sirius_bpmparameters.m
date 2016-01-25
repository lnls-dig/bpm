%SIRIUS_BPMPARAMETERS
%
%   Type "edit sirius_bpmparameters" to edit parameters.

% chamber = struct(...
%     'type', 'octogonal', ...
%     'up', 45e-3, ...                       % Vacuum chamber up face width [m]
%     'down', 45e-3, ...                     % Vacuum chamber down face width [m]
%     'left', 3e-3, ...                      % Vacuum chamber left height [m]
%     'right', 3e-3, ...                     % Vacuum chamber right height [m]
%     'height', 11e-3, ...                   % Vacuum chamber height [m]
%     'width', 66e-3, ...                    % Vacuum chamber width [m]
%     'buttonDistance', 25e-3 ...            % Horizontal distance of buttons from the center [m]
% );

chamber = struct(...
    'type', 'circular', ...
    'radius', 12e-3 ...                 % Vacuum chamber radius [m]
);

button = struct(...
    'type', 'round', ...
    'diameter', 6e-3, ...               % Button diameter [m]
    'gap', 0.3e-3, ...                  % Button gap [m]
    'thickness', 2e-3, ...              % Button thickness [m]
    'R0', 50, ...                       % Load impedance [ohm]
    'Cb_meas', 2.6e-12 ...             % Measured capacitance [F]
);

pickup = struct(...
    'type', 'button', ...
    'button', button, ...
    'chamber', chamber ...             % BPM vaccum chamber geometry
);

cable = struct(...
    'attenuator', 2, ...                % fixed attenuation - conectors [dB]
    'fe', 0.75e9, ...                   % Characteristic frequency of the cable [Hz]
    'length', 25, ...                   % Cable Length [m]
    'Ccab', 83.3e-12, ...               % Cable capacitance per meter
    'Icab', 0.21e-6, ...                % Cable  inductance per meter
    'radius', 0.47e-3, ...              % Inner conductor radius
    'mu', 1.256629e-6, ...              % Copper permeability
    'sigma', 5.96e7 ...                 % Copper conductivity
);

bpm = struct(...
    'pickup', pickup, ...
    'cable', cable ...
);
