function [Ibeam, f] = bunchfseries(accelerator, Iavg, nbunches, nharmonicsRF)
%BUNCHFSERIES Calculate Fourier Series of current and voltage signals for
%   button BPMs (take antenna with higher singal amplitude).
%
%   r = bunchfseries(accelerator, bpm, Iavg, nbunches, beampos, nharmonicsRF)
%
%   Inputs:
%       accelerator: accelerator characteristics
%       bpm: BPM characteristics
%       Iavg: total average beam current [A]
%       nbunches: number of bunches on the beam
%       beampos: horizontal (beampos(1)) and vertical (beampos(2)) beam
%                position [m] - optional (default = [0 0])
%       nharmonicsRF: number of RF harmonics to take into account on the
%                     analysis - optional (default = 100)
%       nharmonicsRev: number of revolution harmonics to take into account
%                      on the analysis - optional (default = 100)
%
%   Outputs:
%       r.freq: frequency vector [Hz]
%       r.Ibeam: Fourier series coefficients of beam current [A]
%       r.Iim: Fourier series coefficients of beam image current [A] on BPM
%              button where signal amplitude is the highest
%       r.Vim: Fourier series coefficients of voltage on button [V]
%       r.Vcable: Fourier series coefficients of voltage at the end of the
%                 coaxial cable (RF front-end input) [V]
%
%   See also FOURIERSERIES2TIME

%   Copyright (C) 2012 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)

if nargin < 4
    nharmonicsRF = 100;
end

h = accelerator.h;
frf = accelerator.frf;
bl = accelerator.bunchLength;

% Time offset for first bunch
t0 = 1/frf/2;

% Revolution frequency
frev = frf/h;

% m is the index of the beam revolution harmonics
m = 0:nharmonicsRF*h;

% Frequency and angular frequency vectors
f = frev*m;

% Calculate the average bunch current
Ib = Iavg/nbunches;

Ibeam=0;
for i=0:nbunches-1
    % One-sided spectrum
    Ibeam = Ibeam + [Ib 2*Ib*exp(-(2*pi.*f(2:end)).^2*bl^2/2 - 1j*2*pi*f(2:end)*(t0+i*1/frf))];
end