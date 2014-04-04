function index = findfreqbin(f, fs, npts, spectrumtype)

if nargin < 4
    spectrumtype = 'onesided';
end

f = f(:);

df = fs/npts;
index1 = f/df + 1;

if ~strcmpi(spectrumtype, 'onesided')
    index2 = npts - f/df + 1;
else
    index2 = [];
end

index = [index1; index2]';
