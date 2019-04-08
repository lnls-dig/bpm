% nrow = length(rgy)
% ncol = length(rgx)

%% Parameters
bd = 12e-3;                             % BPM button diameter [m] - Booster
r = 18.1e-3;                            % BPM radius [m] - Booster
%bd = 6e-3;                             % BPM button diameter [m] - Storage Ring
%r = 12e-3;                             % BPM radius [m] - Storage Ring
pu_ang = [pi/4 3*pi/4 5*pi/4 7*pi/4];   % Angle of BPM pick-ups [rad]
sigmax = 4e-3;                          % Horizontal beam size [m]
sigmay = 2e-3;                          % Vertical beam size [m]
np = 10e3;                              % Number of particles
lim = 12e-3;                            % Booster
%lim = 8e-3;                            % Storage Ring
dx_grid = 1e-3;
dy_grid = 1e-3;
dxy_diff = 1e-9;
verify_std_mean = true;

%% Processing
rgx = -lim:dx_grid:lim;
rgy = -lim:dy_grid:lim;
[x, y] = meshgrid(rgx,rgy);
xy_beam = cat(3,x,y);

nx = length(rgx);
ny = length(rgy);

if np == 1
    sigmax = 0;
    sigmay = 0;
    warning('Ignoring ''sigmax'' and ''sigmay'' parameters since the number of particles is set to 1.');
end

xp = sigmax*randn(nx,ny,np);
yp = sigmay*randn(nx,ny,np);

xm = repmat(x, [1 1 np]);
ym = repmat(y, [1 1 np]);

xp = xm + xp;
yp = ym + yp;

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

xy_bpm_dx1 = calcpos(abcd_dx1, 1, 1, 1, method);
xy_bpm_dx2 = calcpos(abcd_dx2, 1, 1, 1, method);
xy_bpm_dy1 = calcpos(abcd_dy1, 1, 1, 1, method);
xy_bpm_dy2 = calcpos(abcd_dy2, 1, 1, 1, method);

% Calculate BPM sensitivity
Sdx = (xy_bpm_dx2-xy_bpm_dx1)/dxy_diff;
Sdy = (xy_bpm_dy2-xy_bpm_dy1)/dxy_diff;

Kdx = 1./Sdx;
Kdy = 1./Sdy;

Sx_factor = Sdx/S;
Sy_factor = Sdy/S;
S_factor = cat(3, Sx_factor, Sy_factor);

%% Plots

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

bpm_body = r_mm*exp(-1j*linspace(0,2*pi,1000));
bpm_pu = r_mm*exp(-1j*(repmat(linspace(-bd/r/2,bd/r/2,100)',1,size(pu_ang,2))+repmat(pu_ang, 100, 1))); 

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
rgx_mm = rgx/1e-3;
rgy_mm = rgy/1e-3;
r_mm = r/1e-3;

if verify_std_mean
    figure;
    subplot(2,2,1); surf(rgx_mm, rgy_mm, stdx/sigmax); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('X std verification');
    subplot(2,2,2); surf(rgx_mm, rgy_mm, stdy/sigmay); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Y std verification');
    subplot(2,2,3); surf(rgx_mm, rgy_mm, meanx./x); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('X mean verification');
    subplot(2,2,4); surf(rgx_mm, rgy_mm, meany./y); xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Y mean verification');
end