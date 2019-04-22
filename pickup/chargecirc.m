function Q = chargecirc(x, y, l, r, phi)
%CHARGECIRC Calculate the integrated charge over a circular contour
%   given by a unitary point charge inside the contour.
%
%   Q = CHARGECIR(x, y, l, r, phi)
%
%   Inputs:
%       x:   horizontal transverse position of point charge (1-D or 2-D array)
%       y:   vertical transverse position of point charge (1-D or 2-D array)
%       l:   transverse length of pick-up (scalar value)
%       r:   circular contour radius (scalar value)
%       phi: angular position of pick-ups (1-D array)
%
%   Outputs:
%       Q: integrated charge (N-D array of size [size(x) length(phi)]

ndims_xy = ndims(x);
if ndims_xy == 2
    if numel(x) == length(x)
        ndims_xy = 1;
    end
end

[theta,d] = cart2pol(x,y);

phi = phi(:);
phi = permute(phi, [2:ndims_xy+1 1]);

theta = repmat(theta, [ones(1, ndims_xy) length(phi)]);
d = repmat(d, [ones(1, ndims_xy) length(phi)]);
phi = repmat(phi, size(x));

alpha = l/r;
dr = d./r;
dr2 = dr.^2;
Q = 1/pi*atan2((1-dr2).*sin(alpha/2), (1+dr2).*cos(alpha/2) - 2*dr.*cos(theta - phi));