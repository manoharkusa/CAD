set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(PLACE_DIR)
set cur_stage_dir $env(CTS_DIR)


set stage cts 
puts "MyInfo: Started $stage on $design_name @ [date]"

read_db ${prev_stage_dir}/outputs/place.db

#
#set_interactive_constraint_modes func
##Any constraints
#set_interactive_constraint_modes {}


##Common settings
source ${tool_scripts}/common_settings.tcl

###add_clock_spec
if {[llength [get_clock_tree_sinks  *]] == 0} {
    create_clock_tree_spec -out_file ./reports/clk_spec.tcl
    source ./reports/clk_spec.tcl
} else {
    puts "INFO: reusing existing clock tree spec"
    puts "        to releoad a new one use 'delete_clock_tree_spec' and 'read_ccopt_config"
}

##build_clock_tree
#set_ccopt_property cell_halo_sites 8
#set_ccopt_property cell_halo_rows 1
ccopt_design -report_dir ./reports -report_prefix $stage


#add_tieoffs
if {[get_db add_tieoffs_cells] ne "" } {
    delete_tieoffs
    set_db add_tieoffs_max_fanout 1
    set_db add_tieoffs_max_distance 5
    add_tieoffs -matching_power_domains true
}

source ${tool_scripts}/global_connections.tcl

##save database
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db

#Reports
source ${tool_scripts}/innovus_reports.tcl

exit


