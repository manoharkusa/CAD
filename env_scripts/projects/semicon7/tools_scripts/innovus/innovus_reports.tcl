##Common report to all stages
set report_dir ./reports
##############################################################################
report_area -out_file $report_dir/area.summary.rpt -min_count 1000
report_preserves -dont_touch > $report_dir/report_preserve_objects.rpt
report_netlist_statistics > $report_dir/netlist_statistics.rpt
check_place > $report_dir/check_place.rpt
report_congestion -hotspot > ./reports/report_congestion.rpt 
##############################################################################
# STEP report_timing_late_innovus
##############################################################################
#- Update the timer for setup and write reports

time_design -expanded_views -report_only -report_dir $report_dir -report_prefix $stage

#- Reports that describe timing health
report_timing_summary -checks {setup drv} > $report_dir/setup.analysis_summary.rpt
report_timing_summary -checks {setup drv} -expand_views > $report_dir/setup.view_summary.rpt
report_timing_summary -checks {setup drv} -expand_views -expand_clocks launch_capture  > $report_dir/report_timing_summary.setup.rpt
report_constraint -late -all_violators -drv_violation_type {max_capacitance max_transition max_fanout} > $report_dir/report_constraint.all_violators.rpt

#- Reports that show detailed timing with Graph based analysis
report_timing -late -max_paths 1   -nworst 1 -path_type full_clock -net  > $report_dir/setup.worst_max_path.rpt
report_timing -late -max_paths 500 -nworst 1 -path_type full_clock       > $report_dir/setup.gba_500_paths.rpt

if {[regexp "cts|route" $stage]} {
##############################################################################
# STEP report_timing_early_innovus
##############################################################################
#- Update the timer for hold and write reports
time_design -expanded_views -hold -report_only -report_dir debug -report_prefix $stage

#- Reports that describe timing health
report_timing_summary -checks {hold drv} > $report_dir/hold.analysis_summary.rpt
report_timing_summary -checks {hold drv} -expand_views > $report_dir/hold.view_summary.rpt
report_timing_summary -checks {hold drv} -expand_views -expand_clocks launch_capture  > $report_dir/report_timing_summary.hold.rpt
report_constraint -early -all_violators -drv_violation_type {min_capacitance min_transition min_fanout} > $report_dir/hold.all_violators.rpt

#- Reports that show detailed timing with Graph based analysis
report_timing -early -max_paths 1   -nworst 1 -path_type full_clock -net  > $report_dir/hold.worst_max_path.rpt
report_timing -early -max_paths 500 -nworst 1 -path_type full_clock       > $report_dir/hold.gba_500_paths.rpt
}

if {[regexp "cts|route|chip_finish" $stage]} {
##############################################################################
# STEP report_clock_timing
##############################################################################
#- Reports that check clock implementation
report_clock_timing -type summary > $report_dir/clock.summary.rpt
report_clock_timing -type latency > $report_dir/clock.latency.rpt
report_clock_timing -type skew    > $report_dir/clock.skew.rpt
}

if {[regexp "route|chip_finish" $stage]} {
##############################################################################
# STEP report_route_process
##############################################################################
#- Reports that process rules
check_process_antenna -out_file $report_dir/check_antenna.rpt
check_filler -out_file $report_dir/check_filler.rpt

##############################################################################
# STEP report_route_drc
##############################################################################
#- Reports that check signal routing
check_drc -out_file $report_dir/route.drc.rpt
check_connectivity -out_file $report_dir/route.open.rpt

##############################################################################
# STEP report_route_density
##############################################################################
check_metal_density -report $report_dir/route.metal_density.rpt
check_cut_density -out_file $report_dir/route.cut_density.rpt
}
##To capture memory and runtime metrics
#report_memory > ./reports/session_memory_usage_runtime.rpt
write_metric -format json -file ./reports/${design_name}_${stage}_metric.rpt
report_messages

