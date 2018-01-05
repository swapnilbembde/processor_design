--4 TO 1 MULITIPLEXOR

library ieee;
use ieee.std_logic_1164.all;

entity mux4to1 is
port(three,two,one,zero:in std_logic_vector(15 downto 0);
     output:out std_logic_vector(15 downto 0); 
     sel:in std_logic_vector(1 downto 0));
end entity;

architecture d_mux4to1 of mux4to1 is


begin
	
process(zero,one,sel,three,two)
variable temp: std_logic_vector(15 downto 0); 
begin

case sel is 
	when "00" =>
        temp:=zero;
    when "01" =>
        temp:=one;
    when "10" =>
        temp:=two;
    when "11" =>
        temp:=three;
    when others =>
        temp:="XXXXXXXXXXXXXXXX";
end case;

output<= temp;

end process;

end;



 
