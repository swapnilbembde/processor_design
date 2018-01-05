library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

package datapath_comp is

	type ram_type is array (0 to 511) of std_logic_vector(15 downto 0);
--mem array

component decoder is 
port 
		(
			IR_data : in std_logic_vector(15 downto 0); ----instruction current
			check_carry,check_zero	: in std_logic; --- zero and carry flags value
			check_comparator			: in std_logic;
			hazard_a,hazard_b : in std_logic_vector(1 downto 0);	-- as shantanu mentioned input from hazard detector
			all_zero_PE		: in std_logic;	-- all zero from Priority logic mentioning the task is completed
			data_mem_forward	: in std_logic;	-- specific hazard signal for data mux in mem( used in SW and SM)
			address_PE		: in std_logic_vector(2 downto 0);	--- address from Priority Logic
			Reset,clk	: in std_logic;	--
			control_vector	: out std_logic_vector(36 downto 0);
            stall,stall1,stall2,stall3,kept_it_a,kept_it_b : in std_logic;
			s0_en : out std_logic;
            s0 : out std_logic_vector(1 downto 0) 	
		);
end component;

component Hazard_Detector is
	port 
		(IR :in std_logic_vector(15 downto 0);
		 IR_OLD1 :in std_logic_vector(15 downto 0);
		 IR_OLD2 :in std_logic_vector(15 downto 0);
		 IR_OLD3 :in std_logic_vector(15 downto 0);
		 hazard_a,hazard_b : out std_logic_vector(1 downto 0);
		 data_mem_forward: out std_logic;
		 next_reg_PE_output :in std_logic_vector(2 downto 0);
		 all_zero_PE : in std_logic;
		 start_PE : in std_logic;
		 stall,stall1,stall2,stall3: out std_logic;
		 clk,reset: in std_logic;
		 kept_it_a,kept_it_b: out std_logic
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


component data_memory is  ----MEM block
port(address: in std_logic_vector(8 downto 0);----input address
data_in: in std_logic_vector(15 downto 0);----input data(in case of write operation)
data_out: out std_logic_vector(15 downto 0);----output data(in case of read operation)
WE_b,clk,reset: in std_logic-----Write_enable and clock inputs
);
end component;

component instr_memory is
port(address: in std_logic_vector(8 downto 0);----input address
--data_in: in std_logic_vector(15 downto 0);----input data(in case of write operation)
data_out: out std_logic_vector(15 downto 0);----output data(in case of read operation)
WE_b,clk: in std_logic;-----Write_enable and clock inputs
reset		: in std_logic---for initialising mem
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

component RegisterFile is
	port	
		(	
		data_out_R7,data_out_a,data_out_b,data_in_mem	: out std_logic_vector(15 downto 0);
		data_in,data_in_R7									: in std_logic_vector(15 downto 0);
		sel_data_out_a,sel_data_out_b,sel_data_write		: in std_logic_vector(2 downto 0);
		sel_data_in_mem											: in std_logic_vector(2 downto 0);
		--sel_data_R7													: in std_logic;
		LD_reg_all													: in std_logic;
		LD_PC															: in std_logic;
		Reset,Clk													: in std_logic;
		r0																: out std_logic_vector(7 downto 0)
		);
end component;

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

component register_2 is 
	port ( 
		data_in: in std_logic_vector(1 downto 0);
		data_out: out std_logic_vector(1 downto 0);
		LD_reg: in std_logic;
		Reset,clk: in std_logic
		);
end component;

component updateblock is
	port 
		(s1,s2,s3 : in std_logic_vector(1 downto 0);
       stall1,stall2,stall3 :in std_logic;
       stall_1,stall_2,stall_3: out std_logic;
		 hazarda,hazardb: in std_logic_vector(1 downto 0);
		 hazard_a,hazard_b: out std_logic_vector(1 downto 0);
		 data_mem_forward_out: out std_logic;
		 data_mem_forward_in: in std_logic
		);
end component;

--component latch is
--port(latch_in:in std_logic_vector(15 downto 0);
 --    latch_out:out std_logic_vector(15 downto 0); 
 --    clk:in std_logic);
--end component;

component Priority_logic is												-- ENTITY DEFINITION
	port
	(																			
		IR_input: in std_logic_vector(7 downto 0);				-- INPUT OF 8 INSTRUCTION BITS SHOWING ADDRESS
		
		address_out: out std_logic_vector(2 downto 0);		-- REGISTER ADDRSS TO WHICH DATA IS TO BE WRITTEN
		all_zero : out std_logic;				-- ALL ZERO INDICATING NO ADDRESS IS TO WRITTEN
		start_PE :in std_logic;
		clk,reset						: in std_logic
	);
end component;

component register_1 is 
	port ( 
		data_in: in std_logic;
		data_out: out std_logic;
		LD_reg: in std_logic;
		Reset,clk: in std_logic
		);
end component;

component compute_Mux_flag_Sel is
port(op_code : in std_logic_vector(3 downto 0);
	  flag_type : in std_logic_vector(1 downto 0);
	  carry_flag : in std_logic;
	  zero_flag : in std_logic;
	  Sel_flag : out std_logic
	  );
end component;

component mux2to1_36 is
port(zero,one:in std_logic_vector(36 downto 0);
     output:out std_logic_vector(36 downto 0); 
     sel:in std_logic);
end component;

component register_36 is 
	port ( 
		data_in: in std_logic_vector(36 downto 0);
		data_out: out std_logic_vector(36 downto 0);
		LD_reg: in std_logic;
		Reset,clk: in std_logic
		);
end component;

component zero_hard is -----Zero flag Set Block
	port ( 
		data_in: in std_logic_vector(15 downto 0);
		zero_out	: out std_logic
		);
end component;

component Add16 is 
	port ( 
		A,B : in std_logic_vector(15 downto 0);----inputs to be added
		carry:out std_logic;		       ----carry flag to be set
		X   : out std_logic_vector(15 downto 0)-----output after addition
		);
end component;
component starter_PE is 
	port ( 
		IR_in: in std_logic_vector(15 downto 0);
		start_PE: out std_logic
		);
end component;


end package;
