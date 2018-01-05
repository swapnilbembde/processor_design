--HEAD REGISTER FILE---
-- CONTAINS 8 REGISTERS, 2 READ OUTPUTS AND 1 WRITE INPUT
-- OUTPUTS ARE MULTIPLEXED, WITH SELECT AS INPUT ADDress
-- INPUT IS DIRECTLY GIVEN TO ALL REGISTERS, WRITE ENABLE TO EACH REGISTER IS DECODED (3 TO 8) FROM WRITE ADDress
-- FOR pc EXTRA INPUT IS PRESENT, TO WRITE PC+1 MORE FAST, THUS A MULTIPLEXER IS USED FOR THE SAME, SEL_data_R7 IS THE SELECT

library ieee;
use ieee.std_logic_1164.all;

entity RegisterFile is
	port	
		(	
		data_out_R7,data_out_a,data_out_b,data_in_mem	: out std_logic_vector(15 downto 0);
		data_in,data_in_R7										: in std_logic_vector(15 downto 0);
		sel_data_out_a,sel_data_out_b,sel_data_write		: in std_logic_vector(2 downto 0);
		sel_data_in_mem											: in std_logic_vector(2 downto 0);
		--sel_data_R7													: in std_logic;
		LD_reg_all													: in std_logic;
		LD_PC															: in std_logic;
		Reset,Clk													: in std_logic;
		r0																: out std_logic_vector(7 downto 0)
		);
end entity RegisterFile;

architecture d_RegsiterFile of RegisterFile is
------------------------------------------------------------------------------------------------
----------------------------components declaration----------------------------------------------
------------------------------------------------------------------------------------------------
	component register_16 is 
		port 
			( 
			data_in: in std_logic_vector(15 downto 0);
			data_out: out std_logic_vector(15 downto 0);
			LD_reg: in std_logic;
			Reset,clk: in std_logic
			);
	end component register_16;
------------------------------------------------------------------------------------------------	
	component decode_3to8 is
		port
			(
			address : in std_logic_vector(2 downto 0);
			output: out std_logic_vector(7 downto 0)
			);
	end component decode_3to8;
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------	
signal data_of_R0,data_of_R1,data_of_R2,data_of_R3,data_of_R4,data_of_R5,data_of_R6,data_of_R7 : std_logic_vector(15 downto 0):="0000000000001111";
signal data_int_in_R7	: std_logic_vector(15 downto 0);
signal LD_reg_vector		: std_logic_vector(7 downto 0);
signal LD_to_reg			: std_logic_vector(7 downto 0);
begin
	decoder: decode_3to8 port map (sel_data_write,LD_reg_vector);
	data_int_in_R7 <= data_in_R7;
	
	LD_to_reg(0) <= LD_reg_vector(0) and LD_reg_all;	-----------
	LD_to_reg(1) <= LD_reg_vector(1) and LD_reg_all;	--	W	E	S-
	LD_to_reg(2) <= LD_reg_vector(2) and LD_reg_all;	--	R	N	I-
	LD_to_reg(3) <= LD_reg_vector(3) and LD_reg_all;	--	I	A	G-
	LD_to_reg(4) <= LD_reg_vector(4) and LD_reg_all;	--	T	B	N-
	LD_to_reg(5) <= LD_reg_vector(5) and LD_reg_all;	--	E	L	A-
	LD_to_reg(6) <= LD_reg_vector(6) and LD_reg_all;	-----	E	L-
	--LD_to_reg(7) <= LD_reg_vector(7) and LD_reg_all;	-----------
	LD_to_reg(7) <= LD_PC;
							
	R00: register_16 port map (data_in,data_of_R0,LD_to_reg(0),Reset,Clk); --REGISTERS
	R01: register_16 port map (data_in,data_of_R1,LD_to_reg(1),Reset,Clk);
	R02: register_16 port map (data_in,data_of_R2,LD_to_reg(2),Reset,Clk);
	R03: register_16 port map (data_in,data_of_R3,LD_to_reg(3),Reset,Clk);
	R04: register_16 port map (data_in,data_of_R4,LD_to_reg(4),Reset,Clk);
	R05: register_16 port map (data_in,data_of_R5,LD_to_reg(5),Reset,Clk);
	R06: register_16 port map (data_in,data_of_R6,LD_to_reg(6),Reset,Clk);
	R07: register_16 port map (data_int_in_R7,data_of_R7,LD_to_reg(7),Reset,Clk);
	
	
	
	--BELOW IS OUTPUT MULTIPLEXED
	out_mux: process(sel_data_out_a,sel_data_out_b,sel_data_in_mem,
						  data_of_R0,data_of_R1,data_of_R2,data_of_R3,data_of_R4,data_of_R5,data_of_R6,data_of_R7)
					variable temp_data_a,temp_data_b,temp_data_mem	: std_logic_vector(15 downto 0);
					begin
						case sel_data_out_a is 
							when "000" =>
								temp_data_a := data_of_R0;
							when "001" =>
								temp_data_a := data_of_R1;
							when "010" =>
								temp_data_a := data_of_R2;
							when "011" =>
								temp_data_a := data_of_R3;
							when "100" =>
								temp_data_a := data_of_R4;
							when "101" =>
								temp_data_a := data_of_R5;
							when "110" =>
								temp_data_a := data_of_R6;
							when "111" =>
								temp_data_a := data_of_R7;
							when others =>
								temp_data_a := temp_data_a;
						end case;
						
						case sel_data_out_b is 
							when "000" =>
								temp_data_b := data_of_R0;
							when "001" =>
								temp_data_b := data_of_R1;
							when "010" =>
								temp_data_b := data_of_R2;
							when "011" =>
								temp_data_b := data_of_R3;
							when "100" =>
								temp_data_b := data_of_R4;
							when "101" =>
								temp_data_b := data_of_R5;
							when "110" =>
								temp_data_b := data_of_R6;
							when "111" =>
								temp_data_b := data_of_R7;
							when others =>
								temp_data_b := temp_data_b;
						end case;
						
						case sel_data_in_mem is 
							when "000" =>
								temp_data_mem := data_of_R0;
							when "001" =>
								temp_data_mem := data_of_R1;
							when "010" =>
								temp_data_mem := data_of_R2;
							when "011" =>
								temp_data_mem := data_of_R3;
							when "100" =>
								temp_data_mem := data_of_R4;
							when "101" =>
								temp_data_mem := data_of_R5;
							when "110" =>
								temp_data_mem := data_of_R6;
							when "111" =>
								temp_data_mem := data_of_R7;
							when others =>
								temp_data_mem := temp_data_mem;
						end case;
					data_out_R7     <= data_of_R7;
					data_out_a	<= temp_data_a;
					data_out_b	<= temp_data_b;
					data_in_mem <= temp_data_mem;
				end process;
		r0 <= data_of_R2(7 downto 0);

				
end;
					
					
