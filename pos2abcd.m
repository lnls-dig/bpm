function [abcd] = pos2abcd(xy, button_r, chamber_r, current, steps)
 %POS2ABCD Transform a beam position in amplitude signal for each BPM.
 %
 % [abcd] = pos2abcd(xy, button_r, chamber_r) transform each line of
 % the array xy, containing beam position, into a abcd line, with
 % colums representing current for aach button.
 %
 % button_r is the radius of each button.
 %
 % chamber_r is the radius of the BPM's vacuum chamber .
 %
 % current is the beam current. If not set, defaults to 1.
 %
 % steps is the number of steps of the line integral that calculates
 % the current for each button. If not set, defaults to 10.

  
if nargin < 4
    current = 1;
end

if nargin < 5
    steps = 10;
end

%% Calculate start and end angles of each button

% Button angles from center of chamber
half_angle = asin(button_r/chamber_r);

%a_a1 =   pi/4 - half_angle; a_a2 =   pi/4 + half_angle;
%b_a1 = 3*pi/4 - half_angle; b_a2 = 3*pi/4 + half_angle;
%c_a1 = 5*pi/4 - half_angle; c_a2 = 5*pi/4 + half_angle;
%d_a1 = 7*pi/4 - half_angle; d_a2 = 7*pi/4 + half_angle;

a_a1 =   0 - half_angle; a_a2 =   0 + half_angle;
b_a1 = pi/2 - half_angle; b_a2 = pi/2 + half_angle;
c_a1 = pi - half_angle; c_a2 = pi + half_angle;
d_a1 = 3*pi/2 - half_angle; d_a2 = 3*pi/2 + half_angle;


%% Each button receives power according to the current induced in its 
%  circumference arc

% Convert beam position to polar coordiantes
[theta,r] = cart2pol(xy(:,1),xy(:,2));

abcd = zeros(size(xy,1),4);

for i = 1:size(xy,1)
  integration_steps = [linspace(a_a1,a_a2,steps);
		       linspace(b_a1,b_a2,steps);
		       linspace(c_a1,c_a2,steps); linspace(d_a1,d_a2,steps) ]'; 
  abcd(i,:) = trapz(axdensity(r(i),theta(i),chamber_r,integration_steps,current));
end

end

function j = axdensity(r,theta,chamber_r,phi,current)
%% This function is equivalent of the current density times the chamber 
%% radius a it is supposed to be called to make the line integration of 
%% the density function over ther circumference arc of the vaccum chamber

j = current/(2*pi)*((chamber_r^2-r^2)./(chamber_r^2+r^2-2*chamber_r*r*cos(phi-theta)));

end
