function [xy, q, s] = calcpos(abcd, Kx, Ky, Ks)

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

%ac = a-c;
%bd = b-d;
%ab = a-b;
%cd = c-d;
sum = a+b+c+d;

%xy = [(ac-bd)./sum*Kx (ac+bd)./sum*Ky];
%q = (ab+cd)./sum*Kx;
xy = [(a-c)./sum*Kx (b-d)./sum*Ky];
q = 0;
s = sum*Ks;