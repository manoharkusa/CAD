remove_driving_cell      [get_ports clk]
set_drive       0        [get_ports clk]
create_clock -name clk    [get_ports clk] -period 10 -waveform   [list 0 5]
set_dont_touch_network    clk
set_ideal_network -no_propagate    [get_ports clk]
########SKEW & LATENCY#########
set_clock_uncertainty          0.5           [get_clocks clk]
set_clock_latency -source -max 1.0              [get_clocks clk]
set_clock_latency    -max      1.0              [get_clocks clk]
set_clock_transition -max      0.1              [get_clocks clk]
########SET_RST########
set_dont_touch_network                          [get_ports rst]
set_false_path -from                            [get_ports rst]
set_ideal_network -no_propagate     [get_ports rst]
set_drive 0                                     [get_ports rst]
########IO DELAY#########
set_input_delay  2 -max  -clock [get_clocks clk]  [get_ports key*]
set_input_delay  0 -min  -clock [get_clocks clk]  [get_ports key*]

set_output_delay  2 -max  -clock [get_clocks clk]  [get_ports text_out]
set_output_delay  0 -min  -clock [get_clocks clk]  [get_ports text_out]

set_max_fanout 32 [current_design]

