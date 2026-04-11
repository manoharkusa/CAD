create_clock -name clk1 -period 1.5 [get_ports clk]
set_input_delay -clock clk1 [expr {1.5*0.6}] [remove_from_collection [all_inputs] clk ]
set_output_delay -clock clk1 [expr {1.5*0.6}] [all_outputs]
set_clock_uncertainty -setup [expr {1.5*0.2}] [get_clocks clk1 ]
set_clock_uncertainty -hold  [expr {1.5*0.15}] [get_clocks clk1 ]
set_driving_cell -lib_cell BUFFD4BWP40P140HVT [remove_from_collection [all_inputs] clk ]
set_load 00100812 [all_outputs]

