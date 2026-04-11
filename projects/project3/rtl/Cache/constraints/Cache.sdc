######----------------FLOORPLAN--------------#####

create_lib -technology /proj1/projects/pd/projects_28nm/common_inputs/pnr_inputs/techlefs/tsmcn28_9lm4X2Y2RUTRDL.tf -ref_libs { /proj1/projects/pd/projects_28nm/common_inputs/pnr_inputs/NDMs/tcbn28hpcplusbwp40p140.ndm/ /proj1/projects/pd/projects_28nm/common_inputs/pnr_inputs/NDMs/tcbn28hpcplusbwp40p140hvt.ndm/ /proj1/projects/pd/projects_28nm/common_inputs/pnr_inputs/NDMs/ts1n28hpcpuhdhvtb2048x129m4swbso_170a.ndm/ /proj1/projects/pd/projects_28nm/common_inputs/pnr_inputs/NDMs/tsdn28hpcpuhdb4096x33m4mwa_170a.ndm/ } cache_pnr4.ndm.ndm


#puts (\n"Created an NDM with the name rom.ndm")

set sdc_path "./cache.sdc"
set netlist_path "./cache_syn.v"
set tluplus_path "/proj1/projects/pd/projects_28nm/common_inputs/pnr_inputs/itf_files/"


#read verilog and sdc files
read_verilog $netlist_path
read_sdc $sdc_path

#to know the number of input and output ports
sizeof_collection [all_inputs]
sizeof_collection [all_outputs]

#to find the clocks in the design
all_fanin -to [all_registers -clock_pins] -startpoints_only -flat 


#creating metal layers
set_attribute [get_layers {M1 M2 M4 M6 M8 } ] routing_direction horizontal
set_attribute [get_layers {M3 M5 M7 M9 }] routing_direction vertical

#initializing floorplan
initialize_floorplan -core_utilization 0.1 -core_offset {0.5 0.5} -side_ratio {2 2 }




#creating ports
create_pin_guide -boundary {{-8.1000 261.4150} {11.8900 155.5200}} -name I [all_inputs]
create_pin_guide -boundary {{349.0150 273.8400} {364.1450 78.8050}} -name O [all_outputs]
place_pins -ports [all_inputs]
place_pins -ports [all_outputs]

#creating boundary cells
get_lib_cells *BOUNDARY*
set_boundary_cell_rules -left_boundary_cell tcbn28hpcplusbwp40p140hvt/BOUNDARY_LEFTBWP40P140 -right_boundary_cell tcbn28hpcplusbwp40p140hvt/BOUNDARY_RIGHTBWP40P140
compile_boundary_cells
create_tap_cells -lib_cell tcbn28hpcplusbwp40p140hvt/TAPCELLBWP40P140 -distance 30 -pattern stagger -no_1x -prefix welltap -skip_fixed_cells
save_block -as pre_pg
save_lib
create_net -power v08
create_net -ground vss
create_port -port_type power -direction in v08
create_port -port_type ground -direction in vss
connect_pg_net -net v08 [get_pins -physical_context */VDD]
connect_pg_net -net vss [get_pins -physical_context */VSS]
set_host_options -max_cores 16
puts "USER_INFO: ####----------------------Start of PG insertion--------------------------------####"
#To disable via creation during compile pg
set_app_options -name plan.pgroute.disable_via_creation -value true
###To create M1 rails
#std cell rails
create_pg_std_cell_conn_pattern M1_rails -layers {M1}
set_pg_strategy M1_stg -core -pattern {{name: M1_rails} {nets: v08 vss}}
compile_pg -strategies M1_stg
##M4 & M5 mesh
create_pg_mesh_pattern M4M5_pattern -layers {{{vertical_layer: M4} {width: 0.25} {spacing: minimum} {pitch: 2.2} {offset: 0.6} {trim: false}}
	                                        {{horizontal_layer: M5} {width: 0.33} {spacing: minimum} {pitch: 3.3} {offset: 0.6} {trim:false}}}
set_pg_strategy pg_m4m5_mesh -core -pattern {{name: M4M5_pattern} {nets: v08 vss }} -blockage {macros : all} -extension {{stop: 0.2} {layers: M4}}
compile_pg -strategies pg_m4m5_mesh
#M6 & M7 pg stripes creation
create_pg_mesh_pattern M6M7_pattern -layers {{{vertical_layer: M6} {width: 0.3} {spacing: minimum} {pitch: 2.4} {offset: 0.6} {trim: false}} 
	                                       {{horizontal_layer: M7} {width: 0.5} {spacing: minimum} {pitch: 3} {offset: 0.6} {trim: false}}}
set_pg_strategy pg_m6m7_mesh -core -pattern {{name: M6M7_pattern } {nets: v08 vss }} -extension {{stop: 0.2} {layers: M4}}
compile_pg -strategies pg_m6m7_mesh
#M8 & M9 creation
create_pg_mesh_pattern M8toM9 -layers {{{horizontal_layer: M9} {width: 1.63} {pitch: 4.56} {spacing: minimum} {offset: 1.48}} 
	                                       {{vertical_layer: M8} {width: 1.63} {pitch: 4.56} {spacing: minimum} {offset: 1.48}}}
set_pg_strategy top_pg -design_boundary -pattern {{name: M8toM9 } {nets: v08 vss }} -extension {stop: design_boundary_and_generate_pin}
compile_pg -strategies top_pg
puts "USER_INFO: ####----------------------End of PG insertion--------------------------------####"
###Create PG vias
set_pg_via_master_rule via8_rule -contact_code VIA89_1cut -via_array_dimension {2 2}
set layer_pairs [list {M9 M8 via8_rule} {M8 M7 VIA78_1cut_H} {M7 M6 VIA67_1cut_FAT_H} {M6 M5 VIA56_1cut_FAT_H}]
foreach lyr_pr $layer_pairs {
	set frm_lyr [lindex $lyr_pr 0]
	set to_lyr [lindex $lyr_pr 1]
	set via_mstr [lindex $lyr_pr 2]
	puts "$via_mstr"
	puts "USER_INFO: ####----------------------Creating PG vias between $frm_lyr & $to_lyr------------------------####"
	create_pg_vias -from_layers $frm_lyr -to_layers $to_lyr -nets {v08 vss} -within_bbox [get_attribute [current_block] bbox] -via_masters $via_mstr
	}
set_pg_via_master_rule via4_rule -contact_code VIA45_1cut -cut_spacing 0.05 -via_array_dimension {3 3}
create_pg_vias -from_layers M5 -to_layers M4 -nets {v08 vss} -within_bbox [get_attribute [current_block] bbox] -via_masters {via4_rule}
##Creating pg vias between M1 & M5
set_pg_via_master_rule via1_rule -contact_code VIA12_1cut -cut_spacing 0.05 -via_array_dimension {3 1}
set_pg_via_master_rule via2_rule -contact_code VIA23_1cut -cut_spacing 0.05 -via_array_dimension {3 1}
set_pg_via_master_rule via3_rule -contact_code VIA34_1cut -cut_spacing 0.05 -via_array_dimension {3 1}
create_pg_vias -from_layers M4 -to_layers M1 -nets {v08 vss} -within_bbox [get_attribute [current_block] bbox] -via_masters {via1_rule via2_rule  via3_rule}
puts "USER_INFO: ####----------------------End of PG insertion--------------------------------####"
check_pg_drc
check_pg_missing_vias
check_pg_missing_vias
check_pg_connectivity
report_timing
report_qor
save_block -as fp_done
#mmmc_file................................................................................
remove_corners -all
remove_modes -all
remove_scenarios -all
remove_propagated_clocks [all_clocks]
remove_propagated_clocks [get_ports]
remove_propagated_clocks [get_pins -hierarchical]
set tluplus_path "/proj1/projects/pd/projects_28nm/common_inputs/pnr_inputs/itf_files/"
#set sdc_path "/home/sumoct22pd143/mentor/10projects/UnAmiga-master/Cores/Colecovision/src/rom/synth/rom_synth.sdc"
##Modes
create_mode func
##create corners
create_corner ssg0p81v125c_rcw
create_corner ssg0p81vm40c_cw
create_corner ffg0p99vm40c_cb
create_corner ffg0p99v125c_rcb
##create RC corners
read_parasitic_tech -name rcw -tlup $tluplus_path/cln28hpc+_1p09m+ut-alrdl_4x2y2r_rcworst.tluplus
read_parasitic_tech -name cw -tlup $tluplus_path/cln28hpc+_1p09m+ut-alrdl_4x2y2r_cworst.tluplus
read_parasitic_tech -name cb -tlup $tluplus_path/cln28hpc+_1p09m+ut-alrdl_4x2y2r_cbest.tluplus
read_parasitic_tech -name rcb -tlup $tluplus_path/cln28hpc+_1p09m+ut-alrdl_4x2y2r_rcbest.tluplus
##set operating conditions
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
###(-object_list  Specifies  the  supply  nets, supply ports, cells, or ports that have the operating voltages specified in this command...)
set_temperature -40
set_process_number 1.0
set_operating_conditions -analysis_type on_chip_variation
###(-analysis_type  This option is ignored, as the tool always uses the on_chip_variation analysis type...)
set_parasitic_parameters -early_spec cw -late_spec cw -corners [get_corners ssg0p81vm40c_cw]
###(-early_spec & -late_spec  Specifies the early & late parasitic tech specification name i.e., file.tlup... And name should match in both read_parasitic & set_parasitic_patrameters...)
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
##create scenario (Creates a scenario in the current design...  Scenario = mode + corners)
create_scenario -mode func -corner ssg0p81v125c_rcw -name func_setup_ssg0p81v125c_rcw
create_scenario -mode func -corner ssg0p81vm40c_cw -name func_setup_ssg0p81vm40c_cw
create_scenario -mode func -corner ffg0p99vm40c_cb -name func_hold_ffg0p99vm40c_cb
create_scenario -mode func -corner ffg0p99v125c_rcb -name func_hold_ffg0p99v125c_rcb
current_mode func
current_scenario func_setup_ssg0p81vm40c_cw
source $sdc_path
current_mode func
current_scenario func_setup_ssg0p81v125c_rcw
source $sdc_path
current_mode func
current_scenario func_hold_ffg0p99vm40c_cb
source $sdc_path
current_mode func
current_scenario func_hold_ffg0p99v125c_rcb
source $sdc_path
set_scenario_status -setup true -hold false [get_scenarios *setup*]
set_scenario_status -setup false -hold true [get_scenarios *hold*]
set_dont_use [get_lib_cells */CK* ]
get_lib_cells *BUFFD8*
add_buffer -lib_cell tcbn28hpcplusbwp40p140hvt/BUFFD8BWP40P140HVT  [remove_from_collection [all_inputs ] {clk} ]
add_buffer -lib_cell tcbn28hpcplusbwp40p140hvt/BUFFD8BWP40P140HVT [all_outputs]
#magnet_placement [get_cells  *eco*] -mark_fixed
set_dont_touch [get_cells *eco*]
set_app_options -name place.coarse.continue_on_missing_scandef -value true
set_app_options -name opt.dft.optimize_scan_chain -value false
place_opt
report_timing
check_legality
report_qor
report_congestion
report_utilization
report_constraints  -all_violators
 
gui_load_cell_density_mm
gui_load_pin_density_mm
report_utilization
save_block -as placement_done
save_lib
#pre_cts.....................................................................
set_host_options -max_cores 16
set_app_options -name clock_opt.flow.enable_ccd -value true
set_scenario_status -active true [get_scenarios *]
set_lib_cell_purpose -include cts [get_lib_cells {*/CKBD3* */CKBD4* */CKBD6* */CKBD8* */CKBD12* */CKBD16*}]
create_routing_rule -multiplier_width 2.0 -multiplier_spacing 2.0 -taper_distance 5.0 cts_rule
set_clock_routing_rules  -rules  cts_rule
remove_clock_uncertainty [get_clocks clock]
set_clock_uncertainty [expr {5 * 0.15}] -scenarios [get_scenarios ] -setup [get_clocks clock]
set_clock_uncertainty 0.05 -scenarios [get_scenarios *setup* ] -hold [get_clocks clock]
set_clock_uncertainty 0.015 -scenarios [get_scenarios *hold* ] -hold [get_clocks clock]
set_app_options -name cts.common.user_instance_name_prefix -value cts_cells
check_clock_trees
clock_opt -from build_clock -to route_clock
connect_pg_net -net v08 [get_pins -physical_context */VDD]
connect_pg_net -net vss [get_pins -physical_context */VSS]
report_clock_qor
report_qor
report_clock_timing
report_clock_timing -type interclock_skew
report_clock_timing -type skew
report_clock_timing -type summary
report_timing
report_utilization
report_constraints  -all_violators
report_congestion
 
history
##post_cts##...................................................
set_host_options -max_cores 16
set_lib_cell_purpose -include hold [get_lib_cells */DEL*]
set_scenario_status -active true [get_scenarios *]
set_propagated_clock [get_clock clock]
compute_clock_latency
set_app_options -name cts.common.user_instance_name_prefix -value PST_cts
clock_opt -from final_opto -to final_opto
##Gloabal PG connections
connect_pg_net -net v08 [get_pins -physical_context */VDD]
connect_pg_net -net vss [get_pins -physical_context */VSS]
report_clock_qor
report_timing
report_qor
check_legality
report_utilization
report_constraints  -all_violators
report_congestion
report_clock_qor
save_block -as post_cts
save_lib
#pre_route...................................
set_host_options -max_cores 16
set_scenario_status -active true [get_scenarios ]
report_app_options *si*enable*
set_app_options -name time.si_enable_analysis  -value true
report_app_options *timing*driven*
set_app_options -name route.detail.timing_driven -value true
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
report_app_options *cross*driven*
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.crosstalk_driven -value true
route_auto
##Gloabal PG connections
connect_pg_net -net v08 [get_pins -physical_context */VDD]
connect_pg_net -net vss [get_pins -physical_context */VSS]
check_routes
report_timing
check_legality
report_constraints  -all_violators
check_lvs
history
check_routes
report_qor
report_timing
check_legality
report_constraints  -all_violators
report_utilization
report_congestion
history
save_block -as pre_route
save_lib
#post_route.........................................................
set_host_options -max_cores 16
set_app_options -name time.si_enable_analysis  -value true
set_app_options -name route.detail.timing_driven -value true
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.crosstalk_driven -value true
set_clock_uncertainty [expr {5*0.12}] -scenarios [get_scenarios ] -setup [get_clocks clock]
set_clock_uncertainty 0.05 -scenarios [get_scenarios *setup* ] -hold [get_clocks clock]
set_clock_uncertainty 0.015 -scenarios [get_scenarios *hold* ] -hold [get_clocks clock]
set_app_options -name route_opt.flow.enable_ccd -value true
route_opt
##Gloabal PG connections
connect_pg_net -net v08 [get_pins -physical_context */VDD]
connect_pg_net -net vss [get_pins -physical_context */VSS]
check_lvs
check_routes
report_qor
report_timing
check_legality
report_constraints  -all_violators
report_utilization
report_global_timing
save_block -as post_route
save_lib
report_global_timing
report_clock_qor
report_qor
report_timing
report_utilization

