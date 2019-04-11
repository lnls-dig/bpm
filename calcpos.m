function [xy, q, s] = calcpos(abcd, Kx, Ky, Ks, method, polynomial)

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
if nargin < 6
    polynomial = [];
end

if ismatrix(abcd)
    a = abcd(:,1:4:end);
    b = abcd(:,2:4:end);
    c = abcd(:,3:4:end);
    d = abcd(:,4:4:end);
else
    S = struct('type', '()', 'subs', {repmat({':'},1,ndims(abcd))});
    S.subs{end} = 1;
    a = subsref(abcd,S);
    S.subs{end} = 2;
    b = subsref(abcd,S);
    S.subs{end} = 3;
    c = subsref(abcd,S);
    S.subs{end} = 4;
    d = subsref(abcd,S);
end

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
elseif strcmpi(method, 'cross partial delta/sigma')
    aPc = a+c;
    bPd = b+d;
    x = -0.5*Kx*(bMd./bPd);
    y = 0.5*Ky*(aMc./aPc);
    q = (aMb./aPb + cMd./cPd);
elseif strcmpi(method, 'pi/pi')
    aDc = a./c;
    bDd = b./d;
    x = 0.125*Kx*(aDc-1./aDc-(bDd-1./bDd));
    y = 0.125*Ky*(aDc-1./aDc+bDd-1./bDd);
    q = a./b + c./d;
end

if ~isempty(polynomial)
    x_ = fit2dsvdeval(x, y, polynomial.x.coeff, polynomial.x.desc);
    y_ = fit2dsvdeval(x, y, polynomial.y.coeff, polynomial.y.desc);
    x = x_;
    y = y_;
end

if ismatrix(abcd)
    xy = zeros(size(x,1), 2*size(x,2));
    xy(:,1:2:end) = x;
    xy(:,2:2:end) = y;
else
    xy = zeros([size(x) 2]);
    S = struct('type', '()', 'subs', {repmat({':'},1,ndims(xy))});
    S.subs{end} = 1;
    xy = subsasgn(xy,S,x);
    S.subs{end} = 2;
    xy = subsasgn(xy,S,y);
end

s = Ks*sum;