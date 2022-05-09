# Script to generate project for ME
#   vivado_hls -f script_ME.tcl
#   vivado_hls -p matchengine
# WARNING: this will wipe out the original project by the same name

# get some information about the executable and environment
source env_hls.tcl

# the set of modules to test
set modules_to_test {
  {ME_L3PHIB10}
  {ME_L3PHIB11}
  {ME_L3PHIB12}
  {ME_L3PHIB13}
  {ME_L3PHIB14}
  {ME_L3PHIB15}
  {ME_L3PHIB16}
  {ME_L3PHIB9}
  {ME_L4PHIB10}
  {ME_L4PHIB11}
  {ME_L4PHIB12}
  {ME_L4PHIB13}
  {ME_L4PHIB14}
  {ME_L4PHIB15}
  {ME_L4PHIB16}
  {ME_L4PHIB9}
  {ME_L5PHIB10}
  {ME_L5PHIB11}
  {ME_L5PHIB12}
  {ME_L5PHIB13}
  {ME_L5PHIB14}
  {ME_L5PHIB15}
  {ME_L5PHIB16}
  {ME_L5PHIB9}
  {ME_L6PHIB10}
  {ME_L6PHIB11}
  {ME_L6PHIB12}
  {ME_L6PHIB13}
  {ME_L6PHIB14}
  {ME_L6PHIB15}
  {ME_L6PHIB16}
  {ME_L6PHIB9}
}

# create new project (deleting any existing one of same name)
open_project -reset matchengine

# source files
# Optional Flags: -DDEBUG
set CFLAGS {-std=c++11 -I../TrackletAlgorithm -I../TopFunctions/ReducedConfig}
set_top MatchEngineTop
add_files ../TopFunctions/ReducedConfig/MatchEngineTop.cc -cflags "$CFLAGS"
add_files -tb ../TestBenches/MatchEngine_test.cpp -cflags "$CFLAGS"

# data files
add_files -tb ../emData/ME/

foreach i $modules_to_test {
  # Pick out  the layer/disk type and number (i.e. L3)
  set layerDisk [string range $i 3 4]
  # Pick out the phi sector (i.e. C20)
  set iME [string range $i 8 11]
  # Convert from the module name indexing (1-based) to the enum index (0-based)
  if {[string first "L" $layerDisk] != -1} {
    set kLayerDisk [expr {[string range $i 4 4] - 1}]
  } else {
    set kLayerDisk [expr {[string range $i 4 4] + 5}]
  }
  set topfunction [join [list "MatchEngineTop_" $layerDisk] ""]
  puts [join [list "======== TESTING " $i " ========"] ""]
  puts [join [list "layerDisk (enum) = " $layerDisk " (" $kLayerDisk ")"] ""]
  puts [join [list "phi sector = " $iME] ""]
  puts [join [list "top function = " $topfunction] ""]

  # set macros for this module in CCFLAG environment variable
  set ::env(CCFLAG) [join [list "-D \"KLAYERDISK=" $kLayerDisk "\" -D \"KMODULE=" $i "_\" -D \"TOPFUNCTION=" $topfunction "\""] ""]

  # run C-simulation for each module in modules_to_test
  set_top $topfunction
  open_solution [join [list "solution_" $layerDisk "PHI" $iME] ""]

  # Define FPGA, clock frequency & common HLS settings.
  source settings_hls.tcl
  csim_design -mflags "-j8"
  csynth_design
  cosim_design -trace_level all -rtl verilog
}

exit
