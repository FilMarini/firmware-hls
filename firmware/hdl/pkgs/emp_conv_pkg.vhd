library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_misc.all;
-- emp thomas
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;
use work.emp_conv_pkg.all;
-- emp US
use work.tf_pkg.all;
use work.memUtil_pkg.all

package emp_conv_pkg is

  function TdataToStd (
    tdata_i : t_datas(numInputsIR - 1 downto 0))
    return t_arr_DL_39_DATA;

end package emp_conv_pkg;

package body emp_conv_pkg is

  function TdataToStd (
    tdata_i : t_datas(numInputsIR - 1 downto 0))
    return t_arr_DL_39_DATA is
    variable s_arr_DL_39_DATA : t_arr_DL_39_DATA;
  begin  -- function TdataToStd
    s_arr_DL_39_DATA(PS10G_1_A) := t_datas(0).data;
    s_arr_DL_39_DATA(PS10G_2_A) := t_datas(1).data;
    s_arr_DL_39_DATA(PS10G_2_B) := t_datas(2).data;
    s_arr_DL_39_DATA(PS10G_3_A) := t_datas(3).data;
    s_arr_DL_39_DATA(PS10G_3_B) := t_datas(4).data;
    s_arr_DL_39_DATA(PS_1_A)    := t_datas(5).data;
    s_arr_DL_39_DATA(PS_1_B)    := t_datas(6).data;
    s_arr_DL_39_DATA(PS_2_A)    := t_datas(7).data;
    s_arr_DL_39_DATA(PS_2_B)    := t_datas(8).data;
    s_arr_DL_39_DATA(twoS_1_A)  := t_datas(9).data;
    s_arr_DL_39_DATA(twoS_1_B)  := t_datas(10).data;
    s_arr_DL_39_DATA(twoS_2_A)  := t_datas(11).data;
    s_arr_DL_39_DATA(twoS_2_B)  := t_datas(12).data;
    s_arr_DL_39_DATA(twoS_3_A)  := t_datas(13).data;
    s_arr_DL_39_DATA(twoS_4_A)  := t_datas(14).data;
    s_arr_DL_39_DATA(twoS_4_B)  := t_datas(15).data;
    return s_arr_DL_39_DATA;
  end function TdataToStd;

end package body emp_conv_pkg;
