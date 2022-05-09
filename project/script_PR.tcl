# Script to generate project for PR
#   vivado_hls -f script_PR.tcl
#   vivado_hls -p projrouter
# WARNING: this will wipe out the original project by the same name

# get some information about the executable and environment
source env_hls.tcl

set modules_to_test {
  {PR_L3PHIB}
  {PR_L4PHIB}
  {PR_L5PHIB}
  {PR_L6PHIB}
}

# create new project (deleting any existing one of same name)
open_project -reset projrouter

# source files
set CFLAGS {-std=c++11 -I../TrackletAlgorithm -I../TopFunctions/ReducedConfig}
add_files ../TopFunctions/ReducedConfig/ProjectionRouterTop.cc -cflags "$CFLAGS"
add_files -tb ../TestBenches/ProjectionRouter_test.cpp -cflags "$CFLAGS"

# data files
add_files -tb ../emData/PR/


foreach i $modules_to_test {
  puts [join [list "======== TESTING " $i " ========"] ""]
  set module $i
  set top_func [join [list "ProjectionRouterTop_" [string range $i 3 8]] ""]

  # set macros for this module in CCFLAG environment variable
  set ::env(CCFLAG) [join [list "-D \"MODULE_=" $module "_\" -D \"TOP_FUNC_=" $top_func "\""] ""]

  # run C-simulation for each module in modules_to_test
  set_top $top_func
  open_solution [join [list "solution_" $module] ""]

  # Define FPGA, clock frequency & common HLS settings.
  source settings_hls.tcl
  csim_design -mflags "-j8"
  csynth_design
  cosim_design
}

exit
