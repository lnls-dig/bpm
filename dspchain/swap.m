function y = swap(xd, xc, window, phase)

% TODO: checj if phase < sw_ratio
% TODO: check if xd and xc have the same size
% TODO: check if ratio is even

if nargin < 4
    phase = 0;
end

if isscalar(window)
    window = [rectwin(window); zeros(window, 1)];
end

ratio = length(window);

window = window(:);

npts = size(xd, 1);
nsignals = size(xd, 2);

if ~isinf(ratio) && ratio > 0
    % Direct path configuration
    swd = [window(end-phase+1:end); repmat(window, ceil(npts/ratio)-1, 1); window(1:end-phase)];

    % Crossed path configuration
    swc = circshift(swd, ratio/2);

    swd = repmat(swd(1:npts), 1, nsignals);
    swc = repmat(swc(1:npts), 1, nsignals);

    y = xd.*swd + xc.*swc;
else
    y = xd;
end