source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl
source $env(ENV_SCRIPTS)/common/yaml_utils.tcl
source $env(ENV_SCRIPTS)/common/pdk_loader.tcl

set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/place
set cur_stage_dir $env(EXP_DIR)/pnr/cts

set stage cts
ui_stage_start $stage
ui_info "Design: $design_name"
puts "MyInfo: Started $stage on $design_name @ [date]"

ui_status "Loading placement database"
read_db ${prev_stage_dir}/outputs/place.db
ui_info "Database loaded"

##Common settings
source ${tool_scripts}/innovus_common_settings.tcl

###add_clock_spec
ui_status "Setting up clock tree specification"
if {[llength [get_clock_tree_sinks  *]] == 0} {
    create_clock_tree_spec -out_file ./reports/clk_spec.tcl
    source ./reports/clk_spec.tcl
    ui_info "Clock tree spec created"
} else {
    puts "INFO: reusing existing clock tree spec"
    puts "        to releoad a new one use 'delete_clock_tree_spec' and 'read_ccopt_config"
    ui_info "Reusing existing clock tree spec"
}

##build_clock_tree
##User edits can be done in pre_ccopt.tcl and post_ccopt.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_ccopt.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_ccopt.tcl
}
ui_status "Building clock tree"
ccopt_design -report_dir ./reports -report_prefix $stage
ui_info "Clock tree synthesis complete"
if {[file exists $env(BLOCK_SCRIPTS)/post_ccopt.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_ccopt.tcl
}

#add_tieoffs
if {[get_db add_tieoffs_cells] ne "" } {
    ui_status "Adding tieoff cells"
    delete_tieoffs
    set_db add_tieoffs_max_fanout 1
    set_db add_tieoffs_max_distance 5
    add_tieoffs -matching_power_domains true
    ui_info "Tieoff cells added"
}

source ${tool_scripts}/global_connections.tcl

##save database
ui_status "Saving database"
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db
ui_info "Database saved"

#Reports
ui_status "Generating CTS reports"
source ${tool_scripts}/innovus_reports.tcl
ui_info "CTS complete"
ui_stage_end $stage "success"
exec touch ${cur_stage_dir}/work/${stage}_flow_complete
exit
