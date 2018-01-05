library ieee;
use ieee.std_logic_1164.all;


entity starter_PE is 
	port ( 
		IR_in: in std_logic_vector(15 downto 0);
		start_PE: out std_logic
		);
end entity starter_PE;

architecture d_starter_PE of starter_PE is 
	begin
	start_PE <= '1' when IR_in (15 downto 12) = "0110" else
				'1' when IR_in (15 downto 12) = "0111" else
				'0' when IR_in (15 downto 12) = "0000" else
				'0' when IR_in (15 downto 12) = "0001" else
				'0' when IR_in (15 downto 12) = "0010" else
				'0' when IR_in (15 downto 12) = "0100" else
				'0' when IR_in (15 downto 12) = "0101" else
				'0' when IR_in (15 downto 12) = "1100" else
				'0' when IR_in (15 downto 12) = "1000" else
				'0' when IR_in (15 downto 12) = "1001" else
				'0';
				
	end;