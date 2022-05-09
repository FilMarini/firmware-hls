# Script to generate project for MC
#   vivado_hls -f script_MC.tcl
#   vivado_hls -p match_calc
# WARNING: this will wipe out the original project by the same name

# get some information about the executable and environment
source env_hls.tcl

set modules_to_test {
  {MC_L3PHIB}
  {MC_L4PHIB}
  {MC_L5PHIB}
  {MC_L6PHIB}
}

# create new project (deleting any existing one of same name)
open_project -reset match_calc

# source files
set CFLAGS {-std=c++11 -I../TrackletAlgorithm -I../TopFunctions/ReducedConfig}
add_files ../TopFunctions/ReducedConfig/MatchCalculatorTop.cc -cflags "$CFLAGS"
add_files -tb ../TestBenches/MatchCalculator_test.cpp -cflags "$CFLAGS"

# data files
add_files -tb ../emData/MC/

foreach i $modules_to_test {
  set layerDisk [string range $i 3 4]
  set iMC [string range $i 8 9]
  set top_func [join [list "MatchCalculator_" $layerDisk "PHI" $iMC] ""]
  puts [join [list "======== TESTING " $i " ========"] ""]
  puts [join [list "layerDisk = " $layerDisk] ""]
  puts [join [list "iMC = " $iMC] ""]
  puts [join [list "top function = " $top_func] ""]

   # set macros for this module in CCFLAG environment variable
  set ::env(CCFLAG) [join [list "-D \"MODULE_=" $i "_\" -D \"TOP_FUNC_=" $top_func "\""] ""]

  # run C-simulation for each module in modules_to_test
  set_top $top_func
  open_solution [join [list "solution_" $layerDisk $iMC] ""]

  # Define FPGA, clock frequency & common HLS settings.
  source settings_hls.tcl
  csim_design -mflags "-j8"
  csynth_design
  cosim_design
}

exit
