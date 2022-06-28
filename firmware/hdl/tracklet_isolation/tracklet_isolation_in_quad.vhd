-------------------------------------------------------------------------------
-- Title      : tracklet isolation in quad
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tracklet_isolation_in_quad.vhd
-- Author     : 
-- Company    : 
-- Created    : 2022-06-21
-- Last update: 2022-06-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c)
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2022-06-21  1.0              Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.emp_ttc_decl.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;

entity tracklet_isolation_in_quad is
  port (
    clk        : in  std_logic;
    quad_link  : in  std_logic;
    quad_ttc   : in  ttc_stuff_t;
    quad_reset : out t_reset
    );
end;

architecture rtl of tracklet_isolation_in_quad is

  signal link, ready : std_logic                                  := '0';
  signal reset       : t_reset                                    := nulll;
  signal counter     : std_logic_vector(widthFrames - 1 downto 0) := (others => '0');

begin

  quad_reset <= reset;

  process (clk) is
  begin
    if rising_edge(clk) then

      link        <= quad_link;
      reset.reset <= '0';
      counter     <= incr(counter);
      if quad_link = '1' and link = '0' then
        ready    <= '0';
        counter  <= (others => '0');
        reset.bx <= incr(reset.bx);
        if ready = '1' then
          reset.start <= '1';
          reset.bx    <= (others => '0');
        end if;
      end if;
      if reset.start = '1' and quad_link = '0' and uint(counter) = numFrames + 1 - 1 then
        reset.start <= '0';
      end if;
      if uint(quad_ttc.bctr) = 0 and uint(quad_ttc.pctr) = 0 and ready = '0' then
        reset.reset <= '1';
        ready       <= '1';
        reset.start <= '0';
      end if;

    end if;
  end process;

end;

