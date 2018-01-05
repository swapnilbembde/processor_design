library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;

package alu_comp is

	component Add16 is------16 bit adder 
	port ( 
		A,B : in std_logic_vector(15 downto 0);
		carry:out std_logic;
		X   : out std_logic_vector(15 downto 0)
		);
	end component Add16;

component checkEquality is -------checking if equal block
	port ( 
		A,B : in std_logic_vector(15 downto 0);
		X   : out std_logic_vector(15 downto 0)
		);
end component checkEquality;

component Nand16 is ----- 16 bit nand performing block
	port ( 
		A,B : in std_logic_vector(15 downto 0);
		X   : out std_logic_vector(15 downto 0)
		);
end component Nand16;	

end alu_comp;
