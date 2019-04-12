function coeff = fit2dsvd(x, y, z, coeff_desc, cond_tol, W)

if nargin < 5 || isempty(cond_tol)
    cond_tol = Inf;
end
if nargin < 6 || isempty(W)
    W = [];
end

M = fit2dsvdmatrix(x,y,coeff_desc);

z = z(:);

if ~isempty(W)
    W = diag(W(:));
    M = W*M;
    z = W*z;
end

sv = svd(M);
cond = sv(1)./sv(2:end);
idx_cond = find(cond < cond_tol);
tol = sv(idx_cond(end)+1);

coeff = pinv(M,tol)*z;