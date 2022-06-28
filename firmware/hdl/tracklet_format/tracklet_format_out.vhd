-------------------------------------------------------------------------------
-- Title      : tracklet format out
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tracklet_format_out.vhd
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
use work.hybrid_config.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity tracklet_format_out is
  port (
    clk      : in  std_logic;
    out_din  : in  t_datas(numOutputsFT - 1 downto 0);
    out_dout : out t_channlesTB(numSeedTypes - 1 downto 0)
    );
end;

architecture rtl of tracklet_format_out is

  signal dout : t_channlesTB(numSeedTypes - 1 downto 0) := (others => nulll);

begin

  out_dout <= dout;

  process (clk) is
  begin
    if rising_edge(clk) then

      dout(0)             <= nulll;
      dout(0).track.reset <= out_din(0).reset;
      for k in 1 to numOutputsFT - 1 loop
        dout(0).stubs(k - 1).reset <= out_din(0).reset;
      end loop;
      if out_din(0).valid = '1' then
        dout(0).track.valid    <= out_din(0).data(1 + widthTBseedType + widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap - 1);
        dout(0).track.seedtype <= out_din(0).data(widthTBseedType + widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap - 1 downto widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap);
        dout(0).track.inv2R    <= out_din(0).data(widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap - 1 downto widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap);
        dout(0).track.phi0     <= out_din(0).data(widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap - 1 downto widthTBz0 + widthTBcot + widthTrackletLmap);
        dout(0).track.z0       <= out_din(0).data(widthTBz0 + widthTBcot + widthTrackletLmap - 1 downto widthTBcot + widthTrackletLmap);
        dout(0).track.cot      <= out_din(0).data(widthTBcot + widthTrackletLmap - 1 downto widthTrackletLmap);
        for k in 1 to numOutputsFT - 1 loop
          dout(0).stubs(k - 1).valid   <= out_din(k).data(1 + widthTBtrackId + widthTBstubId + widthsTBr(0) + widthsTBphi(0) + widthsTBz(0) - 1);
          dout(0).stubs(k - 1).trackId <= out_din(k).data(widthTBtrackId + widthTBstubId + widthsTBr(0) + widthsTBphi(0) + widthsTBz(0) - 1 downto widthTBstubId + widthsTBr(0) + widthsTBphi(0) + widthsTBz(0));
          dout(0).stubs(k - 1).stubId  <= out_din(k).data(widthTBstubId + widthsTBr(0) + widthsTBphi(0) + widthsTBz(0) - 1 downto widthsTBr(0) + widthsTBphi(0) + widthsTBz(0));
          dout(0).stubs(k - 1).r       <= resize(out_din(k).data(widthsTBr(0) + widthsTBphi(0) + widthsTBz(0) - 1 downto widthsTBphi(0) + widthsTBz(0)), widthTBr);
          dout(0).stubs(k - 1).phi     <= resize(out_din(k).data(widthsTBphi(0) + widthsTBz(0) - 1 downto widthsTBz(0)), widthTBphi);
          dout(0).stubs(k - 1).z       <= resize(out_din(k).data(widthsTBz(0) - 1 downto 0), widthTBz);
        end loop;
      end if;

    end if;
  end process;

end;
