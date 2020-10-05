
library ieee;
library work;
--library ieee_proposed;
Library floatfixlib;
--use ieee_proposed.fixed_float_types.all;
--use ieee_proposed.float_pkg.all;
--use ieee_proposed.math_utility_pkg.all;
--use ieee_proposed.fixed_pkg.all;
use ieee.float_pkg.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.my_package.all;



entity multiplier is 
port(a: in float(8 downto -23);
b: in float(8 downto -23);
c: out float(8 downto -23));
end multiplier;

architecture mult of multiplier is


begin


c <= a * b  ;



end mult;