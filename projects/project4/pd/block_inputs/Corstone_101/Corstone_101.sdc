set target_library { /proj1/projects/pd/projects_28nm/common_inputs/synthesis_inputs/ccs/tcbn28hpcplusbwp40p140hvtssg0p81vm40c_ccs.db }
set link_library { * /proj1/projects/pd/projects_28nm/common_inputs/synthesis_inputs/ccs/tcbn28hpcplusbwp40p140hvtssg0p81vm40c_ccs.db /proj1/projects/pd/projects_28nm/rp_top/macro1_lib/ts1n28hpcpuhdhvtb2048x129m4swbso_170a_ssg0p81vm40c.db /proj1/projects/pd/projects_28nm/rp_top/macro2_lib/tsdn28hpcpuhdb4096x33m4mwa_170a_ssg0p81vm40c.db  }
analyze -autoread -recursive -top cmsdk_apb_subsystem /proj1/dataIn/ARM/Corstone-101/BP200-BU-00000-r1p1-00rel0/logical/
elaborate cmsdk_apb_subsystem
link
create_clock -period 2 -name HCLK [get_ports HCLK]
create_clock -period 2 -name PCLK [get_ports PCLK]
create_clock -period 2 -name PCLKG [get_ports PCLKG]
set_input_delay [expr 2*0.6]  -clock HCLK [get_ports [remove_from_collection [all_inputs] {HCLK PCLK PCLKG}]]
set_input_delay [expr 2*0.6] -add_delay  -clock PCLK [get_ports [remove_from_collection [all_inputs] {HCLK PCLK PCLKG}]]
set_input_delay [expr 2*0.6] -add_delay  -clock PCLKG [get_ports [remove_from_collection [all_inputs] {HCLK PCLK PCLKG}]]
set_output_delay [expr 2*0.6]   -clock HCLK  [all_outputs ]
set_output_delay [expr 2*0.6]  -add_delay -clock PCLK  [all_outputs ]
set_output_delay [expr 2*0.6]  -add_delay -clock PCLKG  [all_outputs ]
create_clock -name vir -period 2
set_output_delay [expr 2*0.35]  -clock vir    [filter_collection [all_fanout  -from    [all_inputs] ] "port_direction == out " ]
set_input_delay [expr 2*0.35]  -clock vir    [filter_collection [all_fanin  -to    [all_outputs] ] "port_direction == in " ]
group_path -from [all_inputs ] -to [all_registers ] -name i2r
group_path -from [all_registers ] -to [all_registers ] -name r2r
group_path -from [all_registers ] -to [all_outputs ] -name r2o
group_path -from [all_inputs ] -to [all_outputs ] -name i2o
set_clock_uncertainty -setup [expr 2*0.2] [get_clocks HCLK]
set_clock_uncertainty -setup [expr 2*0.2] [get_clocks PCLK]
set_clock_uncertainty -setup [expr 2*0.2] [get_clocks PCLKG]
set_clock_uncertainty -hold [expr 2*0.15] [get_clocks PCLKG]
set_clock_uncertainty -hold [expr 2*0.15] [get_clocks PCLK]
set_clock_uncertainty -hold [expr 2*0.15] [get_clocks HCLK]
set_driving_cell -lib_cell BUFFD8BWP40P140HVT [get_ports [remove_from_collection [all_inputs ] {HCLK PCLK PCLKG}]] -no_design_rule
set_load  0.00153669 [all_outputs ]
set_host_options -max_cores 16
compile 
