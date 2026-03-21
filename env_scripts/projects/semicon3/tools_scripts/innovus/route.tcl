source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl

set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/postcts
set cur_stage_dir $env(EXP_DIR)/pnr/route

set stage route
ui_stage_start $stage
ui_info "Design: $design_name"
puts "MyInfo: Started $stage on $design_name @ [date]"

ui_status "Loading post-CTS database"
read_db ${prev_stage_dir}/outputs/postcts.db
ui_info "Database loaded"

##Common settings
source ${tool_scripts}/innovus_common_settings.tcl

##############################################################################
# STEP add_fillers
##############################################################################
#- insert filler cells before final routing
if {[get_db add_fillers_cells] ne "" } {
    ui_status "Adding filler cells"
    add_fillers -fill_gap
    check_filler
    ui_info "Filler cells added"
}

##############################################################################
# STEP run_route
##############################################################################
#- perform detail routing and DRC cleanup
##To insert multi cut via
set_db route_design_detail_use_multi_cut_via_effort low
set_db route_design_reserve_space_for_multi_cut true

##User edits can be done in pre_route.tcl and post_route.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_route.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_route.tcl
}
ui_status "Running detail routing"
route_design
ui_info "Detail routing complete"
if {[file exists $env(BLOCK_SCRIPTS)/post_route.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_route.tcl
}

ui_status "Running via optimization"
set_db route_design_detail_post_route_swap_via true
set_db route_design_with_timing_driven false
route_design -via_opt
set_db route_design_with_timing_driven true
ui_info "Via optimization complete"

source ${tool_scripts}/global_connections.tcl

##save database
ui_status "Saving database"
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db
ui_info "Database saved"

##Reports
ui_status "Generating routing reports"
source ${tool_scripts}/innovus_reports.tcl
ui_info "Routing complete"
ui_stage_end $stage "success"
exit
