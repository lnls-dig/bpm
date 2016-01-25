P1dB = 20;              % Power 1 dB compression point (input or output)
G = 10;                 % Amplifier gain [V/V]
R = 50;                 % Charateristic impedance [Ohm]
port = 'out';           % P1dB relative to input or output power
rel_amplitude = -30;    % Amplitude relative to P1dB [dB]

% Calculate non-linearity coefficient of Vout = Gain*Vin*(1-alpha*Vin^2)
alpha = calcampnl(P1dB, G, R, port, 1);

if strcmpi(port, 'out')
    Vin_P1dB = dbm2volt(P1dB, R)*sqrt(2)/G/(10^(-1/20));
else
    Vin_P1dB = dbm2volt(P1dB, R)*sqrt(2);
end

% Build vin: single-tone sinusoidal voltage input
npts_per_period = 10;
nperiods = 10;
t = ((0:npts_per_period*nperiods-1)*1/npts_per_period)';
vin = Vin_P1dB * 10^(rel_amplitude/20) * (sin(2*pi*t) + 1e-8*randn(length(t),1));

% Simulate ideal amplifier (vout) and non-linear amplifier (vout_nl)
vout = G*vin;
vout_nl = G*polyval([-alpha 0 1 0], vin);

% Fourier series of outputs
[Y,f] = fourierseries([vout vout_nl], npts_per_period);

% Simulate non-linearity measurement with "Linearity box"
att = -1;
stepPi = 1;

Pin1 = (-130:stepPi:0)';
Pin2 = Pin1 + att;

Vin = sqrt(2)*dbm2volt(Pin1, 50);
Vin_att = sqrt(2)*dbm2volt(Pin2, 50);

Vout = polyval([-3/4*G*alpha 0 G 0], Vin);
Vout_att = polyval([-3/4*G*alpha 0 G 0], Vin_att);

Pout = volt2dbm(1/sqrt(2)*Vout, 50);
Pout_att = volt2dbm(1/sqrt(2)*Vout_att, 50);

comp = Pout - (Pin1+20*log10(G));
comp_deriv_1 = Pout - Pout_att + att;
comp_deriv_2 = [0; diff(comp_deriv_1)];

% Plot figures
figure;
plot(f,volt2dbm(Y/sqrt(2), R))

figure;
Pin = -40:0.1:1;
Vin = dbm2volt(Pin, R)*sqrt(2);
Pout = 20*log10(polyval([-3/4*G*alpha 0 G 0], Vin)./Vin/G);
plot(Pin, Pout);

figure;
plot(Pin2, [comp comp_deriv_1 comp_deriv_2],'-*');
legend('NL', 'NL 1st derivative', 'NL 2nd derivative','Location','NorthWest')