close all;
clear all;

theta = 0;
current = 1;
chamber_r = 12;
r = [1 2 5 10];
phi = linspace(-pi,pi,1000);

for i=1:4
  j(i,:) = current/(2*pi*chamber_r)*((chamber_r^2-r(i)^2)./(chamber_r^2+r(i)^2-2*chamber_r*r(i)*cos(phi-theta)));
end


plot(phi*180/pi,j(1,:),phi*180/pi,j(2,:),phi*180/pi,j(3,:),phi*180/pi,j(4,:))
grid on
xlabel('\phi(degrees)')
ylabel('Current line density')
legend('r=1mm','r=2mm','r=5mm','r=10mm')
axis([-180 180 min(min(j)) max(max(j))*1.1])
