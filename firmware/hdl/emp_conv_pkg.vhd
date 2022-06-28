library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_misc.all;

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
    s_arr_DL_39_DATA(PS10G_1_A) := t_datas(0);
    s_arr_DL_39_DATA(PS10G_2_A) := t_datas(1);
    s_arr_DL_39_DATA(PS10G_2_B) := t_datas(2);
    s_arr_DL_39_DATA(PS10G_3_A) := t_datas(3);
    s_arr_DL_39_DATA(PS10G_3_B) := t_datas(4);
    s_arr_DL_39_DATA(PS_1_A)    := t_datas(5);
    s_arr_DL_39_DATA(PS_1_B)    := t_datas(6);
    s_arr_DL_39_DATA(PS_2_A)    := t_datas(7);
    s_arr_DL_39_DATA(PS_2_B)    := t_datas(8);
    s_arr_DL_39_DATA(twoS_1_A)  := t_datas(9);
    s_arr_DL_39_DATA(twoS_1_B)  := t_datas(10);
    s_arr_DL_39_DATA(twoS_2_A)  := t_datas(11);
    s_arr_DL_39_DATA(twoS_2_B)  := t_datas(12);
    s_arr_DL_39_DATA(twoS_3_A)  := t_datas(13);
    s_arr_DL_39_DATA(twoS_4_A)  := t_datas(14);
    s_arr_DL_39_DATA(twoS_4_B)  := t_datas(15);
    return s_arr_DL_39_DATA;
  end function TdataToStd;

end package body emp_conv_pkg;
