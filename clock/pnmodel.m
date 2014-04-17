function [P, f] = pnmodel(modelname)

if strcmpi(modelname, 'cvhd950')
    f = [logspace(log10(10), log10(100), 100) logspace(log10(100), log10(1e3), 100) logspace(log10(1e3), log10(10e3), 100) logspace(log10(10e3), log10(1e6), 100) 2e6];
    P = [-linspace(76, 109, 100) -linspace(109, 137, 100) -linspace(137, 151, 100) -linspace(151, 164, 100) -164];
elseif strcmpi(modelname, 'si571')
    f = [logspace(log10(100), log10(1e3), 100) logspace(log10(1e3), log10(10e3), 100) logspace(log10(10e3), log10(100e3), 100) logspace(log10(100e3), log10(1e6), 100) logspace(log10(1e6), log10(10e6), 100) 20e6];
    P = [-linspace(87, 114, 100) -linspace(114, 132, 100) -linspace(132, 142, 100) -linspace(142, 148, 100) -linspace(148,150, 100) -150];
elseif strcmpi(modelname, 'ad9510_clkdist')
    f = [100e3 10e6];
    P = [-150 -150];
else
    error('A valid phase noise model name must be specified.');
end