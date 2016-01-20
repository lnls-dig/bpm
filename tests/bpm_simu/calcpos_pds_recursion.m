function [xy, q, s] = calcpos_daphini_recursion(abcd, Kx, Ky, rn)

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

xy = [u v];

for i=1:rn
    
    xy = [(Kx(1) + Kx(2).*xy(:,2).^2 + Kx(3).*xy(:,2).^4 + Kx(4).*xy(:,1).^2 + Kx(5).*xy(:,1).^2.*xy(:,2).^2 + Ky(6).*xy(:,1).^4).*u ...
          (Ky(1) + Ky(2).*xy(:,2).^2 + Ky(3).*xy(:,2).^4 + Ky(4).*xy(:,1).^2 + Ky(5).*xy(:,1).^2.*xy(:,2).^2 + Ky(6).*xy(:,1).^4).*v];
end
    

q = 0; % not implemented
s = 0; % not implemented