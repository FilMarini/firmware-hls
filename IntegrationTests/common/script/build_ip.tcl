###################
# Build an HLS IP #
###################

proc build_ip {top_function project_location clock_frequency} {
    global exe
    set cwd [pwd]

    set_top $top_function
    open_solution "solution_$top_function"
    cd $project_location
    source settings_hls.tcl
    create_clock -period $clock_frequency -name default
    cd $cwd
    csynth_design
    export_design -format ip_catalog
}
