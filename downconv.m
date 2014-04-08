function res = downconv(sig, filt, mix_sin, mix_cos)

    I = sig.*mix_cos;
    Q = sig.*mix_sin;
    
    Ifilt = filter(filt,I);
    Qfilt = filter(filt,Q);

    res = Ifilt + 1i*Qfilt;
end

