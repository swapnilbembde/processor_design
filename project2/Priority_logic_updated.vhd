--HEAD LOGIC ELEMENT FOR THE LM AND SM INSTRUCTIONS
--GIVES THE APPROPRIATE ADDRESS OF REGISTER WHICH IS TO BE WRITTEN
--
--				HOW THIS WORKS
--WE HAVE 8 1-BIT REGISTER WHICH STORE ADDRESS TO BE DECODED BY PRIorityEncoder, WE RESET EACH REGISTER INDIVIDUALLY AFTER READING THE ADDRESS
--OUTPUT OF PRIOrityEncoder IS ALSO FED TO A DECODER 3TO8 WHICH STORES THE RESET VALUE ADDRESS CORRESPONDING TO EARLIER REGISTER INDEX 
--THIS 8 BIT REGISTER IS FED TO RESET OF UPPER 8*1BIT REGISTERS
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Priority_logic is												-- ENTITY DEFINITION
	port
	(																			
		IR_input: in std_logic_vector(7 downto 0);				-- INPUT OF 8 INSTRUCTION BITS SHOWING ADDRESS
		
		address_out: out std_logic_vector(2 downto 0);		-- REGISTER ADDRSS TO WHICH DATA IS TO BE WRITTEN
		all_zero : out std_logic;				-- ALL ZERO INDICATING NO ADDRESS IS TO WRITTEN
			-- LD_Pre_priority WRITE ENABLE TO WRITE TO REGISTER WHICH STORES ADDRESS FROM INSTRUCTION REGISTER
		start_PE :in std_logic;
		clk,reset						: in std_logic
	);
end entity Priority_logic;

architecture d_priority of Priority_logic is

-------------------------------------------------------
	component Index_decode is											-- DECODE THE INDEX , I/P FROM PRIorityEncoder O/P TO REGister_8 STORING RESET VALUES
		port
		(
			index_input	: in std_logic_vector(2 downto 0);
			all_zero_input	: in std_logic;
			reset_out	: out std_logic_vector(7 downto 0)
		);
	end component Index_decode;

	component register_1 is 											-- 8 SUCH REGISTERS ARE IMPLEMENTED TO STORE ADDRESS WHICH FURTHER GOES TO PRIorityEncoder
		port ( 
			data_in: in std_logic;
			data_out: out std_logic;
			LD_reg: in std_logic;
			Reset,clk: in std_logic
			);
	end component register_1;
	
	 component PriorityEncoder is
		port (x7 ,x6 ,x5 ,x4 ,x3 ,x2 ,x1 ,x0:in std_logic;
		 s2 ,s1 ,s0 ,N:out std_logic);
		end component PriorityEncoder ;
		
	component register_8 is 											-- 8 BIT REGISTER TO STORE RESET VALUES
	port ( 
		data_in: in std_logic_vector(7 downto 0);
		data_out: out std_logic_vector(7 downto 0);
		LD_reg: in std_logic;
		Reset,clk: in std_logic
		);
end component register_8;

	component checkEquality is 
	port ( 
		A,B : in std_logic_vector(15 downto 0);------inputs to be checked if equal or not
		X   : out std_logic_vector(15 downto 0)------output 1/0 reflecting equality
		);
end component checkEquality;

	
--------------------------------------------------------
signal Pre_Priority_reg_out,reset_pre_priority_reg,index_reg_in,IR_pre	: std_logic_vector(7 downto 0);
signal input_from_PE,IR_index	: std_logic_vector(2 downto 0);
signal temp_all_zero,LD_Index,LD_Pre_priority	: std_logic;
signal reset_reg_reset	: std_logic;
signal IR_input_extended :std_logic_vector(15 downto 0);
signal Pre_Priority_reg_out_extended :std_logic_vector(15 downto 0);
signal start_indicator :std_logic_vector(15 downto 0);
begin
    

	IR_input_extended <="00000000"& IR_input;
	IR_pre <= IR_input when start_PE ='1' else "00000000";														
		LD_Pre_priority <= (start_PE xnor start_indicator(0));
	Pre_Priority_reg0:	register_1 port map (IR_pre(0),Pre_Priority_reg_out(0),LD_Pre_priority,reset_pre_priority_reg(0),clk);
	Pre_Priority_reg1:	register_1 port map (IR_pre(1),Pre_Priority_reg_out(1),LD_Pre_priority,reset_pre_priority_reg(1),clk);
	Pre_Priority_reg2:	register_1 port map (IR_pre(2),Pre_Priority_reg_out(2),LD_Pre_priority,reset_pre_priority_reg(2),clk);
	Pre_Priority_reg3:	register_1 port map (IR_pre(3),Pre_Priority_reg_out(3),LD_Pre_priority,reset_pre_priority_reg(3),clk);
	Pre_Priority_reg4:	register_1 port map (IR_pre(4),Pre_Priority_reg_out(4),LD_Pre_priority,reset_pre_priority_reg(4),clk);
	Pre_Priority_reg5:	register_1 port map (IR_pre(5),Pre_Priority_reg_out(5),LD_Pre_priority,reset_pre_priority_reg(5),clk);
	Pre_Priority_reg6:	register_1 port map (IR_pre(6),Pre_Priority_reg_out(6),LD_Pre_priority,reset_pre_priority_reg(6),clk);
	Pre_Priority_reg7:	register_1 port map (IR_pre(7),Pre_Priority_reg_out(7),LD_Pre_priority,reset_pre_priority_reg(7),clk);
	
	Pre_Priority_reg_out_extended <="00000000"& Pre_Priority_reg_out;
	check_equality: checkEquality port map ( Pre_Priority_reg_out_extended, IR_input_extended ,start_indicator);

	priority_encoder: PriorityEncoder port map (Pre_Priority_reg_out(7),Pre_Priority_reg_out(6),Pre_Priority_reg_out(5),Pre_Priority_reg_out(4),
																Pre_Priority_reg_out(3),Pre_Priority_reg_out(2),Pre_Priority_reg_out(1),Pre_Priority_reg_out(0),
																input_from_PE(2),input_from_PE(1),input_from_PE(0),temp_all_zero);
					
	LD_Index <= not temp_all_zero;															
	index : register_8 port map (index_reg_in,reset_pre_priority_reg,LD_Index,Reset_reg_reset,Clk);
	reset_reg_reset <= reset or temp_all_zero;
        	
	
	
	decoder	: index_decode port map (input_from_PE,temp_all_zero,index_reg_in);
	address_out <= input_from_PE;
	all_zero <= temp_all_zero;
	

		
end;
