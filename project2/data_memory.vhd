
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.datapath_comp.all;
entity data_memory is
port(address: in std_logic_vector(8 downto 0);----input address
data_in: in std_logic_vector(15 downto 0);----input data(in case of write operation)
data_out: out std_logic_vector(15 downto 0);----output data(in case of read operation)
WE_b,clk,reset: in std_logic-----Write_enable and clock inputs
);
end entity;

architecture simple_ram of data_memory is

signal ram_data: ram_type:= (others => (others => '0'));

begin
process(clk,WE_b,address,data_in,ram_data,reset)
variable d_out:std_logic_vector(15 downto 0);
begin


if (WE_b = '1') then -- asynchronous read
	d_out := ram_data(TO_INTEGER(unsigned(address)));
		
elsif(rising_edge(clk) and WE_b='0') then--synchronous write
	d_out := "XXXXXXXXXXXXXXXX";
	ram_data(TO_INTEGER(unsigned(address))) <= data_in;

end if;

if(rising_edge(clk)) then
		if (reset = '1') then 
			ram_data(0) <= "0000000000000001";
			ram_data(1) <= "0000000000000101";
			ram_data(2) <= "0000000000001101";
			ram_data(3) <= "0000000000011101";
			ram_data(4) <= "0000000011111101";
			ram_data(5) <= "0000011111111101";
			ram_data(20) <= "0100001100010100";
			ram_data(21) <= "0100010100010101";
			

		end if;
	end if;

data_out<= d_out;

end process;
end simple_ram;
