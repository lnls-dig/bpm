close all
clear all

big_fonts = 1; % set fonts to big size; 

%% Estimate real and measured beam positions

% Parameters

button_r = 3;
chamber_r = 12;

matrix_size = 15;
x_array_length = chamber_r/sqrt(2)*0.9;

xm = linspace(-x_array_length, x_array_length, matrix_size);
xym=zeros(matrix_size*matrix_size,2);

for i=1:matrix_size
  xym(1+(i-1)*matrix_size:matrix_size+(i-1)*matrix_size,2) = xm(i);
end

for i=1:matrix_size
  xym(1+(i-1)*matrix_size:matrix_size+(i-1)*matrix_size,1) = xm;
end

xym = xym + 0.01;

% Estimated Matrix

[abcdm] = pos2abcd(xym,button_r,chamber_r); % Convert to abcd coordinates

a = abcdm(:,1);
b = abcdm(:,2);
c = abcdm(:,3);
d = abcdm(:,4);

u = 0.5*(((a-c)./(a+c))+((d-b)./(d+b)));
v = 0.5*(((a-c)./(a+c))-((d-b)./(d+b)));


% Calculating the K parameters using non-linear regression

myfittype_x = fittype('a0 + a1*y^2 + a2*y^4 + a3*x^2 + a4*x^2*y^2 + a5*x^4',...
    'dependent',{'Kx_u'},'independent',{'x','y'},...
    'coefficients',{'a0','a1','a2','a3','a4','a5'})
myfit_x = fit([xym(:,1) xym(:,2)],xym(:,1)./u,myfittype_x);
Kx = coeffvalues(myfit_x);

myfittype_y = fittype('a0 + a1*y^2 + a2*y^4 + a3*x^2 + a4*x^2*y^2 + a5*x^4',...
    'dependent',{'Ky'},'independent',{'x','y'},...
    'coefficients',{'a0','a1','a2','a3','a4','a5'})
myfit_y = fit([xym(:,1) xym(:,2)],xym(:,2)./v,myfittype_y);
Ky = coeffvalues(myfit_y);

%plot(myfit_x,[xym(:,1) xym(:,2)],xym(:,1));



%% Plot Matrix

% Create chamber plot

theta = linspace(0,2*pi); % Chamber draw

x_chamber = chamber_r*cos(theta);
y_chamber = chamber_r*sin(theta);

[x_button,y_button] = button_draw(chamber_r,button_r,4,pi/4);

% Create xy vector matrix

matrix_size = 25;
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

rn = 5; % Set number of recursions

[abcdm] = pos2abcd(xym,button_r,chamber_r); % Convert to abcd coordinates
xy1m = calcpos_daphine_recursion(abcdm,Kx,Ky, rn); % Calculate position xy1


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
ll = legend('Real Positions','Calculated Positions','Location','best');
tl = title({['Real x Estimated Beam Position'];['Da\Phine (' num2str(rn) ' iterations)']});
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

print -depsc 5_2 % plotting figure

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
xy1m = calcpos_daphine_recursion(abcdm,Kx,Ky,rn); % Calculate position xy1

figure(3)
plot(xym(:,1),xym(:,2),'o',xy1m(:,1),xy1m(:,2),'r*') % Plot data
axis([-x_array_length x_array_length -x_array_length x_array_length]*1.1)
axis equal
ll = legend('Real Positions','Calculated Positions','Location','bestoutside');
tl = title(['Real x Estimated Beam Position - Da\Phine (' num2str(rn) ' iterations)']);
xl = xlabel('Real Beam Position (mm)');
yl = ylabel('Estimated Beam Position (mm)');
grid on

if big_fonts
    tl = title({['Real x Estimated Beam Position'];['Da\Phine (' num2str(rn) ' iterations)']});
    
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
    set(ll,'FontSize',15);
    set(ll,'position',[0.3192 0.015 0.3973 0.1515]);
    set(gca,'position',[0.1300 0.2972 0.7750 0.4838]);
end
    
print -depsc 5_3 % plotting figure

%% Plot Inaccuracy acording to pipe (absolute, x and y)

matrix_size = 50;

xm = linspace(-x_array_length, x_array_length, matrix_size);

[xx,yy] = meshgrid(xm,xm);

xx = reshape(xx,[],1); % reshape into an array
yy = reshape(yy,[],1); % reshape into an array

[abcdm] = pos2abcd([xx yy],button_r,chamber_r); % Convert to abcd coordinates
xy1m = calcpos_daphine_recursion(abcdm,Kx,Ky, rn); % Calculate position xy1

x1m = reshape(xy1m(:,1),[],sqrt(length(xx)));
y1m = reshape(xy1m(:,2),[],sqrt(length(yy)));
xx = reshape(xx,[],sqrt(length(xx))); % reshape back into a matrix
yy = reshape(yy,[],sqrt(length(yy))); % reshape back into a matrix

xy1m_Inaccuracy=sqrt(x1m.^2+y1m.^2)-sqrt(yy.^2+xx.^2);

% Inaccuracy for x and y
xy1m_Inaccuracy_x=x1m-xx;
xy1m_Inaccuracy_y=y1m-yy;

figure(7)
subplot(2,1,1)
contourf(xx,yy,xy1m_Inaccuracy_x,30); % Plot data
c = colorbar;
ylabel(c,'Inaccuracy (mm)');
grid on
tl = title(['Inaccuracy Estimation for x - Da\Phine (' num2str(rn) ' iterations)']);
yl = ylabel('Y (mm)');
xl = xlabel('X (mm)');
zlabel('Inaccuracy')
axis equal

subplot(2,1,2)
contourf(xx,yy,xy1m_Inaccuracy_y,30); % Plot data
c = colorbar;
ylabel(c,'Inaccuracy (mm)');
grid on
tl = title(['Inaccuracy Estimation for y - Da\Phine (' num2str(rn) ' iterations)']);
yl = ylabel('Y (mm)');
xl = xlabel('X (mm)');
zlabel('Inaccuracy')
axis equal

print -depsc 5_7 % plotting figure

% Plotting the surface

figure(4)
contourf(xx,yy,xy1m_Inaccuracy,30); % Plot data
c = colorbar;
e_bound = caxis;
ylabel(c,'Absolute Inaccuracy (mm)');
grid on
tl = title(['Absolute Inaccuracy Estimation - Da\Phine (' num2str(rn) ' iterations)']);
yl = ylabel('Y (mm)');
xl = xlabel('X (mm)');
zlabel('Inaccuracy')
%set(gca,'DataAspectRatio',[10 10 1])
axis equal

if big_fonts
    tl = title({['Absolute Inaccuracy Estimation'];['Da\Phine (' num2str(rn) ' iterations)']});
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
    ylabel(c,'Inaccuracy (mm)','FontSize',20);
end

print -depsc 5_4 % plotting figure

% set Inaccuracy boundaries

e_bound = [-25e-4 20e-4]; % in nm
caxis([e_bound(1) e_bound(2)]) % set boundaries

if big_fonts
    set(c,'YTick',[e_bound(1) 0 e_bound(2)],'YTickLabel',{num2str(e_bound(1)*1e6) ;'0'; num2str(e_bound(2)*1e6)})
    ylabel(c,'Inaccuracy (nm)','FontSize',20);
end

print -depsc 5_5 % plotting figure


%% Plot for a defined Inaccuracy

err1 = 1e-4; % in mm
err2 = 5e-4; % in mm, must be bigger than err1
figure(6)

hold on

% plot contour for err1

err_vector = [-err1 err1];  
[C,h] = contourf(xx,yy,xy1m_Inaccuracy,err_vector); % Plot data

allH = allchild(h);
valueToHide = err1;
set(allH([false]),'FaceColor','w','FaceAlpha',0);
set(allH([true]),'FaceColor','b','FaceAlpha',1);
hold off


ylabel(c,'Absolute Inaccuracy (mm)');
grid on
tl = title(['Inaccuracy smaller than ' num2str(err1*1e6) ' nm - Da\Phine (' num2str(rn) ' iterations)']);
yl = ylabel('Y (mm)');
xl = xlabel('X (mm)');
axis equal

if big_fonts 
    tl = title({['Inaccuracy smaller than ' num2str(err1*1e6) ' nm'];['Da\Phine (' num2str(rn) ' iterations)']});
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
end

print -depsc 5_6 % plotting figure
