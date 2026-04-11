create_clock -name clk1 -period 4 [get_ports clk]
set_input_delay -clock clk1 2.4 [remove_from_collection [all_inputs] clk ]
set_output_delay -clock clk1 2.4 [all_outputs]
set_clock_uncertainty -setup 0.8 [get_clocks clk1 ]
set_clock_uncertainty -hold  0.7 [get_clocks clk1 ]
set_driving_cell -lib_cell BUFFD4BWP40P140HVT [remove_from_collection [all_inputs] clk ]
set_load 00100812 [all_outputs]

