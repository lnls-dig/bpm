% Function to draw buttons around the chamber
% inputs:
%   cr = chamber radius
%   br = button radius
%   nb =  number of buttons
%   bd = button angle displacement


function [x_button,y_button] = button_draw(cr,br,nb,bd)

ha=asin(br/cr); % calculate half angle

step = 2*pi/nb;

for i=1:nb
    
    theta(i,:) = linspace((i-1)*step - ha, (i-1)*step + ha,100);

end

x_button = cr*cos(theta + bd);
y_button = cr*sin(theta + bd);

end