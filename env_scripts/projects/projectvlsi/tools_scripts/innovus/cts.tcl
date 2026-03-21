set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/place
set cur_stage_dir $env(EXP_DIR)/pnr/cts


set stage cts 
puts "MyInfo: Started $stage on $design_name @ [date]"

read_db ${prev_stage_dir}/outputs/place.db

#
#set_interactive_constraint_modes func
##Any constraints
#set_interactive_constraint_modes {}


##Common settings
source ${tool_scripts}/innovus_common_settings.tcl

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
##User edits can be done in pre_ccopt.tcl and post_ccopt.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_ccopt.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_ccopt.tcl
}
ccopt_design -report_dir ./reports -report_prefix $stage
if {[file exists $env(BLOCK_SCRIPTS)/post_ccopt.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_ccopt.tcl
}


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


