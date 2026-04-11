set target_library "/proj1/projects/pd/projects_28nm/common_inputs/synthesis_inputs/ccs/tcbn28hpcplusbwp40p140hvtssg0p81vm40c_ccs.db"
set link_library " * /proj1/projects/pd/projects_28nm/common_inputs/synthesis_inputs/ccs/tcbn28hpcplusbwp40p140hvtssg0p81vm40c_ccs.db"
analyze -format verilog /home/akashj/seven_segment/syn_inputs/seven_segment.v
elaborate seven_segment
check_timing
create_clock -period 2 -name clk [get_ports clk]
set_input_delay 0.6 -clock clk [all_inputs]
set_output_delay 0.6 -clock clk [all_outputs]
check_timing
report_timing
report_qor
group_path -from [all_inputs] -to [all_outputs] -name i20
group_path -from [all_inputs] -to [all_registers] -name i2r
group_path -from [all_registers] -to [all_registers] -name r2r
group_path -from [all_registers] -to [all_outputs] -name o2r
set_driving_cell -lib_cell BUFFD8BWP40P140HVT [all_inputs] -no_design_rule
set_load  0.00153669 [all_outputs]
set_clock_uncertainty 0.2 [get_clock clk]
compile
report_qor
write -format verilog -output seven_segment -hierarchy seven_segment
write_sdc seven_segment.sdc

