



library ieee;
library work;
Library floatfixlib;

use ieee.float_pkg.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.my_package.all;


entity main is
port(reset: in std_logic ;
clk: in std_logic; 
output_total : out float(8 downto -23));
end main;

architecture arch_main of main is

signal mid_unit12,mid_unit23,output_reg: float(8 downto -23);

begin

tmmu: unit1 port map( reset => reset,
			clk => clk,
			output_unit1 => mid_unit12);
psau: unit2 port map(reset => reset,
			clk => clk,
			input_unit2 => mid_unit12,
			output_unit2 => mid_unit23);

sigmoid_unit : sigmoid2 port map(reset => reset,
				clk => clk,
				input => mid_unit23,
				output => output_reg);
output_total <= output_reg;
end arch_main;