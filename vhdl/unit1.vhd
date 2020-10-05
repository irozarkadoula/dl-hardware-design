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

entity unit1 is
port(reset: in std_logic ;
clk: in std_logic;

output_unit1: out float(8 downto -23));

end unit1;

architecture control1 of unit1 is


type state_type is (a,b,c,d,e);
signal state : state_type ;
signal disablewrite, disablewrite2 : std_logic;
signal empty_input, empty_input2: std_logic;
signal output1,output_buf: array_1;
signal output_buf2: float(8 downto -23);
signal input_data: array_1;
signal o_af1, o_ae1, o_af2, o_ae2: std_logic;


signal we1,en1, after_reset: std_logic ;	
signal dout,mid_funcres: array_adder(0 to network_size -1 );
signal dout2 : array_adder( 0 to tile_size -1 );


signal result: array_adder(0 to tile_size-1);
signal address: std_logic_vector(ram_size-1 downto 0);
signal counter2: integer;
signal counter_state_e: integer :=0;
signal counter_unit2 : integer := 0;


signal mid_counter,exe_count, counter_addr: integer;

signal adder_output: float(8 downto -23);

--signal flag : std_logic;



function fifo_data (name :string ; counter_func : integer ) return array_1 is
file file_fifo : text is in name;
variable file_line: line;
variable y : array_ram;
variable x: array_1;

begin 

	for i in array_ram'range loop
		if i<= network_size-1 then 
			readline(file_fifo, file_line);
			hread(file_line, y(i));
			if i>=counter_func*tile_size and i<=(counter_func+1)*tile_size - 1 then
				x(i mod tile_size) := y( i); 
			end if;
		end if;
	end loop;
	
	return x;

end fifo_data;

function full_func(disablewrite1:std_logic) return std_logic is
variable x: std_logic;
begin
x := not disablewrite1;
return x;
end full_func;

function full_func2(disablewrite3: std_logic) return std_logic is
variable x: std_logic;
begin
x := not disablewrite3;
return x;
end full_func2;

function read_enable(empty_func: std_logic) return std_logic is
variable x: std_logic;
begin
x := not empty_func;
return x;
end read_enable;

function read_enable2(empty_func2: std_logic) return std_logic is
variable x: std_logic;
begin
x := not empty_func2;
return x;
end read_enable2;




begin 


address <= std_logic_vector(to_unsigned(counter_addr,ram_size));

generate_ram_write3: for i in 0 to network_size-1 generate

	signal file1 : string(1 to 16);
	file1 <=("ram_data00" & integer'image(i) & "2.txt") when i<10 and counter_unit2=0 else
		("ram_data0" & integer'image(i) & "2.txt") when i<100 and counter_unit2=0  else
		("ram_data" & integer'image(i) & "2.txt");
--		("ram_data00" & integer'image(i) & "3.txt") when i<10 and counter_unit2=1 else
--		("ram_data0" & integer'image(i) & "3.txt") when i<100 and counter_unit2=1  else
--		("ram_data" & integer'image(i) & "3.txt") when  counter_unit2=1 else 
--		("ram_data00" & integer'image(i) & "4.txt") when i<10 and counter_unit2=2 else
--		("ram_data0" & integer'image(i) & "4.txt") when i<100 and counter_unit2=2  else
--		("ram_data" & integer'image(i) & "4.txt");

ram : rams_01 generic map(ram_size => ram_size)
			port map(clk => clk,
			we => we1, 
			en => en1,
			addr => address,
			file_ram => file1,
			di => (others=>'0'),
			do => dout(i));

end generate generate_ram_write3;

dout2 <= dout(counter2*tile_size to (counter2+1)*tile_size -1);
add_mull: for j in 0 to tile_size-1 generate
	mull2 :  multiplier port map (a => dout2(j),
				b => output_buf(j),
				c => result(j));
adder_comp: adder_tree generic map(depth1 => tile_size)
			port map(array_input => result,
				acc_output => adder_output);
end generate add_mull;


fifo_comp: module_fifo_regs_with_flags port map ( i_rst_sync => reset,						
						i_clk =>clk,
						i_wr_en => full_func(disablewrite),
						i_wr_data => input_data,
						o_af => o_af1,
						o_full => disablewrite,
						i_rd_en => read_enable(empty_input),
						o_rd_data => output_buf,
						o_ae => o_ae1,
						o_empty => empty_input);

fifo2_comp: module_fifo2_regs_with_flags port map ( i_rst_sync => reset,						
						i_clk =>clk,
						i_wr_en => full_func2(disablewrite2),
						i_wr_data =>adder_output ,
						o_af => o_af2,
						o_full => disablewrite2,
						i_rd_en =>read_enable2(empty_input2),
						o_rd_data => output_buf2,
						o_ae => o_ae2,
						o_empty => empty_input2);

process(clk)
begin
	if reset='1' then 
		output1 <= (others => (others=>'0'));
		en1 <= '0';
		we1 <= '0';
		counter2 <= 0;
		input_data <= (others => (others =>'0'));
		output_unit1 <= (others => '0');
		exe_count <= 0;
		state <= a ;
		after_reset <='1';
		counter_addr <= 0;
		--counter <= 0;
	elsif rising_edge(clk) then	
		--/
		--en1 <= '1';
		--we1 <= '1';
		--\
		case state is 
			when a => 
				en1 <= '1';
				we1 <= '1';
				if after_reset <='1' then 
					state <= b;
					after_reset <= '0';
				else
					state <= a;			
				end if ;
			when b => 
				--/
				counter_state_e <= 0;
				en1 <= '1';
				--\
				if counter_unit2 = 0 then 	
		
					input_data <= fifo_data("input_data.txt" ,exe_count);
				
--				elsif counter_unit2 = 1 then
--					input_data <= fifo_data("input_data3.txt" ,exe_count);
--				elsif counter_unit2 = 2 then
--					input_data <= fifo_data("input_data4.txt" ,exe_count);
				end if;
			
				if counter_addr = network_size -1  then 
					counter_addr <=   0 ;
					state <=d;
				else
					state <= c;
				end if;
				
				
			when c =>
				counter_addr <= counter_addr +1 ;
				if counter_addr = network_size -2 then 
					state <= b;
					exe_count <= exe_count + 1 ;
				else
					state <= c;
				end if;	
			when d => 
				
				if exe_count = number_of_iterations then
					state <= e;
					
				else 
					counter2 <= counter2 +1 ;
					counter_addr <= counter_addr + 1;
					state<=c;
				end if;	
				
			when e =>
				counter_state_e <= counter_state_e + 1;		
				en1 <= '0';
				--2*number_of_iterations*network_size 
				if counter_state_e = (number_of_iterations-1)*network_size+8 then 

					state <= b;
					--
					counter_unit2 <= counter_unit2+ 1 ;
					en1 <= '1';
					exe_count <= 0;
					counter2 <= 0;
				else 
					state <= e;
				end if;	


		end case;
				
				
		output_unit1 <= output_buf2;
		

		
	
	end if;

end process;


		
	
end control1;
