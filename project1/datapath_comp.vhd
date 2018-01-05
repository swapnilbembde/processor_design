library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

package datapath_comp is
type FSM_states is
	(Fetch,Decode,Arth_Execute,Arth_MEM,Arth_WB,LS_Execute,LS_MEM,LS_WB,BEQ_Execute,BEQ_MEM,JAL_Execute,JLR_Execute,JLR_MEM,JLR_WB,LM_MEM,LM_MEM2,LM_MEM3,SM_MEM3,INC_PC,Inc_PC2);
---fsm states
	type ram_type is array (0 to 511) of std_logic_vector(15 downto 0);
--mem array
component FSM is
	port
	(
	-----ALU--------
	carry_in,zero_in,equal_in		: in std_logic;
	sel_ALU					: out std_logic_vector(1 downto 0);
	----------------
	--Pre-Post ALU--
	LD_Pre_ALU_B_reg,LD_Pre_ALU_A_reg	: out std_logic;
	LD_Post_ALU_reg				: out std_logic;
	sel_MUX_B,sel_MUX_A			: out std_logic;
	sel_MUX_pre_B				: out std_logic_vector(1 downto 0);
	LD_reg_all				: out std_logic;
	----------------
	----GPR---------
	sel_data_out_a,sel_data_out_b		: out std_logic_vector(2 downto 0);
	sel_data_write				: out std_logic_vector(2 downto 0);
	sel_MUX_R7				: out std_logic;
	----------------
	------IR--------
	LD_IR					: out std_logic;
	IR_data					: in std_logic_vector(15 downto 0);
	----------------
	-----MEM--------
	WE_bar					: out std_logic;
	sel_MUX_MAR,sel_MUX_MDR,sel_MUX_data    : out std_logic;
	----------------
	----LM_SM-------
	LD_Pre_Priority_reg,LD_index		: out std_logic;
	all_zero				: in std_logic;
	address_PE				: in std_logic_vector(2 downto 0);
	----------------
	------General---
	clk,Reset				: in std_logic;
	initialise				: out std_logic
	);
end component;

component alu is    ---ALU block
port (inputa,inputb : in std_logic_vector(15 downto 0);
	carry : out std_logic;
	selector : in std_logic_vector(1 downto 0); 
	output : out std_logic_vector(15 downto 0)
	);
end component;	

component IR is  -----Instruction Register Block
	port 
		(
		IR_in					: in std_logic_vector(15 downto 0);
		IR_out					: out std_logic_vector(15 downto 0);
		sext_6,sext_9_low,sext_9_high		: out std_logic_vector(15 downto 0);
		LD_IR,Reset,clk				: in std_logic
		);
end component IR;


component memory is  ----MEM block
port(address: in std_logic_vector(8 downto 0);
data_in: in std_logic_vector(15 downto 0);
data_out: out std_logic_vector(15 downto 0);
WE_b,clk: in std_logic;
initialise	: in std_logic
);
end component;

component register_16 is ----16 bit register block 
	port ( 
		data_in: in std_logic_vector(15 downto 0);
		data_out: out std_logic_vector(15 downto 0);
		LD_reg: in std_logic;
		Reset,clk: in std_logic
		);
end component register_16;

component RegisterFile is ----Register File containing 8 registers(R0-R7)
	port	
		(	
		data_out_R7,data_out_a,data_out_b			: out std_logic_vector(15 downto 0);
		data_in,data_ext_in_R7					: in std_logic_vector(15 downto 0);
		sel_data_out_a,sel_data_out_b,sel_data_write		: in std_logic_vector(2 downto 0);
		sel_data_R7						: in std_logic;
		LD_reg_all,Reset,Clk					: in std_logic;
		r0     							: out std_logic_vector(7 downto 0)
		);
end component RegisterFile;

component mux4to1 is--------4:1 Mux
port(three,two,one,zero:in std_logic_vector(15 downto 0);
     output:out std_logic_vector(15 downto 0); 
     sel:in std_logic_vector(1 downto 0));
end component;

component mux2to1 is------2:1 Mux
port(zero,one:in std_logic_vector(15 downto 0);
     output:out std_logic_vector(15 downto 0); 
     sel:in std_logic);
end component;

--component latch is
--port(latch_in:in std_logic_vector(15 downto 0);
 --    latch_out:out std_logic_vector(15 downto 0); 
 --    clk:in std_logic);
--end component;

component Priority_logic is-----Priority Encoder Block
	port
	(
		IR_input	: in std_logic_vector(7 downto 0);
		address_out: 	out std_logic_vector(2 downto 0);
		all_zero							: out std_logic;
		LD_Index,LD_Pre_priority	: in std_logic;
		clk,reset						: in std_logic
	);
end component;

component zero_hard is -----Zero flag Set Block
	port ( 
		data_in: in std_logic_vector(15 downto 0);
		zero_out	: out std_logic
		);
end component;

end package;
