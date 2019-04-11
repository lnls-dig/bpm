function [M,t] = fit2dsvdmatrix(x, y, coeff_desc)

x = x(:);
y = y(:);

M = [];
t = '';
for i=1:size(coeff_desc,1)
    M = [M x.^coeff_desc(i,1).*y.^coeff_desc(i,2)];
    if nargout > 1
        t = [t sprintf('C%d*x^%d*y^%d', i, coeff_desc(i,1), coeff_desc(i,2))];
        if i < size(coeff_desc,1)
            t = [t '  +  '];
        end
    end
end