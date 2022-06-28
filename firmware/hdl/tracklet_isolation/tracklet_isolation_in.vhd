-------------------------------------------------------------------------------
-- Title      : tracklet_isolation_in
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tracklet_isolation_in.vhd
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
use work.emp_ttc_decl.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tracklet_isolation_in is
  port (
    clk      : in  std_logic;
    in_ttc   : in  ttc_stuff_array(N_REGION - 1 downto 0);
    in_din   : in  ldata(4 * N_REGION - 1 downto 0);
    in_reset : out t_resets(numPPquads - 1 downto 0);
    in_dout  : out t_stubsDTC
    );
end;

architecture rtl of tracklet_isolation_in is

  component tracklet_isolation_in_quad
    port (
      clk        : in  std_logic;
      quad_link  : in  std_logic;
      quad_ttc   : in  ttc_stuff_t;
      quad_reset : out t_reset
      );
  end component;

  component tracklet_isolation_in_nodePS
    port (
      clk       : in  std_logic;
      node_din  : in  lword;
      node_dout : out t_stubDTCPS
      );
  end component;

  component tracklet_isolation_in_node2S
    port (
      clk       : in  std_logic;
      node_din  : in  lword;
      node_dout : out t_stubDTC2S
      );
  end component;

begin

  g : for k in 0 to numPPquads - 1 generate

    signal quad_link  : std_logic   := '0';
    signal quad_ttc   : ttc_stuff_t := TTC_STUFF_NULL;
    signal quad_reset : t_reset     := nulll;

  begin

    quad_link   <= in_din(4 * k).valid;
    quad_ttc    <= in_ttc(k);
    in_reset(k) <= quad_reset;

    c : tracklet_isolation_in_quad port map (clk, quad_link, quad_ttc, quad_reset);

  end generate;

  gPS : for k in 0 to numTypedStubs(t_stubTypes'pos(LayerPS)) - 1 generate

    signal node_din  : lword       := ((others => '0'), '0', '0', '1');
    signal node_dout : t_stubDTCPS := nulll;

  begin

    node_din      <= in_din(k);
    in_dout.ps(k) <= node_dout;

    cPS : tracklet_isolation_in_nodePS port map (clk, node_din, node_dout);

  end generate;

  g2S : for k in 0 to numTypedStubs(t_stubTypes'pos(Layer2S)) - 1 generate

    signal node_din  : lword       := ((others => '0'), '0', '0', '1');
    signal node_dout : t_stubDTC2S := nulll;

  begin

    node_din      <= in_din(k + numTypedStubs(t_stubTypes'pos(LayerPS)));
    in_dout.ss(k) <= node_dout;

    c2S : tracklet_isolation_in_node2S port map (clk, node_din, node_dout);

  end generate;

end;
