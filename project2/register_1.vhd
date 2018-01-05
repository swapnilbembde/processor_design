--ONE BIT REGISTER, IMPLEMENTED IN PRIORITY ENCODER
library ieee;
use ieee.std_logic_1164.all;

entity register_1 is 
	port ( 
		data_in: in std_logic;
		data_out: out std_logic;
		LD_reg: in std_logic;
		Reset,clk: in std_logic
		);
end entity register_1;

architecture d_register_1 of register_1 is 
	begin
		process(Reset,clk,data_in,LD_reg)
			variable data: std_logic;
			begin
				if(Reset = '1') then
						data := '0';
				elsif(clk'event and (clk = '1')) then
					if (LD_reg = '1') then
						data := data_in;
					else 
						data := data;
					end if;
				else 
					data := data;
				end if;
				data_out <= data;
			end process;
	end;
	
	
				
				