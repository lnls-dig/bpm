function coeff = fit2dsvd(x, y, z, coeff_desc, cond_tol)

if nargin < 5
    cond_tol = Inf;
end

M = fit2dsvdeval(x,y,coeff_desc);

z = z(:);

sv = svd(M);
cond = sv(1)./sv(2:end);
idx_cond = find(cond < cond_tol);
tol = sv(idx_cond(end)+1);

coeff = pinv(M,tol)*z;