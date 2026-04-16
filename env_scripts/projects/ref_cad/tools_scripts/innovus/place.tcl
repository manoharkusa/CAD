source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl
source $env(ENV_SCRIPTS)/common/yaml_utils.tcl
source $env(ENV_SCRIPTS)/common/pdk_loader.tcl

set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/floorplan
set cur_stage_dir $env(EXP_DIR)/pnr/place

set stage place
ui_stage_start $stage
ui_info "Design: $design_name"
puts "MyInfo: Started $stage on $design_name @ [date]"

##Load init db
ui_status "Loading floorplan database"
read_db ${prev_stage_dir}/outputs/floorplan.db
ui_info "Database loaded"

##Common settings
ui_info "Apply common settings"
source ${tool_scripts}/innovus_common_settings.tcl

##placeopt
###Disable usage of high drive strength cells
ui_info "Apply dont use for high drive strength cells"
set_dont_use [get_lib_cells {*D32BWP* *D24BWP* *D20BWP* *D18BWP* *D0BWP*}]

set_db place_detail_check_cut_spacing true
set_db place_detail_use_check_drc true

##User edits can be done in pre_place_opt.tcl and post_place_opt.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_place_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_place_opt.tcl
}
ui_status "Running placement optimization"
place_opt_design -report_dir ${cur_stage_dir}/reports/${stage} -report_prefix $stage
ui_info "Placement optimization complete"
if {[file exists $env(BLOCK_SCRIPTS)/post_place_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_place_opt.tcl
}

source ${tool_scripts}/global_connections.tcl

##save database
ui_status "Saving database"
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db
ui_info "Database saved"

#Reports
ui_status "Generating placement reports"
source ${tool_scripts}/innovus_reports.tcl
ui_info "Placement complete"
ui_stage_end $stage "success"
exec touch ${cur_stage_dir}/work/${stage}_flow_complete
exit
