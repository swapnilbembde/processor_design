library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;


entity Testbench is
end entity;
architecture Behave of Testbench is
component datapath is
	port(clk,reset: in std_logic
	);
end component datapath;

 signal Reset,clk : std_logic := '0';
 signal r0: std_logic_vector(7 downto 0);

  function to_std_logic(x: bit) return std_logic is
      variable ret_val: std_logic;
  begin  
      if (x = '1') then
        ret_val := '1';
      else 
        ret_val := '0';
      end if;
      return(ret_val);
  end to_std_logic;

  function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin  
      ret_val := lx;
      return(ret_val);
  end to_string;

begin
  process 
    variable err_flag : boolean := false;
    File INFILE: text open read_mode is "TRACEFILE.txt";
    FILE OUTFILE: text  open write_mode is "OUTPUTS.txt";

    ---------------------------------------------------
    -- edit the next two lines to customize
    variable clk_input: bit;
	 variable Reset_input: bit;
    ----------------------------------------------------
    variable INPUT_LINE: Line;
    variable OUTPUT_LINE: Line;
    variable LINE_COUNT: integer := 0;
    
  begin
   
    while not endfile(INFILE) loop 
          LINE_COUNT := LINE_COUNT + 1;
	
	  readLine (INFILE, INPUT_LINE);
          read (INPUT_LINE, clk_input);
			 read (INPUT_LINE, reset_input);
			 
          --------------------------------------
          -- from input-vector to DUT inputs
			clk <= to_std_logic(clk_input);
			Reset <= to_std_logic(reset_input);
          --------------------------------------


	  -- let circuit respond.
          wait for 5 ns;

          --------------------------------------
	  -- check outputs.
--	  if (X /= to_std_logic_vector(output_vector)) then
--             write(OUTPUT_LINE,to_string("ERROR: in output, line "));
--             write(OUTPUT_LINE, LINE_COUNT);
--             writeline(OUTFILE, OUTPUT_LINE);
--             err_flag := true;
--          end if;
          --------------------------------------
    end loop;

    assert (err_flag) report "SUCCESS, all tests passed." severity note;
    assert (not err_flag) report "FAILURE, some tests failed." severity error;

    wait;
  end process;

  dut: datapath
     port map(clk => clk,
              Reset => Reset
			  );

end Behave;
