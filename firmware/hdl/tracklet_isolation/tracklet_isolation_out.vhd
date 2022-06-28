-------------------------------------------------------------------------------
-- Title      : tracklet isolation out
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tracklet_isolation_out.vhd
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
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tracklet_isolation_out is
  port (
    clk        : in  std_logic;
    out_packet : in  std_logic_vector(limitsChannelTB(numSeedTypes) - 1 downto 0);
    out_din    : in  t_channlesTB(numSeedTypes - 1 downto 0);
    out_dout   : out ldata(4 * N_REGION - 1 downto 0)
    );
end;

architecture rtl of tracklet_isolation_out is

  signal dout : ldata(4 * N_REGION - 1 downto 0) := (others => ((others => '0'), '0', '0', '1'));

  component tracklet_isolation_out_track
    port (
      clk          : in  std_logic;
      track_packet : in  std_logic;
      track_din    : in  t_trackTB;
      track_dout   : out lword
      );
  end component;

  component tracklet_isolation_out_stub
    port (
      clk         : in  std_logic;
      stub_packet : in  std_logic;
      stub_din    : in  t_stubTB;
      stub_dout   : out lword
      );
  end component;

begin

  out_dout <= dout;

  gSeedTypes : for k in 0 to numSeedTypes - 1 generate

    signal track_packet : std_logic := '0';
    signal track_din    : t_trackTB := nulll;
    signal track_dout   : lword     := ((others => '0'), '0', '0', '1');

  begin

    track_packet             <= out_packet(limitsChannelTB(k));
    track_din                <= out_din(k).track;
    dout(limitsChannelTB(k)) <= track_dout;

    cTrack : tracklet_isolation_out_track port map (clk, track_packet, track_din, track_dout);

    gStubs : for j in 0 to numsProjectionLayers(k) - 1 generate

      signal stub_packet : std_logic := '0';
      signal stub_din    : t_stubTB  := nulll;
      signal stub_dout   : lword     := ((others => '0'), '0', '0', '1');

    begin

      stub_packet                      <= out_packet(j + 1);
      stub_din                         <= out_din(k).stubs(j);
      dout(limitsChannelTB(k) + j + 1) <= stub_dout;

      cStub : tracklet_isolation_out_stub port map (clk, stub_packet, stub_din, stub_dout);

    end generate;

  end generate;

end;
