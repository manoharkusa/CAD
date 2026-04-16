

set TMPDIR /tmp

set_distributed_hosts -local
set_multi_cpu_usage -local_cpu 8

set_db design_process_node  [dict get $PROJ_PDK node]
set_db design_flow_effort   standard

set_db design_bottom_routing_layer [dict get $PROJ_PDK bottom_signal_routing_layer]
set_db design_top_routing_layer [dict get $PROJ_PDK top_signal_routing_layer]

#To avoid 1x gap
set_db place_detail_legalization_inst_gap 2
set_db add_fillers_no_single_site_gap true

##To control cell density
set_db place_global_max_density 0.7

#To avoid 1x gap
#set_db place_detail_legalization_inst_gap 2
#set_db add_fillers_no_single_site_gap true

# Timing attributes  [get_db -category timing && delaycalc]
#-------------------------------------------------------------------------------
set_db timing_analysis_cppr           both
set_db timing_analysis_type           ocv

if [regexp "route" $stage] {
  set_db delaycal_enable_si           true
  set_db extract_rc_engine            post_route
  set_db extract_rc_effort_level      high 
  set_db extract_rc_qrc_run_mode sequential
  set_db route_design_process_node [dict get $PROJ_PDK node]
  #set_glitch_threshold -pin_type all -failure_point {input} -glitch_type {both} -value 0.25
  set_db si_glitch_input_threshold 0.25
  set_db si_delay_enable_double_clocking_check true
  set_db si_enable_glitch_propagation true
  set_db si_glitch_enable_report true
}

# Tieoff attributes  [get_db -category add_tieoffs]
#-------------------------------------------------------------------------------
set tie_high_cell [dict get $PROJ_PDK tie_high_cell]
set tie_low_cell [dict get $PROJ_PDK tie_low_cell]
set_db add_tieoffs_cells              [list $tie_high_cell $tie_low_cell]

# Optimization attributes  [get_db -category opt]
#-------------------------------------------------------------------------------
set_db opt_new_inst_prefix            "PNR_${stage}_"

# Clock attributes  [get_db -category cts]
#-------------------------------------------------------------------------------
set_db cts_target_skew                [dict get $PROJ_PDK cts target_skew]
set_db cts_target_max_transition_time [dict get $PROJ_PDK cts clock_tran_limit]
set_db cts_max_fanout    [dict get $PROJ_PDK cts max_fanout]

set_db cts_buffer_cells  [dict get $PROJ_PDK cts_buffers] 
set_db cts_inverter_cells [dict get $PROJ_PDK cts_inverters] 


if {[get_db route_types] ne ""} {
  set_db cts_route_type_leaf    "leaf"
  set_db cts_route_type_trunk   "trunk"
  set_db cts_route_type_top     "top"
}

###Hold fix cells
#set_db opt_hold_cells {gf180mcu_fd_sc_mcu7t5v0__dlya_1 gf180mcu_fd_sc_mcu7t5v0__dlya_2 gf180mcu_fd_sc_mcu7t5v0__dlya_4 gf180mcu_fd_sc_mcu7t5v0__dlyb_1 gf180mcu_fd_sc_mcu7t5v0__dlyb_2 gf180mcu_fd_sc_mcu7t5v0__dlyb_4 gf180mcu_fd_sc_mcu7t5v0__dlyc_1 gf180mcu_fd_sc_mcu7t5v0__dlyc_2 gf180mcu_fd_sc_mcu7t5v0__dlyc_4 gf180mcu_fd_sc_mcu7t5v0__dlyd_1 gf180mcu_fd_sc_mcu7t5v0__dlyd_2 gf180mcu_fd_sc_mcu7t5v0__dlyd_4 gf180mcu_fd_sc_mcu7t5v0__buf_1 gf180mcu_fd_sc_mcu7t5v0__buf_2 gf180mcu_fd_sc_mcu7t5v0__buf_3}

set dcap_filler_list [dict get $PROJ_PDK decap_fillers]
set plain_filler_list [dict get $PROJ_PDK plain_fillers]

set_db add_fillers_cells [concat $dcap_filler_list $plain_filler_list] 

