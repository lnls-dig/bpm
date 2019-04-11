function z = fit2dsvdeval(x, y, coeff, coeff_desc)

M = fit2dsvdmatrix(x, y, coeff_desc);
z = M*coeff;
z = reshape(z, size(x));