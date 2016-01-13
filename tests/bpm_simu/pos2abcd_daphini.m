
function [abcd] = pos2abcd_daphini(xy,M,chamber_r,button_r,button_theta)

% Implementing the calculus using "sigma = -[G]+B"

% Elements position 

th = linspace(0,2*pi,M+1) + button_theta;
th = th(1:M); % eliminates last point (redundant)
[M_x M_y] = pol2cart(th,chamber_r);

M_xy = [M_x' M_y'];

% Calculus of G

G = zeros(M,M);

for j=1:M
    for i=1:M
        G(j,i) = trapz(log(1/norm(M_xy(i,:) - M_xy(j,:))));
    end
end

% Calculus of B

B = zeros(M);

for j=1:M
    B(j) = log(norm(xy - M_xy(j,:)));  
end

B = B';

% Calculus of sigma

sigma = -(G)^(-1)*B;
abcd = sigma;

end