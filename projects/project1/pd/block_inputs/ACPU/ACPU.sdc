set_app_options -list { time.delay_calculation_style zero_interconnect}
set_app_options -list {  time.high_fanout_net_pin_capacitance 0pF  time.high_fanout_net_threshold 50}
reset_app_options  { time.delay_calculation_style zero_interconnect}
reset_app_options  {time.delay_calculation_style zero_interconnect}


initialize_floorplan -core_utilization 0.6 -core_offset {1.4 0.9} -side_ratio {1  1 }
create_pin_guide -boundary ##{{-1.5150 76.1500} {3.1750 27.8000}}## -name i [get_ports [all_inputs]]
create_pin_guide -boundary ##{{100.5900 75.4400} {105.4250 19.1250}}##  -name o [get_ports [all_outputs]]
set_boundary_cell_rules -left_boundary_cell BOUNDARY_LEFTBWP40P140 -right_boundary_cell BOUNDARY_RIGHTBWP40P140
create_tap_cells -lib_cell tcbn28hpcplusbwp40p140hvt/TAPCELLBWP40P140 -distance 30 -pattern stagger -no_1x -prefix welltap -skip_fixed_cells

set_dont_use [get_lib_cells */CK* ]
add_buffer -lib_cell tcbn28hpcplusbwp40p140hvt/BUFFD8BWP40P140HVT [get_ports [all_inputs]]
add_buffer -lib_cell tcbn28hpcplusbwp40p140hvt/BUFFD8BWP40P140HVT [get_ports [all_outputs]]
magnet_placement [get_cells  *eco*] -mark_fixed
set_dont_touch [get_cells *eco*]
set_app_options -name place.coarse.continue_on_missing_scandef -value true
set_app_options -name opt.dft.optimize_scan_chain -value false

set_app_options -name clock_opt.flow.enable_ccd -value true
set_lib_cell_purpose -include cts [get_lib_cells {*/CKBD3* */CKBD4* */CKBD6* */CKBD8* */CKBD12* */CKBD16*}]
set_clock_tree_options -target_skew 0.1 -clocks [get_clocks clk]
create_routing_rule -multiplier_width 2.0 -multiplier_spacing 2.0 -taper_distance 5.0 cts_rule
set_clock_routing_rules  -rules  cts_rule
create_routing_rule -multiplier_width 2 -multiplier_spacing 2 cts_2w2s
create_routing_rule -multiplier_width 1 -multiplier_spacing 2 cts_1w2s
set_clock_routing_rules -net_type {internal} -rules cts_2w2s -max_routing_layer M7 -min_routing_layer M4
set_clock_routing_rules -net_type {root} -rules cts_2w2s -max_routing_layer M7 -min_routing_layer M4
set_clock_routing_rules -net_type {sink} -rules cts_1w2s -max_routing_layer M6 -min_routing_layer M3
remove_clock_uncertainty [get_clocks clk]
set_clock_uncertainty [expr {10*0.15}] -scenarios [get_scenarios ] -setup [get_clocks clk]
set_clock_uncertainty 0.5 -scenarios [get_scenarios *setup* ] -hold [get_clocks clk]
set_clock_uncertainty 0.15 -scenarios [get_scenarios *hold* ] -hold [get_clocks clk]
set_app_options -name cts.common.user_instance_name_prefix -value cts_cells



set_lib_cell_purpose -include hold [get_lib_cells */DEL*]


set_app_options -name cts.common.user_instance_name_prefix -value PST_cts





report_app_options *timing*driven*
set_app_options -name route.detail.timing_driven -value true
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
report_app_options *cross*driven*
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.crosstalk_driven -value true


set_app_options -name time.si_enable_analysis  -value true
set_app_options -name route.detail.timing_driven -value true
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.crosstalk_driven -value true

