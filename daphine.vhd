library ieee;
use ieee.std_logic_1164.all;
use ieee.std_numeric.all;

entity daphine is
  port ( a,b,c,d : in real;
         x,y :out real );

end entity

architecture daphine_arch of daphine is
  begin
    x <= ((a-c)/(a+c)+(d-b)/(d+b))*Kx;
    y <= ((a-c)/(a+c)-(d-b)/(d+b))*Ky;

end daphine_arch

      
