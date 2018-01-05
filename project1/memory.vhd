
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.datapath_comp.all;
entity memory is
port(address: in std_logic_vector(8 downto 0);----input address
data_in: in std_logic_vector(15 downto 0);----input data(in case of write operation)
data_out: out std_logic_vector(15 downto 0);----output data(in case of read operation)
WE_b,clk: in std_logic;-----Write_enable and clock inputs
initialise		: in std_logic---for initialising mem
);
end entity;

architecture simple_ram of memory is


signal ram1: ram_type:= (others => (others => '0'));
begin
process(clk,WE_b,address,data_in,ram1,initialise)
variable d_out:std_logic_vector(15 downto 0);
begin


if WE_b = '1' then -- asynchronous read
	d_out := ram1(TO_INTEGER(unsigned(address)));

elsif(rising_edge(clk) and WE_b='0') then--synchronous write
	d_out := "XXXXXXXXXXXXXXXX";
	if(initialise = '1') then
	

ram1(0) <= "0011000000000000";
ram1(1) <= "0011001000000001";
ram1(2) <= "0011010000000010";
ram1(3) <= "0011011000000011";
ram1(4) <= "0011100000000100";
ram1(5) <= "0000001010000000";
ram1(6) <= "0000010011001010";
ram1(7) <= "0000011100010001";
ram1(8) <= "0001001000000001";
ram1(9) <= "0010010011001000";
ram1(10) <= "0010011100010001";
ram1(11) <= "0011001000000000";
ram1(12) <= "0011100000000100";
ram1(13) <= "0100000001010101";
ram1(14) <= "0011000000000000";
ram1(15) <= "1100000001000010";
ram1(16) <= "0011110000001001";
ram1(17) <= "1100001010000010";
ram1(18) <= "0011001000000010";
ram1(19) <= "0011101000000000";
ram1(20) <= "0001101101011110";
ram1(21) <= "0111101011100000";
ram1(22) <= "0110101001110000";
--ram1(23) <= "0100010100000101";
--ram1(24) <= "0000010011010001";
--ram1(25) <= "1001001000000000";
ram1(23) <= "1111111111111111";




	else 
	ram1(TO_INTEGER(unsigned(address))) <= data_in;
	end if;
	end if;

data_out<= d_out;

end process;
end simple_ram;
