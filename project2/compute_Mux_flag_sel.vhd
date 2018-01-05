library ieee;
use ieee.std_logic_1164.all;

entity compute_Mux_flag_Sel is
port(op_code : in std_logic_vector(3 downto 0);
	  flag_type : in std_logic_vector(1 downto 0);
	  carry_flag : in std_logic;
	  zero_flag : in std_logic;
	  Sel_flag : out std_logic
	  );
end entity;

architecture d_compute_Mux_flag_Sel of compute_Mux_flag_Sel is

begin

process(op_code,flag_type,carry_flag,zero_flag)
begin

 if(op_code = "0000" or op_code ="0010") then 
		
		if(flag_type = "10") then
			
			if(carry_flag ='1') then
				Sel_flag <= '0';
			else Sel_flag <='1';
			end if;
		
		elsif(flag_type = "01") then
			
			if(zero_flag = '1') then
				Sel_flag <= '0';
			else Sel_flag <= '1';
			end if;
		
		else Sel_flag <= '0';
		end if;
  else Sel_flag <= '0';
  end if;  
  end process;
				
end;	  