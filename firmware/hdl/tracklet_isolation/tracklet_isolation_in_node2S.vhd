-------------------------------------------------------------------------------
-- Title      : tracklet isolation in node 2S
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tracklet_isolation_in_node2S.vhd
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

use work.emp_data_types.all;

use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity tracklet_isolation_in_node2S is
  port (
    clk       : in  std_logic;
    node_din  : in  lword;
    node_dout : out t_stubDTC2S
    );
end;

architecture rtl of tracklet_isolation_in_node2S is

-- step 1
  signal din : lword := ((others => '0'), '0', '0', '1');

-- step 2
  signal dout : t_stubDTC2S := nulll;

  function conv(l : std_logic_vector) return t_stubDTC2S is
    variable s : t_stubDTC2S := nulll;
  begin
    s.bx    := l(LWORD_WIDTH - 2 downto LWORD_WIDTH - 4);
    s.r     := l(widthsIRr(1) + widthsIRz(1) + widthsIRphi(1) + widthsIRbend(1) + widthIRlayer + 1 - 1 downto widthsIRz(1) + widthsIRphi(1) + widthsIRbend(1) + widthIRlayer + 1);
    s.z     := l(widthsIRz(1) + widthsIRphi(1) + widthsIRbend(1) + widthIRlayer + 1 - 1 downto widthsIRphi(1) + widthsIRbend(1) + widthIRlayer + 1);
    s.phi   := l(widthsIRphi(1) + widthsIRbend(1) + widthIRlayer + 1 - 1 downto widthsIRbend(1) + widthIRlayer + 1);
    s.bend  := l(widthsIRbend(1) + widthIRlayer + 1 - 1 downto widthIRlayer + 1);
    s.layer := l(widthIRlayer + 1 - 1 downto 1);
    s.valid := l(0);
    return s;
  end function;

begin

-- step 2
  node_dout <= dout;

  process(clk) is
  begin
    if rising_edge(clk) then

      -- step 1
      din <= node_din;

      -- step 2
      dout <= nulll;
      if din.valid = '1' then
        dout <= conv(din.data);
      elsif node_din.valid = '1' then
        dout.reset <= '1';
      end if;

    end if;
  end process;

end;
