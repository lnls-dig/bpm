function coeff = fit2dsvd(x, y, z, coeff_desc, alpha, W)

if nargin < 5 || isempty(alpha)
    alpha = 0;
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

[U,S,V] = svd(M,'econ');
sig = diag(S);
invsig = sig./(sig.^2 + alpha^2);

coeff = V*diag(invsig)*U'*z;