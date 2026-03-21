set design_name $env(BLOCK_NAME)
set input_netlist $env(SYNTH_DIR)/outputs/${design_name}.v
set tool_scripts $env(ENV_SCRIPTS)/innovus
set cur_stage_dir $env(INIT_DIR)  

set stage init_design
puts "MyInfo: Started $stage on $design_name @ [date]"



##init_design step
read_mmmc  ${tool_scripts}/mmmc_config.tcl
read_physical -lef { \
/proj1/projects/pd/projects_28nm/common_inputs/pnr_inputs/techlefs/tsmcn28_9lm4X2Y2RUTRDL.tlef \
/proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140lvt_180b/AN61001_20180509/TSMCHOME/digital/Back_End/lef/tcbn28hpcplusbwp40p140lvt_110a/lef/tcbn28hpcplusbwp40p140lvt.lef \
/proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140hvt_180a/AN61001_20180829/TSMCHOME/digital/Back_End/lef/tcbn28hpcplusbwp40p140hvt_110a/lef/tcbn28hpcplusbwp40p140hvt.lef \
/proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140_180b/AN61001_20180509/TSMCHOME/digital/Back_End/lef/tcbn28hpcplusbwp40p140_110a/lef/tcbn28hpcplusbwp40p140.lef \
}

##Netlist
read_netlist $input_netlist 
set_db init_ground_nets {VSS}
set_db init_power_nets {VDD}
init_design



check_timing -verbose > ./reports/check_timing.rpt
#check_design -type library -format detail > ./reports/check_design.library.rpt
check_timing_library_consistency > ./reports/check_design.library.rpt
#check_design -type netlist -format detail > ./reports/check_design.netlist.rpt
check_netlist -out_file ./reports/check_design.netlist.rpt
#check_design -type synthesis -format detail > ./reports/check_design.synthesis.rpt
time_design -pre_place -report_prefix preplace -report_dir ./reports
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db

#Reports
source ${tool_scripts}/innovus_reports.tcl
exit


