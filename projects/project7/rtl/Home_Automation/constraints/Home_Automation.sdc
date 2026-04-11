create_clock -name clk -period 2 [get_ports clk]
set_input_delay  [expr 2 * 0.6] -clock clk [get_ports [remove_from_collection [all_inputs] {clk}]]
set_output_delay  [expr 2 * 0.6] -clock clk [get_ports [all_outputs]]

 ### Vitrual_clock..............................######
create_clock -period 2 -name vir
set_input_delay [expr 2 * 0.35]  -clock vir   [filter_collection [all_fanout  -from    [all_inputs] ] "port_direction == out " ]
set_input_delay [expr 2 * 0.35]  -clock vir   [filter_collection [all_fanin  -to [all_outputs] ] "port_direction == in " ]
set_output_delay [expr 2 * 0.35] -clock vir [filter_collection [all_fanout -from [all_outputs]] "port_direction == out" ]

set_clock_uncertainty -setup [expr 2 * 0.2] [get_clocks clk]
set_clock_uncertainty -hold  [expr 2 * 0.15] [get_clocks clk]

set_driving_cell -lib_cell  BUFFD8BWP40P140HVT [remove_from_collection [all_inputs] clk ]
set_load 0.5 [all_outputs]

report_area -nosplit
report_power
report_qor



