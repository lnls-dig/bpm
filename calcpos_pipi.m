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

ac = a-c;
bd = b-d;
ab = a-b;
cd = c-d;

xy = [log2(sqrt((a.*b)./(c.*d)))*Kx log2(sqrt((a.*d)./(b.*c)))*Ky]; % first equation
%xy = [(0.5*(log(a)+log(b)-log(c)-log(d)))*Kx (0.5*(log(a)+log(d)-log(b)-log(c)))*Ky]; % Working
%xy = [(log(a)-log(c))*Kx (log(b)-log(d))*Ky]; % cross config
q = 0; % Not implemented yet