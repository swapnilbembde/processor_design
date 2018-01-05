library ieee;
use ieee.std_logic_1164.all;

library work;
use work.datapath_comp.all;

entity datapath is 
port(clk,reset: in std_logic);
end entity;


architecture d_datapath of datapath is

--pc
signal carry_tp1,carry_tp2 : std_logic;
signal updatedPC_tp,PC_0_out_tp,jumped_PC_out,nextPC_tp,pcimmediate_d : std_logic_vector(15 downto 0);

signal carry_intp,zero_intp,carry_data,zero_data:std_logic;
signal sel_MUX_R7tp,WE_bartp:std_logic;
signal hazard_atp,hazard_btp,hazard_an,hazard_bn : std_logic_vector(1 downto 0);
signal data_mem_forward_tp,data_mem_forward_n : std_logic;

signal stall_tp,stall1_tp,stall2_tp,stall3_tp,start_PE_tp,Sel_flag_tp,stall1_n,stall2_n,stall3_n : std_logic;

---IR
signal sext_6tp,sext_9_hightp,sext_9_lowtp,sext_6_out_tp,sext_9high_out_tp,sext_9low_out_tp:std_logic_vector(15 downto 0);
signal IR_datatp,IR_old_data1_tp,IR_old_data2_tp,IR_old_data3_tp:std_logic_vector(15 downto 0);
---RegisterFile
signal data_out_atp,data_out_btp,data_in_mem_tp,data_intp,data_out_R7tp,mux_ma_in,mux_mb_in,data_out_mux_preA_tp:std_logic_vector(15 downto 0);
--ALU
signal pre_ALU_A_regin,pre_ALU_A_regout,pre_ALU_B_regin,pre_ALU_B_regout,pre_B_MUX_dataouttp,alu_outputtp:std_logic_vector(15 downto 0);
signal post_ALU_regouttp,mux_ALU_A_out,mux_ALU_B_out:std_logic_vector(15 downto 0);

--memory--
signal data_out_instr_mem,data_out_mem_tp:std_logic_vector(15 downto 0);
signal Mux_mem_out_tp,mem_reg_in_tp,mem_reg_out_tp : std_logic_vector(15 downto 0);
--priorityenc----
signal LD_Pre_Prioritytp,LD_indextp,all_zerotp:std_logic;	
signal address_PEtp: std_logic_vector(2 downto 0);

constant const_one:std_logic_vector(15 downto 0) :="0000000000000001";
signal a: std_logic_vector(7 downto 0);

signal control_vector_re_tp,control_vector_dr_tp,control_vector_em_tp : std_logic_vector(36 downto 0);
signal control_vector_mw_tp,control_vector_tp : std_logic_vector(36 downto 0);

signal s0_in,s0_out,s1_out,s2_out,s3_out : std_logic_vector(1 downto 0);
signal s0_en_tp,kept_it_atp,kept_it_btp : std_logic;

begin


--Fetch

RegisterFile_inst: RegisterFile port map(data_out_R7tp,--Register FIle
													  data_out_atp,
													  data_out_btp,
													  data_in_mem_tp,
													  mem_reg_out_tp,
													  updatedPC_tp,
													  control_vector_dr_tp(30 downto 28),
													  control_vector_dr_tp(27 downto 25),
													  control_vector_mw_tp(4 downto 2),
													  control_vector_em_tp(8 downto 6),
													  control_vector_mw_tp(5),
													  control_vector_tp(33),
													  reset,
													  clk,
													  a		
													  );
					
PC_0_inst :	register_16 port map(data_out_R7tp,
											PC_0_out_tp,
											control_vector_tp(33),
											reset,
											clk
											);				

Add16_pc_inst1 : Add16 port map (data_out_R7tp,
										  const_one,
										  carry_tp1,
										  nextPC_tp
										  );

Mux_PC_inst : mux2to1 port map (nextPC_tp,
									jumped_PC_out,
									pcimmediate_d,
									control_vector_tp(32)
									);

Add16_pc_inst2 : Add16 port map (PC_0_out_tp,
										   sext_6_out_tp,
											carry_tp2,
											jumped_PC_out
											);

mux_alupc_inst : mux2to1 port map(pcimmediate_d,
											 alu_outputtp,
											 updatedPC_tp,
											 control_vector_tp(36)
											); 

instr_memory_inst : instr_memory port map (data_out_R7tp(8 downto 0),
														 data_out_instr_mem,
														 '1',
														 clk,
														 reset
														 );									

--Decode



Decoder_inst : decoder port map (IR_datatp,
										   carry_data,
											zero_data,
											Alu_outputtp(0),
											hazard_an,
											hazard_bn,
											all_zerotp,
											data_mem_forward_n,
											address_PEtp,
											reset,
											clk,
											control_vector_tp,
											stall_tp,
											stall1_n,
											stall2_n,
											stall3_n,
											kept_it_atp,
											kept_it_btp,
											s0_en_tp,
											s0_in
											);

											
Hazard_Detector_inst : Hazard_Detector port map (IR_datatp,
															  IR_old_data1_tp,
															  IR_old_data2_tp,
															  IR_old_data3_tp,
															  hazard_atp,
															  hazard_btp,
															  data_mem_forward_tp,
															  address_PEtp,
															  all_zerotp,
															  start_PE_tp,
															  stall_tp,
															  stall1_tp,
															  stall2_tp,
															  stall3_tp,
															  clk,
															  reset,
															  kept_it_atp,
															  kept_it_btp
															  );											

IR_inst: IR port map(data_out_instr_mem,------Instruction Register
							IR_datatp,
							sext_6tp,
							sext_9_lowtp,
							sext_9_hightp,
							control_vector_tp(31),
							reset,
							clk
							);
							
IR_old1_inst : register_16 port map(IR_datatp,
											   IR_old_data1_tp,
												control_vector_tp(31),
												reset,
												clk
												);

IR_old2_inst : register_16 port map(IR_old_data1_tp,
											   IR_old_data2_tp,
												control_vector_tp(31),
												reset,
												clk
												);
												
IR_old3_inst : register_16 port map(IR_old_data2_tp,
											   IR_old_data3_tp,
												control_vector_tp(31),
												reset,
												clk
												);

sext_6_reg_inst : register_16 port map (sext_6tp,
													 sext_6_out_tp,
													 '1',
													 reset,
													 clk
													 );
													 
sext_9low_reg_inst : register_16 port map (sext_9_lowtp,
														 sext_9low_out_tp,
														 '1',
														 reset,
													    clk
													    );
													 
sext_9high_reg_inst : register_16 port map (sext_9_hightp,
														  sext_9high_out_tp,
														  '1',
														  reset,
														  clk
														  );

control_dr_reg_inst : register_36 port map (control_vector_tp,
														  control_vector_dr_tp,
														  '1',
														  reset,
														  clk);

priority_logic_inst: Priority_logic port map(IR_datatp(7 downto 0),----priority encoder block 
															address_PEtp,
															all_zerotp,
															start_PE_tp,
															clk,
															reset
															);
				
update_block_inst : updateblock port map(s1_out,
													   s2_out,
														s3_out,
														stall1_tp,
														stall2_tp,
														stall3_tp,
														stall1_n,
														stall2_n,
														stall3_n,
														hazard_atp,
														hazard_btp,
														hazard_an,
														hazard_bn,
														data_mem_forward_n,
														data_mem_forward_tp
														); 				

															
s0_reg : register_2 port map (s0_in,
									   s0_out,
										s0_en_tp,
										reset,
										clk
									   );
										
s1_reg : register_2 port map (s0_out,
										s1_out,
										control_vector_tp(31),
										reset,
										clk
										);

s2_reg : register_2 port map (s1_out,
										s2_out,
										control_vector_tp(31),
										reset,
										clk
										);											

s3_reg : register_2 port map (s2_out,
										s3_out,
										control_vector_tp(31),
										reset,
										clk
										);	
										
--Register Read

mux4to1_PA_inst:mux4to1 port map(data_out_R7tp,-----4:1 MUX for Pre_A
											sext_9high_out_tp,
											sext_9low_out_tp,
											sext_6_out_tp,
											data_out_mux_preA_tp,
											control_vector_dr_tp(23 downto 22));

mux2to1_A_inst:mux2to1 port map(data_out_atp,--2:1 MUX for input A
										  data_out_mux_preA_tp,
										  mux_ma_in,
										  control_vector_dr_tp(24)
										  );	

mux2to1_B_inst:mux2to1 port map(data_out_btp,------2:1 MUX for input B
										  PC_0_out_tp,
										  mux_mb_in,
										  control_vector_dr_tp(21)
										  );
										  
mux_ma_inst : mux2to1 port map(mux_ma_in,
										 mem_reg_out_tp,	
										 pre_ALU_A_regin,
										 control_vector_dr_tp(35)
										 );

mux_mb_inst : mux2to1 port map(mux_mb_in,
										 mem_reg_out_tp,	
										 pre_ALU_B_regin,
										 control_vector_dr_tp(34)
										 );										 
													 
		
pre_ALU_A_inst:register_16 port map( pre_ALU_A_regin,   -----Pre_ALU_A
												 pre_ALU_A_regout,
											    control_vector_dr_tp(20),
												 reset,
												 clk
												);
												
pre_ALU_B_inst:register_16 port map( pre_ALU_B_regin,   -----Pre_ALU_A
												 pre_ALU_B_regout,
											    control_vector_dr_tp(20),
												 reset,
												 clk
												);


									 
control_re_reg_inst : register_36 port map (control_vector_dr_tp,
														  control_vector_re_tp,
														  '1',
														  reset,
														  clk
														  );												

--Execute

mux_ALU_A_inst : mux4to1 port map (const_one,
											  mem_reg_out_tp,
											  post_ALU_regouttp,
											  pre_ALU_A_regout,
											  mux_ALU_A_out,
											  control_vector_re_tp(19 downto 18)
											  );
											  
mux_ALU_B_inst : mux4to1 port map (post_ALU_regouttp,
											  mem_reg_out_tp,
											  post_ALU_regouttp,
											  pre_ALU_B_regout,
											  mux_ALU_B_out,
											  control_vector_re_tp(17 downto 16)
											  );											  
											
ALU_inst: ALU port map(mux_ALU_A_out,-----ALU
							  mux_ALU_B_out,
							  carry_intp,
							  control_vector_re_tp(15 downto 14),
							  ALU_outputtp
							  );
								

post_ALU_inst:register_16 port map(ALU_outputtp,----Post_ALU_reg
											  post_ALU_regouttp,
											  control_vector_re_tp(13),
											  reset,
											  clk
											  );

Carry_flag: register_1 port map (carry_intp,carry_data,control_vector_re_tp(1), Reset, Clk);											  
											  
control_em_reg_inst : register_36 port map (control_vector_re_tp,
														  control_vector_em_tp,
														  '1',
														  reset,
														  clk
														  );
											  
--Memory Access

Mux_Mem_inst : mux2to1 port map(data_in_mem_tp,
										  mem_reg_out_tp,
										  mux_mem_out_tp,
										  control_vector_em_tp(9)
										  );
WE_bartp <= not control_vector_em_tp(12);										  

data_memory_inst : data_memory port map (post_ALU_regouttp(8 downto 0),
													  mux_mem_out_tp,
													  data_out_mem_tp,
													  WE_bartp,
													  clk,
													  reset
													  );


Mux_data_output_inst : mux2to1 port map (post_ALU_regouttp,
													 data_out_mem_tp,
													 mem_reg_in_tp,
													 control_vector_em_tp(11)
													 );													  

Mem_Reg_inst : register_16 port map (mem_reg_in_tp,
												 mem_reg_out_tp,
												 control_vector_em_tp(10),
												 reset,
												 clk
												 );

control_mw_reg_inst : register_36 port map (control_vector_em_tp,
														  control_vector_mw_tp,
														  '1',
														  reset,
														  clk
														  );

zero_hard_inst: zero_hard port map (mem_reg_in_tp,-----zero flag set block
												zero_intp
												);												  

zero_flag: register_1 port map (zero_intp,zero_data,control_vector_mw_tp(0), Reset, Clk);														  

starter_PE_inst: starter_PE port map ( IR_datatp,
													start_PE_tp);

															

															
																												

end;		
		
		
