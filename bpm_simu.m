close all
clear all

%% Parameters

button_r = 2;
chamber_r = 12;

Kx = 8.89; %8.89
Ky = 0;
Ks = 1;

x_array_length = 10; %length in mm
y_array_length = 0; %length in mm
array_size = 1e4;

%% Create xy vector

x = linspace(-x_array_length, x_array_length, array_size)';
y = linspace(-y_array_length, y_array_length, array_size)';

xy = [x y];

%% Convert to abcd coordinates

[abcd] = pos2abcd(xy,button_r,chamber_r);

%% Calculate position xy1

xy1 = calcpos(abcd,Kx,Ky,Ks);

% Calculate Kx;

Kx = Kx*kcalc(xy(:,1),xy1(:,1));
Ky = Kx;

% Recalculate position xy1 with correct Kx

xy1 = calcpos(abcd,Kx,Ky,Ks);

%% Plot relation between real and estimated values
figure(1)
plot(xy(:,1),xy1(:,1))
grid on
xlabel('Real beam position (mm)')
ylabel('Estimated beam Position (mm)')
title('ABCD Linear Aproximation')

%% Correction od Kx and Ky (made manually, use function "kcalc.m")

%% Plot Matrix

% Create chamber plot

theta = linspace(0,2*pi);
x_chamber = chamber_r*cos(theta);
y_chamber = chamber_r*sin(theta);

% Create xy vector matrix

matrix_size = 15;
x_array_length = chamber_r/sqrt(2)*0.6;

xm = linspace(-x_array_length, x_array_length, matrix_size);
xym=zeros(matrix_size*matrix_size,2);

for i=1:matrix_size
  xym(1+(i-1)*matrix_size:matrix_size+(i-1)*matrix_size,2) = xm(i);
end

for i=1:matrix_size
  xym(1+(i-1)*matrix_size:matrix_size+(i-1)*matrix_size,1) = xm;
end

% Estimated Matrix

[abcdm] = pos2abcd(xym,button_r,chamber_r); % Convert to abcd coordinates
xy1m = calcpos(abcdm,Kx,Ky,Ks); % Calculate position xy1


figure(2)%, set(gcf,'position',[100 100 200 400])
plot(x_chamber,y_chamber,'b',xym(:,1),xym(:,2),'o',xy1m(:,1),xy1m(:,2),'*')
axis([-chamber_r chamber_r -chamber_r chamber_r]*1.1)
axis equal
legend('Chamber','Real Positions','Calculated Positions')
grid on

%% Plot error acording to pipe

[xx,yy] = meshgrid(xym(:,1),xym(:,2));
%%xy1m_error=sqrt((xy1m(:,1)-xym(:,1)).^2+(xy1m(:,2)-xym(:,2)).^2);
xy1m_error=sqrt((xx.^2+yy.^2));
figure(3)
%mesh(xym(:,1)',xym(:,2)',xy1m_error)
%surf(xy1m_error)
mesh(xx,yy,xy1m_error)

%xy1m_error=sqrt((xy1m(:,1)-xym(:,1)).^2+(xy1m(:,2)-xym(:,2)).^2);
%figure(3)
%plot3(xym(:,1)',xym(:,2)',xy1m_error)
%surf(xy1m_error)