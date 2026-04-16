source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl
source $env(ENV_SCRIPTS)/common/yaml_utils.tcl
source $env(ENV_SCRIPTS)/common/pdk_loader.tcl

set design_name $env(BLOCK_NAME)
set input_netlist $env(EXP_DIR)/syn/outputs/${design_name}.v
set tool_scripts $env(ENV_SCRIPTS)/innovus
set cur_stage_dir $env(EXP_DIR)/pnr/init

set stage init_design
ui_stage_start $stage
ui_info "Design: $design_name"
ui_info "MyInfo: Started $stage on $design_name @ [date]"

##init_design step
ui_status "Loading MMMC configuration"
read_mmmc  ${tool_scripts}/mmmc_config.tcl
ui_info "MMMC configuration loaded"

ui_status "Reading LEF files"
set tech_lef [dict get $metal_cfg tech_lef]
read_physical -lef [concat $tech_lef $CELL_LEFS]
ui_info "Tech LEF  : $tech_lef"
ui_info "Cell LEFs : $CELL_LEFS"
ui_info "LEF files loaded"

##Netlist
ui_status "Reading netlist"
read_netlist $input_netlist
ui_info "Netlist loaded"

set_db init_ground_nets [dict get $PROJ_PDK ground_net]
set_db init_power_nets [dict get $PROJ_PDK power_net]
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
exec touch ${cur_stage_dir}/work/${stage}_flow_complete
exit
