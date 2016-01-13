function [xy, q, s] = calcpos_daphini(abcd, Kx, Ky, Ks)

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

u = 0.5*(((a-c)./(a+c))+((d-b)./(d+b)));
v = 0.5*(((a-c)./(a+c))-((d-b)./(d+b)));

xy = [Kx*u Ky*v];
    

q = 0; % not implemented
s = 0; % not implemented