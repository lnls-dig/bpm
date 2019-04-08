function [M, z, t] = fit2dsvdeval(x, y, coeff_desc, coeff)

shape = size(x);

x = x(:);
y = y(:);

M = [];
t = '';
for i=1:size(coeff_desc,1)
    M = [M x.^coeff_desc(i,1).*y.^coeff_desc(i,2)];
    if nargout > 2
        t = [t sprintf('C%d*x^%d*y^%d', i, coeff_desc(i,1), coeff_desc(i,2))];
        if i < size(coeff_desc,1)
            t = [t '  +  '];
        end
    end
end

if nargout > 1
    z = M*coeff;
    z = reshape(z, shape);
end