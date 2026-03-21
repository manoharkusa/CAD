set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(CTS_DIR)
set cur_stage_dir $env(POSTCTS_DIR)


set stage postcts
puts "MyInfo: Started $stage on $design_name @ [date]"

read_db ${prev_stage_dir}/outputs/cts.db

##Common settings
source ${tool_scripts}/common_settings.tcl

set_interactive_constraint_modes func
set_false_path -from [remove_from_collection [all_inputs] [get_ports clk]] -hold
set_false_path -hold -to [all_outputs]
set_clock_uncertainty -hold 0.02 [get_clocks *]

set_interactive_constraint_modes {}

opt_design -post_cts -hold -report_dir ./reports -report_prefix $stage

source ${tool_scripts}/global_connections.tcl

##save database
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db



#Reports
source ${tool_scripts}/innovus_reports.tcl
exit

