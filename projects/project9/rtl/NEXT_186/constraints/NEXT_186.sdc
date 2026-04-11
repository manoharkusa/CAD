create_clock -period 10 -name clk [get_ports clk]
set_input_delay 6 -clock clk [get_ports [all_inputs]]
set_output_delay 6 -clock clk [get_ports [all_outputs]]
set_driving_cell -lib_cell BUFFD8BWP40P140HVT [all_inputs] -no_design_rule
set_load  0.00153669 [all_outputs]
set_clock_uncertainty 2 [get_clock {clk}]

