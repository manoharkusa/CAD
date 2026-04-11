create_clock -name clk -period 3.5 [get_ports clk]
set_input_delay -clock clk [expr {3.5*0.6}] [get_ports [remove_from_collection [all_inputs ] clk]]
set_output_delay -clock clk [expr {3.5*0.6}] [get_ports [all_outputs ]]
set_clock_uncertainty -setup [expr {3.5*0.2}] [get_clocks clk]
set_clock_uncertainty -hold [expr {3.5*0.15}] [get_clocks clk]
set_driving_cell -lib_cell BUFFD8BWP40P140HVT [get_ports [remove_from_collection [all_inputs ] clk]] -no_design_rule
set_load 0.00146193 [all_outputs ]
create_clock -name vir -period 3.5
set_input_delay [expr {3.5 * 0.3}] -clock vir [get_ports [filter_collection [all_fanin -to [all_outputs ]] "port_direction == in"]]
set_output_delay [expr {3.5 * 0.3}] -clock vir [get_ports [filter_collection [all_fanout -from [all_inputs ]] "port_direction == out"]]
