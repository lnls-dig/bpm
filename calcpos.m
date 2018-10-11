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

a = abcd(:,1:4:end);
b = abcd(:,2:4:end);
c = abcd(:,3:4:end);
d = abcd(:,4:4:end);

aMc = a-c;
bMd = b-d;
aMb = a-b;
cMd = c-d;

aPb = a+b;
cPd = c+d;

sum = aPb+cPd;

if strcmpi(method, 'delta/sigma')
    x = Kx*(aMc-bMd)./sum;
    y = Ky*(aMc+bMd)./sum;
    q = (aMb+cMd)./sum;
elseif strcmpi(method, 'partial delta/sigma')
    aPc = a+c;
    bPd = b+d;    
    x = 0.5*Kx*(aMc./aPc - bMd./bPd);
    y = 0.5*Ky*(aMc./aPc + bMd./bPd);
    q = 0.5*(aMb./aPb + cMd./cPd);
end

xy = zeros(size(x,1), 2*size(x,2));
xy(:,1:2:end) = x;
xy(:,2:2:end) = y;

s = Ks*sum;