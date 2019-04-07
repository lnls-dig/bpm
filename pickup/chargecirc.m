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

dphi1 = -0.5*l/r;
dphi2 = 0.5*l/r;

r_p_d = r+d;
r_m_d = r-d;

ang1 = (phi + dphi1 - theta)/2;
ang2 = (phi + dphi2 - theta)/2;
ang3 = atan2((r_p_d).*sin(ang1),(r_m_d).*cos(ang1));
ang4 = atan2((r_p_d).*sin(ang2),(r_m_d).*cos(ang2));

% Ensure ang4-ang3 will result in a minimal positive angle difference
while any_all(ang4 - ang3 < 0) % TODO: use 'while any(ang4 - ang3 < 0, 'all')' in the future - this syntax is only available from Matlab R2018b on
    ang4 = ang4 + double(ang4 - ang3 < 0)*2*pi;
end

Q =  1/pi*(ang4 - ang3);

function r = any_all(boolvar)

r = boolvar;
for i=1:ndims(boolvar)
    r = any(r);
end
