

set clk_period 10

#Agent_info: Added by SPD agent (fix TCL syntax error - missing $ prefix on clk_period variable) [2026-05-05 14:27:10]
create_clock -name clk    [get_ports clk] -period $clk_period -waveform   [list 0 [expr 0.5*$clk_period]]

set_clock_uncertainty          0.5           [get_clocks clk]

##IO constraints
set_input_delay  [expr 0.6*$clk_period] -max  -clock [get_clocks clk]  [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay  0.2 -min  -add_delay -clock [get_clocks clk]  [remove_from_collection [all_inputs] [get_ports clk]]

set_output_delay  [expr 0.6*$clk_period] -max  -clock [get_clocks clk]  [all_outputs]
set_output_delay  0.2 -min  -add_delay -clock [get_clocks clk]  [all_outputs]

set_max_fanout 32 [current_design]

