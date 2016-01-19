function [resp, t] = fmcadc130m_resp(input_signal, f)

f = f(:);
input_signal = input_signal(:);

% FMC ADC analog front-end
adc_afe_il = 10^(-2.5/20);

% ADC non-linearity
adc_nonlinearity = [-0.001 1 0];

% Build frequency responses along signal path
names = {'ADC input', 'ADC analog front-end'};
freqresps = {ones(size(f)), adc_afe_il, 1};
nonlinearities = {[], [], adc_nonlinearity};

[resp, t] = buildresp(input_signal, f, names, freqresps, nonlinearities);