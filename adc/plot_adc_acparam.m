function plot_adc_acparam(p, fseries, df, Fbins)

ADC_specs = [p(:).ADC_specs];

fc = [ADC_specs.fc];
fs = ADC_specs(1).fs;    % FIXME ADC_sepcs(1)
fif = calcalias(fc, fs);

[fc_plot, fc_unit] = goodunit(fc, 'Hz', 'tex');
[fif_plot, fif_unit] = goodunit(fif, 'Hz', 'tex');
[fs_plot, fs_unit] = goodunit(fs, 'S/s', 'tex');

half_npts = length(fseries);

figure;
set(gcf, 'WindowStyle', 'docked');

if length(p) == 1
    % Frequency resolution and frequency array
    freq = (0:half_npts-1)*df;

    [f_plot, f_unit] = goodunit(freq, 'Hz', 'tex');
    plot(f_plot, [p.noisefloor_dBFS; 20*log10(fseries(2:end))]);
    hold on
    plot([f_plot(1) f_plot(end)], repmat(p.noisefloor_dBFS,1,2), 'r', 'LineWidth', 2);
    plot([f_plot(1) f_plot(end)], repmat(-p.SNR_dBFS,1,2), 'g', 'LineWidth', 2);
    plot([f_plot(1) f_plot(end)], repmat(-p.SNR_dBFS_theoretical,1,2), 'g:', 'LineWidth', 2);
    plot([f_plot(1) f_plot(end)], repmat(-p.SFDR_dBFS,1,2), 'm','LineWidth', 2);
    plot([f_plot(1) f_plot(end)], repmat(-p.SINAD_dBFS,1,2), 'k', 'LineWidth', 2);
    set(gca, 'FontSize', 12);
    legend('Fourier series', 'Noise floor', 'SNR', 'Ideal SNR', 'SFDR', 'SINAD');
    title(sprintf('f_c = %0.2f %s (f_{IF} = %0.2f %s), f_s = %0.2f %s, %d bits, %0.2f Vpp full-scale', fc_plot, fc_unit, fif_plot, fif_unit, fs_plot, fs_unit, p.ADC_specs.nbits, p.ADC_specs.fsr), 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Signal power [dBFS]', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel(sprintf('Frequency [%s]', f_unit), 'FontSize', 12, 'FontWeight', 'bold');
    axis tight
    ax = axis;
    ax(4) = 0;
    axis(ax);
    grid on
%    axis(gca, [f_plot(1) f_plot(end) -180 0]);
%    set(gca, 'YTick', -180:10:0);
    plot(f_plot(Fbins), 20*log10(fseries(Fbins)), 'ro');
    for i=1:length(Fbins)
        plot([f_plot(Fbins(i)) f_plot(Fbins(i))] , [p.noisefloor_dBFS 20*log10(fseries(Fbins(i)))], 'r-');
        text(f_plot(Fbins(i)) + 0.01*f_plot(Fbins(1)), 20*log10(0.5*fseries(Fbins(i))), sprintf('%d',i), 'Color', 'r', 'FontSize', 12, 'HorizontalAlignment', 'center', 'FontWeight', 'bold')
    end

    plot(f_plot(p.f_max_spur_bin), 20*log10(p.spur), 'mo');
    plot([f_plot(p.f_max_spur_bin) f_plot(p.f_max_spur_bin)] , [p.noisefloor_dBFS 20*log10(p.spur)], 'm-');
    text(f_plot(p.f_max_spur_bin), 20*log10(3*fseries(p.f_max_spur_bin)), 'max. spur', 'Color', 'm', 'FontSize', 12, 'HorizontalAlignment', 'center', 'FontWeight', 'bold')
    fprintf('\n');
    fprintf('----------------------\n');
    fprintf('ADC AC characteristics\n');
    fprintf('----------------------\n');
    fprintf('Ideal SNR = %0.2f dBFS\n', p.SNR_dBFS_theoretical);
    fprintf('SNR = %0.2f dBc\n', p.SNR);
    fprintf('SNR (dBFS) = %0.2f dBFS\n', p.SNR_dBFS);
    fprintf('SINAD = %0.2f dBc\n', p.SINAD);
    fprintf('SINAD (dBFS) = %0.2f dBFS\n', p.SINAD_dBFS);
    fprintf('SFDR = %0.2f dBc\n', p.SFDR_dBc);
    fprintf('THD = %0.2f dBc\n', p.THD_dBc);
    fprintf('THD = %0.2f %%\n', p.THD*100);
    fprintf('ENOB = %0.2f bits\n', p.ENOB);
    fprintf('Noise floor = %0.2f dBFS\n', p.noisefloor_dBFS);
    fprintf('DFT process gain = %0.2f dB\n', p.DFT_PG_dB);
    fprintf('\n');

else
    plot(fc_plot, [p.SNR], 'LineWidth',2);
    hold on;
    plot(fc_plot, [p.SINAD], 'k', 'LineWidth',2);
    set(gca, 'FontSize', 12);
    legend('SNR', 'SINAD');
    title(sprintf('f_s = %0.2f %s, %d bits, %0.2f Vpp full-scale', fs_plot, fs_unit, p(1).ADC_specs.nbits, p(1).ADC_specs.fsr), 'FontSize', 12, 'FontWeight', 'bold'); % FIXME p(1)
    ylabel('dB', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel(sprintf('Frequency [%s]', fc_unit), 'FontSize', 12, 'FontWeight', 'bold');
    axis tight
%     ax = axis;
%     ax(4) = 0;
%     if ax(1) ~= ax(2)
%         axis(ax);
%     end
    grid on
end
