
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.datapath_comp.all;
entity instr_memory is
port(address: in std_logic_vector(8 downto 0);----input address
--data_in: in std_logic_vector(15 downto 0);----input data(in case of write operation)
data_out: out std_logic_vector(15 downto 0);----output data(in case of read operation)
WE_b,clk: in std_logic;-----Write_enable and clock inputs
reset		: in std_logic---for initialising mem
);
end entity;

architecture simple_ram of instr_memory is


signal ram_instr: ram_type:= (others => (others => '0'));
begin
process(clk,WE_b,address,ram_instr,reset)
variable d_out:std_logic_vector(15 downto 0):="XXXXXXXXXXXXXXXX";
begin
if(rising_edge(clk)) then
	if(reset = '1') then
	


ram_instr(0) <= "0011000000000001";
ram_instr(1) <= "0110001000011111";
ram_instr(2) <= "0001001000011111";
ram_instr(3) <= "0001010000000100";
ram_instr(4) <= "0001011000000001";
ram_instr(5) <= "0000000001100000";
ram_instr(6) <= "0000000011000001";
ram_instr(7) <= "0010101010000000";
ram_instr(8) <= "0010110110000000";
ram_instr(9) <= "0000011000000001";
ram_instr(10) <= "1001001001000000";
ram_instr(11) <= "0000011100110001";
ram_instr(12) <= "0101011101010100";
ram_instr(13) <= "0000001000110000";
ram_instr(14) <= "1001011010000000";
ram_instr(15) <= "1100001010000010";
ram_instr(16) <= "0010100110011000";
--ram_instr(17) <= "1000011000000010";
--ram_instr(18) <= "0010100110011000";
--ram_instr(19) <= "1001011011000000";
--ram_instr(0) <= "0011001000000001";
--ram_instr(1) <= "0011010000000010";
--ram_instr(2) <= "0011000000000100";

--ram_instr(1) <= "0110000011111110";
--ram_instr(3) <= "0111100000011110";
--ram_instr(4) <= "0000000010011000";

---ram_instr(19) <= "0011101000000000";
--ram_instr(20) <= "0001101101011110";
--ram_instr(21) <= "0111101011100000";
--ram_instr(22) <= "0110101001110000";
--ram_instr(23) <= "0100010100000101";
--ram_instr(24) <= "0000010011010001";
--ram_instr(25) <= "1001001000000000";
--ram_instr(23) <= "1111111111111111";
	end if;
end if;	

if WE_b = '1' then -- asynchronous read
	d_out := ram_instr(TO_INTEGER(unsigned(address)));
else
			d_out :="0000000000000000";
	end if;

data_out<= d_out;
end process;
end simple_ram;
