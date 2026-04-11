
create_clock -period 2.1 -name i_clk [get_ports i_clk]
set_input_delay [expr 2.1  * 0.6] -clock i_clk [get_ports [remove_from_collection [all_inputs ] {i_clk} ]]
set_output_delay [expr 2.1 * 0.6] -clock i_clk [get_ports [all_outputs]]
set_output_delay [expr 2.1 * 0.6] -clock i_clk [get_pins {rinse_done_reg/D soak_done_reg/D spin_done_reg/D wash_done_reg/D}]

create_clock -name vir -period 2.1
set_input_delay -clock vir [expr 2.1 * 0.35]  [filter_collection [all_fanin  -to [all_outputs] ] "port_direction == in"]
set_output_delay -clock vir [expr 2.1 * 0.35]  [filter_collection [all_fanout  -from [all_inputs] ] "port_direction == out"]
set_clock_uncertainty -setup [expr 2.1 * 0.2] [get_clock i_clk]
set_clock_uncertainty -hold [expr 2.1 * 0.15] [get_clock i_clk]
set_driving_cell -lib_cell  BUFFD8BWP40P140HVT  [get_ports [remove_from_collection [all_inputs ] {i_clk} ]] -no_design_rule
set_load 0.5 [get_ports [all_outputs ]]
report_timing

report_timing -group i2r
report_power
report_area
report_qor

write -format verilog -hierarchy -output washing_machine.v
write_sdc washing.sdc


