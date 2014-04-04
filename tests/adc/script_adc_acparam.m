dataset = loadall_chipscopedata('R:\Grupos\DIG\Projetos\Ativos\ALL_EBPM\Tests\ICALEPCS2013_adc\fmc516_passive\ch0',3,'name');

adctype = 'isla216p25';

% Number of points in dataset shall be 131071
if strcmpi(adctype, 'ltc2208_pga2v25')
    frf = 480182260;
    fadc = 113376415;
    fsr = 2.25;
    nbits = 16;
elseif strcmpi(adctype, 'ltc2208_pga1v5')
    frf = 480182260;
    fadc = 113376415;
    fsr = 1.5;
    nbits = 16;
elseif strcmpi(adctype, 'isla216p25')
    frf = 480087296;
    fadc = 208927174;
    fsr = 2;
    nbits = 16;
end

for i=1:length(dataset);
    data = dataset{i};
    adc_acparam(data(1:end-1,1), nbits, fadc, frf, fsr);
end