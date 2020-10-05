

library ieee;
library work;
Library floatfixlib;

use ieee.float_pkg.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.numeric_bit.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use std.textio.all;
use ieee.math_complex.all;
use work.my_package.all;

entity tb is 
end tb;

architecture tb_arch of tb is 
signal reset,clk: std_logic;
signal output : float(8 downto -23);
signal test : real;
signal counter : integer :=0 ;
signal it : integer :=1;



constant clk_period: time :=100 ns;
constant cycles : integer := it*((number_of_iterations)*(network_size) + 12);

begin 
	
uut: entity work.main
	port map(reset => reset,
		clk => clk,
		output_total => output);
test <= to_real(output);

sim: process

begin
	for i in 1 to cycles loop 
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
		--report "test is" & real'image(test);
	end loop;
	wait;	
end process sim;

reset_sim: process
begin 
reset<='1';
wait for 100 ns;
reset<= '0';
wait;
end process reset_sim;


result_process: process
variable time_for_text : time := ((number_of_iterations-1)*network_size+13)*clk_period;

variable line3_write : line;

variable line4_write : line;


variable linehex5_write : line;
variable linereal5_write : line;


--file results :text open write_mode is "results_sim.txt";
--file results_hex : text open write_mode is "results.txt";
file results_hex3: text open write_mode is "input_data3.txt";
file results_hex4: text open write_mode is "input_data4.txt";

file results_hex5: text open write_mode is "results_hex.txt";
file results_real5: text open write_mode is "results_sim.txt";

begin
		
	
	--file_open(status,results,"results.txt",write_mode);
	for i in 1 to it loop
		
			if i = 1 then 
				for j in 1 to network_size  loop
					if j=1 then 
						wait for time_for_text;
					end if;
					
					hwrite(linehex5_write,output);
					writeline(results_hex5, linehex5_write);
					write(linereal5_write,test);
					writeline(results_real5, linereal5_write);
					if j=network_size then 

						counter <= counter+ 1;	
						file_close(results_hex5);	
					end if;
				wait for clk_period;
				end loop;
				
--			elsif i=2 then 
--				
--				for j in 1 to network_size  loop
--					if j=1 then 
--						wait for time_for_text-2*clk_period;
--					end if;
--					
--					hwrite(line4_write,output);
--					writeline(results_hex4, line4_write);
--					if j=network_size then 
--						counter <= counter+ 1;
--						file_close(results_hex4);	
--					end if;
--				wait for clk_period;
--				end loop;
--			else 
--				for j in 1 to network_size  loop
--					if j=1 then 
--						wait for time_for_text-2*clk_period;
--					end if;
--					
--					hwrite(linehex5_write,output);
--					writeline(results_hex5, linehex5_write);
--					write(linereal5_write,test);
--					writeline(results_real5, linereal5_write);
--					if j=network_size then 
--						counter <= counter+ 1;
--					end if;
--				wait for clk_period;
--				end loop;
--				file_close(results_hex5);	
--				file_close(results_real5);	
			
			end if;
			
	
	end loop;
	wait;
end process result_process;



end tb_arch;