--8 BIT REGISTER ----INCLUDES WRITE ENABLE(LD_REG),DATA IN, DATA OUT,RESET, CLOCK
--RESET IS ASYNCHRONOUS
library ieee;
use ieee.std_logic_1164.all;

entity register_8 is 
	port ( 
		data_in: in std_logic_vector(7 downto 0);
		data_out: out std_logic_vector(7 downto 0);
		LD_reg: in std_logic;
		Reset,clk: in std_logic
		);
end entity register_8;

architecture d_register_8 of register_8 is 
	begin
		process(Reset,clk,data_in,LD_reg)
			variable data: std_logic_vector(7 downto 0);
			begin
				if(Reset = '1') then								--FIRST CHECK IF RESET IS EQUAL TO 1
						data := "00000000";						-- IF RESET 1 SET VALUE = 0
				elsif(clk'event and (clk = '1')) then		-- WHEN CLOCK IS HIGH AND WRITE ENABLE IS ON
					if (LD_reg = '1') then
						data := data_in;							-- WRITE DATA
					else 
						data := data;
					end if;
				else 
					data := data;
				end if;
				data_out <= data;									-- OUTPUT DEFINATION
			end process;
	end;
	
	
				
				