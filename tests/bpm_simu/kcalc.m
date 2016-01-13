%-------------------------------------
% Function that uses a vector 
%-------------------------------------

function [Kx] = kcalc(x_real,x_estimated)
len=length(x_real);
mid=ceil(len/2);

a = polyfit(x_real(mid-5:mid+5),x_estimated(mid-5:mid+5),1);

if(a(2) > 10e-3) % linear coeff is not negligible
  error('Linear coefficient is not negligible');
else
  Kx = 1/a(1);
end
end