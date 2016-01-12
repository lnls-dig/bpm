%SIRIUS_PARAMETERS
%
%   Type "edit sirius_parameters" to edit parameters.

storagering = struct(...
    'circumference', 518.246, ...       % Ring circumference [m]
    'frf', 499.798e6, ...               % RF accelerating frequency [Hz]
    'bunchLength', 8.8e-12, ...         % Natural bunch length [s]
    'beamCurrent', 350e-3, ...          % Beam current (multi bunch) [A] 
    'beamCurrentSB', 1e-3, ...          % Beam current (single bunch) [A] 
    'h', 864, ...                       % Harmonic number 
    'beta', 1 ...                       % Beam speed (fraction of c)
);
