library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Add16 is 
	port ( 
		A,B : in std_logic_vector(15 downto 0);----inputs to be added
		carry:out std_logic;		       ----carry flag to be set
		X   : out std_logic_vector(15 downto 0)-----output after addition
		);
end entity Add16;

architecture dadd of Add16 is
signal inputa,inputb,output : signed(16 downto 0);
signal in_vector_a, in_vector_b,out_vector	: std_logic_vector(16 downto 0);
begin
		in_vector_a <= a(15) & a;----inputs with sign
		in_vector_b <= b(15) & b;
		inputa <= signed(in_vector_a);
		inputb <= signed(in_vector_b);
		output <= inputa + inputb;------signed addition
		out_vector <= std_logic_vector(output);
		X <= out_vector(16) & out_vector(14 downto 0);
		carry <= out_vector(15);-----carry to be set as flag
	end;
		
			
