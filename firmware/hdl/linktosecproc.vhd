-------------------------------------------------------------------------------
-- Title      : link to sector processor
-- Project    : 
-------------------------------------------------------------------------------
-- File       : linktosecproc.vhd
-- Author     : Filippo Marini  <filippo.marini@cern.ch>
-- Company    : University of Colorado Boulder
-- Created    : 2022-06-27
-- Last update: 2022-06-27
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2022 University of Colorado Boulder
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2022-06-27  1.0      fmarini Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

entity linktosecproc is
  port (
    clk_i                : in  std_logic;
    ttc_i                : in  ttc_stuff_array(N_REGION - 1 downto 0);
    din_i                : in  ldata(4 * N_REGION - 1 downto 0);
    DL_39_link_AV_dout   : out t_arr_DL_39_DATA;
    DL_39_link_empty_neg : out t_arr_DL_39_1b;
    DL_39_link_read      : in  t_arr_DL_39_1b
    );
end entity linktosecproc;

architecture rtl of linktosecproc is

  signal s_tracklet_reset : t_resets(numPPquads - 1 downto 0);
  signal s_tracklet_isol  : t_stubsDTC;
  signal s_tracklet_data  : t_datas(numInputsIR - 1 downto 0);

begin  -- architecture rtl

  tracklet_isolation_in_1 : entity work.tracklet_isolation_in
    port map (
      clk      => clk_i,
      in_ttc   => ttc_i,
      in_din   => din_i,
      in_reset => s_tracklet_reset,
      in_dout  => s_tracklet_isol
      );

  tracklet_format_in_1 : entity work.tracklet_format_in
    port map (
      clk      => clk_p,
      in_reset => s_tracklet_reset,
      in_din   => s_tracklet_isol,
      in_dout  => s_tracklet_data
      );

  DL_39_link_AV_dout <= TdataToStd(s_tracklet_data);

end architecture rtl;
