library ieee;
use ieee.std_logic_1164.all;

entity IR is 
	port 
		(
		IR_in					: in std_logic_vector(15 downto 0);-----Instruction input
		IR_out					: out std_logic_vector(15 downto 0);--IR output
		sext_6,sext_9_low,sext_9_high		: out std_logic_vector(15 downto 0);----sign extender output
		LD_IR,Reset,clk						: in std_logic-----Instruction read_enable and clock
		);
end entity IR;

architecture d_IR of IR is
	
	component register_16 is 
		port ( 
			data_in: in std_logic_vector(15 downto 0);
			data_out: out std_logic_vector(15 downto 0);
			LD_reg: in std_logic;
			Reset,clk: in std_logic
			);
	end component register_16;
	
	signal temp_IR_out	: std_logic_vector(15 downto 0) := (others => '0');
	begin
	
		IR: register_16 port map  (IR_in,temp_IR_out,LD_IR,Reset,Clk);
		
		process(temp_IR_out)
			begin
			
				for i in 6 to 15 loop----6 bit immediate data to be extended(retained as LSB)	
					sext_6(i) <= temp_IR_out(5);
				end loop;
				for i in 0 to 5 loop
					sext_6(i) <= temp_IR_out(i);
				end loop;
				
				for i in 9 to 15 loop----9 bit immediate data to be extended(retained as LSB)	
					sext_9_low(i) <= temp_IR_out(8);
				end loop;
				for i in 0 to 8 loop
					sext_9_low(i) <= temp_IR_out(i);
				end loop;
		
				sext_9_high <= temp_IR_out(8 downto 0) & "0000000";---9 bit immediate data to be extended(retained as MSB)	
				IR_out <= temp_IR_out;
					
		end process;
end;
		
