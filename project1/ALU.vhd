library ieee;
use ieee.std_logic_1164.all;
library work;
use work.alu_comp.all;

entity alu is
port (inputa,inputb : in std_logic_vector(15 downto 0);----inputs
	carry : out std_logic;                        -----carry flag(coming from addition operation only)
	selector : in std_logic_vector(1 downto 0);  -----operation selector
	output : out std_logic_vector(15 downto 0)   ----output
	);
end entity;	

architecture d_alu of alu is
signal carry_an:std_logic;
Signal output_an,output_nd,output_ce : std_logic_vector(15 downto 0);

begin 

an : Add16 port map( A => inputa,B => inputb,X => output_an,carry => carry_an);
nd : Nand16 port map( A => inputa,B => inputb,X => output_nd);
ce : checkEquality port map( A => inputa,B => inputb,X => output_ce);

process(inputa,inputb,selector,output_an,output_nd,output_ce,carry_an)
begin

case selector is
	when "00" =>
		output <= output_an;-----addition operation
		carry <= carry_an;------carry flag modification
	when "01" =>
		output <= output_nd;------nand oeration
	when "10" =>
		output <= output_ce;-----compare_equality operation
	when "11" =>
		output <= inputb;-------bypass operation
	when others =>
		output <= "XXXXXXXXXXXXXXXX";  
end case;

end process;

end d_alu;












