
library ieee;
library work;
Library floatfixlib;

use ieee.float_pkg.all;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.my_package.all;


entity unit2 is
port(reset: in std_logic;
clk: in std_logic;
input_unit2: in float(8 downto -23);
output_unit2: out float(8 downto -23));
end unit2;

architecture control2 of unit2 is 

function read_enable2(empty_func: in std_logic) return std_logic is
variable x: std_logic;
begin
x := not empty_func;
return x;
end read_enable2;

function read_enable3(empty_func: in std_logic) return std_logic is
variable x: std_logic;
begin
x := not empty_func;
return x;
end read_enable3;

type state2_type is (a2,b2,c2,d2,e2);
signal state2 : state2_type;
signal o_af2,o_af3, disablewrite3, disablewrite4, o_ae3,o_ae4, empty_input3, empty_input4 : std_logic;
signal output_buf3 , output_buf4 : float(8 downto -23);
signal input_buffer: float(8 downto -23);
signal dout3: float(8 downto -23);
signal dout , dout2 : float(8 downto -23) := (others=>'0');
signal counter_psau,counter_exe: integer ;
signal counter_state_e2 : integer :=0;
signal rd_array,wr_array: integer range 0 to network_size;
signal wr_address,rd_address: std_logic_vector(ram_size-1 downto 0);
signal we1, en1 : std_logic;
signal rst2 : std_logic := '0' ;


begin
input_buffer <= input_unit2;
rd_address <= std_logic_vector(to_unsigned(rd_array,ram_size));
wr_address <= std_logic_vector(to_unsigned(wr_array,ram_size));
fifo3_comp: module_fifo3_regs_with_flags port map ( i_rst_sync => reset,						
						i_clk =>clk,
						i_wr_en => '1',
						i_wr_data => input_buffer,
						o_af => o_af2,
						o_full => disablewrite3,
						i_rd_en =>read_enable2(empty_input3),
						o_rd_data => output_buf3,
						o_ae => o_ae3,
						o_empty => empty_input3);

ram2_a: rams_02 generic map(ram_size => ram_size)
			port map(clk => clk,
			we => we1, 
			en => en1, 
			rst => rst2,
			wr_addr => wr_address,
			rd_addr => rd_address,
			di => dout2,
			do => dout);
dout2 <= dout + output_buf3 ;


--not the last of tile_size , the last of the network
fifo4_comp: module_fifo4_regs_with_flags port map ( i_rst_sync => reset,						
						i_clk =>clk,
						i_wr_en => '1',
						i_wr_data => dout3,
						o_af => o_af3,
						o_full => disablewrite4,
						i_rd_en =>read_enable3(empty_input4),
						o_rd_data => output_buf4,
						o_ae => o_ae4,
						o_empty => empty_input4);

process(clk)
begin
	if reset='1' then 
		output_unit2 <=(others=>'0'); 
		en1 <= '0' ;
		we1 <= '0' ;
		counter_psau <= 0;
		state2<= a2;
		counter_exe<= 0;
	elsif rising_edge(clk) then	
		case state2 is
			when a2 =>
				if counter_psau >= 4 then
					state2 <= b2;
					we1 <= '1';
					en1 <= '1';
					
				else
					counter_psau <= counter_psau +1;
					state2 <= a2;
				end if;
			when b2 =>
				--/
				counter_state_e2 <= 0;
				rst2 <= '0';
				--\
				if rd_array>=1 then
					state2 <= c2;
					wr_array<= wr_array+ 1 ;
					
				else
					state2 <= b2;
					
				end if;
				if counter_exe = number_of_iterations -1 then 
					dout3 <= dout2;
				end if;

				rd_array <= rd_array +1;
			when c2 =>
				wr_array<= wr_array+ 1 ;
				rd_array <= rd_array +1 ;
				if rd_array = network_size -1 then 
					rd_array <= 0;
					counter_exe<= counter_exe+ 1 ;
					state2 <= d2;
				else 
					state2<= c2;
				end if;
				if counter_exe = number_of_iterations -1 then 
					dout3 <= dout2;
				
				end if;
			when d2 =>
		
				if counter_exe =  number_of_iterations then 
					dout3<= dout2 ;
					--rd_array <= rd_array +1 ;
					rd_array <= 0;
					state2 <= e2;
					--/
					rst2 <= '1' ; 
					--\
				else 
					rd_array <= rd_array +1 ;
					wr_array <= 0;
					state2 <= c2;
				end if;

				
			when e2 =>
				--/
				counter_state_e2 <= counter_state_e2 + 1;		
				if counter_state_e2 = (number_of_iterations-1)*network_size+9  then 

					state2 <= b2;
					rd_array <= 0;
					wr_array <= 0;
					counter_exe <= 0;
				
				else 
				--/
					state2 <= e2;
				end if;	
		end case;		

		
		output_unit2 <= output_buf4;
	end if;
end process;

		


end control2;