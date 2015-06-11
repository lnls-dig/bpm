close all
clear all

%% Parameters

x_array_length = 10;
y_array_length = 0;
array_size = 1e4;

button_r = 6;
chamber_r = 12;

Kx = 8.89;
Ky = 8.89;
Ks = 1;

%% Create xy vector

x = linspace(-x_array_length, x_array_length, array_size)';
y = linspace(-y_array_length, y_array_length, array_size)';

xy = [x y];

%% Convert to abcd coordinates

[abcd] = pos2abcd(xy,button_r,chamber_r);

%% Calculate position xy1

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
x_array_length = chamber_r/sqrt(2)*0.5;

x = linspace(-x_array_length, x_array_length, matrix_size);
xy=zeros(matrix_size*matrix_size,2);

for i=1:matrix_size
  xy(1+(i-1)*matrix_size:matrix_size+(i-1)*matrix_size,2) = x(i);
end

for i=1:matrix_size
  xy(1+(i-1)*matrix_size:matrix_size+(i-1)*matrix_size,1) = x;
end

% Estimated Matrix

[abcd] = pos2abcd(xy,button_r,chamber_r); % Convert to abcd coordinates
xy1 = calcpos(abcd,Kx,Ky,Ks); % Calculate position xy1


figure(2)%, set(gcf,'position',[100 100 200 400])
plot(x_chamber,y_chamber,'b',xy(:,1),xy(:,2),'o',xy1(:,1),xy1(:,2),'*')
axis([-chamber_r chamber_r -chamber_r chamber_r]*1.1)
axis equal
legend('Chamber','Real Positions','Calculated Positions',"location",'outside')