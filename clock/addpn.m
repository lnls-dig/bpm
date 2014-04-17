function abcd_jitter = addpn(signals, fc, fs, pn_P, pn_f, correlated)

if correlated
    randstream = RandStream.getGlobalStream;
    seed = get(randstream, 'Seed');
end

abcd_jitter = zeros(size(signals));
for i=1:size(signals, 2)
    if correlated
        reset(randstream, seed);
    end

    abcd_jitter(:,i) = add_phase_noise(signals(:, i), fs, pn_f, pn_P + 20*log10(fc/fs));
end
