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


xy = [log2((a.*d)./(b.*c))*Kx log2((a.*b)./(c.*d))*Ky]; % first equation


q = 0; % Not implemented yet