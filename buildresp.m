function [resp, t] = buildresp(input_signal, f, names, freqresps, nonlinearities)

resp = struct('name', names{1}, 'freqresp', freqresps{1}, 'nonlinearity', nonlinearities{1}, 'signal_freq', input_signal, 'signal_time', fourierseries2time(abs(input_signal), angle(input_signal), f));

for i=2:length(names)
    resp(i).name = names{i};
    resp(i).freqresp = resp(i-1).freqresp.*freqresps{i};
    resp(i).nonlinearity = nonlinearities{i};
    resp(i).signal_freq = resp(i).freqresp.*resp(1).signal_freq;
    [resp(i).signal_time, t] = fourierseries2time(abs(resp(i).signal_freq), angle(resp(i).signal_freq), f);
    
    if ~isempty(nonlinearities{i})
        resp(i).signal_time = polyval(resp(i).nonlinearity, resp(i).signal_time);
    end
end