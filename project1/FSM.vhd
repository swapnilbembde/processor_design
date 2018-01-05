library ieee;
use ieee.std_logic_1164.all;
library work;
use work.datapath_comp.all;

entity FSM is							--SIGNALS RELATED TO COMPONENTS 
	port
	(
	-----ALU--------
	carry_in,zero_in,equal_in				: in std_logic;
	sel_ALU										: out std_logic_vector(1 downto 0);
	----------------
	--Pre-Post ALU--
	LD_Pre_ALU_B_reg,LD_Pre_ALU_A_reg	: out std_logic;
	LD_Post_ALU_reg							: out std_logic;
	sel_MUX_B,sel_MUX_A						: out std_logic;
	sel_MUX_pre_B								: out std_logic_vector(1 downto 0);
	LD_reg_all									: out std_logic;
	----------------
	----GPR---------
	sel_data_out_a,sel_data_out_b			: out std_logic_vector(2 downto 0);
	sel_data_write								: out std_logic_vector(2 downto 0);
	sel_MUX_R7									: out std_logic;
	----------------
	------IR--------
	LD_IR											: out std_logic;
	IR_data										: in std_logic_vector(15 downto 0);
	----------------
	-----MEM--------
	WE_bar										: out std_logic;
	sel_MUX_MAR,sel_MUX_MDR,sel_MUX_data: out std_logic;
	----------------
	----LM_SM-------
	LD_Pre_Priority_reg,LD_index			: out std_logic;
	all_zero										: in std_logic;
	address_PE									: in std_logic_vector(2 downto 0);
	----------------
	----------------
	clk,Reset									: in std_logic;
	initialise									: out std_logic
	);
end entity;

architecture d_FSM of FSM is

	component register_1 is 
		port ( 
			data_in: in std_logic;
			data_out: out std_logic;
			LD_reg: in std_logic;
			Reset,clk: in std_logic
			);
	end component register_1;

	
	--type FSM_states is
	--(Fetch,Decode,Arth_Execute,Arth_MEM,Arth_WB,LS_Execute,LS_MEM,LS_WB,BEQ_Execute,BEQ_MEM,JAL_Execute,JLR_Execute,JLR_MEM,JLR_WB,LM_MEM,LM_MEM2,LM_MEM3,SM_MEM3,INC_PC,Inc_PC2);
	signal current_state : FSM_states;
	signal carry_data,zero_data,LD_zero,LD_carry	: std_logic;
	
begin	
	
	zero_flag: register_1 port map (zero_in,zero_data,LD_zero, Reset, Clk);
	Carry_flag: register_1 port map (carry_in,carry_data,LD_carry, Reset, Clk);
	
	process(current_state,equal_in,IR_data,clk,Reset,zero_data,carry_data,all_zero,address_PE)
		variable next_state	: FSM_states;
		variable LD_IR_var,LD_Post_ALU_reg_var,LD_Pre_ALU_A_reg_var,LD_Pre_ALU_B_reg_var,LD_carry_var,LD_zero_var	: std_logic :='0';
		variable sel_ALU_var		: std_logic_vector(1 downto 0):="00";
		variable sel_MUX_A_var,sel_MUX_B_var,sel_MUX_MAR_var,sel_MUX_MDR_var,sel_MUX_R7_var,sel_MUX_data_var			: std_logic :='0';
		variable sel_MUX_pre_B_var	: std_logic_vector(1 downto 0):="00";
		variable sel_data_out_a_var,sel_data_out_b_var,sel_data_write_var		: std_logic_vector(2 downto 0):="000";
		variable WE_bar_var		: std_logic := '0';
		variable LD_Index_var, LD_Pre_Priority_reg_var : std_logic := '0';
		variable LD_reg_all_var 	: std_logic := '0';
		begin	
			next_state := current_state;
			LD_IR_var := '0';
			LD_Post_ALU_reg_var := '0';
			LD_Pre_ALU_A_reg_var := '0';
			LD_Pre_ALU_B_reg_var := '0';
			LD_carry_var := '0';
			LD_zero_var := '0';
			LD_pre_priority_reg_var := '0';
			LD_index_var := '0';
			LD_reg_all_var := '0';
			sel_ALU_var := "11";
			sel_MUX_A_var := '1';
			sel_MUX_B_var := '1';
			sel_MUX_MAR_var := '1';
			sel_MUX_MDR_var := '1';
			sel_MUX_R7_var	:= '0';
			sel_MUX_pre_B_var := "11";
			sel_data_out_a_var := sel_data_out_a_var;
			sel_data_out_b_var := "111";
			sel_data_write_var := "111";
			sel_Mux_data_var := '1';
			WE_bar_var := '1';
			
			case current_state is

				when Fetch =>									----FETCH STATE
					sel_MUX_MAR_var := '1';
					WE_bar_var := '1';
					LD_IR_var := '1';
					next_state := Decode;
					
				when Decode =>									----DECODE STATE
					
					case IR_data(15 downto 12) is
				------------------------------------------------	
						when ("0000") | ("0010")  =>
							sel_data_out_a_var := IR_data(11 downto 9);
							sel_data_out_b_var := IR_data(8 downto 6);
							sel_MUX_A_var := '1';
							sel_MUX_B_var := '1';     
							LD_Pre_ALU_A_reg_var := '1';
							LD_Pre_ALU_B_reg_var := '1';
							case IR_data(1 downto 0) is
								when "00" =>
									next_state := Arth_Execute;
								when "01" =>
									if(zero_data = '1') then	
										next_state := Arth_Execute;
									else
										next_state := Inc_PC;
									end if;
								when "10" =>
									if(carry_data = '1') then
										next_state := Arth_Execute;
									else
										next_state := Inc_PC;
									end if;
								when others =>
									next_state := Decode;
							end case;							
				----------------------------------------------------
						when "0001" =>
							sel_data_out_a_var := IR_data(11 downto 9);
							sel_MUX_A_var := '1';
							sel_MUX_B_var := '0';
							sel_MUX_Pre_B_var := "01";
							LD_Pre_ALU_A_reg_var := '1';
							LD_Pre_ALU_B_reg_var := '1';
							next_state := Arth_Execute;
				----------------------------------------------------
			
					----------------------------------------------------
						when "0011" =>
							sel_MUX_B_var := '0';
							sel_MUX_Pre_B_var := "11";
							LD_Pre_ALU_A_reg_var := '1';
							LD_Pre_ALU_B_reg_var := '1';
							next_state := Arth_Execute;
					----------------------------------------------------
						when ("0110") | ("0111") =>
							
							sel_MUX_B_var := '1';
							sel_data_out_b_var := IR_data(11 downto 9);
							LD_Pre_ALU_B_reg_var := '1';
							next_state := LM_MEM;
					----------------------------------------------------
						when ("0100") | ("0101")  =>
							sel_data_out_a_var := IR_data(8 downto 6);
							sel_MUX_A_var := '1';
							sel_MUX_B_var := '0';
							sel_MUX_Pre_B_var := "01";
							LD_Pre_ALU_A_reg_var := '1';
							LD_Pre_ALU_B_reg_var := '1';
							next_state := LS_Execute;
					----------------------------------------------------
						when  "1100" => 
							sel_data_out_a_var := IR_data(11 downto 9);
							sel_data_out_b_var := IR_data(8 downto 6);
							sel_MUX_A_var := '1';
							sel_MUX_B_var := '1';     
							LD_Pre_ALU_A_reg_var := '1';
							LD_Pre_ALU_B_reg_var := '1';
							next_state := BEQ_Execute;
					----------------------------------------------------
						when ("1000") | ("1001") =>
							sel_data_out_b_var := "111";
							sel_MUX_A_var := '0';
							sel_MUX_B_var := '1';
							sel_MUX_Pre_B_var := "10";
							LD_Pre_ALU_A_reg_var := '1';
							LD_Pre_ALU_B_reg_var := '1';
							if(IR_data(12) = '1') then
								next_state := JLR_Execute;
							else
								next_state	:= JAL_Execute;
							end if;
							
						when "1111"	=>
							next_state := Decode;
						when others =>
							next_state := Fetch;
							
						end case;
					----------------------------------------------------

							
					when Arth_Execute =>
						if(IR_data(13) = '1') then
							if(IR_data(12) = '1') then
								sel_ALU_var := "11";
							else
								sel_ALU_var := "01";
							end if;
						else
							sel_ALU_var := "00";
						end if;
						LD_Post_ALU_reg_var := '1';
						sel_data_out_b_var := "111";
						sel_MUX_A_var := '0';
						sel_MUX_B_var := '1';
						LD_Pre_ALU_A_reg_var := '1';
						LD_Pre_ALU_B_reg_var := '1';
						LD_carry_var := '1';
						next_state := Arth_MEM;
						
					when Arth_MEM =>
						sel_ALU_var := "00";
						sel_MUX_MDR_var := '0';
						sel_mUX_R7_var := '1';
						LD_reg_all_var := '1';
						sel_data_write_var := "111";
						if(IR_data(15) = '0') then
							next_state := Arth_WB;
						else
							next_state := JLR_WB;
						end if;
						
					when Arth_WB =>
						LD_zero_var := '1';
						LD_reg_all_var := '1';
						if(IR_data(12) = '1') then
							if(IR_data(13) = '1') then
								sel_data_write_var :=  IR_data(11 downto 9);
							else
								sel_data_write_var :=  IR_data(8 downto 6);
							end if;
							
						else
							sel_data_write_var := IR_data(5 downto 3);
						end if;
						sel_MUX_MDR_var := '0';
						next_state := Fetch;
						
					when LS_Execute =>
						sel_ALU_var := "00";
						LD_Post_ALU_reg_var := '1';
						sel_data_out_b_var := "111";
						sel_MUX_A_var := '0';
						sel_MUX_B_var := '1';
						LD_Pre_ALU_A_reg_var := '1';
						LD_Pre_ALU_B_reg_var := '1';
						next_state := LS_MEM;
						
					when LS_MEM =>
						LD_reg_all_var := '1';
						sel_data_out_a_var := IR_data(11 downto 9);
						sel_mux_data_var := not IR_data(12);
						WE_bar_var := not IR_data(12);
						sel_ALU_var := "00";
						sel_data_write_var := "111";
						sel_MUX_MAR_var := '0';
						sel_MUX_R7_var	 := '0';
						sel_MUX_MDR_var := '1';
						sel_mUX_R7_var := '1';
						if(IR_data(12) = '1') then 
							next_state := Fetch;
						else
							next_state := LS_WB;
						end if;
						
					when LS_WB =>
						LD_reg_all_var := '1';
						LD_zero_var := '1';
						WE_bar_var := '1';
						sel_data_write_var := IR_data(11 downto 9);
						sel_MUX_MDR_var := '0';
						next_state := Fetch;
						
					when BEQ_Execute =>
						sel_ALU_var := "10";
						sel_data_out_a_var := "111";
						sel_MUX_A_var := '1';
						sel_MUX_B_var := '0';
						sel_MUX_Pre_B_var := "01";
						LD_Pre_ALU_A_reg_var := '1';
						LD_Pre_ALU_B_reg_var := '1';
						if(equal_in = '0') then
							next_state := Inc_PC;
						else 
							next_state := BEQ_MEM;
						end if;
							
					when BEQ_MEM =>
						LD_reg_all_var := '1';
						sel_ALU_var := "00";
						sel_MUX_MDR_var := '0';
						sel_mUX_R7_var := '1';
						sel_data_write_var := "111";
						next_state := Fetch;
						
					when JAL_Execute =>
						sel_ALU_var := "00";
						LD_Post_ALU_reg_var := '1';
						sel_data_out_a_var := "111";
						sel_MUX_A_var := '1';
						sel_MUX_B_var := '0';
						sel_MUX_Pre_B_var := "01";
						LD_Pre_ALU_A_reg_var := '1';
						LD_Pre_ALU_B_reg_var := '1';
						next_state := Arth_MEM;
						
					when JLR_Execute =>
						sel_ALU_var := "00";
						LD_Post_ALU_reg_var := '1';
						sel_data_out_b_var := IR_data(8 downto 6);
						sel_MUX_B_var := '1';
						LD_Pre_ALU_A_reg_var := '1';
						LD_Pre_ALU_B_reg_var := '1';
						next_state := JLR_MEM;
						
					when JLR_MEM =>
						LD_reg_all_var := '1';
						sel_ALU_var := "11";
						sel_MUX_MDR_var := '0';
						sel_mUX_R7_var := '1';
						sel_data_write_var := "111";
						next_state := JLR_WB;
					
					when JLR_WB =>
						LD_reg_all_var := '1';
						sel_data_write_var :=  IR_data(11 downto 9);
						sel_MUX_MDR_var := '0';
						next_state := Fetch;
						
					when LM_MEM =>
						LD_Pre_Priority_reg_var := '1';
						LD_Post_ALU_reg_var := '1';
						sel_ALU_var := "11";
						next_state := LM_MEM2;
						
					when LM_MEM2 =>
					   sel_MUX_MDR_var := '1';
						sel_MUX_MAR_var := '0';
						sel_MUX_pre_B_var := "00";
						sel_MUX_A_var := '0';
						sel_MUX_B_var := '0';
						LD_Pre_ALU_A_reg_var := '1';
						LD_Pre_ALU_B_reg_var := '1';
						if(all_zero = '0') then
							if(IR_data(12) = '0') then
								next_state := LM_MEM3;
							else 
								next_state := SM_MEM3;
							end if;
						else
							next_state := Inc_PC;
						end if;
						
					when LM_MEM3 =>
						sel_data_out_a_var := address_PE;
						LD_reg_all_var := '1';
						sel_ALU_var := "00";
						LD_index_var := '1';
						LD_Post_ALU_reg_var := '1';
						sel_data_write_var := address_PE;
						next_state := LM_MEM2;
						
					when SM_MEM3 =>
						sel_MUX_MAR_var := '0';
						sel_ALU_var := "00";
						LD_index_var := '1';
						LD_Post_ALU_reg_var := '1';
						sel_data_out_a_var := address_PE;
						WE_bar_var := '0';
						next_state := LM_MEM2;
						
					when Inc_PC =>
						sel_data_out_b_var := "111";
						sel_MUX_A_var := '0';
						sel_MUX_B_var := '1';
						LD_Pre_ALU_A_reg_var := '1';
						LD_Pre_ALU_B_reg_var := '1';
						next_state := Inc_PC2;
					
					when Inc_PC2 =>
						LD_reg_all_var := '1';
						sel_ALU_var := "00";
						sel_MUX_MDR_var := '0';
						sel_mUX_R7_var := '1';
						sel_data_write_var := "111";
						next_state := Fetch;
					
					when others =>
						next_state := Fetch;
					
					end case;
	
			if(clk'event and Clk = '1') then
				current_state <= next_state;
			end if;
				LD_IR <= LD_IR_var;
				LD_Post_ALU_reg <= LD_Post_ALU_reg_var;
				LD_Pre_ALU_A_reg <= LD_Pre_ALU_A_reg_var;
				LD_Pre_ALU_B_reg <= LD_Pre_ALU_B_reg_var;
				LD_carry <= LD_carry_var;
				LD_zero <= LD_zero_var;
				LD_Pre_Priority_reg <= LD_pre_priority_reg_var;
				LD_index <= LD_index_var;
				LD_reg_all <= LD_reg_all_var;
				sel_ALU <= sel_ALU_var;
				sel_MUX_A <= sel_MUX_A_var;
				sel_MUX_B <= sel_MUX_B_var;
				sel_MUX_MAR <= sel_MUX_MAR_var;
				sel_MUX_MDR <= sel_MUX_MDR_var;
				sel_mUX_R7	<= sel_MUX_R7_var;
				sel_mux_pre_B 	<= sel_MUX_Pre_B_var;
				sel_data_out_a <= sel_data_out_a_var;
				sel_data_out_b <= sel_data_out_b_var;
				sel_data_write	<= sel_data_write_var;
				sel_Mux_data <= sel_mux_data_var;
				WE_bar <= WE_bar_var;
			
			if(Reset = '1') then							----RESET ALL VALUES
				current_state <= Fetch;
				next_state := Fetch;
				LD_IR <= '0';
				LD_reg_all <= '0';
				LD_Post_ALU_reg <= '0';
				LD_Pre_ALU_A_reg <= '0';
				LD_Pre_ALU_B_reg <= '0';
				LD_carry <= '0';
				LD_zero <= '0';
				LD_Pre_Priority_reg <= '0';
				LD_index <= '0';
				WE_bar <= '0';
			end if;
		end process;
				initialise <= Reset;					---MEMORY INTIALISER
		
	end;
				