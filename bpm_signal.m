function [adc_a, adc_c] = bpm_signal(position, t, fc, fadc, fswR, sw_transition, ...
                                     ch2_gain, ch2_phase, K, noise, ...
                                     filename)
% bpm_signal returns a simulated BPM signal for two buttons, given the
% relative position of the beam.
%
% position => beam displacement from the center, in m (positive is nearer to
% btn_a)
% t => time vector
% fswR => Switching rate (in relation to ADC sampling frequency) 
% sw_off => switching duration
% ch2_gain => gain of ch2 relative to ch1
% ch2_phase => phase difference between ch2 and ch1, in radians

% Beam signal carrier
carrier  = cos(2*pi*fc*t); % + pi/3 to avoid any phase sync effects
carrier2 = cos(2*pi*fc*t + ch2_phase);

% Delta/Sigma x K = pos (m)
% delta = pos*Sigma/K

ch2_gain_mag = db2mag(ch2_gain);

L = length(t);
a_mod =  (1+position/K).*carrier               + noise*randn([1,L]);
a_mod2 = (1+position/K).*carrier2*ch2_gain_mag + noise*randn([1,L]);

c_mod =  (1-position/K).*carrier  + noise*randn([1,L]);
c_mod2 = (1-position/K).*carrier2*ch2_gain_mag + noise*randn([1,L]);

samples_off = ceil(sw_transition*fadc);
%straight configuration for swithc
sw_s = repmat( [ zeros(1,floor(samples_off/2)) , ones(1,fswR-samples_off), ...
                zeros(1,ceil(samples_off/2)), zeros(1,fswR) ], ...
                1, length(t)/fswR/2 );

% cross configuration for switch            
sw_c = [ zeros(1,fswR), sw_s(1:end-fswR)];


%two channels
a_ch1 = a_mod .*sw_s;
a_ch2 = a_mod2.*sw_c;

adc_a = a_ch1 + a_ch2;

c_ch1 = c_mod .*sw_c;
c_ch2 = c_mod2.*sw_s;

adc_c = c_ch1 + c_ch2; 

%% Print file if option chosen
if exist('filename','var')
    fileID = fopen(filename,'w');
    for count = 1 : length(adc_a)
        fprintf(fileID,'%e %e\r\n',a_mod(count),a_mod2(count));
    end
end
end