library ieee;
use ieee.std_logic_1164.all;

entity decoder is 
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
end entity decoder;

architecture d_decoder of decoder is
signal temp_control_vector	: std_logic_vector(36 downto 0);
signal instruction_keeper : std_logic_vector(1 downto 0) := "00";
signal mux_pre_alu_a,mux_pre_alu_b 	: std_logic_vector(1 downto 0);
signal mux_ma,mux_mb,one_more_stall1,one_more_stall2,stall_completed : std_logic;
signal stall1_flag,stall2_flag,stall3_flag :std_logic :='0';
signal stall_keeper	: std_logic_vector(1 downto 0);
signal mux_alupc,give_stall : std_logic;
begin
	
	process(IR_data,stall_completed,stall_keeper, check_carry, check_zero, hazard_a, hazard_b, Reset, clk,mux_ma ,mux_mb ,stall1 ,stall2 ,one_more_stall1,one_more_stall2, mux_pre_alu_a , mux_pre_alu_b, data_mem_forward, all_zero_PE, address_PE, instruction_keeper, temp_control_vector, check_comparator,stall1_flag,stall2_flag,stall3_flag)
		variable variable_control : std_logic_vector(36 downto 0) := ( others => '0');
		variable variable_fetch	  : std_logic_vector(1 downto 0);
		variable variable_decode  : std_logic;
		variable variable_register_read	: std_logic_vector(10 downto 0);
		variable variable_execute	: std_logic_vector(6 downto 0);
		variable variable_mem		: std_logic_vector(6 downto 0);
		variable variable_writeback : std_logic_vector(3 downto 0);
		variable variable_instruction_keeper : std_logic_vector(1 downto 0) := "00";
		variable variable_flags_set : std_logic_vector(1 downto 0) := "00"; ---first carry then zero flag enable to set
		variable stall_keeper_var : std_logic_vector(1 downto 0) :="00";
		variable stall_completed_var,s0_en_var,give_stall_var	: std_logic := '0';
		--variable mux_ma_var,mux_mb_var :std_logic;
		begin
			
			if(hazard_a = "10") then 
				mux_pre_alu_a <= "01";
				mux_ma <= '0';
			elsif (hazard_a = "11") then
				mux_pre_alu_a <= "10";
				mux_ma <= '0';
			elsif (hazard_a = "01") then
				mux_pre_alu_a <= "00";
				mux_ma <= '1';
			else 
				mux_pre_alu_a <= "00";
				mux_ma <= '0';
			end if;
			
			if(hazard_b = "10") then 
				mux_pre_alu_b <= "01";
				mux_mb <= '0';
			elsif (hazard_b = "11") then
				mux_pre_alu_b <= "10";
				mux_mb <= '0';
			elsif (hazard_b = "01") then
				mux_mb <= '1';
				mux_pre_alu_b <= "00";	
			else 
				mux_pre_alu_b <= "00";
				mux_mb <= '0';
			end if;
			
			if(kept_it_a = '1') then 
				mux_ma <= '1';
			end if;
		
			if(kept_it_b = '1') then
				mux_mb <= '1';
			end if;	
				
			
			
			case IR_data(15 downto 12) is
				------------------------------------------------	
					when "0000"  =>
						variable_instruction_keeper := "00";
						variable_fetch := "10";
						variable_decode := '1';
						mux_alupc <= '0';
						
						if(IR_data(1 downto 0) = "00") then
							variable_register_read := IR_data(11 downto 6) & "00001";
							variable_execute := mux_pre_alu_a & mux_pre_alu_b & "001";     ---fill correct value for alu select here in place "00"
							variable_mem := "001" & data_mem_forward & IR_data(11 downto 9);
							variable_writeback := '1' & IR_data(5 downto 3);
							variable_flags_set := "11";
						
						elsif(IR_data(1 downto 0) = "01") then
							variable_register_read := IR_data(11 downto 6) & "0000" & check_carry;
							variable_execute := mux_pre_alu_a & mux_pre_alu_b & "00" & check_carry;     ---fill correct value for alu select here in place "00"
							variable_mem := "00" & check_carry  &  data_mem_forward & IR_data(11 downto 9);
							variable_writeback := check_carry & IR_data(5 downto 3);
							variable_flags_set := check_carry & check_carry;
						
						elsif(IR_data(1 downto 0) = "10") then
							variable_register_read := IR_data(11 downto 6) & "0000" & check_zero;
							variable_execute := mux_pre_alu_a & mux_pre_alu_b & "00" & check_zero;     ---fill correct value for alu select here in place "00"
							variable_mem := "00" & check_zero & data_mem_forward & IR_data(11 downto 9);
							variable_writeback := check_zero & IR_data(5 downto 3);
							variable_flags_set := check_zero & check_zero;
							
						else 
							variable_register_read := IR_data(11 downto 6) & "00000";
							variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for alu select here in place "00"
							variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
							variable_writeback := '0' & IR_data(5 downto 3);
							variable_flags_set := "00";
						
						end if;
													
			----------------------------------------------------
					when "0001" =>
						mux_alupc <= '0';
						variable_instruction_keeper := "00";
						variable_fetch := "10";
						variable_decode := '1';			
						variable_register_read := IR_data(11 downto 9) & IR_data(11 downto 9) & "10001";
						variable_execute := mux_pre_alu_a & mux_pre_alu_b & "001";     ---fill correct value for alu select here in place "00"
						variable_mem := "001" & data_mem_forward & IR_data(11 downto 9);
						variable_writeback := '1' & IR_data(8 downto 6);
						variable_flags_set := "11";
			----------------------------------------------------
					when "0010"  =>
						variable_instruction_keeper := "00";
						variable_fetch := "10";
						variable_decode := '1';
						mux_alupc <= '0';
						
						if(IR_data(1 downto 0) = "00") then
							variable_register_read := IR_data(11 downto 6) & "00001";
							variable_execute := mux_pre_alu_a & mux_pre_alu_b & "011";     ---fill correct value for alu select here in place "00"
							variable_mem := "001" & data_mem_forward & IR_data(11 downto 9);
							variable_writeback := '1' & IR_data(5 downto 3);
							variable_flags_set := "01";
						
						elsif(IR_data(1 downto 0) = "01") then
							variable_register_read := IR_data(11 downto 6) & "0000" & check_carry;
							variable_execute := mux_pre_alu_a & mux_pre_alu_b & "01" & check_carry;     ---fill correct value for alu select here in place "00"
							variable_mem := "00" & check_carry & data_mem_forward & IR_data(11 downto 9);
							variable_writeback := check_carry & IR_data(5 downto 3);
							variable_flags_set := '0' & check_carry;
						
						elsif(IR_data(1 downto 0) = "10") then
							variable_register_read := IR_data(11 downto 6) & "0000" & check_zero;
							variable_execute := mux_pre_alu_a & mux_pre_alu_b & "01" & check_zero;     ---fill correct value for alu select here in place "00"
							variable_mem := "00" & check_zero & data_mem_forward & IR_data(11 downto 9);
							variable_writeback := check_zero & IR_data(5 downto 3);
							variable_flags_set := '0' & check_zero;
						else 
							variable_register_read := IR_data(11 downto 6) & "00000";
							variable_execute := mux_pre_alu_a & mux_pre_alu_b & "010";     ---fill correct value for alu select here in place "00"
							variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
							variable_writeback := '0' & IR_data(5 downto 3);
							variable_flags_set := "00";
						
						end if;
				----------------------------------------------------
					when "0011" =>
					   mux_alupc <= '0';
						variable_instruction_keeper := "00";
						variable_fetch := "10";
						variable_decode := '1';
						variable_register_read := IR_data(11 downto 6) & "11001";
						variable_execute := mux_pre_alu_a & mux_pre_alu_b &"111";     ---fill correct value for ALU(respective operand) select here in place "00"
						variable_mem := "001" & data_mem_forward & IR_data(11 downto 9);
						variable_writeback := '1' & IR_data(11 downto 9);
						variable_flags_set := "00";
				----------------------------------------------------
					when "0100" =>
						variable_instruction_keeper := "00";
						variable_fetch := "10";
						variable_decode := '1';
						variable_register_read := IR_data(11 downto 6) & "10001";
						variable_execute := mux_pre_alu_a & mux_pre_alu_b & "001";     ---fill correct value for alu select here in place "00"
						variable_mem := "011" & data_mem_forward & IR_data(11 downto 9);
						variable_writeback := '1' & IR_data(11 downto 9);
						variable_flags_set := "01";
						mux_alupc <= '0';
				----------------------------------------------------
					when "0101" =>
						mux_alupc <= '0';	
						variable_instruction_keeper := "00";
						variable_fetch := "10";
						variable_decode := '1';
						variable_register_read := IR_data(11 downto 6) & "10001";
						variable_execute := mux_pre_alu_a & mux_pre_alu_b & "001";     ---fill correct value for aluselect here in place "00"
						variable_mem := "100" & data_mem_forward & IR_data(11 downto 9);
						variable_writeback := '0' & IR_data(11 downto 9);
						variable_flags_set := "00";
				----------------------------------------------------
					when "0110" =>
						mux_alupc <= '0';
						case instruction_keeper is
							when "00" =>
								variable_instruction_keeper := "01";
								variable_fetch := "00"; -- change here first increment the pc but always give reset to IR to fetch stall
								variable_decode := '0'; --updated PC value but not ready to take in next instruction
								variable_register_read := IR_data(11 downto 6) & "00001";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b &"111";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "011" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := ( not all_zero_PE )  & address_PE;
								variable_flags_set := "00";
							when "01" =>
								if(all_zero_PE = '1') then
									variable_instruction_keeper := "10";
									variable_decode := '0';
								else 					
									variable_instruction_keeper := "01";
									variable_decode := '0';
								end if;
								variable_fetch := "00";
								variable_register_read := IR_data(11 downto 6) & "00001";
								variable_execute := "1111" & "001";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "011" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := ( not all_zero_PE )  & address_PE;
								variable_flags_set := "00";
							when "10" =>
								variable_instruction_keeper := "11";
								variable_decode := '0';
								variable_fetch := "00";
								variable_register_read := IR_data(11 downto 6) & "10010";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
							when "11" =>
								variable_instruction_keeper := "00";
								variable_decode := '1';
								variable_fetch := "10";
								variable_register_read := IR_data(11 downto 6) & "10010";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
							when others => 
								variable_instruction_keeper := "00";
								variable_decode := '1';
								variable_fetch := "10";
								variable_register_read := IR_data(11 downto 6) & "11100";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
							end case;
							
				----------------------------------------------------
					when "0111" =>
						mux_alupc <= '0';
						case instruction_keeper is
							when "00" =>
								variable_instruction_keeper := "01";
								variable_fetch := "00"; -- change here first increment the pc but always give reset to IR to fecth stall
								variable_decode := '0';
								variable_register_read := IR_data(11 downto 6) & "00001";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b &"111";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := (not all_zero_PE) & "00" & data_mem_forward & address_PE;  --**changed mux_mem and LD_mem  to "00"
								variable_writeback := "0000";
								variable_flags_set := "00";
							when "01" =>
								if(all_zero_PE = '1') then
									variable_instruction_keeper := "00";
									variable_decode := '1';
									variable_fetch := "10";
								else 					
									variable_instruction_keeper := "01";
									variable_decode := '0';
									variable_fetch := "00";
								end if;
								
								variable_register_read := IR_data(11 downto 6) & "00001";
								variable_execute := "1111" & "001";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := (not all_zero_PE) & "00" & data_mem_forward & address_PE; --**changed mux_mem and LD_mem  to "00"
								variable_writeback := "0000";
								variable_flags_set := "00";
							when others => 
								variable_instruction_keeper := "00";
								variable_decode := '1';
								variable_fetch := "10";
								variable_register_read := IR_data(11 downto 6) & "11100";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
							end case;
								
								----------------------------------------------------
					when "1100" =>
					   mux_alupc <= '0';
						case instruction_keeper is
							when "00" =>
								variable_instruction_keeper := "01";
								variable_fetch := "00"; -- change here first increment the pc but always give reset to IR to fetch stall
								variable_decode := '0';
								variable_register_read := IR_data(11 downto 6) & "00001";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b &"101";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
							when "01" => 
								variable_instruction_keeper := "10";
								variable_decode := '0';
								variable_fetch := "00";
								variable_register_read := IR_data(11 downto 6) & "11100";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
							when "10" =>
							  if(check_comparator = '1') then
									variable_instruction_keeper := "11";
									variable_decode := '0';
									variable_fetch := '1' & check_comparator;
									variable_register_read := IR_data(11 downto 6) & "10010";
									variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
									variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
									variable_writeback := "0000";
									variable_flags_set := "00";
								else
									variable_instruction_keeper := "00";
									variable_decode := '1';
									variable_fetch := "10";
									variable_register_read := IR_data(11 downto 6) & "11100";
									variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
									variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
									variable_writeback := "0000";
									variable_flags_set := "00";
									mux_alupc <= '0';
								end if;	
									
							when "11" =>
								variable_instruction_keeper := "00";
								variable_decode := '1';
								variable_fetch := "10";
								variable_register_read := IR_data(11 downto 6) & "11100";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
								mux_alupc <= '0';
							when others => 
								variable_instruction_keeper := "00";
								variable_decode := '1';
								variable_fetch := "10";
								variable_register_read := IR_data(11 downto 6) & "11100";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
						end case;
					----------------------------------------------------
					when "1000" =>
						case instruction_keeper is
							when "00" =>
								variable_instruction_keeper := "01";
								variable_fetch := "00"; -- change here first increment the pc but always give reset to IR to fetch stall 
								variable_decode := '0';
								variable_register_read := IR_data(11 downto 6) & "10111";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "001";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
								mux_alupc <= '0';
							when "01" =>
								mux_alupc <= '0';
								variable_instruction_keeper := "10";
								variable_decode := '0';
								variable_fetch := "00";
								variable_register_read := IR_data(11 downto 6) & "11101";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "111";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "001" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := '1' & IR_data(11 downto 9);
								variable_flags_set := "00";
							when "10" =>
								variable_instruction_keeper := "11";
								variable_decode := '0';
								variable_fetch := "10";
								variable_register_read := IR_data(11 downto 6) & "11100";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
								mux_alupc <= '1';
								give_stall_var := '1';
							when "11" =>
								if(give_stall = '1') then
									variable_instruction_keeper := "11"; 
								else 
									variable_instruction_keeper := "00";
								end if;	
								variable_decode := '1';
								variable_fetch := "10";
								variable_register_read := IR_data(11 downto 6) & "11100";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
								mux_alupc <= '0';
							when others => 
								variable_instruction_keeper := "00";
								variable_decode := '1';
								variable_fetch := "10";
								variable_register_read := IR_data(11 downto 6) & "11100";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
								mux_alupc <= '0';
						end case;
								
										----------------------------------------------------
					when "1001" =>
						case instruction_keeper is
							when "00" =>
								variable_instruction_keeper := "01";
								variable_fetch := "00"; -- change here first increment the pc but always give reset to IR to fetch stall
								variable_decode := '0';
								variable_register_read := IR_data(8 downto 6) & IR_data(8 downto 6) & "00001";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "111";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "001" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";--*no need for writeback
								variable_flags_set := "00";
								mux_alupc <= '0';
							when "01" =>
								variable_instruction_keeper := "10";
								variable_decode := '0';
								variable_fetch := "00";
								variable_register_read := IR_data(11 downto 6) & "11101";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "111";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "001" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := '1' & IR_data(11 downto 9);
								variable_flags_set := "00";
								mux_alupc <= '0';
							when "10" =>
								variable_instruction_keeper := "11";
								variable_decode := '0';
								variable_fetch := "10";
								variable_register_read := IR_data(11 downto 6) & "11100";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
								mux_alupc <= '1';
								give_stall_var := '1';
							when "11" =>
								if(give_stall = '1') then
									variable_instruction_keeper := "11";
									 
								else 
									variable_instruction_keeper := "00";
								end if;	
								variable_decode := '1';
								variable_fetch := "10";
								variable_register_read := IR_data(11 downto 6) & "11100";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
								mux_alupc <= '0';
							when others => 
								variable_instruction_keeper := "00";
								variable_decode := '1';
								variable_fetch := "10";
								variable_register_read := IR_data(11 downto 6) & "11100";
								variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
								variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
								variable_writeback := "0000";
								variable_flags_set := "00";
								mux_alupc <= '0';
						end case;
						
						----------------------------------------------------------------------------------------------------------------------------------------
						when "1111" => 
							variable_instruction_keeper := "00";
							variable_decode := '0';
							variable_fetch := "00";
							variable_register_read := IR_data(11 downto 6) & "11100";
							variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
							variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
							variable_flags_set := "00";
							mux_alupc <= '0';
						----------------------------------------------------------------------------------------------------------------------------------------
						when others => 
							variable_instruction_keeper := "00";
							variable_decode := '1';
							variable_fetch := "10";
							variable_register_read := IR_data(11 downto 6) & "11100";
							variable_execute := mux_pre_alu_a & mux_pre_alu_b & "000";     ---fill correct value for ALU(respective operand) select here in place "00"
							variable_mem := "000" & data_mem_forward & IR_data(11 downto 9);
							variable_writeback := "0000";
							variable_flags_set := "00";
							mux_alupc <= '0';
					end case;
					
				case stall_keeper is
					when "00" =>
						
						if(stall_completed = '0') then
							if(stall3 = '1') then
								stall_keeper_var := "10";
								variable_control:= "0000000000000000000000000000000000000";
								s0 <= "11";
								s0_en_var := '1';
							elsif(stall2 = '1') then
								stall_keeper_var := "01";
								variable_control:= "0000000000000000000000000000000000000";
								s0 <= "10";
								s0_en_var := '1';
							elsif(stall1 = '1' or stall = '1') then
								stall_keeper_var := "00";
								stall_completed_var := '1';
								variable_control:= "0000000000000000000000000000000000000";
								s0 <= "01";
								s0_en_var := '1';
							else
								s0 <= "00";
								s0_en_var := '1';
								stall_keeper_var := "00";
								variable_control := mux_alupc & mux_ma & mux_mb & variable_fetch & variable_decode & variable_register_read & variable_execute & variable_mem & variable_writeback & variable_flags_set;
							end if;
						else
							stall_completed_var := '0';

							if(stall_completed = '1') and (stall3 = '1') then
								variable_execute(6 downto 3) := "0000";
								variable_mem(3) := '0';
								stall_keeper_var := "00";
								
						
							elsif((stall_completed = '1') and (stall2 = '1')) then

								if(hazard_a="10") then
									variable_execute(6 downto 5) :="00";
									variable_mem(3) := '0';
									mux_ma<='1';
									
								else
									variable_execute(6 downto 5) := "00";------edit
									variable_mem(3) := '0';
									stall_keeper_var := "00";
								end if;
								if(hazard_b="10") then
									variable_execute(4 downto 3) :="00";
									variable_mem(3) := '0';
									mux_mb <='1';
								else
									variable_execute(4 downto 3) := "00";------edit
									variable_mem(3) := '0';
									stall_keeper_var := "00";
								end if;
							elsif((stall_completed = '1') and ((stall1 = '1') or(stall='1'))) then
								if(hazard_a="10") then
									variable_execute(6 downto 5) :="10";
									variable_mem(3) := '0';
									mux_ma<='0';
								elsif(hazard_a="11") then
									variable_execute(6 downto 5) :="00";
									variable_mem(3) := '0';
									mux_ma <='1';
								else
									variable_execute(6 downto 5) := "00";------edit
									variable_mem(3) := '0';
									stall_keeper_var := "00";
								end if;
								if(hazard_b="10") then
									variable_execute(4 downto 3) :="10";
									variable_mem(3) := '0';
									mux_mb <='0';
								elsif(hazard_b="11") then
									variable_execute(4 downto 3) :="00";
									variable_mem(3) := '0';
									mux_mb <='1';
								else
									variable_execute(4 downto 3) := "00";------edit
									variable_mem(3) := '0';
									stall_keeper_var := "00";
								end if;
							
								
							else
								variable_execute(6 downto 3) := "0000";------edit
								variable_mem(3) := '0';
								stall_keeper_var := "00";
								
								
							end if;
							variable_control := mux_alupc & mux_ma & mux_mb & variable_fetch & variable_decode & variable_register_read & variable_execute & variable_mem & variable_writeback & variable_flags_set;
						end if;
					when "01" =>
						stall_completed_var := '1';
						stall_keeper_var := "00";
						variable_control:= "0000000000000000000000000000000000000";
						s0_en_var := '0';
					when "10" =>
						stall_completed_var := '0';
						stall_keeper_var := "01";
						variable_control:= "0000000000000000000000000000000000000";
						s0_en_var := '0';
					when others =>
						stall_completed_var := '0';
						s0_en_var := '0';
						stall_keeper_var := "00";
						variable_control := mux_alupc & mux_ma & mux_mb & variable_fetch & variable_decode & variable_register_read & variable_execute & variable_mem & variable_writeback & variable_flags_set;
						
				end case;
				
				if(give_stall = '1') then
						variable_control:= "0000000000000000000000000000000000000";
						give_stall_var := '0';
				else 
						give_stall_var := '0';
				end if; 
						
				
				case IR_data(15 downto 12) is

						when "1100" | "1001" | "1000" =>
							s0 <= "11";
							s0_en_var := '1';
						when others =>
							s0_en_var := s0_en_var;
							
			  end case;
			
				if(clk'event and clk = '0') then
					temp_control_vector <= variable_control;
					instruction_keeper <= variable_instruction_keeper;
					stall_keeper <= stall_keeper_var;
					stall_completed <= stall_completed_var;
               s0_en <= s0_en_var;
					give_stall <= give_stall_var;
				end if;
				if (Reset = '1') then
					temp_control_vector <= "0000000000000000000000000000000000000";
					instruction_keeper <= "00";
					stall_keeper <="00";
					stall_completed <= '0';
				end if;
			
				
			end process;
			control_vector <= temp_control_vector;
end;
								
					
