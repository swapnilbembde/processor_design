library ieee;
use ieee.std_logic_1164.all;

entity updateblock is
	port 
		(s1,s2,s3 : in std_logic_vector(1 downto 0);
       stall1,stall2,stall3 :in std_logic;
       stall_1,stall_2,stall_3: out std_logic;
		 hazarda,hazardb: in std_logic_vector(1 downto 0);
		 hazard_a,hazard_b: out std_logic_vector(1 downto 0);
		 data_mem_forward_out: out std_logic;
		 data_mem_forward_in: in std_logic
		);
end entity updateblock;

architecture behave of updateblock is

begin

process(s1,s2,s3,stall1,stall2,stall3,hazarda,hazardb,data_mem_forward_in)

begin
 

case s1 is
	when "01" =>
		data_mem_forward_out<='0';
		case s2 is
			when "00" =>
				if(hazarda = "10") then
                    hazard_a <= "11";
                elsif(hazarda = "11") then
                    hazard_a <= "01";
                else 
                    hazard_a <= "00";
                end if;
                
                if(hazardb = "10") then
                    hazard_b <= "11";
                elsif(hazardb = "11") then
                    hazard_b <= "01";
                else 
                    hazard_b <= "00";
                end if;
                    
				stall_3<='0';
				stall_2<=stall3;
				stall_1<=stall1;
				
			when others =>
				if(hazarda = "10") then
                    hazard_a <= "11";
                else 
                    hazard_a <= "00";
                end if;
                
                if(hazardb = "10") then
                    hazard_b <= "11";
                else 
                    hazard_b <= "00";
                end if;
                
				stall_3<='0';
				stall_2<=stall3;
				stall_1<='0';
		end case;		
				

	when "10" =>
					 data_mem_forward_out<='0';
                if(hazarda = "10") then
                    hazard_a <= "01";
                else 
                    hazard_a <= "00";
                end if;
                
                if(hazardb = "10") then
                    hazard_b <= "01";
                else 
                    hazard_b <= "00";
                end if;
		
                stall_3<='0';
                stall_2<='0';
                stall_1<=stall3;

	when "11" =>
					 data_mem_forward_out<='0';
                hazard_a <= "00";
                hazard_b <= "00";
		
                stall_3<='0';
                stall_2<='0';
                stall_1<='0';
		
	when "00"=>

		data_mem_forward_out<=data_mem_forward_in;
		case s2 is
			when "00" =>
				case s3 is
					when "00" =>

			
						if(hazarda = "10") then
                            hazard_a <= "10";
                        elsif(hazarda = "11") then
                            hazard_a <= "11";
                        elsif(hazarda = "01") then 
                            hazard_a <= "01";
                        else
                            hazard_a <= "00";
                        end if;
                
                        if(hazardb = "10") then
                            hazard_b <= "10";
                        elsif(hazardb = "11") then
                            hazard_b <= "11";
                        elsif(hazardb = "01") then
                            hazard_b <= "01";
                        else 
                            hazard_b <= "00";    
                        end if;
                        
						stall_3<=stall3;
						stall_2<=stall2;
						stall_1<=stall1;

					when others=>
			
                        if(hazarda = "10") then
                            hazard_a <= "10";
                        elsif(hazarda = "11") then
                            hazard_a <= "11";
                        else 
                            hazard_a <= "00";
                        end if;
                        
                        if(hazardb = "10") then
                            hazard_b <= "10";
                        elsif(hazardb = "11") then
                            hazard_b <= "11";
                        else 
                            hazard_b <= "00";
                        end if;
                    
						
						stall_3<=stall3;
						stall_2<=stall2;
						stall_1<='0';
				end case;		

			when "01"=>
		
                if(hazarda = "10") then
                    hazard_a <= "10";
                elsif(hazarda = "11") then
                    hazard_a <= "01";
                else 
                    hazard_a <= "00";
                end if;
                
                if(hazardb = "10") then
                    hazard_b <= "10";
                elsif(hazardb = "11") then
                    hazard_b <= "01";
                else 
                    hazard_b <= "00";
                end if;
				
				stall_3<=stall3;
				stall_2<='0';
				stall_1<=stall2;

			when others=>
		
                if(hazarda = "10") then
                    hazard_a <= "10";
                else 
                    hazard_a <= "00";
                end if;
                
                if(hazardb = "10") then
                    hazard_b <= "10";
                else 
                    hazard_b <= "00";
                end if;
				
				stall_3<=stall3;
				stall_2<='0';
				stall_1<='0';
			
			end case;
		
    when others =>
          	data_mem_forward_out<='0';
            hazard_a <= "00";
            hazard_b <= "00";
            stall_3<='0';
				stall_2<='0';
				stall_1<='0';
	
	end case;

end process;				
                
end;
					
						

