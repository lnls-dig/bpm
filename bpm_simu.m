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

xy1 = calcpos(abcd,Kx,Ky,Ks);

% Plot relation between real and estimated values
figure(1)
plot(xy(:,1),xy1(:,1))
grid on
xl = xlabel('Real Beam Position (mm)');
yl = ylabel('Estimated Beam Position (mm)');
tl = title('ABCD Linear Aproximation - \Delta/\Sigma');

if big_fonts 
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
end

axis equal
axis([-x_array_length x_array_length -x_array_length x_array_length])


print -depsc 1_1 % plotting figure

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

% Estimated Matrix

[abcdm] = pos2abcd(xym,button_r,chamber_r); % Convert to abcd coordinates
xy1m = calcpos(abcdm,Kx,Ky,Ks); % Calculate position xy1


figure(2)%, set(gcf,'position',[100 100 200 400])
plot(xym(:,1),xym(:,2),'o',xy1m(:,1),xy1m(:,2),'r*') % Plot data
hold on
plot(x_chamber,y_chamber,'k--') % Plot draws
for i=1:size(x_button,1)
    plot(x_button(i,:),y_button(i,:),'k.')
end
hold off
% axis([-chamber_r chamber_r -chamber_r chamber_r]*1.1)
axis equal
ll = legend('Real Positions','Calculated Positions','Location','best');
tl = title('Real x Estimated Beam Position - \Delta/\Sigma');
xl = xlabel('Real Beam Position (mm)');
yl = ylabel('Estimated Beam Position (mm)');
grid on

if big_fonts 
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
    set(ll,'FontSize',15)
end

print -depsc 1_2 % plotting figure

%% Zoomed plot

% Create xy vector matrix

matrix_size = 15;
x_array_length = 0.5; % length in mm

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
ll = legend('Real Positions','Calculated Positions','Location','bestoutside');
tl = title('Real x Estimated Beam Position - \Delta/\Sigma');
xl = xlabel('Real Beam Position (mm)');
yl = ylabel('Estimated Beam Position (mm)');
grid on

if big_fonts
    tl = title({'Real x Estimated';'Beam Position - \Delta/\Sigma'});
    
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
    set(ll,'FontSize',15);
    set(ll,'position',[0.3192 0.015 0.3973 0.1515]);
    set(gca,'position',[0.1300 0.2972 0.7750 0.4838]);
end

print -depsc 1_3 % plotting figure

%% Plot error acording to pipe (absolute, x and y)

matrix_size = 50;

xm = linspace(-x_array_length, x_array_length, matrix_size);

[xx,yy] = meshgrid(xm,xm);

xx = reshape(xx,[],1); % reshape into an array
yy = reshape(yy,[],1); % reshape into an array

[abcdm] = pos2abcd([xx yy],button_r,chamber_r); % Convert to abcd coordinates
xy1m = calcpos(abcdm,Kx,Ky,Ks); % Calculate position xy1

x1m = reshape(xy1m(:,1),[],sqrt(length(xx)));
y1m = reshape(xy1m(:,2),[],sqrt(length(yy)));
xx = reshape(xx,[],sqrt(length(xx))); % reshape back into a matrix
yy = reshape(yy,[],sqrt(length(yy))); % reshape back into a matrix

% Inaccuracy
%xy1m_error=sqrt(x1m-xx).^2+(y1m-yy).^2);
xy1m_error=sqrt(x1m.^2+y1m.^2)-sqrt(yy.^2+xx.^2);


% Error for x and y
xy1m_error_x=x1m-xx;
xy1m_error_y=y1m-yy;

figure(7)
subplot(2,1,1)
contourf(xx,yy,xy1m_error_x,30); % Plot data
c = colorbar;
ylabel(c,'Inaccuracy (mm)');
grid on
tl = title('Inaccuracy Estimation for x - \Delta/\Sigma');
yl = ylabel('Y (mm)');
xl = xlabel('X (mm)');
zlabel('Inaccuracy');
axis equal

if 0
    tl = title({'Inaccuracy Estimation';'for x - \Delta/\Sigma'});
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
end

subplot(2,1,2)
contourf(xx,yy,xy1m_error_y,30); % Plot data
c = colorbar;
ylabel(c,'Inaccuracy (mm)');
grid on
tl = title('Inaccuracy Estimation for y - \Delta/\Sigma');
yl = ylabel('Y (mm)');
xl = xlabel('X (mm)');
zlabel('Inaccuracy');
axis equal

if 0 
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
end

print -depsc 1_7 % plotting figure

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
tl = title('Inaccuracy Estimation')
yl = ylabel('Y (mm)')
xl = xlabel('X (mm)')
zlabel('Inaccuracy')
%set(gca,'DataAspectRatio',[10 10 1])
axis equal
%}


figure(4)
contourf(xx,yy,xy1m_error,30); % Plot data
c1 = colorbar;
e_bound = caxis;
ylabel(c1,'Inaccuracy (mm)');
grid on
tl = title('Inaccuracy Estimation - \Delta/\Sigma');
yl = ylabel('Y (mm)');
xl = xlabel('X (mm)');
% zlabel('Inaccuracy');
%set(gca,'DataAspectRatio',[10 10 1])
axis equal

if big_fonts
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
    ylabel(c1,'Inaccuracy (mm)','FontSize',20);
end

print -depsc 1_4 % plotting figure

% set error boundaries

e_bound = [-25e-4 20e-4]; % in nm
caxis([e_bound(1) e_bound(2)]); % set boundaries

if big_fonts 
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
    ylabel(c1,'Inaccuracy (nm)','FontSize',20);
    set(c1,'YTick',[e_bound(1) 0 e_bound(2)],'YTickLabel',{num2str(e_bound(1)*1e6) ;'0'; num2str(e_bound(2)*1e6)})
    
end

print -depsc 1_5 % plotting figure


%% Plot for a defined error

err1 = 1e-4; % in mm
% err2 = 5e-4; % in mm, must be bigger than err1
figure(6)

% % plot contour for err2
% 
% err_vector = [-err2 err2]; 
% [C,h] = contourf(xx,yy,xy1m_error,err_vector); % Plot data
% 
% allH = allchild(h);
% valueToHide = err2;
% patchValues = cell2mat(get(allH,'UserData'));
% % patchesToHide = abs(patchValues - valueToHide) < 100*eps(valueToHide);
% patchesToHide = abs(patchValues - valueToHide) < 100*eps(valueToHide);
% set(allH(patchesToHide),'FaceColor','w','FaceAlpha',1);
% set(allH([false false false false true]),'FaceColor','c','FaceAlpha',1);
hold on

% plot contour for err1

err_vector = [-err1 err1]; 
[C,h] = contourf(xx,yy,xy1m_error,err_vector); % Plot data

allH = allchild(h);
valueToHide = err1;
patchValues = cell2mat(get(allH,'UserData'));
% patchesToHide = abs(patchValues - valueToHide) < 100*eps(valueToHide);
patchesToHide = abs(patchValues - valueToHide) < 100*eps(valueToHide);
set(allH(patchesToHide),'FaceColor','w','FaceAlpha',1);
set(allH([false false false false true]),'FaceColor','b','FaceAlpha',1);
hold off

ylabel(c,'Inaccuracy (mm)');
grid on
tl = title(['Inaccuracy smaller than ' num2str(err1*1e6) ' nm - \Delta/\Sigma']);
yl = ylabel('Y (mm)');
xl = xlabel('X (mm)');
zlabel('Inaccuracy');
axis equal

if big_fonts 
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
end

print -depsc 1_6 % plotting figure


