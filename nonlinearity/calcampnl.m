function alpha = calcampnl(CP, G, R, port, comp_dB)
%CALCAMPNL Calculation of amplifier non-linearity coefficient. Assumes a
%   third-order polynomial non-linearity model for the amplifier's voltage
%   transfer function: Vout = Gain*Vin*(1-alpha*Vin^2)
%
%   alpha = calcampnl(P1dB, R)
%
%   Inputs:
%       CP:         compression point [dBm]
%       G:          gain [V/V]
%       R:          characteristic impedance [Ohm]
%       port:       specify whether compression point is referred to input
%                   (port = 'in') or output power (port = 'out')
%                   optional / default = 'out'
%       comp_dB:    compression on compression point [dB]
%                   optional / default = 1
%
%   Outputs:
%       alpha:      third-order nonlinearity coefficient [1/V^2]

%   Copyright (C) 2016 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)

if nargin < 4 || isempty(port)
    port = 'out';
end
if nargin < 5 || isempty(comp_dB)
    comp_dB = 1;
end

V_CP = dbm2volt(CP, R);
V_CP = V_CP*sqrt(2);    % Convert Vrms to V (amplitude)
NL = 10^(-comp_dB/20);

if strcmpi(port, 'out')
    alpha = 4/3*(1-NL)/(V_CP/G/NL)^2;
else
    alpha = 4/3*(1-NL)/V_CP^2;
end