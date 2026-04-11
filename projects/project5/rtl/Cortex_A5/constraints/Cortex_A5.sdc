set target_library /proj1/projects/pd/projects_28nm/common_inputs/synthesis_inputs/ccs/tcbn28hpcplusbwp40p140hvtssg0p81vm40c_ccs.db
set link_library { * /proj1/projects/pd/projects_28nm/common_inputs/synthesis_inputs/ccs/tcbn28hpcplusbwp40p140hvtssg0p81vm40c_ccs.db /proj1/projects/pd/projects_28nm/rp_top/macro1_lib/ts1n28hpcpuhdhvtb2048x129m4swbso_170a_ssg0p81vm40c.db /proj1/projects/pd/projects_28nm/rp_top/macro2_lib/tsdn28hpcpuhdb4096x33m4mwa_170a_ssg0p81vm40c.db }
analyze -recursive -autoread -top ca5dpu_fp_dp ./verilog/
elaborate ca5dpu_fp_dp
link
compile
all_fanin -to [all_registers -clock_pins ] -flat -startpoints_only
start_gui
create_clock -period 2.75 -name clk [get_ports clk]
check_design
check_timing
check_timing
set_input_delay [expr 2.75*0.6]  -clock clk [get_ports [remove_from_collection [all_inputs] {clk}]]
set_output_delay [expr 2.75*0.6]  -clock clk [all_outputs ]
check_timing
report_timing
group_path -from [all_inputs ] -to [all_registers ] -name i2r
group_path -from [all_registers ] -to [all_registers ] -name r2r
group_path -from [all_registers ] -to [all_outputs ] -name r2o
group_path -from [all_inputs ] -to [all_outputs ] -name i2o
report_timing -group r2r
filter_collection [all_fanout  -from    [all_inputs] ] "port_direction == out "
create_clock -period 2.75 -name vir
set_output_delay [expr 2.75*0.35]  -clock vir    [filter_collection [all_fanout  -from    [all_inputs] ] "port_direction == out " ]
set_input_delay [expr 2.75*0.35]  -clock vir    [filter_collection [all_fanin  -to    [all_outputs] ] "port_direction == in " ]
report_timing
set_clock_uncertainty -setup [expr 2.75*0.2] [get_clocks clk]
set_clock_uncertainty -hold [expr 2.75*0.15] [get_clocks clk]
report_timing
set_driving_cell -lib_cell BUFFD8BWP40P140HVT [get_ports [remove_from_collection [all_inputs ] clk]] -no_design_rule
set_driving_cell -lib_cell BUFFD8BWP40P140HVT [get_ports [remove_from_collection [all_inputs ] {clk}]] -no_design_rule
set_load 0.00153669 [all_outputs ]
group_path -name i2r -from [all_inputs ] -to [all_registers ] -weight 50
compile
