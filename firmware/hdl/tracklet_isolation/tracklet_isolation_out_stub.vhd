-------------------------------------------------------------------------------
-- Title      : tracklet isolation out stub
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tracklet_isolation_out_stub.vhd
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

entity tracklet_isolation_out_stub is
  port (
    clk         : in  std_logic;
    stub_packet : in  std_logic;
    stub_din    : in  t_stubTB;
    stub_dout   : out lword
    );
end;

architecture rtl of tracklet_isolation_out_stub is

--constant widthStub: natural := 1 + widthTrackletTrackId + widthTrackletStubId + widthTrackletR + widthTrackletPhi + widthTrackletZ;
  constant widthStub : natural                                        := 1 + widthsTBr(0) + widthsTBphi(0) + widthsTBz(0);
-- sr
-- FIX: This signal used to create output "valid" signal by delaying input
--      one by PAYLOAD_LATENCY. Better to take it from HLS ap_done signal.
  signal sr          : std_logic_vector(PAYLOAD_LATENCY - 1 downto 0) := (others => '0');

-- step 1
  signal din  : t_stubTB := nulll;
  signal dout : lword    := ((others => '0'), '0', '0', '1');

  function conv(s : t_stubTB) return std_logic_vector is
  begin
    --return s.valid & s.trackId & s.stubId & s.r & s.phi & s.z;
    return s.valid & s.r(widthsTBr(0) - 1 downto 0) & s.phi(widthsTBphi(0) - 1 downto 0) & s.z(widthsTBz(0) - 1 downto 0);
  end function;

begin

-- step 1
  din       <= stub_din;
  stub_dout <= dout;

  process(clk) is
  begin
    if rising_edge(clk) then

      -- sr
      sr <= sr(sr'high - 1 downto 0) & stub_packet;

      -- step 1
      dout.valid <= '0';
      dout.data  <= (others => '0');
      if sr(sr'high) = '1' then
        dout.valid                        <= '1';
        dout.data(widthStub - 1 downto 0) <= conv(din);
      end if;

    end if;
  end process;

end;
