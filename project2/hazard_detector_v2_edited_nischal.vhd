library ieee;
use ieee.std_logic_1164.all;

entity hazard_detector is
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
		 clk: in std_logic;
		 reset: in std_logic;
		 kept_it_a,kept_it_b : out std_logic
		);
end entity hazard_detector;

architecture d_hazard of hazard_detector is

component single_hazard_detect is
	port 
		(RX	: in std_logic_vector(2 downto 0);
		IR_OLD_num :in std_logic_vector(15 downto 0);
		next_reg_PE_output : in std_logic_vector(2 downto 0);
		all_zero_PE	: in std_logic;
		is_hazard	: out std_logic;
		do_stall		: out std_logic;
		keep_it : out std_logic
		);
end component;
component single_hazard_detect_23 is
	port 
		(RX	: in std_logic_vector(2 downto 0);
		IR_OLD_num :in std_logic_vector(15 downto 0);
		next_reg_PE_output : in std_logic_vector(2 downto 0);
		all_zero_PE	: in std_logic;
		is_hazard	: out std_logic
		);
end component;		


signal ra,rb : std_logic_vector(2 downto 0);
signal check_ra,check_rb : std_logic;
signal hazard1a,hazard2a,hazard3a,hazard1b,hazard2b,hazard3b	: std_logic;
signal stall1a,stall2a,stall3a,stall1b,stall2b,stall3b	: std_logic;
signal final_hazard_a,final_hazard_b	: std_logic_vector(1 downto 0);
signal stall_a,stall_b	: std_logic;
signal flag_funda_1,flag_funda_2,flag_funda_3	: std_logic;
begin
	
	-- select RA and RB
	find: process(IR,IR_OLD1,IR_OLD2,IR_OLD3)
	begin
		case IR(15 downto 12) is
			when "0000" | "0010" | "1100" =>
			ra <= IR(11 downto 9);
			rb <= IR(8 downto 6);
			check_ra <= '1';
			check_rb <= '1';
			when "0001" =>
			rb <= IR(11 downto 9);
			ra <= "111";
			check_ra <= '0';
			check_rb <= '1';
			when "0100" | "0101" =>
			rb <= IR(8 downto 6);
			ra <= "111";
			check_ra <= '0';
			check_rb <= '1';
			when "0110" | "0111" =>
			rb <= "111";
			ra <= IR(11 downto 9);
			check_ra <= '1';
			check_rb <= '0';
			when "1001" =>
			rb <= "111";
			ra <= IR(8 downto 6);
			check_ra <= '1';
			check_rb <= '0';
			when others =>
			rb <= "111";
			ra <= "111";
			check_ra <= '0';
			check_rb <= '0';
		end case;
		
		if(IR(15 downto 12)="0000" or IR(15 downto 12)="0010" ) then
			if(IR(1 downto 0)="10" or IR(1 downto 0)="01") then
				case IR_OLD1(15 downto 12) is
					when "0000" | "0001" | "0010" | "0100" =>
						flag_funda_1 <= '1';
					when others =>
						flag_funda_1 <= '0';
				end case;
		
				case IR_OLD2(15 downto 12) is
					when "0000" | "0001" | "0010" | "0100" =>
						flag_funda_2 <= '1';
					when others =>
						flag_funda_2 <= '0';
				end case;
		
				case IR_OLD3(15 downto 12) is
					when "0000" | "0001" | "0010" | "0100" =>
						flag_funda_3 <= '1';
					when others =>
						flag_funda_3 <= '0';
				end case;
			else
				flag_funda_1 <= '0';
				flag_funda_2 <= '0';
				flag_funda_3 <= '0';
			end if;
		else
			flag_funda_1 <= '0';
			flag_funda_2 <= '0';
			flag_funda_3 <= '0';
		end if;
		
	end process;
	
	h1a	: single_hazard_detect	 port map (ra,IR_oLD1,next_reg_PE_output,all_zero_PE,hazard1a,stall_a,kept_it_a);
	h2a	: single_hazard_detect_23 port map (ra,IR_oLD2,next_reg_PE_output,all_zero_PE,hazard2a);
	h3a	: single_hazard_detect_23 port map (ra,IR_oLD3,next_reg_PE_output,all_zero_PE,hazard3a);
	h1b	: single_hazard_detect 		port map (rb,IR_oLD1,next_reg_PE_output,all_zero_PE,hazard1b,stall_b,kept_it_b);
	h2b	: single_hazard_detect_23 port map (rb,IR_oLD2,next_reg_PE_output,all_zero_PE,hazard2b);
	h3b	: single_hazard_detect_23 port map (rb,IR_oLD3,next_reg_PE_output,all_zero_PE,hazard3b);
	
	priority: process(hazard1a,hazard1b,hazard2a,hazard2b,hazard3a,hazard3b,check_ra,check_rb,IR,next_reg_PE_output,IR_oLD1)
					begin
						if(check_ra = '1') then
							if(hazard1a = '1') then
								final_hazard_a <= "10";
								if(IR_oLD1(15 downto 12) = "0000" or IR_OLD1(15 downto 12) = "0010") then
									if(IR_OLD1(1 downto 0)="10" or IR_OLD1(1 downto 0)="01") then
										stall3a <= '1';
									else
										stall3a <= '0';
									end if;
								else 
									stall3a <= '0';
								end if;
								stall2a <= '0';
								stall1a <= '0';
							elsif (hazard2a = '1') then
								stall3a <= '0';
								if(IR_OLD1(15 downto 12) = "0110") then
									final_hazard_a <= "00";
								else 
									final_hazard_a <= "11";
								end if;
								if(IR_oLD2(15 downto 12) = "0000" or IR_OLD2(15 downto 12) = "0010") then
									if(IR_OLD2(1 downto 0)="10" or IR_OLD2(1 downto 0)="01") then
										stall2a <= '1';
									else
										stall2a <= '0';
									end if;
								else 
									stall2a <= '0';
								end if;
								stall1a <= '0';
							elsif (hazard3a = '1') then
								if(IR_OLD1(15 downto 12) = "0110" or IR_oLD2(15 downto 12) = "0110") then
									final_hazard_a <= "00";
								else 
									final_hazard_a <= "01";
								end if;
								stall3a <= '0';
								stall2a <= '0';
								if(IR_oLD3(15 downto 12) = "0000" or IR_OLD3(15 downto 12) = "0010") then
									if(IR_OLD3(1 downto 0)="10" or IR_OLD3(1 downto 0)="01") then
										stall1a <= '1';
									else
										stall1a <= '0';
									end if;
								else 
									stall1a <= '0';
								end if;
							else
								final_hazard_a <= "00";
								stall2a <= '0';
								stall3a <= '0';
								stall1a <= '0';
							end if;
						else 
							stall1a <= '0';
							stall2a <= '0';
							stall3a <= '0';
							final_hazard_a <= "00";
						end if;
						
						if(check_rb = '1') then
							if(hazard1b = '1') then
								stall1b <= '0';
								stall2b <= '0';
								final_hazard_b <= "10";
								if(IR_oLD1(15 downto 12) = "0000" or IR_OLD1(15 downto 12) = "0010") then
									if(IR_OLD1(1 downto 0)="10" or IR_OLD1(1 downto 0)="01") then
										stall3b <= '1';
									else
										stall3b <= '0';
									end if;
								else 
									stall3b <= '0';
								end if;
							elsif (hazard2b = '1') then
								stall1b <= '0';
								if(IR_OLD1(15 downto 12) = "0110") then
									final_hazard_b <= "00";
								else 
									final_hazard_b <= "11";
								end if;
								if(IR_oLD2(15 downto 12) = "0000" or IR_OLD2(15 downto 12) = "0010") then
									if(IR_OLD2(1 downto 0)="10" or IR_OLD2(1 downto 0)="01") then
										stall2b <= '1';
									else
										stall2b <= '0';
									end if;
								else 
									stall2b <= '0';
								end if;
								stall3b <= '0';
							elsif (hazard3b = '1') then
								if(IR_oLD3(15 downto 12) = "0000" or IR_OLD3(15 downto 12) = "0010") then
									if(IR_OLD3(1 downto 0)="10" or IR_OLD3(1 downto 0)="01") then
										stall1b <= '1';
									else
										stall1b <= '0';
									end if;
								else 
									stall1b <= '0';
								end if;
								if(IR_OLD1(15 downto 12) = "0110" or IR_oLD2(15 downto 12) = "0110") then
									final_hazard_b <= "00";
								else 
									final_hazard_b <= "01";
								end if;
								stall2b <= '0';
								stall3b <= '0';
							else
								final_hazard_b <= "00";
								stall1b <= '0';
								stall2b <= '0';
								stall3b <= '0';
							end if;
						else 
							stall1b <= '0';
							stall2b <= '0';
							stall3b <= '0';
							final_hazard_b <= "00";
						end if;
						
					
						
						if(IR(15 downto 12) = "0101") then
							if ( IR_OLD1(5 downto 3)=IR(11 downto 9)) then
								data_mem_forward <= '1';
							else 
								data_mem_forward <= '0';
							end if;
							
						elsif (IR(15 downto 12) = "0111") then
								if ( next_reg_PE_output=IR(11 downto 9)) then
									data_mem_forward <= '1';
								else 
									data_mem_forward <= '0';
								end if;
						else	
								data_mem_forward <= '0';
						end if;
						end process;
			stall <= stall_a or stall_b;
			hazard_a <= final_hazard_a;
			hazard_b <= final_hazard_b;
			stall1 <= flag_funda_3 or stall1a or stall1b;
			stall2 <= flag_funda_2 or stall2a or stall2b;
			stall3 <= flag_funda_1 or stall3a or stall3b;
			
end;		
	
	
	
