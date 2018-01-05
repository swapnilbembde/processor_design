library ieee;
use ieee.std_logic_1164.all;

library work;
use work.datapath_comp.all;

entity datapath is 
port(clk,reset,my_clk: in std_logic);
end entity;


architecture d_datapath of datapath is

--fsm
signal carry_intp,zero_intp,LD_Pre_ALU_A_regtp,LD_Pre_ALU_B_regtp,LD_Post_ALU_regtp:std_logic;
signal sel_MUX_R7tp,sel_MUX_Atp,sel_MUX_Btp,LD_IRtp,WE_bartp,sel_MUX_MARtp,sel_MUX_MDRtp,sel_MUX_datatp:std_logic;
signal sel_ALUtp,sel_MUX_pre_Btp:std_logic_vector(1 downto 0);
signal sel_data_out_atp,sel_data_out_btp,sel_data_writetp: std_logic_vector(2 downto 0);
signal IR_datatp:std_logic_vector(15 downto 0);
---IR
signal sext_6tp,sext_9_hightp,sext_9_lowtp:std_logic_vector(15 downto 0);
---RegisterFile
signal data_out_atp,data_out_btp,data_out_R7tp,data_intp:std_logic_vector(15 downto 0);
--ALU
signal pre_ALU_A_regin,pre_ALU_A_regout,pre_ALU_B_regin,pre_ALU_B_regout,pre_B_MUX_dataouttp,alu_outputtp:std_logic_vector(15 downto 0);
signal post_ALU_regouttp:std_logic_vector(15 downto 0);
---latch
signal latch_intp:std_logic_vector(15 downto 0);
--memory--
signal mem_addresstp,dataout_memtp:std_logic_vector(15 downto 0);
--priorityenc----
signal LD_Pre_Prioritytp,LD_indextp,all_zerotp:std_logic;	
signal address_PEtp: std_logic_vector(2 downto 0);
signal LD_reg_all_tp : std_logic;
signal initialise_tp	: std_logic;
constant const_one:std_logic_vector(15 downto 0) :="0000000000000001";


signal a: std_logic_vector(7 downto 0);
begin

fsm_inst: FSM port map(  ----fsm block
	carry_intp,
	zero_intp,
	ALU_outputtp(0),				
	sel_ALUtp,									
	LD_Pre_ALU_B_regtp,
	LD_Pre_ALU_A_regtp,	
	LD_Post_ALU_regtp,							
	sel_MUX_Btp,
	sel_MUX_Atp,						
	sel_MUX_pre_Btp,
	LD_reg_all_tp,
	sel_data_out_atp,
	sel_data_out_btp,			
	sel_data_writetp,								
	sel_MUX_R7tp,								
	LD_IRtp,											
	IR_datatp,										
	WE_bartp,										
	sel_MUX_MARtp,
	sel_MUX_MDRtp,
	sel_MUX_datatp,
	LD_Pre_Prioritytp,
	LD_indextp,
	all_zerotp,
	address_PEtp,
	clk,
	Reset,
	initialise_tp
	);
	
 pre_ALU_B_inst:register_16 port map( pre_ALU_B_regin,  -----Pre_ALU_B
					pre_ALU_B_regout,
					LD_Pre_ALU_B_regtp,
					reset,
					clk
					);
		
pre_ALU_A_inst:register_16 port map( pre_ALU_A_regin,   -----Pre_ALU_A
					pre_ALU_A_regout,
					LD_Pre_ALU_A_regtp,
					reset,
					clk
					);

ALU_inst: ALU port map(pre_ALU_A_regout,-----ALU
			pre_ALU_B_regout,
			carry_intp,
			sel_ALUtp,
			ALU_outputtp);
								

post_ALU_inst:register_16 port map( ALU_outputtp,----Post_ALU_reg
					post_ALU_regouttp,
					LD_Post_ALU_regtp,
					 reset,
					clk
		);

RegisterFile_inst: RegisterFile port map(data_out_R7tp,---Register FIle
					data_out_atp,
					data_out_btp,
					data_intp,
					ALU_outputtp,
					sel_data_out_atp,
					sel_data_out_btp,
					sel_data_writetp,
					sel_MUX_R7tp,
					LD_reg_all_tp,
					reset,
					clk,
					a		
					);	
		
mux2to1_A_inst:mux2to1 port map(const_one,--2:1 MUX for input A
				 data_out_atp,
				 pre_ALU_A_regin,
				sel_MUX_Atp
		);	

mux2to1_B_inst:mux2to1 port map(pre_B_MUX_dataouttp,------2:1 MUX for input B
				data_out_btp,
				pre_ALU_B_regin,
				sel_MUX_Btp
		);	

mux4to1_inst:mux4to1 port map(sext_9_hightp,-----4:1 MUX for Pre_B
				sext_9_lowtp,
										sext_6tp,
										post_ALU_regouttp,
										pre_B_MUX_dataouttp,
										sel_MUX_pre_Btp);



IR_inst: IR port map(dataout_memtp,------Instruction Register
		IR_datatp,
		sext_6tp,
		sext_9_lowtp,
		sext_9_hightp,
		LD_IRtp,
		reset,
		clk
		);		
		
mux_mdr_inst: mux2to1 port map(post_ALU_regouttp, -----2:1 MUX for data from post_alu or from mem 
										 dataout_memtp,
										 latch_intp,
										 sel_MUX_MDRtp
										);		
										
latch_postmdr_inst: register_16 port map(latch_intp,
														data_intp,
														'1',
														reset,
														clk
											);		
--mux_data_inst:mux2to1 port map (post_ALU_regouttp,
	--										data_out_atp,
	--										datain_memtp,
	--										sel_MUX_datatp);											
-----------------------------------------------------------------------------		
mux_mar_inst: mux2to1 port map(post_ALU_regouttp,
										 data_out_R7tp,
										 mem_addresstp,
										 sel_MUX_MARtp
										);

memory_inst: memory port map (mem_addresstp(8 downto 0),
										data_out_atp,
										dataout_memtp,
										WE_bartp,
										clk,
										initialise_tp
										);
 
priority_logic_inst: Priority_logic port map(IR_datatp(7 downto 0),----priority encoder block 
															address_PEtp,
															all_zerotp,
															LD_indextp,
															LD_Pre_Prioritytp,
															clk,
															reset
															);
															
zero_hard_inst: zero_hard port map (data_intp,-----zero flag set block
												zero_intp
												);	
															
																												

end;		
		
		
