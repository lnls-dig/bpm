% nrow = length(rgy)
% ncol = length(rgx)

%%
bd = 12e-3;                             % BPM button diameter [m] - Booster
r = 18.1e-3;                            % BPM radius [m] - Booster
%bd = 6e-3;                             % BPM button diameter [m] - Storage Ring
%r = 12e-3;                             % BPM radius [m] - Storage Ring
pu_ang = [pi/4 3*pi/4 5*pi/4 7*pi/4];   % Angle of BPM pick-ups [rad]

%%
lim = 12e-3;                            % Booster
%lim = 8e-3;                            % Storage Ring
dx_grid = 0.5e-3;
dy_grid = 0.5e-3;

dxy_diff = 1e-9;

rgx = -lim:dx_grid:lim;
rgy = -lim:dy_grid:lim;
[x, y] = meshgrid(rgx,rgy);
xy_beam = [x y];

S = sqrt(2)/r;
K = 1/S;

method = 'partial delta/sigma';

abcd_dx1 = chargecirc(x-dxy_diff/2, y, bd, r, pu_ang);
abcd_dx2 = chargecirc(x+dxy_diff/2, y, bd, r, pu_ang);

abcd_dy1 = chargecirc(x, y-dxy_diff/2, bd, r, pu_ang);
abcd_dy2 = chargecirc(x, y+dxy_diff/2, bd, r, pu_ang);

xy_bpm_dx1 = calcpos(abcd_dx1, 1, 1, 1, method);
xy_bpm_dx2 = calcpos(abcd_dx2, 1, 1, 1, method);

xy_bpm_dy1 = calcpos(abcd_dy1, 1, 1, 1, method);
xy_bpm_dy2 = calcpos(abcd_dy2, 1, 1, 1, method);

% Calculate BPM sensitivity
Sdx = (xy_bpm_dx2-xy_bpm_dx1)/dxy_diff;
Sdy = (xy_bpm_dy2-xy_bpm_dy1)/dxy_diff;

Kdx = 1./Sdx;
Kdy = 1./Sdy;

Sideal_dx = cat(3, repmat(1/K, size(x)), zeros(size(x)));
Sideal_dy = cat(3, zeros(size(x)), repmat(1/K, size(x)));
Sx_error = (Sdx-Sideal_dx)/S*100;
Sy_error = (Sdy-Sideal_dy)/S*100;
S_error = cat(3, Sx_error, Sy_error);

rgx_mm = rgx/1e-3;
rgy_mm = rgy/1e-3;
r_mm = r/1e-3;

color_lim = [-80 0.1; -30 30; -30 30; -80 0.1];

figure;

zlabel('sens. X to dx');

tt = { ...
    'S_{XX} error [% S]' ...
    'S_{YX} error [% S]' ...
    'S_{XY} error [% S]' ...
    'S_{YY} error [% S]' ...
    };

levels = { ...
    -200:5:200; ...
    -200:5:200; ...
    -200:5:200; ...
    -200:5:200; ...
    };

bpm_body = r_mm*exp(-1j*linspace(0,2*pi,1000));
bpm_pu = r_mm*exp(-1j*(repmat(linspace(-bd/r/2,bd/r/2,100)',1,size(pu_ang,2))+repmat(pu_ang, 100, 1)));

for i=1:size(S_error,3)
    subplot(2,2,i);
    [c,h] = contourf(rgx_mm, rgy_mm, S_error(:,:,i), levels{i});
    clabel(c,h)
    hold all
    grid on
    plot(bpm_body, 'k')
    plot(bpm_pu, 'k', 'LineWidth', 4)
    xlabel('X [mm]');
    ylabel('Y [mm]');
    title(tt{i})
    colorbar;
    colormap('jet')
    axis equal
end