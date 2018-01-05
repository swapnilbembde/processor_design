--Decoder input is 3 bits output is 8 bit
library ieee;
use ieee.std_logic_1164.all;

entity decode_3to8 is
	port(
		address 	: in std_logic_vector(2 downto 0);
		output	: out std_logic_vector(7 downto 0)
		);
end entity decode_3to8;

architecture d_decode_3to8 of decode_3to8 is
begin 
	process(address)
		variable temp: std_logic_vector(7 downto 0) := "00000000";
		begin
		temp := "00000000";							--TEMPORARY VARIABLE DEFINED
			case address is 
						when "000" =>
							temp(0) := '1';
						when "001" =>
							temp(1) := '1';
						when "010" =>
							temp(2) := '1';
						when "011" =>
							temp(3) := '1';
						when "100" =>
							temp(4) := '1';
						when "101" =>
							temp(5) := '1';
						when "110" =>
							temp(6) := '1';
						when "111" =>
							temp(7) := '1';
						when others =>
							temp(0) := '0';
					end case;
		
		output <= temp;							--OUTPUT DEFINITION
		end process;
end;