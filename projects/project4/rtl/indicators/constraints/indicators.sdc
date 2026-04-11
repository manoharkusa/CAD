set link_library { * /proj1/projects/pd/projects_28nm/common_inputs/synthesis_inputs/ccs/tcbn28hpcplusbwp40p140hvtssg0p72vm40c_ccs.db }
set target_library { /proj1/projects/pd/projects_28nm/common_inputs/synthesis_inputs/ccs/tcbn28hpcplusbwp40p140hvtssg0p72vm40c_ccs.db }

analyze -format verilog ../indicators.v

elaborate loaderrom
compile
create_clock -period 5 -name clk [get_ports {clk}]
set_input_delay [expr 5 * 0.4] -clock clk [get_ports [remove_from_collection [all_inputs] clk]]
set_output_delay [expr 5 * 0.4] -clock clk [get_ports [all_outputs]]
set_clock_uncertainty -setup [expr 5 * 0.2] [get_ports clk]
set_clock_uncertainty -hold [expr 5 * 0.15] [get_ports clk]
set_driving_cell -lib_cell BUFFD16BWP40P140HVT [get_ports [remove_from_collection [all_inputs] clk]] -no_design_rule
set_load 0.00146193 [all_outputs]
compile
report_timing
report_qor
report_timing -significant_digits 5
compile
#group_path -name I2R -from [all_inputs] -to [all_registers -data_pins ]
#group_path -name R2R -from [all_registers -clock_pins ] -to [all_registers -data_pins ]
#group_path -name R20 -from [all_registers -clock_pins ] -to [all_outputs ]
#group_path -name I2O -from [all_inputs ] -to [all_outputs ]
#report_timing
#write_sdc rom_synth.sdc
#write_file -hierarchy -format verilog -output rom_netlist.v
#pwd
#history -h rom_synth.tcl
#history -h > rom_synth.tcl
