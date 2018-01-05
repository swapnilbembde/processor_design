library ieee;
use ieee.std_logic_1164.all;

entity checkEquality is 
	port ( 
		A,B : in std_logic_vector(15 downto 0);------inputs to be checked if equal or not
		X   : out std_logic_vector(15 downto 0)------output 1/0 reflecting equality
		);
end entity checkEquality;


architecture dcheckEquality of checkEquality is 
	begin
		process(A, B)
			variable tempC : std_logic_vector( 15 downto 0 );
            variable equal : std_logic;  ----flag generating output
            variable Xtemp : std_logic_vector(15 downto 0);
			begin	
			equal := '1';
				for i in 0 to 15 loop
				tempC(i):=A(i) xor B(i); ----bit wise XOR to check equality(if equal o/p=0,if not o/p=1)
				if(tempC(i) = '1') then-----(if previous one is not equal,final o/p=0,i.e. inputs are not equal)
					equal := '0';		
				end if;  
				end loop;
				
				if(equal = '1') then
					Xtemp := "0000000000000001";----final output
                else Xtemp := "0000000000000000";    
				end if;
					X <= Xtemp;
		end process;
	end;
