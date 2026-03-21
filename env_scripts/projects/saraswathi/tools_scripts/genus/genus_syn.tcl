
source $env(ENV_SCRIPTS)/genus/common_procs.tcl
source $env(ENV_SCRIPTS)/genus/genus_common_settings.tcl

set design_name $env(BLOCK_NAME)
set_db init_lib_search_path { }
set_db init_hdl_search_path { }
set_db library {/proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140_180b/AN61001_20180509/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp40p140_180a/tcbn28hpcplusbwp40p140ssg0p81vm40c.lib /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140hvt_180a/AN61001_20180829/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp40p140hvt_180a/tcbn28hpcplusbwp40p140hvtssg0p81vm40c.lib /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140lvt_180b/AN61001_20180509/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp40p140lvt_180a/tcbn28hpcplusbwp40p140lvtssg0p81vm40c.lib}

set rtl_filelist $env(BLOCK_INPUTS)/${design_name}.rtl.f
puts "MyInfo: Using rtl file list $rtl_filelist"

read_hdl -f $rtl_filelist 
set_db lp_insert_clock_gating true
##User edits can be done in pre_elab.tcl and post_elab.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_elab.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_elab.tcl
}
elaborate $design_name
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
syn_generic
if {[file exists $env(BLOCK_SCRIPTS)/post_syn_generic.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_syn_generic.tcl
}
uniquify $design_name

##Read SDC
set sdc_file $env(BLOCK_INPUTS)/${design_name}.sdc
puts "MyInfo: Using SDC file : $sdc_file"
source -e -v $sdc_file 

check_timing_intent > ../reports/check_timing.rpt
check_design  -all > ../reports/check_design.rpt
##User edits can be done in pre_syn_map.tcl and post_syn_map.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_syn_map.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_syn_map.tcl
}
syn_map
if {[file exists $env(BLOCK_SCRIPTS)/post_syn_map.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_syn_map.tcl
}

check_design -unresolved > ../reports/check_design.unresolved.rpt

##group_paths
group_path -name in2reg -from [get_ports [remove_from_collection [all_inputs] clk]] -to [all_registers -data_pins]
group_path -name reg2reg -from [all_registers -clock_pins] -to [all_registers -data_pins]
group_path -name reg2out -from [all_registers -clock_pins] -to [all_outputs]
group_path -name in2out -from [get_ports [remove_from_collection [all_inputs] clk]] -to [all_outputs]
##User edits can be done in pre_syn_opt.tcl and post_syn_opt.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_syn_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_syn_opt.tcl
}
syn_opt
if {[file exists $env(BLOCK_SCRIPTS)/post_syn_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_syn_opt.tcl
}
write_hdl > ../outputs/$design_name.v
write_sdc > ../outputs/$design_name.sdc
write_db ../outputs/$design_name.db

check_design -combo_loop > ../reports/check_design.combo.loops.rpt
##reports
 
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
#report_constraint -drv_violation_type {max_capacitance max_transition max_fanout} > ./reports/report_constraint.all_violators.rpt
#report_constraint  -all_violators > ./reports/report_constraint.all_violators.rpt
#
##To capture memory and runtime metrics
report_memory > ../reports/session_memory_usage_runtime.rpt
set runtime [lindex [get_metric flow.realtime.total] 1]
echo "RUNTIME: $runtime" >> ../reports/session_memory_usage_runtime.rpt

report_messages
exit


