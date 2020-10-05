
library ieee;
library work;
Library floatfixlib;

use ieee.float_pkg.all;
use ieee.float_pkg.float;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.my_package.all;
use ieee.math_real."ceil";
use ieee.math_real."log2";
use ieee.math_real.all;


--activation function = sigmoid function
--implementation is based on " implementation of a sigmoid activation function for neural network using FPGA" 
entity sigmoid3 is
port(reset : in std_logic;
clk : in std_logic;
input: in  float(8 downto -23); 
output: out float(8 downto -23));
end sigmoid3;

architecture arch_sigmoid3 of sigmoid3 is

-- approximation f(x) = (x/(1 + |x|)  + 1 ) /2
signal mid1, mid2 , constant_reg ,mid_reg,mid_reg2, first_term, second_term, case1 , case2, x_2b, x_abs2: float(8 downto -23);
signal input_buffer2, output_buf4 , output_buf5: float(8 downto -23);
signal o_af2, disablewrite5 ,empty_input4, o_ae4, o_af3 , disablewrite6, empty_input5, o_ae5: std_logic;
signal k : real ;

signal counter_s : integer ;

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
 

mid1 <="00111110100000101000001001000001"; -- 0.2549
mid2 <= "00111101000001111111110010111001"; --0.0032
constant_reg <= "00111111000000000000000000000000" ;  --0.5
--x <= to_real (output_buf4) ;
x_abs2 <= abs(output_buf4);
x_2b <= x_abs2 * x_abs2;
k <= to_real(output_buf4);
first_term <= mid2* x_2b; 
second_term <= mid1*output_buf4;
case1  <= constant_reg + second_term - first_term ;
case2 <= constant_reg + second_term + first_term ;

mid_reg <= case1 when k >= -4.0 and k < 0.0 else
	case2 when k>= 0.0 and k <= 4.0 else
	"00000000000000000000000000000000" when k < -4.0 else
	"00111111100000000000000000000000" ;
		
mid_reg2 <= mid_reg;
fifo6_comp: module_fifo6_regs_with_flags port map ( i_rst_sync => reset,						
						i_clk =>clk,
						i_wr_en => '1',
						i_wr_data => mid_reg2,
						o_af => o_af3,
						o_full => disablewrite6,
						i_rd_en =>read_enable5(empty_input5),
						o_rd_data => output_buf5,
						o_ae => o_ae5,
						o_empty => empty_input5);

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

end arch_sigmoid3;