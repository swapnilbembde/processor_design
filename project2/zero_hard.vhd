--CHECKS IF INPUT IS ZERO, INPUT COMES FROM POST ALU REGISTER
--RETURNS ONE IF ZERO
library ieee;
use ieee.std_logic_1164.all;

entity zero_hard is 
	port ( 
		data_in: in std_logic_vector(15 downto 0);
		zero_out	: out std_logic
		);
end entity zero_hard;

architecture d_zero_hard of zero_hard is
begin 
	zero_out <= not(data_in(0) or data_in(1) or data_in(2) or data_in(3) or data_in(4) or data_in(5) or data_in(6) or data_in(7) or data_in(8) or data_in(9)
					 or data_in(10) or data_in(11) or data_in(12) or data_in(13) or data_in(14) or data_in(15));
end;