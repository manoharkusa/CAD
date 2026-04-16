source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl
source $env(ENV_SCRIPTS)/common/yaml_utils.tcl
source $env(ENV_SCRIPTS)/common/pdk_loader.tcl
source $env(ENV_SCRIPTS)/genus/common_procs.tcl
source $env(ENV_SCRIPTS)/genus/genus_common_settings.tcl

set design_name $env(BLOCK_NAME)
ui_stage_start "synthesis"
ui_info "Design: $design_name"

set_db init_lib_search_path { }
set_db init_hdl_search_path { }

ui_status "Loading technology libraries"
set synthesis_view [dict get $PROJ_PDK synthesis_corners]
set pvt_corner [dict get $PROJ_PDK corners $synthesis_view lib_pvt]
set_db library $TIMING_LIBS($pvt_corner) 
ui_info "Technology libraries loaded for $pvt_corner corner"

set rtl_filelist $env(BLOCK_INPUTS)/${design_name}.rtl.f
if {[file exists $rtl_filelist]} {
	ui_info "Using RTL file list $rtl_filelist"
	ui_status "Reading RTL files"
	read_hdl -f $rtl_filelist
	ui_info "RTL files loaded"
} else {
	ui_error "FATAL RTL filelist missing @ $rtl_filelist, filelist is expected in $env(BLOCK_INPUTS) directory"
        exit
}	



set_db lp_insert_clock_gating true
##User edits can be done in pre_elab.tcl and post_elab.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_elab.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_elab.tcl
}
ui_status "Elaborating design: $design_name"
elaborate $design_name
ui_info "Elaboration complete"
if {[file exists $env(BLOCK_SCRIPTS)/post_elab.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_elab.tcl
}

report_qor -levels_of_logic > ../reports/report_qor_after_elaborate.rpt
##To avoid scan flops for functional paths
set_db use_scan_seqs_for_non_dft false

##User edits can be done in pre_syn_generic.tcl and post_syn_generic.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_syn_generic.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_syn_generic.tcl
}
ui_status "Running generic synthesis"
syn_generic
ui_info "Generic synthesis complete"
if {[file exists $env(BLOCK_SCRIPTS)/post_syn_generic.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_syn_generic.tcl
}
ui_status "Uniquifying design"
uniquify $design_name

##Read SDC
set sdc_file $env(BLOCK_INPUTS)/${design_name}.sdc
if {[file exists $sdc_file]} {
	ui_info "Using SDC file : $sdc_file"
	ui_status "Reading SDC constraints"
	source -e -v $sdc_file
	ui_info "SDC constraints loaded"
} else {
	ui_error "FATAL no sdc file @ $sdc_file"
	exit
}

ui_status "Running timing and design checks"
check_timing_intent > ../reports/check_timing.rpt
check_design  -all > ../reports/check_design.rpt
ui_info "Design checks complete"

##User edits can be done in pre_syn_map.tcl and post_syn_map.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_syn_map.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_syn_map.tcl
}
ui_status "Running technology mapping"
syn_map
ui_info "Technology mapping complete"
if {[file exists $env(BLOCK_SCRIPTS)/post_syn_map.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_syn_map.tcl
}

check_design -unresolved > ../reports/check_design.unresolved.rpt

##Project default path groups
source $env(ENV_SCRIPTS)/common/path_groups.default.tcl

##User path groups
if {[file exists $env(BLOCK_SCRIPTS)/path_groups.block.tcl]} {
    source $env(BLOCK_SCRIPTS)/path_groups.block.tcl
}

##User edits can be done in pre_syn_opt.tcl and post_syn_opt.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_syn_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_syn_opt.tcl
}
ui_status "Running synthesis optimization"
syn_opt
ui_info "Synthesis optimization complete"
if {[file exists $env(BLOCK_SCRIPTS)/post_syn_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_syn_opt.tcl
}

ui_status "Writing output netlist"
write_hdl > ../outputs/$design_name.v
ui_status "Writing output SDC"
write_sdc > ../outputs/$design_name.sdc
ui_status "Writing synthesis database"
write_db ../outputs/$design_name.db
ui_info "Output files written"

check_design -combo_loop > ../reports/check_design.combo.loops.rpt

##reports
ui_status "Generating synthesis reports"
generate_high_drive_cell_report "../reports"
report_qor -levels_of_logic > ../reports/report_qor.rpt
report_timing -max_paths 100 > ../reports/timing-max.rpt
report_gates > ../reports/report_gates.rpt
report_area > ../reports/report_area.rpt
report_timing_summary -checks {setup drv} > ../reports/timing_summary.rpt
report_constraint -all_violators -drv_violation_type max_capacitance > ../reports/report.constraint.max_cap.rpt
report_constraint -all_violators -drv_violation_type max_transition > ../reports/report.constraint.max_tran.rpt
report_constraint -all_violators -drv_violation_type max_fanout > ../reports/report.constraint.max_fanout.rpt
report_constraint -check_type pulse_width > ../reports/min_period.rpt
report_clock_gating > ../reports/clock_gating.rpt
ui_info "Synthesis reports generated"

##To capture memory and runtime metrics
report_memory > ../reports/session_memory_usage_runtime.rpt
set runtime [lindex [get_metric flow.realtime.total] 1]
echo "RUNTIME: $runtime" >> ../reports/session_memory_usage_runtime.rpt

report_messages
ui_info "Synthesis complete"
ui_stage_end "synthesis" "success"
exec touch genus_flow_complete
exit
