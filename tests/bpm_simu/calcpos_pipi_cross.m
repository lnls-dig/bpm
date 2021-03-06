function [xy, q] = calcpos_pipi(abcd, Kx, Ky)

if nargin < 2
    Kx = 1;
end
if nargin < 3
    Ky = Kx;
end
if nargin < 4
    Ks = 1;
end

a = abcd(:,1);
b = abcd(:,2);
c = abcd(:,3);
d = abcd(:,4);

xy = [(log(a)-log(c))*Kx (log(b)-log(d))*Ky]; % cross config

q = 0; % Not implemented yet