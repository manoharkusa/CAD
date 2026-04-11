
create_clock -period 2 -name clk [get_ports clk]

set_input_delay [expr 2 * 0.6]  -clock clk [get_ports [remove_from_collection [all_inputs] {clk}]]

set_output_delay [expr 2 * 0.6]  -clock clk [all_outputs]
set_driving_cell -lib_cell  BUFFD8BWP40P140HVT [remove_from_collection [all_inputs] clk ]
set_load 0.5 [all_outputs]
set_clock_uncertainty -setup [expr 2 * 0.2] [get_clocks clk]
set_clock_uncertainty -hold  [expr 2 * 0.15] [get_clocks clk]
report_timing
compile
report_timing

report_qor
report_area
report_power
check_design

