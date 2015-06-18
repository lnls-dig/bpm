close all
clear all

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

% Rotation Matrix

R = [cos(pi/4) -sin(pi/4); sin(pi/4) cos(pi/4)];

xy = [x y];

xy = R*xy';

xy = xy';

% Convert to abcd coordinates

[abcd] = pos2abcd_cross(xy,button_r,chamber_r);

% Calculate position xy1

xy1 = calcpos_pipi_cross(abcd,Kx,Ky);

% Calculate Kx;

Kx = Kx*kcalc(xy(:,1),xy1(:,1));
Ky = Kx;

% Recalculate position xy1 with correct Kx

xy1 = calcpos_pipi_cross(abcd,Kx,Ky);

% Plot relation between real and estimated values
figure(1)
plot(xy(:,1),xy1(:,1))
grid on
xlabel('Real Beam Position (mm)')
ylabel('Estimated Beam Position (mm)')
title('ABCD Linear Aproximation')
axis([min(xy(:,1)) max(xy(:,1)) min(xy1(:,1)) max(xy1(:,1))])

print -depsc 3_1 % plotting figure


%% Plot Matrix

% Create chamber plot

theta = linspace(0,2*pi); % Chamber draw

x_chamber = chamber_r*cos(theta);
y_chamber = chamber_r*sin(theta);

[x_button,y_button] = button_draw(chamber_r,button_r,4,pi/4);

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


% Estimating Matrix

[abcdm] = pos2abcd_cross(xym,button_r,chamber_r); % Convert to abcd coordinates
xy1m = calcpos_pipi_cross(abcdm,Kx,Ky); % Calculate position xy1

% Rotation Matrix

xym = R*xym';
xym = xym';

xy1m = R*xy1m';
xy1m = xy1m';


figure(2)%, set(gcf,'position',[100 100 200 400])
plot(xym(:,1),xym(:,2),'o',xy1m(:,1),xy1m(:,2),'r*') % Plot data
hold on
plot(x_chamber,y_chamber,'k--') % Plot draws
for i=1:size(x_button,1)
    plot(x_button(i,:),y_button(i,:),'k.')
end
hold off
axis([-chamber_r chamber_r -chamber_r chamber_r]*1.1)
axis equal
legend('Real Positions','Calculated Positions','Location','best')
title('Real x Estimated Beam Position')
grid on

print -depsc 3_2 % plotting figure

%% Zoomed plot

% Create xy vector matrix

matrix_size = 15;
x_array_length = 2; % length in mm

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

figure(3)
plot(xym(:,1),xym(:,2),'o',xy1m(:,1),xy1m(:,2),'r*') % Plot data
axis([-x_array_length x_array_length -x_array_length x_array_length]*1.1)
axis equal
legend('Real Positions','Calculated Positions','Location','bestoutside')
title('Real x Estimated Beam Position')
grid on

print -depsc 3_3 % plotting figure

%% Plot error acording to pipe

matrix_size = 50;

xm = linspace(-x_array_length, x_array_length, matrix_size);

[xx,yy] = meshgrid(xm,xm);

xx = reshape(xx,[],1); % reshape into an array
yy = reshape(yy,[],1); % reshape into an array

[abcdm] = pos2abcd_cross([xx yy],button_r,chamber_r); % Convert to abcd coordinates
xy1m = calcpos_pipi_cross(abcdm,Kx,Ky); % Calculate position xy1

% Rotation Matrix

xxyy = R*[xx yy]';
xxyy = xxyy';

xx = xxyy(:,1);
yy = xxyy(:,2);

xy1m = R*xy1m';
xy1m = xy1m';

x1m = reshape(xy1m(:,1),[],sqrt(length(xx)));
y1m = reshape(xy1m(:,2),[],sqrt(length(yy)));

xx = reshape(xx,[],sqrt(length(xx))); % reshape back into a matrix
yy = reshape(yy,[],sqrt(length(yy))); % reshape back into a matrix

%xy1m_error=sqrt(x1m-xx).^2+(y1m-yy).^2);
xy1m_error=sqrt(x1m.^2+y1m.^2)-sqrt(yy.^2+xx.^2);

% Plotting the surface

%{
figure(4)
surf(xx,yy,xy1m_error); % Plot data
hold on
plot(x_chamber,y_chamber,'k--') % Plot draws
for i=1:size(x_button,1)
    plot(x_button(i,:),y_button(i,:),'k.')
end
hold off
grid on
title('Error Estimation')
ylabel('Y (mm)')
xlabel('X (mm)')
zlabel('Error')
%set(gca,'DataAspectRatio',[10 10 1])
axis tight
%}

figure(4)
contourf(xx,yy,xy1m_error); % Plot data
colorbar;
grid on
title('Error Estimation')
ylabel('Y (mm)')
xlabel('X (mm)')
zlabel('Error')
%set(gca,'DataAspectRatio',[10 10 1])
axis equal

print -depsc 3_4 % plotting figure
