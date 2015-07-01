%% Script to plot chamber sketch

close all;
clear all;

big_fonts = 1; % set fonts to big size; 

% Create chamber plot

chamber_r = 12; % in mm
button_r = 3; % in mm

theta = linspace(0,2*pi); % Chamber draw

x_chamber = chamber_r*cos(theta);
y_chamber = chamber_r*sin(theta);

[x_button,y_button] = button_draw(chamber_r,button_r,4,pi/4);


hold on
plot(x_chamber,y_chamber,'k--') % Plot draws
for i=1:size(x_button,1)
    plot(x_button(i,:),y_button(i,:),'k.')
end
hold off
axis([-chamber_r chamber_r -chamber_r chamber_r]*1.1)
axis equal
% legend('Real Positions','Calculated Positions','Location','southoutside')
tl = title('Chamber Sketch');
xl = xlabel('(mm)');
yl = ylabel('(mm)');
grid on

if big_fonts 
    set(gca,'FontSize', 24);
    set(xl,'FontSize', 20);
    set(yl,'FontSize', 20);
    set(tl,'FontSize', 24);
%     set(ll,'FontSize',13);
end

print -depsc chamber_ilu % plotting figure