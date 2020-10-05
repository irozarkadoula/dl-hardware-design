
library ieee;
library work;
library floatfixlib;

use ieee.float_pkg.all;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.my_package.all;



entity rams_02 is
generic(ram_size : integer);
port (clk : in std_logic;
		we : in std_logic;
		en : in std_logic;
		rst :in std_logic;
		wr_addr : in std_logic_vector(ram_size-1 downto 0);
		rd_addr : in std_logic_vector(ram_size-1  downto 0);
		di : in float(8 downto -23);
		do : out float(8 downto -23));
end rams_02;

architecture syn2 of rams_02 is
signal RAM: array_ram :=  (others => (others => '0' ));
begin
process (clk)
begin
	if clk'event and clk = '1' then
		if en = '1' then
			if we = '1' then
				-- an i8elw na diabasw apo arxeio 
				RAM(conv_integer(wr_addr)) <= di;
				--RAM<= ram_data(file_ram);
			end if;
			do <= RAM(conv_integer(rd_addr)) ;
			
		end if;
		if rst ='1' then 
			RAM <= (others => (others => '0' ));
		else 
			do <= RAM(conv_integer(rd_addr)) ;
		end if;

	end if;
end process;
end syn2;