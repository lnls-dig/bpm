function poly = circbpmfit(npoly, r, bd, pu_ang, method, roix, roiy, Wspec)

if nargin < 8
    Wspec = [];
end

[x, y] = meshgrid(roix,roiy);
abcd = chargecirc(x, y, bd, r, pu_ang);
[xy_bpm, q_bpm, sum_bpm] = calcpos(abcd, 1, 1, 1, method);

% Normalize sum
sum_bpm = sum_bpm*pi/2/bd*r;

% Build polynomial coefficients
npoly_xy = floor((npoly.x-1)/2)*2+1;
coeff_desc_x = [];
k = 1;
m = 1;
for i=1:2:npoly_xy
    for j=0:2:npoly_xy-m
        coeff_desc_x(k,:) = [i j];
    k = k+1;
    end
    m = m+2;
end
coeff_desc_y = coeff_desc_x(:,[2 1]);

[aux1,aux2] = meshgrid(1:2:npoly.q,1:2:npoly.q);
coeff_desc_q = [aux1(:) aux2(:)];

[aux1,aux2] = meshgrid(0:2:npoly.sum,0:2:npoly.sum);
coeff_desc_sum = [aux1(:) aux2(:)];

%sum_bpm = sum_bpm*pi/2/bd*r;
if ~isempty(Wspec)
    [~,reorder] = sort(Wspec(:,1));
    Wspec = Wspec(reorder(end:-1:1),:);
    
    W = ones(size(x));
    for i=1:size(Wspec,1)
        W(roix >= -Wspec(i,1) & roix <= Wspec(i,1), roiy >= -Wspec(i,1) & roiy <= Wspec(i,1)) = Wspec(i,2);
    end
else
    W = [];
end

poly.x.coeff = fit2dsvd(xy_bpm(:,:,1), xy_bpm(:,:,2), x, coeff_desc_x, Inf, W);
poly.x.desc = coeff_desc_x;
poly.y.coeff = poly.x.coeff;
poly.y.desc = coeff_desc_y;
poly.q.coeff = fit2dsvd(xy_bpm(:,:,1), xy_bpm(:,:,2), q_bpm, coeff_desc_q, Inf, W);
poly.q.desc = coeff_desc_q;
poly.sum.coeff = fit2dsvd(xy_bpm(:,:,1), xy_bpm(:,:,2), sum_bpm, coeff_desc_sum, Inf, W);
poly.sum.desc = coeff_desc_sum;