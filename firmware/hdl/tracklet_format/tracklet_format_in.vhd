-------------------------------------------------------------------------------
-- Title      : tracklet format in
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tracklet_format_in.vhd
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
use work.hybrid_data_types.all;
use work.tracklet_data_types.all;
use work.tracklet_config.all;
use work.hybrid_config.all;

entity tracklet_format_in is
  port (
    clk      : in  std_logic;
    in_reset : in  t_resets(numPPQuads - 1 downto 0);
    in_din   : in  t_stubsDTC;
    in_dout  : out t_datas(numInputsIR - 1 downto 0)
    );
end;

architecture rtl of tracklet_format_in is

begin

  gPS : for k in in_din.ps'range generate

    signal r : t_reset     := nulll;
    signal s : t_stubDTCPS := nulll;
    signal d : t_data      := nulll;

  begin

    r                 <= in_reset(k / 4);
    s                 <= in_din.ps(k);
    d.reset           <= r.reset;
    d.start           <= r.start;
    d.bx              <= r.bx;
    d.valid           <= '1';
    d.data(r_dataDTC) <= s.r & s.z & s.phi & s.bend & s.layer & s.valid;
    in_dout(k)        <= d;

  end generate;

  g2S : for k in in_din.ss'range generate

    constant l          : natural     := numTypedStubs(t_stubTypes'pos(LayerPS)) + k;
    signal r            : t_reset     := nulll;
    signal s            : t_stubDTC2S := nulll;
    signal reset, start : std_logic   := '0';
    signal d            : t_data      := nulll;

  begin

    r                 <= in_reset(l / 4);
    s                 <= in_din.ss(k);
    d.reset           <= r.reset;
    d.start           <= r.start;
    d.bx              <= r.bx;
    d.valid           <= '1';
    d.data(r_dataDTC) <= s.r & s.z & s.phi & s.bend & s.layer & s.valid;
    in_dout(l)        <= d;

  end generate;

end;

