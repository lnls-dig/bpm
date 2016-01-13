close all
clear all

big_fonts = 1; % set fonts to big size; 

%% Estimate real and measured beam positions

% Parameters

button_r = 3;
chamber_r = 12;

Kx = 1; %8.89
Ky = 1;
Ks = 1;

x_array_length = 10; %length in mm
y_array_length = 0; %length in mm
array_size = 1e4;

% Create xy vector

x = linspace(-x_array_length, x_array_length, array_size)';
y = linspace(-y_array_length, y_array_length, array_size)';

xy = [x y];

% Convert to abcd coordinates

[abcd] = pos2abcd(xy,button_r,chamber_r);

% Calculate position xy1

xy1 = calcpos(abcd,Kx,Ky,Ks);

% Calculate Kx;

Kx = Kx*kcalc(xy(:,1),xy1(:,1));
Ky = Kx;

% Recalculate position xy1 with correct Kx

xy2 = calcpos(abcd,Kx,Ky,Ks);

% Plot relation between real and estimated values
figure(1)
plot(xy(:,1),xy(:,1),'r',xy(:,1),xy1(:,1),'g',xy(:,1),xy2(:,1),'b')
grid on
xl = xlabel('Real Beam Position (mm)');
yl = ylabel('Estimated Beam Position (mm)');
tl = title('ABCD Linear Aproximation - \Delta/\Sigma');
axis equal
axis([-x_array_length x_array_length -x_array_length x_array_length])
ll = legend('Ideal','No K compensation','With K compensation','location','southeast');

if big_fonts 
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
    set(ll,'FontSize',13);
end



print -depsc K_calc_demo % plotting figure