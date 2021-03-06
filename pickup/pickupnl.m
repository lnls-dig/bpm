% nrow = length(rgy)
% ncol = length(rgx)

unitconv = 1e9;                         % Set 1 for m or 1e9 for nm

%% Parameters
bd = 12e-3;                             % BPM button diameter [m] - Booster
r = 18.05e-3;                           % BPM radius [m] - Booster
%bd = 6e-3;                             % BPM button diameter [m] - Storage Ring
%r = 12e-3;                             % BPM radius [m] - Storage Ring
pu_ang = [pi/4 3*pi/4 5*pi/4 7*pi/4];   % Angle of BPM pick-ups [rad]
sigmax = 4e-3;                          % Horizontal beam size [m]
sigmay = 0.1e-3;                        % Vertical beam size [m]
np = 1;                                 % Number of particles
lim = 18e-3;
step_grid = 0.5e-3;
method = 'partial delta/sigma';
dxy_diff = 1e-9;
verify_std_mean = true;
lim_fit = 12e-3;
step_fit = 0.5e-3;
Wspec = 7;

bd = bd*unitconv;
r = r*unitconv;
sigmax = sigmax*unitconv;
sigmay = sigmay*unitconv;
lim = lim*unitconv;
step_grid = step_grid*unitconv;
dxy_diff = dxy_diff*unitconv;
lim_fit = lim_fit*unitconv;
step_fit = step_fit*unitconv;

max_poserror_mm = 200e-3;
max_Serror_sup = 0.05;
max_Serror_inf = 0.05;
max_couperror = 0.05;
max_sumerror = 0.01;
max_qerror = 0.01;

roix = -lim_fit:step_fit:lim_fit;
roiy = roix;

npoly.x = 9;
npoly.y = npoly.x;
npoly.q = 5;
npoly.sum = 6;

%% BPM polynomial fit
poly = circbpmfit(npoly, r, bd, pu_ang, method, roix, roiy, Wspec);
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
xp(outofchamber) = nan;
yp(outofchamber) = nan;

if verify_std_mean
    stdx = std(xp,1,3,'omitnan');
    stdy = std(yp,1,3,'omitnan');
    meanx = mean(xp,3,'omitnan');
    meany = mean(yp,3,'omitnan');
end

alpha = bd/r;
S = sqrt(2)/r*2*sin(alpha/2)/alpha;
K = 1/S;

if np > 1
    abcd     = squeeze(sum(chargecirc(xp, yp, bd, r, pu_ang),3,'omitnan'))/np;
    abcd_dx1 = squeeze(sum(chargecirc(xp-dxy_diff/2, yp, bd, r, pu_ang),3,'omitnan'))/np;
    abcd_dx2 = squeeze(sum(chargecirc(xp+dxy_diff/2, yp, bd, r, pu_ang),3,'omitnan'))/np;
    abcd_dy1 = squeeze(sum(chargecirc(xp, yp-dxy_diff/2, bd, r, pu_ang),3,'omitnan'))/np;
    abcd_dy2 = squeeze(sum(chargecirc(xp, yp+dxy_diff/2, bd, r, pu_ang),3,'omitnan'))/np;
else
    abcd     = chargecirc(xp, yp, bd, r, pu_ang);
    abcd_dx1 = chargecirc(xp-dxy_diff/2, yp, bd, r, pu_ang);
    abcd_dx2 = chargecirc(xp+dxy_diff/2, yp, bd, r, pu_ang);
    abcd_dy1 = chargecirc(xp, yp-dxy_diff/2, bd, r, pu_ang);
    abcd_dy2 = chargecirc(xp, yp+dxy_diff/2, bd, r, pu_ang);
end

if isempty(polynomial)
    [xy_bpm    , q_bpm,     sum_bpm]     = calcpos(abcd,     K, K, 1, method);
    [xy_bpm_dx1, q_bpm_dx1, sum_bpm_dx1] = calcpos(abcd_dx1, 1, 1, 1, method);
    [xy_bpm_dx2, q_bpm_dx2, sum_bpm_dx2] = calcpos(abcd_dx2, 1, 1, 1, method);
    [xy_bpm_dy1, q_bpm_dy1, sum_bpm_dy1] = calcpos(abcd_dy1, 1, 1, 1, method);
    [xy_bpm_dy2, q_bpm_dy2, sum_bpm_dy2] = calcpos(abcd_dy2, 1, 1, 1, method);
else
    [xy_bpm    , q_bpm,     sum_bpm]     = calcpos(abcd,     1, 1, 1, method, polynomial);
    [xy_bpm_dx1, q_bpm_dx1, sum_bpm_dx1] = calcpos(abcd_dx1, 1, 1, 1, method, polynomial);
    [xy_bpm_dx2, q_bpm_dx2, sum_bpm_dx2] = calcpos(abcd_dx2, 1, 1, 1, method, polynomial);
    [xy_bpm_dy1, q_bpm_dy1, sum_bpm_dy1] = calcpos(abcd_dy1, 1, 1, 1, method, polynomial);
    [xy_bpm_dy2, q_bpm_dy2, sum_bpm_dy2] = calcpos(abcd_dy2, 1, 1, 1, method, polynomial);
    xy_bpm_dx1 = xy_bpm_dx1/polynomial.x.coeff(1);
    xy_bpm_dx2 = xy_bpm_dx2/polynomial.x.coeff(1);
    xy_bpm_dy1 = xy_bpm_dy1/polynomial.x.coeff(1);
    xy_bpm_dy2 = xy_bpm_dy2/polynomial.x.coeff(1);   
end

% Calculate BPM sensitivity
Sdx = (xy_bpm_dx2-xy_bpm_dx1)/dxy_diff;
Sdy = (xy_bpm_dy2-xy_bpm_dy1)/dxy_diff;

Kdx = 1./Sdx;
Kdy = 1./Sdy;

Sx_factor = Sdx/S;
Sy_factor = Sdy/S;
S_factor = cat(3, Sx_factor, Sy_factor);

% Normalize sum
sum_bpm = sum_bpm*pi/2/bd*r;

% Calculate position error
xy_error = xy_beam - xy_bpm;
xy_dist_error = sqrt(xy_error(:,:,1).^2 + xy_error(:,:,2).^2);

%% Plots
rgx_mm = rg/1e-3/unitconv;
rgy_mm = rg/1e-3/unitconv;
r_mm = r/1e-3/unitconv;
xy_error_mm = xy_error/1e-3/unitconv;
xy_dist_error_mm = xy_dist_error/1e-3/unitconv;

bpm_body = r_mm*exp(-1j*linspace(0,2*pi,1000));
bpm_pu = r_mm*exp(-1j*(repmat(linspace(-bd/r/2,bd/r/2,100)',1,size(pu_ang,2))+repmat(pu_ang, 100, 1))); 

% Plot 1
title_persubplot = { ...
    'S_X [S]' ...
    'Coupling Y|dx [S]' ...
    'Coupling X|dy [S]' ...
    'S_Y [S]' ...
    };

caxis_persubplot = [...
    1-max_Serror_inf 1+max_Serror_sup; ...
    -max_couperror max_couperror; ...
    -max_couperror max_couperror; ...
    1-max_Serror_inf 1+max_Serror_sup; ...
    ];

figure;
zlabel('sens. X to dx');
for i=1:size(S_factor,3)
    subplot(2,2,i);
    h = surf(rgx_mm, rgy_mm, S_factor(:,:,i)); set(h, 'EdgeAlpha', 0.3);
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
h = surf(rgx_mm, rgy_mm, xy_dist_error_mm); set(h, 'EdgeAlpha', 0.3);
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Distance to beam position [mm]'); title('Distance error ||xy_{beam} - xy_{BPM}|| [mm]');
colorbar; colormap('jet'); caxis([0 max_poserror_mm]);
axis equal;
view(0,90);

% Plot 3
figure;
h = surf(rgx_mm, rgy_mm, xy_error_mm(:,:,1)); set(h, 'EdgeAlpha', 0.3);
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('X error [mm]'); title('X error (x_{beam} - x_{BPM}) [mm]');
colorbar; colormap('jet'); caxis([-max_poserror_mm max_poserror_mm]);
axis equal;
view(0,90);

% Plot 4
figure;
h = surf(rgx_mm, rgy_mm, xy_error_mm(:,:,2)); set(h, 'EdgeAlpha', 0.3);
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Y erro [mm]'); title('Y error (y_{beam} - y_{BPM}) [mm]');
colorbar; colormap('jet'); caxis([-max_poserror_mm max_poserror_mm]);
axis equal;
view(0,90);

% Plot 5
figure;
h = surf(rgx_mm, rgy_mm, q_bpm); set(h, 'EdgeAlpha', 0.3);
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Q'); title('Q');
colorbar; colormap('jet'); caxis([-max_qerror max_qerror]);
axis equal;
view(0,90);

% Plot 6
figure;
h = surf(rgx_mm, rgy_mm, sum_bpm); set(h, 'EdgeAlpha', 0.3);
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Sum'); title('Sum');
colorbar; colormap('jet'); caxis([1-max_sumerror 1+max_sumerror]);
axis equal;
view(0,90);

% Plot 7
if verify_std_mean
    figure;
    subplot(2,2,1); h = surf(rgx_mm, rgy_mm, stdx/sigmax); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('X std verification'); set(h, 'EdgeAlpha', 0.3);
    subplot(2,2,2); h = surf(rgx_mm, rgy_mm, stdy/sigmay); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Y std verification'); set(h, 'EdgeAlpha', 0.3);
    subplot(2,2,3); h = surf(rgx_mm, rgy_mm, meanx./x); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('X mean verification'); set(h, 'EdgeAlpha', 0.3);
    subplot(2,2,4); h = surf(rgx_mm, rgy_mm, meany./y); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Y mean verification'); set(h, 'EdgeAlpha', 0.3);
end