
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

entity rams_01 is
generic(ram_size : integer);
port (clk : in std_logic;
		we : in std_logic;
		en : in std_logic;
		addr : in std_logic_vector(ram_size-1  downto 0);
		file_ram : in string(1 to 16);
		di : in float(8 downto -23);
		do : out float(8 downto -23));
end rams_01;

architecture syn of rams_01 is

signal RAM: array_ram;


 function ram_data (name : in string ) return array_ram is
file file_ram : text ;
variable file_line: line;
variable file_status: file_open_status;
variable y : array_ram;

begin 

file_open(file_status,file_ram,name,read_mode);

	for i in array_ram'range loop
		
			readline(file_ram, file_line);
			hread(file_line, y(i));
		
	end loop;
	return y;
file_close(file_ram);
end ram_data;

begin


process (clk)
begin
	if clk'event and clk = '1' then
		if en = '1' then
			if we = '1' then
				-- an i8elw na parw eisodo , alla twra diabaszw mono apo arxeio
				--RAM(int_addr) <= di;
				RAM<= ram_data(file_ram);
			end if;
			do <= RAM(conv_integer(addr)) ;
			
		end if;
	end if;
end process;
end syn;
