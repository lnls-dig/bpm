function [xy, q, s] = calcpos(abcd, Kx, Ky, Ks, method)

if nargin < 2
    Kx = 1;
end
if nargin < 3
    Ky = Kx;
end
if nargin < 4
    Ks = 1;
end
if nargin < 5
    method = 'delta/sigma';
end

a = abcd(:,1);
b = abcd(:,2);
c = abcd(:,3);
d = abcd(:,4);

aMc = a-c;
bMd = b-d;
aMb = a-b;
cMd = c-d;

aPb = a+b;
cPd = c+d;

sum = aPb+cPd;

if strcmpi(method, 'delta/sigma')
    xy = [Kx*(aMc-bMd)./sum Ky*(aMc+bMd)./sum];
    q = (aMb+cMd)./sum;
elseif strcmpi(method, 'partial delta/sigma')
    aPc = a+c;
    bPd = b+d;
    
    xy = 0.5*[Kx*(aMc./aPc - bMd./bPd) Ky*(aMc./aPc + bMd./bPd)];
    q = 0.5*(aMb./aPb + cMd./cPd);
end

s = Ks*sum;