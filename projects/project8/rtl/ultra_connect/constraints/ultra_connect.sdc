create_clock -name clk -period 1 [get_ports clk]
set_input_delay -clock clk [expr {1*0.6}] [get_ports [remove_from_collection [all_inputs ] clk]]
set_output_delay -clock clk [expr {1*0.6}] [get_ports [all_outputs ]]
set_clock_uncertainty -setup [expr {1*0.2}] [get_clocks clk]
set_clock_uncertainty -hold [expr {1*0.15}] [get_clocks clk]
set_driving_cell -lib_cell BUFFD8BWP40P140HVT [get_ports [remove_from_collection [all_inputs ] clk]] -no_design_rule
set_load 0.00146193 [all_outputs ]
