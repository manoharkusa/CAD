source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl

set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/cts
set cur_stage_dir $env(EXP_DIR)/pnr/postcts

set stage postcts
ui_stage_start $stage
ui_info "Design: $design_name"
puts "MyInfo: Started $stage on $design_name @ [date]"

ui_status "Loading CTS database"
read_db ${prev_stage_dir}/outputs/cts.db
ui_info "Database loaded"

##Common settings
source ${tool_scripts}/innovus_common_settings.tcl

set_interactive_constraint_modes func
set_false_path -from [remove_from_collection [all_inputs] [get_ports clk]] -hold
set_false_path -hold -to [all_outputs]
set_clock_uncertainty -hold 0.02 [get_clocks *]

set_interactive_constraint_modes {}

##User edits can be done in pre_postcts_opt.tcl and post_postcts_opt.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_postcts_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_postcts_opt.tcl
}
ui_status "Running post-CTS hold optimization"
opt_design -post_cts -hold -report_dir ./reports -report_prefix $stage
ui_info "Post-CTS hold optimization complete"
if {[file exists $env(BLOCK_SCRIPTS)/post_postcts_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_postcts_opt.tcl
}

source ${tool_scripts}/global_connections.tcl

##save database
ui_status "Saving database"
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db
ui_info "Database saved"

#Reports
ui_status "Generating post-CTS reports"
source ${tool_scripts}/innovus_reports.tcl
ui_info "Post-CTS complete"
ui_stage_end $stage "success"
exit
