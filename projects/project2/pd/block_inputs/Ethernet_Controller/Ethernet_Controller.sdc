  
 create_lib -technology /proj1/projects/pd/projects_28nm/common_inputs/pnr_inputs/techlefs/tsmcn28_9lm4X2Y2RUTRDL.tf -ref_libs {/proj1/projects/pd/projects_28nm/common_inputs/pnr_inputs/NDMs/tcbn28hpcplusbwp40p140hvt.ndm/} ethernet.ndm
read_verilog ../design/pnr_inputs/ethernet_mac_tx_netlist.v
read_sdc ../design/pnr_inputs/ethernet_mac_tx_syn.sdc
set_app_options -list { time.delay_calculation_style zero_interconnect}
set_app_options -list {  time.high_fanout_net_pin_capacitance 0pF  time.high_fanout_net_threshold 50}
reset_app_options  { time.delay_calculation_style zero_interconnect}
reset_app_options  {time.delay_calculation_style zero_interconnect}






  


 initialize_floorplan -core_utilization 0.6 -core_offset {1.4 0.9} -side_ratio {1  1 }
start_gui
create_pin_guide -boundary {{-0.8900 8.4300} {1.8900 1.6300}} -name i [get_ports [all_inputs]]
create_pin_guide -boundary {{10.6450 8.2850} {12.7650 1.3950}}  -name o [get_ports [all_outputs]]
place_pins -ports [all_inputs]
place_pins -ports [all_outputs]
           

  

 get_lib_cells *BOUNDARY*
 set_boundary_cell_rules -left_boundary_cell BOUNDARY_LEFTBWP40P140 -right_boundary_cell BOUNDARY_RIGHTBWP40P140
 compile_boundary_cells
 check_legality
   


 
create_net -power v08
 create_net -ground vss
 create_port -port_type power -direction in v08
 create_port -port_type ground -direction in vss
 connect_pg_net -net v08 [get_pins -physical_context */VDD]
 connect_pg_net -net vss [get_pins -physical_context */VSS]
###Power planning
set_host_options -max_cores 8
puts "USER_INFO: ####----------------------Start of PG insertion--------------------------------####"
#To disable via creation during compile pg
set_app_options -name plan.pgroute.disable_via_creation -value true
###To create M1 rails
#create_pg_std_cell_conn_pattern rail_pattern -layers M1
create_pg_std_cell_conn_pattern rail_pattern -layers M1 -rail_width 0.15
set_pg_strategy M1_rails -core -pattern {{name: rail_pattern} {nets: v08 vss}}
###Define PG mesh for M5 to M7 layers (only in core region)
create_pg_mesh_pattern m5tom7_mesh_pattern -layers {{{vertical_layer: M5} {width: 0.45} {spacing: minimum} {pitch: 5.0} {offset: 0.6}} \
					     {{horizontal_layer: M6} {width: 0.45} {spacing: minimum} {pitch: 5.0} {offset: 0.6}} \
					     {{vertical_layer: M7} {width: 0.62} {spacing: minimum} {pitch: 3.0} {offset: 0.6}}}
set_pg_strategy PG_mesh -core -pattern {{name: m5tom7_mesh_pattern} {nets: v08 vss}} -extension {{layers: M5} {stop: 0.2}}
##Define PG mesh for M8 & M9 (extended till die boundary, assuming they need to be aligned at top)
create_pg_mesh_pattern m8m9_mesh_pattern -layers {{{horizontal_layer: M8} {width: 1.52} {spacing: minimum} {pitch: 6.0} {offset: 3.2}} \
					     	  {{vertical_layer: M9} {width: 3.0} {spacing: minimum} {pitch: 7.5} {offset: 3.48}}}
set_pg_strategy M8M9PG_mesh -design_boundary -pattern {{name: m8m9_mesh_pattern} {nets: v08 vss}} -extension {{stop: design_boundary_and_generate_pin}}
##
compile_pg -strategies {M8M9PG_mesh PG_mesh M1_rails}


###Create PG vias
set layer_pairs [list {M9 M8 VIA89_1cut} {M8 M7 VIA78_1cut} {M7 M6 VIA67_1cut} {M6 M5 VIA56_1cut}]
foreach lyr_pr $layer_pairs {
set frm_lyr [lindex $lyr_pr 0]
set to_lyr [lindex $lyr_pr 1]
set via_mstr [lindex $lyr_pr 2]
puts "$via_mstr"
puts "USER_INFO: ####----------------------Creating PG vias between $frm_lyr & $to_lyr------------------------####"
#create_pg_vias -from_layers $frm_lyr -to_layers $to_lyr -nets {v08 vss} -within_bbox [get_attribute [current_block] bbox] -via_masters $via_mstr
create_pg_vias -from_layers $frm_lyr -to_layers $to_lyr -nets {v08 vss} -within_bbox [get_attribute [current_block] bbox] 
}
##Creating pg vias between M1 & M5
set_pg_via_master_rule via1_rule -contact_code VIA12_1cut -cut_spacing 0.1 -via_array_dimension {3 1}
set_pg_via_master_rule via2_rule -contact_code VIA23_1cut -cut_spacing 0.1 -via_array_dimension {3 1}
set_pg_via_master_rule via3_rule -contact_code VIA34_1cut -cut_spacing 0.1 -via_array_dimension {3 1}
set_pg_via_master_rule via4_rule -contact_code VIA45_1cut -cut_spacing 0.1 -via_array_dimension {3 1}
create_pg_vias -from_layers M5 -to_layers M1 -nets {v08 vss} -within_bbox [get_attribute [current_block] bbox] -via_masters {via1_rule via2_rule  via3_rule via4_rule}
puts "USER_INFO: ####----------------------End of PG insertion--------------------------------####"

#Via over macro pins








check_pg_drc
check_pg_connectivity
check_pg_missing_vias
connect_pg_net -net v08 [get_pins -physical_context */VDD]
connect_pg_net -net vss [get_pins -physical_context */VSS]
    

get_lib_cells *TAP*
create_tap_cells -lib_cell tcbn28hpcplusbwp40p140hvt/TAPCELLBWP40P140 -distance 30 -pattern stagger -no_1x -prefix welltap -skip_fixed_cells
connect_pg_net -net v08 [get_pins -physical_context */VDD]
connect_pg_net -net vss [get_pins -physical_context */VSS]
check_pg_drc
check_pg_connectivity
check_pg_missing_vias
remove_corners -all
remove_modes -all
remove_scenarios -all
#remove_propagated_clocks [ all_clocks ]
#remove_propagated_clocks [ get_ports ]
#remove_propagated_clocks [ get_pins -hierarchical ]



set tluplus_path "/home/deva/ICC2_28NM_TECH2"

###Modes
create_mode func

###Create corners
create_corner ssg0p81v125c_rcw
create_corner ssg0p81vm40c_cw
create_corner ffg0p99vm40c_cb
create_corner ffg0p99v125c_rcb



###create RC corners
read_parasitic_tech -name cw -tlup $tluplus_path/cln28hpc+_1p09m+ut-alrdl_4x2y2r_cworst.tluplus
read_parasitic_tech -name rcw  -tlup $tluplus_path/cln28hpc+_1p09m+ut-alrdl_4x2y2r_rcworst.tluplus
read_parasitic_tech -name cb -tlup $tluplus_path/cln28hpc+_1p09m+ut-alrdl_4x2y2r_cbest.tluplus
read_parasitic_tech -name rcb -tlup $tluplus_path/cln28hpc+_1p09m+ut-alrdl_4x2y2r_rcbest.tluplus


###set operating conditions

current_corner ssg0p81v125c_rcw
set_voltage 0.81 -object_list v08
set_voltage 0.00 -object_list vss
set_temperature 125
set_process_number 1.0
set_operating_conditions -analysis_type on_chip_variation
set_parasitic_parameters -early_spec rcw -late_spec rcw -corners [get_corners ssg0p81v125c_rcw]

current_corner ssg0p81vm40c_cw
set_voltage 0.81 -object_list v08
set_voltage 0.00 -object_list vss
set_temperature -40
set_process_number 1.0
set_operating_conditions -analysis_type on_chip_variation
set_parasitic_parameters -early_spec cw -late_spec cw -corners [get_corners ssg0p81vm40c_cw]

current_corner ffg0p99vm40c_cb
set_voltage 0.99 -object_list v08
set_voltage 0.00 -object_list vss
set_temperature -40
set_process_number 1.0
set_operating_conditions -analysis_type on_chip_variation
set_parasitic_parameters -early_spec cb -late_spec cb -corners [get_corners ffg0p99vm40c_cb]

current_corner ffg0p99v125c_rcb 
set_voltage 0.99 -object_list v08
set_voltage 0.00 -object_list vss
set_temperature 125
set_process_number 1.0
set_operating_conditions -analysis_type on_chip_variation
set_parasitic_parameters -early_spec rcb -late_spec rcb -corners [get_corners ffg0p99v125c_rcb]


create_scenario -mode func -corner ssg0p81v125c_rcw -name func_setup_ssg0p81v125c_rcw
create_scenario -mode func -corner ssg0p81vm40c_cw -name func_setup_ssg0p81vm40c_cw
create_scenario -mode func -corner ffg0p99vm40c_cb -name func_hold_ffg0p99vm40c_cb
create_scenario -mode func -corner ffg0p99v125c_rcb -name func_hold_ffg0p99v125c_rcb


current_mode func
current_scenario func_setup_ssg0p81vm40c_cw

source   ../design/pnr_inputs/ethernet_mac_tx_syn.sdc




current_mode func
current_scenario func_setup_ssg0p81v125c_rcw
 

source  ../design/pnr_inputs/ethernet_mac_tx_syn.sdc


current_mode func
current_scenario func_hold_ffg0p99vm40c_cb

source  ../design/pnr_inputs/ethernet_mac_tx_syn.sdc
 


current_mode func
current_scenario func_hold_ffg0p99v125c_rcb
 
source  ../design/pnr_inputs/ethernet_mac_tx_syn.sdc
 






report_scenarios
set_scenario_status -setup true -hold false [get_scenarios *setup*]
report_scenarios
set_dont_use [get_lib_cells */CK* ]
get_lib_cells *BUFFD8*
add_buffer -lib_cell tcbn28hpcplusbwp40p140hvt/BUFFD8BWP40P140HVT [get_ports [all_inputs]]
add_buffer -lib_cell tcbn28hpcplusbwp40p140hvt/BUFFD8BWP40P140HVT [get_ports [all_outputs]]
magnet_placement [get_cells  *eco*] -mark_fixed
set_dont_touch [get_cells *eco*]
set_app_options -name place.coarse.continue_on_missing_scandef -value true
set_app_options -name opt.dft.optimize_scan_chain -value false
place_opt



report_timing
report_constraints -all_violators
check_legality
report_utilization -of_objects [get_voltage_areas]
man report_utilization
report_utilization -of_objects [get_voltage_areas]
set_app_options -name clock_opt.flow.enable_ccd -value true
    










set_scenario_status -active true [get_scenarios *]
report_scenarios
set_lib_cell_purpose -include cts [get_lib_cells {*/CKBD3* */CKBD4* */CKBD6* */CKBD8* */CKBD12* */CKBD16*}]
set_clock_tree_options -target_skew 0.1 -clocks [get_clocks clk1]
create_routing_rule -multiplier_width 2.0 -multiplier_spacing 2.0 -taper_distance 5.0 cts_rule
set_clock_routing_rules  -rules  cts_rule
create_routing_rule -multiplier_width 2 -multiplier_spacing 2 cts_2w2s
create_routing_rule -multiplier_width 1 -multiplier_spacing 2 cts_1w2s
set_clock_routing_rules -net_type {internal} -rules cts_2w2s -max_routing_layer M7 -min_routing_layer M4
set_clock_routing_rules -net_type {root} -rules cts_2w2s -max_routing_layer M7 -min_routing_layer M4
set_clock_routing_rules -net_type {sink} -rules cts_1w2s -max_routing_layer M6 -min_routing_layer M3
remove_clock_uncertainty [get_clocks clk1]
set_clock_uncertainty [expr {2*0.15}] -scenarios [get_scenarios ] -setup [get_clocks clk1]
set_clock_uncertainty 0.5 -scenarios [get_scenarios *setup* ] -hold [get_clocks clk1]
set_clock_uncertainty 0.15 -scenarios [get_scenarios *hold* ] -hold [get_clocks clk1]
set_app_options -name cts.common.user_instance_name_prefix -value cts_cells
check_clock_trees
clock_opt -from build_clock -to route_clock
connect_pg_net -net v08 [get_pins -physical_context */VDD]
connect_pg_net -net vss [get_pins -physical_context */VSS]
   



report_clock_qor
 report_clock_timing -type summary
#report_clock_timing -type setup
#report_clock_timing -type skew
report_qor
#report_constraints  -all_violators [all_scenarios]
report_constraints  -all_violators
report_timing
  







set_lib_cell_purpose -include hold [get_lib_cells */DEL*]
set_scenario_status -active true [get_scenarios *]
set_propagated_clock [get_clocks clk1]
set_propagated_clock [get_clocks en]
compute_clock_latency
set_app_options -name cts.common.user_instance_name_prefix -value PST_cts
clock_opt -from final_opto -to final_opto
connect_pg_net -net v08 [get_pins -physical_context */VDD]
connect_pg_net -net vss [get_pins -physical_context */VSS]






report_clock_qor
#report_clock_timing
report_clock_timing -type summary
report_qor
check_legality
report_timing
report_constraints  -all_violator
compute_clock_latency
#compute_clock_latency











set_scenario_status -active true [get_scenarios *]
set_app_options -name time.si_enable_analysis  -value true
report_app_options *timing*driven*
set_app_options -name route.detail.timing_driven -value true
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
report_app_options *cross*driven*
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.crosstalk_driven -value true
route_auto
connect_pg_net -net v08 [get_pins -physical_context */VDD]
connect_pg_net -net vss [get_pins -physical_context */VSS]




check_lvs
check_routes
report_qor
report_timing
check_legality
report_constraints  -all_violators
report_utilization -of_objects [get_voltage_areas]





set_app_options -name time.si_enable_analysis  -value true
set_app_options -name route.detail.timing_driven -value true
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.crosstalk_driven -value true
set_clock_uncertainty [expr {2*0.12}] -scenarios [get_scenarios ] -setup [get_clocks clk1]
set_clock_uncertainty 0.5 -scenarios [get_scenarios *setup* ] -hold [get_clocks clk1]
set_clock_uncertainty 0.15 -scenarios [get_scenarios *hold* ] -hold [get_clocks	clk1]
set_app_options -name route_opt.flow.enable_ccd -value true
route_opt
check_lvs


report_qor
check_routes
report_qor
report_timing
check_legality
report_constraints  -all_violators [all_scenarios] 
report_utilization
