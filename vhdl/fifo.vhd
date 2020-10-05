
library ieee;
library work;
Library floatfixlib;
use ieee.float_pkg.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.my_package.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--i_wr_data_control='1' when weight data and i_wr_data_control='0' when input data
--o_rd_data_control='1' when weight data and o_wr_data_control='0' when input data
entity module_fifo_regs_with_flags is
  generic (
    g_WIDTH    : natural := 32;
    g_DEPTH    : integer := 16;  --1024
    g_AF_LEVEL : integer := 12;   --896
    g_AE_LEVEL : integer := 4   --128
 );
  port (
    i_rst_sync : in std_logic;
    i_clk      : in std_logic;
 
    -- FIFO Write Interface
    i_wr_en   : in  std_logic ;
    i_wr_data : in array_1;
    o_af      : out std_logic;
    o_full    : out std_logic;
 
    -- FIFO Read Interface
    i_rd_en   : in  std_logic ;
    o_rd_data: out array_1;
    o_ae      : out std_logic;
    o_empty   : out std_logic
    );
end module_fifo_regs_with_flags;
 
architecture rtl of module_fifo_regs_with_flags is
  
  type t_FIFO_DATA is array (0 to g_DEPTH-1) of array_1;
  signal r_FIFO_DATA : t_FIFO_DATA := (others=>(others => (others => '0')));
 
  signal r_WR_INDEX   : integer range 0 to g_DEPTH-1 := 0;
  signal r_RD_INDEX   : integer range 0 to g_DEPTH-1 := 0;
 
  -- # Words in FIFO, has extra range to allow for assert conditions
  signal r_FIFO_COUNT : integer range -1 to g_DEPTH+1 := 0;
 
  signal w_FULL  : std_logic;
  signal w_EMPTY : std_logic;
   
begin
 
  p_CONTROL : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst_sync = '1' then
        r_FIFO_COUNT <= 0;
        r_WR_INDEX   <= 0;
        r_RD_INDEX   <= 0;
      else
 
        -- Keeps track of the total number of words in the FIFO
        if (i_wr_en = '1' and i_rd_en = '0') then
	  r_FIFO_COUNT <= r_FIFO_COUNT + 1;
        elsif (i_wr_en = '0' and i_rd_en = '1') then
          r_FIFO_COUNT <= r_FIFO_COUNT - 1;
        end if;
 
        -- Keeps track of the write index (and controls roll-over)
        if (i_wr_en = '1' and w_FULL = '0') then
          if r_WR_INDEX = g_DEPTH-1 then
            r_WR_INDEX <= 0;
          else
            r_WR_INDEX <= r_WR_INDEX + 1;
          end if;
        end if;
 
        -- Keeps track of the read index (and controls roll-over)        
        if (i_rd_en = '1' and w_EMPTY = '0') then
          if r_RD_INDEX = g_DEPTH-1 then
            r_RD_INDEX <= 0;
          else
            r_RD_INDEX <= r_RD_INDEX + 1;
          end if;
        end if;
 
        -- Registers the input data when there is a write
        if i_wr_en = '1' then
		
          r_FIFO_DATA(r_WR_INDEX) <= i_wr_data;
        end if;
         
      end if;                           -- sync reset
    end if;                             -- rising_edge(i_clk)
  end process p_CONTROL;

  o_rd_data <= r_FIFO_DATA(r_RD_INDEX);
 
  w_FULL  <= '1' when r_FIFO_COUNT = g_DEPTH else '0';
  w_EMPTY <= '1' when r_FIFO_COUNT = 0       else '0';
 
  o_af <= '1' when r_FIFO_COUNT > g_AF_LEVEL else '0';
  o_ae <= '1' when r_FIFO_COUNT < g_AE_LEVEL else '0';
   
  o_full  <= w_FULL;
  o_empty <= w_EMPTY;
   
 
  -----------------------------------------------------------------------------
  -- ASSERTION LOGIC - Not synthesized
  -----------------------------------------------------------------------------
  -- synthesis translate_off
 
  p_ASSERT : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_wr_en = '1' and w_FULL = '1' then
        report "ASSERT FAILURE - MODULE_REGISTER_FIFO: FIFO IS FULL AND BEING WRITTEN " severity failure;
      end if;
 
      if i_rd_en = '1' and w_EMPTY = '1' then
        report "ASSERT FAILURE - MODULE_REGISTER_FIFO: FIFO IS EMPTY AND BEING READ " severity failure;
      end if;
    end if;
  end process p_ASSERT;
 
  -- synthesis translate_on
     
   
end rtl;



