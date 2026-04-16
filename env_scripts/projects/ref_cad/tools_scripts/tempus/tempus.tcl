source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl
source $env(ENV_SCRIPTS)/common/yaml_utils.tcl
source $env(ENV_SCRIPTS)/common/pdk_loader.tcl

set design_name $env(BLOCK_NAME)
set twf_gen false
set sdf_gen false

#settings
#========

set_multi_cpu_usage -verbose -local_cpu $env(NUM_CORES)

set input_netlist $env(CHIP_FINISH_DIR)/outputs/${design_name}.vg
if {![file exists $input_netlist]} {
    ui_error "Input netlist not found: $input_netlist"
    exit 1
}

read_mmmc $env(ENV_SCRIPTS)/tempus/signoff_mmmc_config.tcl 

set tech_lef [dict get $metal_cfg tech_lef]
read_physical -lef [concat $tech_lef $CELL_LEFS]
ui_info "Tech LEF  : $tech_lef"
ui_info "Cell LEFs : $CELL_LEFS"


read_netlist $input_netlist 

set_db init_ground_nets [dict get $PROJ_PDK ground_net]
set_db init_power_nets [dict get $PROJ_PDK power_net]

init_design

set_db design_process_node [dict get $PROJ_PDK node]
#set_db design_tech_node 28

set_db timing_analysis_cppr                       both
set_db timing_analysis_type                       ocv
set_db timing_enable_simultaneous_setup_hold_mode true
set_db timing_report_unconstrained_paths true
set_db timing_report_group_based_mode true


set_db delaycal_enable_si true
set_db delaycal_equivalent_waveform_model propagation
set_db si_delay_separate_on_data true
set_db si_delay_delta_annotation_mode lumpedOnNet
set_db si_enable_glitch_propagation true
set_db si_delay_enable_double_clocking_check true
set_db si_glitch_enable_report true
set_db si_glitch_input_threshold  0.3
set_db si_delay_enable_report true

##Read spef — one per unique rc+temp combination, rc_corner name matches mmmc
set read_spef_corners {}
foreach corner_name [dict get $PROJ_PDK signoff_corners] {
    set corner_cfg     [dict get $PROJ_PDK corners $corner_name]
    set rc             [dict get $corner_cfg rc]
    set temp           [dict get $corner_cfg temp]
    set rc_corner_name ${rc}_${temp}
    if {$rc_corner_name ni $read_spef_corners} {
        set spef_file $env(QRC_BASE_DIR)/outputs/${design_name}_${rc}_${temp}.spef.gz
        ui_info "Reading SPEF: rc_corner=$rc_corner_name  file=$spef_file"
        read_spef -rc_corner $rc_corner_name $spef_file
        lappend read_spef_corners $rc_corner_name
    }
}

#check_design -type {timing assign_statements signoff}  > $_REPORTS_PATH/${DESIGN}_check_design_timing.rpt
#check_library > $_REPORTS_PATH/${DESIGN}_check_library.rpt

#source scripts/derate.tcl

##Clock propagation
set_interactive_constraint_mode [get_db constraint_modes -if {.is_setup || .is_hold}]
set_propagated_clock [get_db clocks .sources]
set_interactive_constraint_mode {}

update_timing -full

write_db -sdc ../outputs/${design_name}_session_timing.db

#Check design & check timing
check_netlist -out_file        ../reports/check.netlist.rpt
check_timing                 > ../reports/check.timing.rpt
report_analysis_coverage     > ../reports/check.coverage.rpt
report_annotated_parasitics  > ../reports/check.annotation.rpt

#- Reports that describe cons
report_clocks                > ../reports/report.clocks.rpt
report_case_analysis         > ../reports/report.case_analysis.rpt
report_inactive_arcs         > ../reports/report.inactive_arcs.rpt

#source scripts/path_groups.tcl

###reporting late
report_timing_summary -checks {setup drv} > ../reports/setup.analysis_summary.rpt
report_timing_summary -checks {setup drv} -expand_views > ../reports/setup.view_summary.rpt
report_timing_summary -checks {setup drv} -expand_views -expand_clocks launch_capture  > ../reports/setup.group_summary.rpt
report_constraint -late -all_violators -drv_violation_type {max_capacitance max_transition max_fanout} > ../reports/setup.all_violators.rpt
#set_metric -name timing.setup.type -value gba
#set_metric -name timing.drv.report_file -value [file join [get_db flow_report_name] [get_db flow_report_prefix]setup.all_violators.rpt]

##hold reports
report_timing_summary -checks {hold drv} > ../reports/hold.analysis_summary.rpt
report_timing_summary -checks {hold drv} -expand_views > ../reports/hold.view_summary.rpt
report_timing_summary -checks {hold drv} -expand_views -expand_clocks launch_capture  > ../reports/hold.group_summary.rpt
#set_metric -name timing.hold.type -value gba
report_constraint -early -all_violators -drv_violation_type {min_capacitance min_transition min_fanout} > ../reports/hold.all_violators.rpt

##
report_double_clocking > ../reports/${design_name}_double_clocking.rpt
check_noise -all -verbose > ../reports/${design_name}_check_noise.rpt

update_glitch

report_noise -sort_by noise -failure -out_file ../reports/${design_name}_glitch.rpt
report_double_clocking -out_file ../reports/${design_name}_double_clock.rpt
report_noise -noisy_waveform -out_file ../reports/${design_name}_noisy_waveform.rpt

set_interactive_constraint_modes {func}
set_min_pulse_width 0.1
set_interactive_constraint_modes {}

report_min_pulse_width > ../reports/${design_name}_mpw.rpt

report_timing_summary -checks clock > ../reports/${design_name}_min_pulse_width.rpt


write_db -sdc ../outputs/${design_name}_session_noise.db

if { $twf_gen == true } {
set_db delaycal_enable_si false
write_twf -pin -view func_ff125c_rcb ../outputs/${design_name}_pin_based.twf
write_twf -view func_ff125c_rcb ../outputs/${design_name}_net_based.twf
}

if { $sdf_gen == true } {

reset_timing_derate
set_db delaycal_enable_si false
set_db si_glitch_enable_report false
set_db si_enable_glitch_propagation false
set_db si_delay_enable_double_clocking_check false

 foreach active_view  [get_db analysis_views .name] {
 	write_sdf -view $active_view -recompute_parallel_arcs -interconnect noport -split_recrem -split_setuphold -map_removal_to_hold ../outputs/${design_name}_${active_view}.sdf.gz
 }
}
exec touch tempus_flow_complete
exit
