library ieee;
use ieee.std_logic_1164.all;

entity register_36 is 
	port ( 
		data_in: in std_logic_vector(36 downto 0);
		data_out: out std_logic_vector(36 downto 0);
		LD_reg: in std_logic;
		Reset,clk: in std_logic
		);
end entity register_36;

architecture d_register_36 of register_36 is 
	begin
		process(Reset,clk,data_in,LD_reg)
			variable data: std_logic_vector(36 downto 0);
			begin
				if(Reset = '1') then
						data := "0000000000000000000000000000000000000";
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