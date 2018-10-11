%SIRIUS_PARAMETERS
%
%   Type "edit sirius_parameters" to edit parameters.

storagering = struct(...
    'circumference', 518.4, ...         % Ring circumference [m]
    'frf', 499.65e6, ...                % RF accelerating frequency [Hz]
    'bunchLength', 8.8e-12, ...         % Natural bunch length [s]
    'beamCurrent', 500e-3, ...          % Beam current (multi bunch) [A] 
    'beamCurrentSB', 1e-3, ...          % Beam current (single bunch) [A] 
    'h', 864, ...                       % Harmonic number 
    'beta', 1 ...                       % Beam speed (fraction of c)
);


booster = struct(...
    'circumference', 496.800, ...       % Ring circumference [m]
    'frf', 499.65e6, ...                % RF accelerating frequency [Hz]
    'bunchLength', 37.53e-12, ...       % Natural bunch length [s]
    'beamCurrent', 2e-3, ...            % Beam current (multi bunch) [A] 
    'beamCurrentSB', 2.4e-6, ...        % Beam current (single bunch) [A] 
    'h', 828, ...                       % Harmonic number 
    'beta', 1 ...                       % Beam speed (fraction of c)
);
