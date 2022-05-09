# Script to generate project for TE
#   vivado_hls -f script_TE.tcl
#   vivado_hls -p trackletEngine
# WARNING: this will wipe out the original project by the same name

# get some information about the executable and environment
source env_hls.tcl

set modules_to_test {
  {TE_L1PHID14_L2PHIB15}
  {TE_L1PHID14_L2PHIB16}
  {TE_L1PHID15_L2PHIB13}
  {TE_L1PHID15_L2PHIB14}
  {TE_L1PHID15_L2PHIB15}
  {TE_L1PHID15_L2PHIB16}
  {TE_L1PHID16_L2PHIB14}
  {TE_L1PHID16_L2PHIB15}
  {TE_L1PHID16_L2PHIB16}
}

# create new project (deleting any existing one of same name)
open_project -reset trackletEngine

# source files
set CFLAGS {-std=c++11 -I../TrackletAlgorithm -I../TopFunctions/ReducedConfig}
add_files ../TopFunctions/ReducedConfig/TrackletEngineTop.cc -cflags "$CFLAGS"
add_files -tb ../TestBenches/TrackletEngine_test.cpp -cflags "$CFLAGS"

# data files
add_files -tb ../emData/TE/tables/
add_files -tb ../emData/TE/

foreach i $modules_to_test {
  puts [join [list "======== TESTING " $i " ========"] ""]
  set innerLayer [string range $i 3 4]
  set outerLayerIndex [string first "_" $i 5]
  set outerLayer [string range $i [expr $outerLayerIndex + 1] [expr $outerLayerIndex + 2]]
  set seed [join [list $innerLayer $outerLayer] ""]
  set innerTable [join [list "../emData/TE/tables/" $i "_stubptinnercut.tab"] ""]
  set outerTable [join [list "../emData/TE/tables/" $i "_stubptoutercut.tab"] ""]

  if { $seed == "L1L2" } {
    set top_func "TrackletEngine_PS_PS"
  } elseif { $seed == "L2L3" } {
    set top_func "TrackletEngine_PS_PS"
  } elseif { $seed == "L3L4" } {
    set top_func "TrackletEngine_PS_2S"
  } elseif { $seed == "L5L6" } {
    set top_func "TrackletEngine_2S_2S"
  }

  # set macros for this module in CCFLAG environment variable
  set ::env(CCFLAG) [join [list "-D \"SEED_=" $seed "_\" -D \"MODULE_=" $i "_\" -D \"TOP_FUNC_=" $top_func "\" -D \"INNER_TABLE_=\\\"" $innerTable "\\\"\" -D \"OUTER_TABLE_=\\\"" $outerTable "\\\"\""] ""]

  # run C-simulation for each module in modules_to_test
  set_top $top_func
  open_solution [join [list "solution_" $i] ""]

  # Define FPGA, clock frequency & common HLS settings.
  source settings_hls.tcl
  csim_design -mflags "-j8"
  csynth_design
  cosim_design
}

exit
