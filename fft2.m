function [fft_data, f] = fft2(data, Fs, window)

if nargin < 3
    window = @rectwin;
end

data = data(:);

npts = size(data,1);
data = data.*repmat(window(npts), 1, size(data,2));
fft_data = abs(fft(data))/npts;

half_npts = ceil(npts/2+1);
fft_data = fft_data(1:half_npts, :);

if rem(npts,2) > 0
    fft_data = [fft_data(1,:); 2*fft_data(2:end,:)];
else
    fft_data = [fft_data(1,:); 2*fft_data(2:end-1,:); fft_data(end,:)];
end

df = Fs/npts;

f = 0:df:(half_npts-1)*df;