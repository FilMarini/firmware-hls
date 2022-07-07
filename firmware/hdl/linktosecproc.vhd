-------------------------------------------------------------------------------
-- Title      : link to sector processor
-- Project    : 
-------------------------------------------------------------------------------
-- File       : linktosecproc.vhd
-- Author     : Filippo Marini  <filippo.marini@cern.ch>
-- Company    : University of Colorado Boulder
-- Created    : 2022-06-27
-- Last update: 2022-07-05
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
use ieee.numeric_std.all;
use work.emp_data_types.all;
use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

-- emp thomas
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;
use work.emp_conv_pkg.all;
-- emp US
use work.tf_pkg.all;
use work.memUtil_pkg.all;

entity linktosecproc is
  port (
    clk_i                : in  std_logic;
    ttc_i                : in  ttc_stuff_array(N_REGION - 1 downto 0);
    din_i                : in  ldata(4 * N_REGION - 1 downto 0);
    ir_start_o           : out std_logic;
    bx_o                 : out std_logic_vector(2 downto 0);
    DL_39_link_AV_dout   : out t_arr_DL_39_DATA;
    DL_39_link_empty_neg : out t_arr_DL_39_1b;
    DL_39_link_read      : in  t_arr_DL_39_1b
    );
end entity linktosecproc;

architecture rtl of linktosecproc is

  signal s_tracklet_reset : t_resets(numPPquads - 1 downto 0);
  signal s_tracklet_isol  : t_stubsDTC;
  signal s_tracklet_data  : t_datas(numInputsIR - 1 downto 0);
  signal s_ir_start       : std_logic;

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
      clk      => clk_i,
      in_reset => s_tracklet_reset,
      in_din   => s_tracklet_isol,
      in_dout  => s_tracklet_data
      );

  DL_39_link_AV_DOUT(PS10G_1_A) <= s_tracklet_data(0).data(r_dataDTC);
  DL_39_link_AV_DOUT(PS10G_2_A) <= s_tracklet_data(1).data(r_dataDTC);
  DL_39_link_AV_DOUT(PS10G_2_B) <= s_tracklet_data(2).data(r_dataDTC);
  DL_39_link_AV_DOUT(PS10G_3_A) <= s_tracklet_data(3).data(r_dataDTC);
  DL_39_link_AV_DOUT(PS10G_3_B) <= s_tracklet_data(4).data(r_dataDTC);
  DL_39_link_AV_DOUT(PS_1_A)    <= s_tracklet_data(5).data(r_dataDTC);
  DL_39_link_AV_DOUT(PS_2_A)    <= s_tracklet_data(7).data(r_dataDTC);
  DL_39_link_AV_DOUT(PS_2_B)    <= s_tracklet_data(8).data(r_dataDTC);
  DL_39_link_AV_DOUT(twoS_1_A)  <= s_tracklet_data(9).data(r_dataDTC);
  DL_39_link_AV_DOUT(twoS_1_B)  <= s_tracklet_data(10).data(r_dataDTC);
  DL_39_link_AV_DOUT(twoS_2_A)  <= s_tracklet_data(11).data(r_dataDTC);
  DL_39_link_AV_DOUT(twoS_2_B)  <= s_tracklet_data(12).data(r_dataDTC);
  DL_39_link_AV_DOUT(twoS_3_A)  <= s_tracklet_data(13).data(r_dataDTC);
  DL_39_link_AV_DOUT(twoS_4_A)  <= s_tracklet_data(15).data(r_dataDTC);
  DL_39_link_AV_DOUT(twoS_4_B)  <= s_tracklet_data(16).data(r_dataDTC);

  s_ir_start <= s_tracklet_data(0).start;
  ir_start_o <= s_ir_start;

  p_bx_count : process (clk_i) is
    variable v_bx         : integer;
    variable v_word_count : natural := 1;
  begin  -- process p_bx_count
    if rising_edge(clk_i) then          -- rising clock edge
      if s_ir_start = '1' then
        if v_word_count < MAX_ENTRIES then
          v_word_count := v_word_count + 1;
        else
          v_word_count := 1;
          v_bx         := v_bx + 1;
        end if;
      end if;
      bx_o <= std_logic_vector(to_unsigned(v_bx, bx_o'length));
    end if;
  end process p_bx_count;

end architecture rtl;
