source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl
source $env(ENV_SCRIPTS)/common/yaml_utils.tcl
source $env(ENV_SCRIPTS)/common/pdk_loader.tcl

set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/route
set cur_stage_dir $env(EXP_DIR)/pnr/postroute

set stage postroute
ui_stage_start $stage
ui_info "Design: $design_name"
puts "MyInfo: Started $stage on $design_name @ [date]"

ui_status "Loading route database"
read_db ${prev_stage_dir}/outputs/route.db
ui_info "Database loaded"

##Common settings
source ${tool_scripts}/innovus_common_settings.tcl

##############################################################################
# STEP run_opt_postroute
##############################################################################
##User edits can be done in pre_postroute_opt.tcl and post_postroute_opt.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_postroute_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_postroute_opt.tcl
}
ui_status "Running post-route setup/hold optimization"
opt_design -post_route -setup -hold -report_dir ./reports -report_prefix $stage
ui_info "Post-route setup/hold optimization complete"
if {[file exists $env(BLOCK_SCRIPTS)/post_postroute_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_postroute_opt.tcl
}

ui_status "Running final hold optimization"
opt_design -post_route -hold -report_dir ./reports -report_prefix ${stage}.hold
ui_info "Final hold optimization complete"
set_db write_db_save_timing_contraints_always true

source ${tool_scripts}/global_connections.tcl

##save database
ui_status "Saving database"
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db
ui_info "Database saved"

##Reports
ui_status "Generating post-route reports"
source ${tool_scripts}/innovus_reports.tcl
ui_info "Post-route complete"
ui_stage_end $stage "success"
exec touch ${cur_stage_dir}/work/${stage}_flow_complete
exit
