function [Ibeam, f] = bunchfseries(accelerator, Iavg, nbunches, nharmonicsRF)
%BUNCHFSERIES Calculate Fourier Series of beam current.
%
%   r = bunchfseries(accelerator, bpm, Iavg, nbunches, nharmonicsRF)
%
%   Inputs:
%       accelerator: accelerator characteristics
%       Iavg: total average beam current [A]
%       nbunches: number of bunches on the beam
%       nharmonicsRF: number of RF harmonics to take into account on the
%                     analysis - optional (default = 100)
%
%   Outputs:
%       Ibeam: Fourier series coefficients of beam current [A]
%       f:     frequency vector [Hz]
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

% Frequency vectors
f = frev*m;

% Calculate the average bunch current
Ib = Iavg/nbunches;

Ibeam=0;
for i=0:nbunches-1
    % One-sided spectrum
    Ibeam = Ibeam + [Ib 2*Ib*exp(-(2*pi.*f(2:end)).^2*bl^2/2 - 1j*2*pi*f(2:end)*(t0+i*1/frf))];
end