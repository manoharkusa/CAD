source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl
source $env(ENV_SCRIPTS)/common/yaml_utils.tcl
source $env(ENV_SCRIPTS)/common/pdk_loader.tcl

set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/init
set cur_stage_dir $env(EXP_DIR)/pnr/floorplan

set stage floorplan
ui_stage_start $stage
ui_info "Design: $design_name"
puts "MyInfo: Started $stage on $design_name @ [date]"

##Load init db
ui_status "Loading init_design database"
read_db ${prev_stage_dir}/outputs/init_design.db
ui_info "Database loaded"

##Common settings
source ${tool_scripts}/innovus_common_settings.tcl

###User floorplan script
set user_floorplan_file $env(EXP_DIR)/block_scripts/user_floorplan.tcl
if {[file exists $user_floorplan_file]} {
     puts "MyInfo: Souring floorplan file $user_floorplan_file"
     ui_status "Creating floorplan"
     source -e -v $user_floorplan_file
     ui_info "Floorplan created"
} else {
    puts "MyInfo: No floorplan file exists $user_floorplan_file"
    ui_error "Floorplan file not found: $user_floorplan_file"
    exit
}

source ${tool_scripts}/global_connections.tcl

#- define route_types and/or route_rules
create_route_rule -width_multiplier {M7:M3 2} -spacing_multiplier {M7:M3 2} -name cts_2w2s
create_route_rule -spacing_multiplier {M7:M3 2} -name cts_1w2s

create_route_type -name leaf -route_rule cts_1w2s -top_preferred_layer M5 -bottom_preferred_layer M3
create_route_type -name trunk -route_rule cts_2w2s -top_preferred_layer M7 -bottom_preferred_layer M4
create_route_type -name top  -route_rule cts_2w2s -top_preferred_layer M7 -bottom_preferred_layer M6

#Apply derates
time_design -pre_place -report_dir ${cur_stage_dir}/reports/time_design_${stage}

##add tracks
add_tracks -honor_pitch

##PG script
##User edits can be done in pre_power_plan.tcl and post_power_plan.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_power_plan.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_power_plan.tcl
}

ui_status "Adding power rings and stripes"
source ${tool_scripts}/power_plan.tcl
ui_info "Power plan complete"

if {[file exists $env(BLOCK_SCRIPTS)/post_power_plan.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_power_plan.tcl
}

##routing halos around design boundary to avoid DRC at top level
create_route_halo -design_halo -bottom_layer M1 -top_layer M7 -space 0.2

##PG checks
ui_status "Running power grid checks"
set report_dir ${cur_stage_dir}/reports
check_pg_shorts -out_file $report_dir/shorts.sanity_pg.rpt
check_power_vias -report $report_dir/power_via.sanity_pg.rpt
check_drc -limit 1000000 -out_file $report_dir/check_pg_drc.rpt
check_pin_assignment -out_file $report_dir/PinAssignment.sanity_pg.rpt
check_floorplan -report_density -out_file $report_dir/utilization.sanity_pg.rpt
ui_info "Power grid checks complete"

##physical only
ui_status "Adding endcaps"
set_db add_endcaps_left_edge [dict get $PROJ_PDK endcap_cells right] 
set_db add_endcaps_right_edge [dict get $PROJ_PDK endcap_cells left]
##User edits can be done in pre_add_endcaps.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_add_endcaps.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_add_endcaps.tcl
}
add_endcaps -prefix endcap
ui_info "Endcaps added"

##User edits can be done in pre_add_well_taps.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_add_well_taps.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_add_well_taps.tcl
}

ui_status "Adding well taps"
add_well_taps -cell [dict get $PROJ_PDK tap_cell] -prefix Welltap -cell_interval [dict get $PROJ_PDK tap_distance] -checker_board
ui_info "Well taps added"
check_endcaps > $report_dir/check_endcap.rpt
check_well_taps -max_distance [dict get $PROJ_PDK tap_distance] -cells [dict get $PROJ_PDK tap_cell] > $report_dir/check_welltaps.rpt

##save database
ui_status "Saving database"
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db
ui_info "Database saved"

##FP outputs
ui_status "Generating floorplan outputs"
write_def -floorplan ${cur_stage_dir}/outputs/${design_name}.floorplan.def
write_floorplan ${cur_stage_dir}/outputs/${design_name}.fp
write_io_file ${cur_stage_dir}/outputs/${design_name}.io
ui_info "Floorplan outputs written"

##FP reports
ui_status "Running design and timing checks"
check_design -out_file $report_dir/check.design.tcl -type {timing}
check_timing > $report_dir/checkTiming.init.rpt
time_design -pre_place -report_dir $report_dir
check_floorplan -report_density -out_file $report_dir/utilization.init.rpt

report_area -out_file $report_dir/area.summary.rpt -min_count 1000
report_preserves -dont_touch > $report_dir/report_preserve_objects.rpt

check_drc -limit 0 -out_file $report_dir/check_pg_drc.rpt
check_connectivity -nets {VDD VSS} -ignore_dangling_wires -out_file $report_dir/check_pg_connectivity.rpt
ui_info "Floorplan reports generated"

puts "MyInfo: End of $stage on $design_name @ [date]"
ui_info "Floorplan complete"
ui_stage_end $stage "success"
exec touch ${cur_stage_dir}/work/${stage}_flow_complete
exit
