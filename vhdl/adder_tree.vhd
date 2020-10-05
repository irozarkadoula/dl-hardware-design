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
use ieee.math_real.all;
use ieee.math_real.all;
use work.my_package.all;

entity adder_tree is 
generic(depth1: integer);
port(array_input: in array_adder(0 to depth1-1);
acc_output: out float(8 downto -23));
end adder_tree;

architecture adder_arch of adder_tree is




signal stages: integer := integer (ceil(log2(real(depth))));
signal acc: array_adder (0 to depth1/2-1):= (others => (others =>'0'));
signal x: integer :=1;
begin

if_last : if depth1 = 2 generate
acc_output <= array_input(0) + array_input(1);
end generate if_last;

if_generate : if depth1 > 2 generate
	generate_tree: for i in 0 to depth1/2 -1 generate
		acc(i) <= array_input(2*i) + array_input(2*i+1);
	end generate generate_tree;
	tree_dev : entity work.adder_tree 
		generic map(depth1 => depth1/2)
		port map (array_input => acc,
				acc_output => acc_output);

end generate if_generate;



end adder_arch;