library ieee;
use ieee.std_logic_1164.all;

entity Nand16 is 
	port ( 
		A,B : in std_logic_vector(15 downto 0);----inputs
		X   : out std_logic_vector(15 downto 0)----output of nand operation
		);
end entity Nand16;

architecture dNand16 of Nand16 is 
	begin
		X(0) <= A(0) nand B(0);---bitwise nand operation
		X(1) <= A(1) nand B(1);
		X(2) <= A(2) nand B(2);
		X(3) <= A(3) nand B(3);
		X(4) <= A(4) nand B(4);
		X(5) <= A(5) nand B(5);
		X(6) <= A(6) nand B(6);
		X(7) <= A(7) nand B(7);
		X(8) <= A(8) nand B(8);
		X(9) <= A(9) nand B(9);
		X(10) <= A(10) nand B(10);
		X(11) <= A(11) nand B(11);
		X(12) <= A(12) nand B(12);
		X(13) <= A(13) nand B(13);
		X(14) <= A(14) nand B(14);
		X(15) <= A(15) nand B(15);

	end;
