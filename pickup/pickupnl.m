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
lim = 12e-3;                            % Booster
%lim = 8e-3;                            % Storage Ring
dx_grid = 1e-3;
dy_grid = 1e-3;
dxy_diff = 1e-9;
verify_std_mean = true;

lim_fit = 12e-3;
dx_grid_fit = 1e-3;
dy_grid_fit = 1e-3;


%% Processing
rgx = -lim:dx_grid:lim;
rgy = -lim:dy_grid:lim;
[x, y] = meshgrid(rgx,rgy);
xy_beam = cat(3,x,y);

rgx_fit = -lim_fit:dx_grid_fit:lim_fit;
rgy_fit = -lim_fit:dy_grid_fit:lim_fit;
[x_fit, y_fit] = meshgrid(rgx_fit,rgy_fit);

nx = length(rgx);
ny = length(rgy);

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

method = 'partial delta/sigma';

if np > 1    
    abcd_dx1 = squeeze(sum(chargecirc(xp-dxy_diff/2, yp, bd, r, pu_ang),3))/np;
    abcd_dx2 = squeeze(sum(chargecirc(xp+dxy_diff/2, yp, bd, r, pu_ang),3))/np;
    abcd_dy1 = squeeze(sum(chargecirc(xp, yp-dxy_diff/2, bd, r, pu_ang),3))/np;
    abcd_dy2 = squeeze(sum(chargecirc(xp, yp+dxy_diff/2, bd, r, pu_ang),3))/np;
else    
    abcd_dx1 = chargecirc(xp-dxy_diff/2, yp, bd, r, pu_ang);
    abcd_dx2 = chargecirc(xp+dxy_diff/2, yp, bd, r, pu_ang);
    abcd_dy1 = chargecirc(xp, yp-dxy_diff/2, bd, r, pu_ang);
    abcd_dy2 = chargecirc(xp, yp+dxy_diff/2, bd, r, pu_ang);
end

abcd_fit = chargecirc(x_fit, y_fit, bd, r, pu_ang);
abcd_eval = chargecirc(x, y, bd, r, pu_ang);
xy_bpm_eval = calcpos(abcd_eval, K, K, 1, method);
xy_bpm_fit = calcpos(abcd_fit, K, K, 1, method);

xy_bpm_dx1 = calcpos(abcd_dx1, 1, 1, 1, method);
xy_bpm_dx2 = calcpos(abcd_dx2, 1, 1, 1, method);
xy_bpm_dy1 = calcpos(abcd_dy1, 1, 1, 1, method);
xy_bpm_dy2 = calcpos(abcd_dy2, 1, 1, 1, method);

% BPM fit
[aa, bb] = meshgrid(0:9,0:10);
[cc, dd] = meshgrid(0:8,0:7);
coeff_desc_x = [aa(:) bb(:)];
coeff_desc_y = [cc(:) dd(:)];

coeff_desc_x = [ ...
    1   0; ...
    3   0; ...
    5   0; ...
    7   0; ...
    9   0; ...
    1   2; ...
    3   2; ...
    5   2; ...
    7   2; ...
    1   4; ...
    3   4; ...
    5   4; ...
    1   6; ...
    3   6; ...
    1   8; ...
];

coeff_desc_y = coeff_desc_x(:,[2 1]);

%coeff_desc = [1 0; 0 1; 3 2; 2 3];
coeff_x = fit2dsvd(xy_bpm_fit(:,:,1), xy_bpm_fit(:,:,2), x_fit, coeff_desc_x, 1e18);
coeff_y = fit2dsvd(xy_bpm_fit(:,:,1), xy_bpm_fit(:,:,2), y_fit, coeff_desc_y, 1e18);

% figure;
% surf(20*log10(reshape(abs(coeffx(:,1)),size(aa,1),size(aa,2))))
% view(0,90)
% 
% figure;
% surf(20*log10(reshape(abs(coeffy(:,1)),size(cc,1),size(cc,2))))
% view(0,90)

[~, x_bpm_corr] = fit2dsvdeval(xy_bpm_eval(:,:,1), xy_bpm_eval(:,:,2), coeff_desc_x, coeff_x); 
[~, y_bpm_corr] = fit2dsvdeval(xy_bpm_eval(:,:,1), xy_bpm_eval(:,:,2), coeff_desc_y, coeff_y); 
xy_bpm_corr = cat(3, x_bpm_corr, y_bpm_corr);

% Calculate BPM sensitivity
Sdx = (xy_bpm_dx2-xy_bpm_dx1)/dxy_diff;
Sdy = (xy_bpm_dy2-xy_bpm_dy1)/dxy_diff;

Kdx = 1./Sdx;
Kdy = 1./Sdy;

Sx_factor = Sdx/S;
Sy_factor = Sdy/S;
S_factor = cat(3, Sx_factor, Sy_factor);

% Calculate position error
xy_error = xy_beam - xy_bpm_eval;
xy_dist_error = sqrt(xy_error(:,:,1).^2 + xy_error(:,:,2).^2);

xy_error_corr = xy_beam - xy_bpm_corr;
xy_dist_error_corr = sqrt(xy_error_corr(:,:,1).^2 + xy_error_corr(:,:,2).^2);

%% Plots
rgx_mm = rgx/1e-3;
rgy_mm = rgy/1e-3;
r_mm = r/1e-3;
xy_error_mm = xy_error/1e-3;
xy_dist_error_mm = xy_dist_error/1e-3;
xy_error_corr_mm = xy_error_corr/1e-3;
xy_dist_error_corr_mm = xy_dist_error_corr/1e-3;

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
    0 1.2; ...
    -0.5 0.5; ...
    -0.5 0.5; ...
    0 1.2; ...
    ];

levels_persubplot = { ...
    -2:0.05:2; ...
    -2:0.05:2; ...
    -2:0.05:2; ...
    -2:0.05:2; ...
    };

figure;
zlabel('sens. X to dx');
for i=1:size(S_factor,3)
    subplot(2,2,i);
    [c,h] = contourf(rgx_mm, rgy_mm, S_factor(:,:,i), levels_persubplot{i}); clabel(c,h);
    hold all; grid on;
    plot(bpm_body, 'k');
    plot(bpm_pu, 'k', 'LineWidth', 4);
    xlabel('X [mm]'); ylabel('Y [mm]'); title(title_persubplot{i});
    colorbar; colormap('jet'); caxis(caxis_persubplot(i,:));
    axis equal;
end

% Plot 2
caxis_persubplot = [0 max(max(max(xy_dist_error_mm, xy_dist_error_corr_mm)))];
figure;
subplot(121); surf(rgx_mm, rgy_mm, xy_dist_error_mm);
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Distance to beam position [mm]'); title('Distance error ||xy_{beam} - xy_{BPM}|| [mm]');
colorbar; colormap('jet'); caxis(caxis_persubplot);
axis equal;
view(0,90);
subplot(122); surf(rgx_mm, rgy_mm, xy_dist_error_corr_mm);
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Distance to beam position [mm]'); title('Distance error ||xy_{beam} - xy_{BPM}|| with polynomial correction [mm]');
colorbar; colormap('jet'); caxis(caxis_persubplot);
axis equal;
view(0,90);

% Plot 3
caxis_persubplot = [min(min(min(xy_error_mm(:,:,1), xy_error_corr_mm(:,:,1)))) max(max(max(xy_error_mm(:,:,1), xy_error_corr_mm(:,:,1))))];
figure;
subplot(121); surf(rgx_mm, rgy_mm, xy_error_mm(:,:,1));
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('X error [mm]'); title('X error (x_{beam} - x_{BPM}) [mm]');
colorbar; colormap('jet'); caxis(caxis_persubplot);
axis equal;
view(0,90);
subplot(122); surf(rgx_mm, rgy_mm, xy_error_corr_mm(:,:,1));
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('X error [mm]'); title('X error (x_{beam} - x_{BPM}) with polynomial correction [mm]');
colorbar; colormap('jet'); caxis(caxis_persubplot);
axis equal;
view(0,90);

% Plot 4
caxis_persubplot = [min(min(min(xy_error_mm(:,:,2), xy_error_corr_mm(:,:,2)))) max(max(max(xy_error_mm(:,:,2), xy_error_corr_mm(:,:,2))))];
figure;
subplot(121); surf(rgx_mm, rgy_mm, xy_error_mm(:,:,2));
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Y erro [mm]'); title('Y error (y_{beam} - y_{BPM}) [mm]');
colorbar; colormap('jet'); caxis(caxis_persubplot);
axis equal;
view(0,90);subplot(122); surf(rgx_mm, rgy_mm, xy_error_corr_mm(:,:,2));
hold all; grid on;
plot(bpm_body, 'k');
plot(bpm_pu, 'k', 'LineWidth', 4);
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Y erro [mm]'); title('Y error (y_{beam} - y_{BPM}) with polynomial correction [mm]');
colorbar; colormap('jet'); caxis(caxis_persubplot);
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