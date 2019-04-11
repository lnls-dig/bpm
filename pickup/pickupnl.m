% nrow = length(rgy)
% ncol = length(rgx)

%% Parameters
bd = 12e-3;                             % BPM button diameter [m] - Booster
r = 18.1e-3;                            % BPM radius [m] - Booster
%bd = 6e-3;                             % BPM button diameter [m] - Storage Ring
%r = 12e-3;                             % BPM radius [m] - Storage Ring
pu_ang = [pi/4 3*pi/4 5*pi/4 7*pi/4];   % Angle of BPM pick-ups [rad]
sigmax = 4e-3;                          % Horizontal beam size [m]
sigmay = 0.1e-3;                          % Vertical beam size [m]
np = 10e3;                              % Number of particles
lim = 12e-3;
step_grid = 0.5e-3;
method = 'partial delta/sigma';
dxy_diff = 1e-9;
verify_std_mean = true;

lim_fit = 9e-3;
step_fit = 0.1e-3;

max_poserror_mm = 500e-3;
max_Serror = 0.5;
max_couperror = 0.5;

roix = -lim_fit:step_fit:lim_fit;
roiy = roix;

npoly = 9;

%% BPM polynomial fit
poly = circbpmfit(npoly, r, bd, pu_ang, method, roix, roiy);
polynomial = poly;

%% Processing
rg = -lim:step_grid:lim;
[x, y] = meshgrid(rg,rg);
xy_beam = cat(3,x,y);

nx = length(rg);
ny = nx;

if np == 1
    sigmax = 0;
    sigmay = 0;
    warning('Ignoring ''sigmax'' and ''sigmay'' parameters since the number of particles is set to 1.');
end

xm = repmat(x, [1 1 np]);
ym = repmat(y, [1 1 np]);

xp = xm + sigmax*randn(nx,ny,np);
yp = ym + sigmay*randn(nx,ny,np);

dist = sqrt(xp.^2 + yp.^2);
outofchamber = find(dist >= r);
xp(outofchamber) = xm(outofchamber);
yp(outofchamber) = ym(outofchamber);

if verify_std_mean
    stdx = std(xp,1,3);
    stdy = std(yp,1,3);
    meanx = mean(xp,3);
    meany = mean(yp,3);
end

alpha = bd/r;
S = sqrt(2)/r*2*sin(alpha/2)/alpha;
K = 1/S;

if np > 1
    abcd     = squeeze(sum(chargecirc(xp, yp, bd, r, pu_ang),3))/np;
    abcd_dx1 = squeeze(sum(chargecirc(xp-dxy_diff/2, yp, bd, r, pu_ang),3))/np;
    abcd_dx2 = squeeze(sum(chargecirc(xp+dxy_diff/2, yp, bd, r, pu_ang),3))/np;
    abcd_dy1 = squeeze(sum(chargecirc(xp, yp-dxy_diff/2, bd, r, pu_ang),3))/np;
    abcd_dy2 = squeeze(sum(chargecirc(xp, yp+dxy_diff/2, bd, r, pu_ang),3))/np;
else
    abcd     = chargecirc(xp, yp, bd, r, pu_ang);
    abcd_dx1 = chargecirc(xp-dxy_diff/2, yp, bd, r, pu_ang);
    abcd_dx2 = chargecirc(xp+dxy_diff/2, yp, bd, r, pu_ang);
    abcd_dy1 = chargecirc(xp, yp-dxy_diff/2, bd, r, pu_ang);
    abcd_dy2 = chargecirc(xp, yp+dxy_diff/2, bd, r, pu_ang);
end

if isempty(polynomial)
    xy_bpm     = calcpos(abcd, 1, 1, 1, method);
    xy_bpm_dx1 = calcpos(abcd_dx1, 1, 1, 1, method);
    xy_bpm_dx2 = calcpos(abcd_dx2, 1, 1, 1, method);
    xy_bpm_dy1 = calcpos(abcd_dy1, 1, 1, 1, method);
    xy_bpm_dy2 = calcpos(abcd_dy2, 1, 1, 1, method);
else
    xy_bpm     = calcpos(abcd, 1, 1, 1, method, polynomial);
    xy_bpm_dx1 = calcpos(abcd_dx1, 1, 1, 1, method, polynomial)/polynomial.x.coeff(1);
    xy_bpm_dx2 = calcpos(abcd_dx2, 1, 1, 1, method, polynomial)/polynomial.x.coeff(1);
    xy_bpm_dy1 = calcpos(abcd_dy1, 1, 1, 1, method, polynomial)/polynomial.x.coeff(1);
    xy_bpm_dy2 = calcpos(abcd_dy2, 1, 1, 1, method, polynomial)/polynomial.x.coeff(1);
end

% Calculate BPM sensitivity
Sdx = (xy_bpm_dx2-xy_bpm_dx1)/dxy_diff;
Sdy = (xy_bpm_dy2-xy_bpm_dy1)/dxy_diff;

Kdx = 1./Sdx;
Kdy = 1./Sdy;

Sx_factor = Sdx/S;
Sy_factor = Sdy/S;
S_factor = cat(3, Sx_factor, Sy_factor);

% Calculate position error
xy_error = xy_beam - xy_bpm;
xy_dist_error = sqrt(xy_error(:,:,1).^2 + xy_error(:,:,2).^2);

%% Plots
rgx_mm = rg/1e-3;
rgy_mm = rg/1e-3;
r_mm = r/1e-3;
xy_error_mm = xy_error/1e-3;
xy_dist_error_mm = xy_dist_error/1e-3;

bpm_body = r_mm*exp(-1j*linspace(0,2*pi,1000));
bpm_pu = r_mm*exp(-1j*(repmat(linspace(-bd/r/2,bd/r/2,100)',1,size(pu_ang,2))+repmat(pu_ang, 100, 1))); 

% Plot 1
title_persubplot = { ...
    'S_{XX} [S]' ...
    'S_{YX} [S]' ...
    'S_{XY} [S]' ...
    'S_{YY} [S]' ...
    };

caxis_persubplot = [...
    1-max_Serror 1+max_Serror; ...
    -max_couperror max_couperror; ...
    -max_couperror max_couperror; ...
    1-max_Serror 1+max_Serror; ...
    ];

figure;
zlabel('sens. X to dx');
for i=1:size(S_factor,3)
    subplot(2,2,i);
    h = surf(rgx_mm, rgy_mm, S_factor(:,:,i));
    hold all; grid on;
    plot(bpm_body, 'k');
    plot(bpm_pu, 'k', 'LineWidth', 4);
    xlabel('X [mm]'); ylabel('Y [mm]'); title(title_persubplot{i});
    colorbar; colormap('jet'); caxis(caxis_persubplot(i,:));
    axis equal;
    view(0,90);
end

% Plot 2
figure;
h = surf(rgx_mm, rgy_mm, xy_dist_error_mm);
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Distance to beam position [mm]'); title('Distance error ||xy_{beam} - xy_{BPM}|| [mm]');
colorbar; colormap('jet'); caxis([0 max_poserror_mm]);
axis equal;
view(0,90);

% Plot 3
figure;
surf(rgx_mm, rgy_mm, xy_error_mm(:,:,1));
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('X error [mm]'); title('X error (x_{beam} - x_{BPM}) [mm]');
colorbar; colormap('jet'); caxis([-max_poserror_mm max_poserror_mm]);
axis equal;
view(0,90);

% Plot 4
figure;
surf(rgx_mm, rgy_mm, xy_error_mm(:,:,2));
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Y erro [mm]'); title('Y error (y_{beam} - y_{BPM}) [mm]');
colorbar; colormap('jet'); caxis([-max_poserror_mm max_poserror_mm]);
axis equal;
view(0,90);

% Plot 5
if verify_std_mean
    figure;
    subplot(2,2,1); surf(rgx_mm, rgy_mm, stdx/sigmax); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('X std verification');
    subplot(2,2,2); surf(rgx_mm, rgy_mm, stdy/sigmay); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Y std verification');
    subplot(2,2,3); surf(rgx_mm, rgy_mm, meanx./x); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('X mean verification');
    subplot(2,2,4); surf(rgx_mm, rgy_mm, meany./y); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Y mean verification');
end