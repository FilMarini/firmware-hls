-------------------------------------------------------------------------------
-- Title      : tracklet isolation out track
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tracklet_isolation_out_track.vhd
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
use work.emp_project_decl.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity tracklet_isolation_out_track is
  port (
    clk          : in  std_logic;
    track_packet : in  std_logic;
    track_din    : in  t_trackTB;
    track_dout   : out lword
    );
end;

architecture rtl of tracklet_isolation_out_track is

  constant widthTrack : natural                                        := 1 + widthTBseedType + widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot;
-- sr
  signal sr           : std_logic_vector(PAYLOAD_LATENCY - 1 downto 0) := (others => '0');

-- step 1
  signal din  : t_trackTB := nulll;
  signal dout : lword     := ((others => '0'), '0', '0', '1');

  function conv(s : t_trackTB) return std_logic_vector is
  begin
    return s.valid & s.seedType & s.inv2R & s.phi0 & s.z0 & s.cot;
  end function;

begin

-- step 1
  din        <= track_din;
  track_dout <= dout;

  process(clk) is
  begin
    if rising_edge(clk) then

      -- sr
      sr <= sr(sr'high - 1 downto 0) & track_packet;

      -- step 1
      dout.valid <= '0';
      dout.data  <= (others => '0');
      if sr(sr'high) = '1' then
        dout.valid                         <= '1';
        dout.data(widthTrack - 1 downto 0) <= conv(din);
      end if;

    end if;
  end process;

end;
