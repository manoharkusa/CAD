source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl

set design_name $env(BLOCK_NAME)
set input_netlist $env(EXP_DIR)/syn/outputs/${design_name}.v
set tool_scripts $env(ENV_SCRIPTS)/innovus
set cur_stage_dir $env(EXP_DIR)/pnr/init

set stage init_design
ui_stage_start $stage
ui_info "Design: $design_name"
puts "MyInfo: Started $stage on $design_name @ [date]"

##init_design step
ui_status "Loading MMMC configuration"
read_mmmc  ${tool_scripts}/mmmc_config.tcl
ui_info "MMMC configuration loaded"

ui_status "Reading LEF files"
read_physical -lef { \
/proj1/projects/pd/projects_28nm/common_inputs/pnr_inputs/techlefs/tsmcn28_9lm4X2Y2RUTRDL.tlef \
/proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140lvt_180b/AN61001_20180509/TSMCHOME/digital/Back_End/lef/tcbn28hpcplusbwp40p140lvt_110a/lef/tcbn28hpcplusbwp40p140lvt.lef \
/proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140hvt_180a/AN61001_20180829/TSMCHOME/digital/Back_End/lef/tcbn28hpcplusbwp40p140hvt_110a/lef/tcbn28hpcplusbwp40p140hvt.lef \
/proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140_180b/AN61001_20180509/TSMCHOME/digital/Back_End/lef/tcbn28hpcplusbwp40p140_110a/lef/tcbn28hpcplusbwp40p140.lef \
}
ui_info "LEF files loaded"

##Netlist
ui_status "Reading netlist"
read_netlist $input_netlist
ui_info "Netlist loaded"

set_db init_ground_nets {VSS}
set_db init_power_nets {VDD}
ui_status "Initializing design"
init_design
ui_info "Design initialized"

ui_status "Running design checks"
check_timing -verbose > ${cur_stage_dir}/reports/check_timing.rpt
check_timing_library_consistency > ${cur_stage_dir}/reports/check_design.library.rpt
check_netlist -out_file ${cur_stage_dir}/reports/check_design.netlist.rpt
ui_info "Design checks complete"

ui_status "Running pre-place timing analysis"
time_design -pre_place -report_prefix preplace -report_dir ${cur_stage_dir}/reports
ui_info "Pre-place timing complete"

ui_status "Saving database"
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db
ui_info "Database saved"

#Reports
ui_status "Generating reports"
source ${tool_scripts}/innovus_reports.tcl
ui_info "Init design complete"
ui_stage_end $stage "success"
exit
