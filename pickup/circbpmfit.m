function poly = circbpmfit(npoly, r, bd, pu_ang, method, roix, roiy)

[x, y] = meshgrid(roix,roiy);
abcd = chargecirc(x, y, bd, r, pu_ang);
[xy_bpm, q_bpm, sum_bpm] = calcpos(abcd, 1, 1, 1, method);

% Normalize sum
sum_bpm = sum_bpm*pi/2/bd*r;

% Build polynomial coefficients
npoly_xy = floor((npoly-1)/2)*2+1;
coeff_desc_x = [];
k = 1;
m = 1;
for i=1:2:npoly_xy
    for j=0:2:npoly-m
        coeff_desc_x(k,:) = [i j];
    k = k+1;
    end
    m = m+2;
end
coeff_desc_y = coeff_desc_x(:,[2 1]);

[aux1,aux2] = meshgrid(0:2:npoly,0:2:npoly);
coeff_desc_sum = [aux1(:) aux2(:)];

[aux1,aux2] = meshgrid(1:2:npoly,1:2:npoly);
coeff_desc_q = [aux1(:) aux2(:)];

%sum_bpm = sum_bpm*pi/2/bd*r;

W = 1*ones(size(x));
% W(sqrt(x.^2+y.^2)<10e-3) = 1e1;
% W(sqrt(x.^2+y.^2)<8e-3) = 1e2;
% W(sqrt(x.^2+y.^2)<6e-3) = 1e3;
% W(sqrt(x.^2+y.^2)<4e-3) = 1e4;
% W(sqrt(x.^2+y.^2)<2e-3) = 1e5;
W(roix <= 10e-3 & roix >= -10e-3, roiy <= 10e-3 & roiy >= -10e-3) = 1e1;
W(roix <= 8e-3 & roix >= -8e-3, roiy <= 8e-3 & roiy >= -8e-3) = 1e2;
W(roix <= 6e-3 & roix >= -6e-3, roiy <= 6e-3 & roiy >= -6e-3) = 1e3;
W(roix <= 4e-3 & roix >= -4e-3, roiy <= 4e-3 & roiy >= -4e-3) = 1e4;
W(roix <= 2e-3 & roix >= -2e-3, roiy <= 2e-3 & roiy >= -2e-3) = 1e5;

%figure; surf(x,y,W)

poly.x.coeff = fit2dsvd(xy_bpm(:,:,1), xy_bpm(:,:,2), x, coeff_desc_x, 1e17, W);
poly.x.desc = coeff_desc_x;
poly.y.coeff = poly.x.coeff;
poly.y.desc = coeff_desc_y;
poly.q.coeff = fit2dsvd(xy_bpm(:,:,1), xy_bpm(:,:,2), q_bpm, coeff_desc_q, 1e17, W);
poly.q.desc = coeff_desc_q;
poly.sum.coeff = fit2dsvd(xy_bpm(:,:,1), xy_bpm(:,:,2), sum_bpm, coeff_desc_sum, 1e17, W);
poly.sum.desc = coeff_desc_sum;