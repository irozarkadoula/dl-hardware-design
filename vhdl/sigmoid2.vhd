library ieee;
library work;
Library floatfixlib;

use ieee.float_pkg.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.my_package.all;
use ieee.math_real.all;
use ieee.math_real.all;

entity sigmoid2 is
port(reset : in std_logic;
clk : in std_logic;
input: in  float(8 downto -23); 
output: out float(8 downto -23));
end sigmoid2;

--implementation is based on "Efficient digital implementation  of the sigmoid function for reprogrammable logic"
architecture arch_sigmoid2 of sigmoid2 is

signal mid_reg: float(8 downto -23);
signal input_buffer2, output_buf4 , output_buf5: float(8 downto -23);
signal o_af2, disablewrite5 ,empty_input4, o_ae4, o_af3 , disablewrite6, empty_input5, o_ae5: std_logic;
signal counter_s : integer ;
signal mid_signal : float(8 downto -23);

type state3_type is (a3,b3);
signal state3 : state3_type;

function read_enable4(empty_func: in std_logic) return std_logic is
variable x: std_logic;
begin
x := not empty_func;
return x;
end read_enable4;

function read_enable5(empty_func: in std_logic) return std_logic is
variable x: std_logic;
begin
x := not empty_func;
return x;
end read_enable5;


begin

input_buffer2 <= input;
fifo5_comp: module_fifo5_regs_with_flags port map ( i_rst_sync => reset,						
						i_clk =>clk,
						i_wr_en => '1',
						i_wr_data => input_buffer2,
						o_af => o_af2,
						o_full => disablewrite5,
						i_rd_en =>read_enable4(empty_input4),
						o_rd_data => output_buf4,
						o_ae => o_ae4,
						o_empty => empty_input4);
fifo6_comp: module_fifo6_regs_with_flags port map ( i_rst_sync => reset,						
						i_clk =>clk,
						i_wr_en => '1',
						i_wr_data => mid_reg,
						o_af => o_af3,
						o_full => disablewrite6,
						i_rd_en =>read_enable5(empty_input5),
						o_rd_data => output_buf5,
						o_ae => o_ae5,
						o_empty => empty_input5);
process(clk)
variable k: float(8 downto -23) := (others => '0');
variable g, h: float(8 downto -23) := (others => '0');
variable d , mid_out: float(8 downto -23) ; 

begin
	
	if clk'event and clk='1' then 
		-- 2.1.4 : g(x) = (1 + x/2) /2 , x>0
		g:= (1+abs(input)/2)/2;  
		h:= "00111111100000000000000000000000"; 
		d:= "00111110100010000010000101101100" ; --0.26588
		for i in 0 to 3 loop
			if g<=h then 
				k:= g;
			else
				k:= h;
			end if; 
   			h:= (g+h-d)/2;
   			g:= k;
   			d:= d/4 ;
		end loop;
	if g<=h then 
		mid_out:= g;
	else
		mid_out:= h;
	end if;
	if input<0 then 
		-- only half of the results have to be computed 
		-- if x<0 the result is 1- y(|x|) 
		mid_out:= 1-mid_out ;
	end if;
	mid_signal  <= mid_out ;
	end if;
	
end process;
mid_reg<= mid_signal;

process(clk)
begin
	if reset='1' then 
		output <= (others => '0');
		state3 <= a3;
		counter_s <=0;
	elsif rising_edge(clk) then 
		case state3 is 
			when a3 =>
				if counter_s <=4 then 
					state3 <= a3;
					counter_s <=counter_s +1 ;
				else 
					state3 <= b3;
				end if;
			when b3 =>
				output <= output_buf5 ;
		end case;
	end if;
end process;		


end arch_sigmoid2;
