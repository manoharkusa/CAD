create_clock -period 10 [get_ports clk]
create_clock -period 20 [get_ports I1]
set_clock_uncertainty -setup 2 [get_clock clk]
set_clock_uncertainty -hold 1.5 [get_clock clk]
set_clock_uncertainty  -hold 3 [get_clock I1]
set_clock_uncertainty -setup 4  [get_clock I1]
set_driving_cell -lib_cell  BUFFD8BWP40P140HVT  [get_ports [remove_from_collection [all_inputs] {clk  I1}]] -no_design_rule
set_load 0.5 [all_outputs]
set_input_delay 6 -clock clk [get_ports [remove_from_collection [all_inputs ] {clk I1}]]
set_output_delay 6 -clock clk [get_ports [all_outputs ]]
set_input_delay 12 -add_delay -clock I1 [get_ports [remove_from_collection [all_inputs ] {clk I1}]]
set_output_delay 12 -add_delay -clock I1 [get_ports [all_outputs ]]
set_case_analysis 0 I2
set_case_analysis 0 TE
create_generated_clock -name gen -source clk -divide_by 2 [get_pins ckGen/ckDiv_reg/Q]
create_clock -name vir -period 10
set_input_delay 3.5 -clock vir [get_ports [filter_collection [all_fanin -to [all_outputs ]] "port_direction == in"]]
filter_collection [all_fanout -from [all_inputs ]] "port_direction == out"
set_output_delay 3.5 -clock vir [get_ports [filter_collection [all_fanout -from [all_inputs ]] "port_direction == out"]]
set_input_delay 5 -clock I1 [get_ports ci]


