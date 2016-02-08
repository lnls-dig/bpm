function [Ibeam, f] = bunchfseries(accelerator, Iavg, nbunches, nharmonicsRF)
%BUNCHFSERIES Calculate Fourier Series of beam current.
%
%   r = bunchfseries(accelerator, bpm, Iavg, nbunches, nharmonicsRF)
%
%   Inputs:
%       accelerator: struct with accelerator parameters
%       Iavg: total average beam current [A] (if scalar value)
%             average current [A] of each bunch (if array value)
%       nbunches: number of bunches on the beam
%                 (this value is ignored when 'Iavg' is an array)
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

% Frequency vector
f = frev*m;

if isscalar(Iavg)
    % Average bunch current
    Ib = Iavg/nbunches;
    
	fill = [ones(nbunches,1)*Ib; zeros(h-nbunches,1)]; 
else
    if length(Iavg) ~= h
        error('bpm:bunchfseries:inputarguments', '''Iavg'' must be an scalar value or an array with length equal to the accelerator''s harmonic number.');
    end
    fill = Iavg;
end

Ibeam=0;
for i=1:h
    if fill(i) ~= 0
        % Sum one-sided spectrum of one bunch
        Ibeam = Ibeam + [fill(i) 2*fill(i)*exp(-(2*pi.*f(2:end)).^2*bl^2/2 - 1j*2*pi*f(2:end)*(t0+(i-1)*1/frf))];
    end
end