# Script to generate project for VMR
#   vivado_hls -f script_VMR.tcl
#   vivado_hls -p vmrouter
# WARNING: this will wipe out the original project by the same name

# get some information about the executable and environment
source env_hls.tcl

# list of modules to test in C-simulation
set modules_to_test {
  {VMR_L1PHID}
  {VMR_L2PHIB}
  {VMR_L3PHIB}
  {VMR_L4PHIB}
  {VMR_L5PHIB}
  {VMR_L6PHIB}
}

# create new project (deleting any existing one of same name)
open_project -reset vmrouter

# source files
set CFLAGS {-std=c++11 -I../TrackletAlgorithm -I../TopFunctions/ReducedConfig}
add_files -tb ../TestBenches/VMRouter_test.cpp -cflags "$CFLAGS"

# data files
add_files -tb ../emData/VMR/

foreach i $modules_to_test {

  puts [join [list "======== TESTING " $i " ========"] ""]

  set region [string range $i 4 10]
  set top_func [join [list "VMRouterTop_" $region] ""]
  set header_file [join [list "\\\"" $top_func ".h\\\""] ""]

  # set macros for this module in CCFLAG environment variable
  set ::env(CCFLAG) [join [list "-D \"TOP_FUNC_=" $top_func "\" -D \"HEADER_FILE_=" $header_file "\""] ""]

  # run C-simulation for each module in modules_to_test
  add_files ../TopFunctions/ReducedConfig/$top_func.cc -cflags "$CFLAGS"
  set_top $top_func
  open_solution [join [list "solution_" $top_func] ""]

  # Define FPGA, clock frequency & common HLS settings.
  source settings_hls.tcl

  # run C-simulation
  csim_design -mflags "-j8"
  csynth_design
  cosim_design
}

exit
