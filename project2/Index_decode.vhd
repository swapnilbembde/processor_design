--DECODES THE OUTPUT FROM PRIORITY ENCODER,
--EXTRA IS IFF ALL INPUTS ARE ZERO, THE OUTPUT VALUE IS ALSO ZERO
library ieee;
use ieee.std_logic_1164.all;

entity Index_decode is
	port
	(
		index_input	: in std_logic_vector(2 downto 0);
		all_zero_input	: in std_logic;
		reset_out	: 	out std_logic_vector(7 downto 0)
	);
end entity Index_decode;


architecture d_index of Index_decode is
begin
	reset_out(0) <=   (not all_zero_input) and (not index_input(0)) and (not index_input(1)) and (not index_input(2));
	reset_out(1) <=   (not all_zero_input) and (index_input(0)) and (not index_input(1)) and (not index_input(2));
	reset_out(2) <=   (not all_zero_input) and (not index_input(0)) and (index_input(1)) and (not index_input(2));
	reset_out(3) <=   (not all_zero_input) and (index_input(0)) and (index_input(1)) and (not index_input(2));
	reset_out(4) <=   (not all_zero_input) and (not index_input(0)) and (not index_input(1)) and (index_input(2));
	reset_out(5) <=   (not all_zero_input) and (index_input(0)) and (not index_input(1)) and (index_input(2));
	reset_out(6) <=   (not all_zero_input) and (not index_input(0)) and (index_input(1)) and (index_input(2));
	reset_out(7) <=   (not all_zero_input) and (index_input(0)) and (index_input(1)) and (index_input(2));
end;
