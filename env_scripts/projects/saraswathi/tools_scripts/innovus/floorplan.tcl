set design_name $env(BLOCK_NAME)
set input_netlist $env(SYNTH_DIR)/outputs/${design_name}.v
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/init
set cur_stage_dir $env(EXP_DIR)/pnr/floorplan

set stage floorplan 
puts "MyInfo: Started $stage on $design_name @ [date]"


##Load init db
read_db ${prev_stage_dir}/outputs/init_design.db 


##Common settings
source ${tool_scripts}/innovus_common_settings.tcl
###User floorplan script
set user_floorplan_file $env(EXP_DIR)/block_scripts/user_floorplan.tcl
if {[file exists $user_floorplan_file]} {
     puts "MyInfo: Souring floorplan file $user_floorplan_file"
     source -e -v $user_floorplan_file
} else {
    puts "MyInfo: No floorplan file exists $user_floorplan_file"
    return
}


source ${tool_scripts}/global_connections.tcl


#- define route_types and/or route_rules
create_route_rule -width_multiplier {M7:M3 2} -spacing_multiplier {M7:M3 2} -name cts_2w2s
create_route_rule -spacing_multiplier {M7:M3 2} -name cts_1w2s

create_route_type -name leaf -route_rule cts_1w2s -top_preferred_layer M5 -bottom_preferred_layer M3
create_route_type -name trunk -route_rule cts_2w2s -top_preferred_layer M7 -bottom_preferred_layer M4
create_route_type -name top  -route_rule cts_2w2s -top_preferred_layer M7 -bottom_preferred_layer M6

#create_route_type -name leaf_rt -top_preferred_layer M4 -bottom_preferred_layer M3
#Apply derates
time_design -pre_place -report_dir ${cur_stage_dir}/reports/time_design_${stage}
#source ./scripts/derate.tcl

##add tracks
add_tracks -honor_pitch

##PG script
##User edits can be done in pre_power_plan.tcl and post_power_plan.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_power_plan.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_power_plan.tcl
}

source ${tool_scripts}/power_plan.tcl

if {[file exists $env(BLOCK_SCRIPTS)/post_power_plan.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_power_plan.tcl
}

##routing halos around design boundary to avoid DRC at top level
#puts "INFO: Creating routing halos around design boundary"
create_route_halo -design_halo -bottom_layer M1 -top_layer M7 -space 0.2

##PG checks
set report_dir ${cur_stage_dir}/reports
check_pg_shorts -out_file $report_dir/shorts.sanity_pg.rpt
#check_connectivity -out_file $report_dir/Connectivity.sanity_pg.rpt
check_power_vias -report $report_dir/power_via.sanity_pg.rpt
check_drc -limit 1000000 -out_file $report_dir/check_pg_drc.rpt
check_pin_assignment -out_file $report_dir/PinAssignment.sanity_pg.rpt
check_floorplan -report_density -out_file $report_dir/utilization.sanity_pg.rpt

##physical only
set_db add_endcaps_left_edge BOUNDARY_RIGHTBWP40P140
set_db add_endcaps_right_edge BOUNDARY_LEFTBWP40P140
##User edits can be done in pre_add_endcaps.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_add_endcaps.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_add_endcaps.tcl
}
add_endcaps -prefix endcap

##User edits can be done in pre_add_well_taps.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_add_well_taps.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_add_well_taps.tcl
}

add_well_taps -cell TAPCELLBWP40P140 -prefix Welltap -cell_interval 30 -checker_board
check_endcaps > $report_dir/check_endcap.rpt 
check_well_taps -max_distance 30 -cells TAPCELLBWP40P140 > $report_dir/check_welltaps.rpt


##save database
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db

##FP outputs
puts "INFO: Generating PNR outputs at floorplan stage"
write_def -floorplan ${cur_stage_dir}/outputs/${design_name}.floorplan.def
write_floorplan ${cur_stage_dir}/outputs/${design_name}.fp
write_io_file ${cur_stage_dir}/outputs/${design_name}.io

##FP reports
check_design -out_file $report_dir/check.design.tcl -type {timing}
check_timing > $report_dir/checkTiming.init.rpt
time_design -pre_place -report_dir $report_dir
check_floorplan -report_density -out_file $report_dir/utilization.init.rpt

report_area -out_file $report_dir/area.summary.rpt -min_count 1000
report_preserves -dont_touch > $report_dir/report_preserve_objects.rpt

check_drc -limit 0 -out_file $report_dir/check_pg_drc.rpt
check_connectivity -nets {VDD VSS} -ignore_dangling_wires -out_file $report_dir/check_pg_connectivity.rpt

puts "MyInfo: End of $stage on $design_name @ [date]"

exit


