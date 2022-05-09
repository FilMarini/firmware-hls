# Script to generate project for TB
#   vivado_hls -f script_TB.tcl
#   vivado_hls -p trackBuilder
# WARNING: this will wipe out the original project by the same name

# get some information about the executable and environment
source env_hls.tcl

set modules_to_test {
  {FT_L1L2}
}

# create new project (deleting any existing one of same name)
open_project -reset trackBuilder

# source files
set CFLAGS {-std=c++11 -I../TrackletAlgorithm -I../TopFunctions/ReducedConfig}
add_files ../TopFunctions/ReducedConfig/TrackBuilderTop.cc -cflags "$CFLAGS"
add_files -tb ../TestBenches/TrackBuilder_test.cpp -cflags "$CFLAGS"

# data files
add_files -tb ../emData/FT/

foreach i $modules_to_test {
  puts [join [list "======== TESTING " $i " ========"] ""]
  set seed [string range $i 3 6]
  set top_func [join [list "TrackBuilder_" $seed] ""]

  # set macros for this module in CCFLAG environment variable
  set ::env(CCFLAG) [join [list "-D \"SEED_=" $seed "_\" -D \"MODULE_=" $i "_\" -D \"TOP_FUNC_=" $top_func "\""] ""]

  # run C-simulation for each module in modules_to_test
  set_top $top_func
  open_solution [join [list "solution_" $seed] ""]

  # Define FPGA, clock frequency & common HLS settings.
  source settings_hls.tcl
  csim_design -mflags "-j8"
  csynth_design
  cosim_design
}

exit
