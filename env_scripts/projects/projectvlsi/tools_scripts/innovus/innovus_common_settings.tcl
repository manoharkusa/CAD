

set TMPDIR /tmp

set_distributed_hosts -local
set_multi_cpu_usage -local_cpu 8

set_db design_process_node  28
set_db design_flow_effort   standard

set_db route_design_bottom_routing_layer 1
set_db route_design_top_routing_layer 7

#To avoid 1x gap
set_db place_detail_legalization_inst_gap 2
set_db add_fillers_no_single_site_gap true

##To control cell density
set_db place_global_max_density 0.6

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
  set_db route_design_process_node 28
  #set_glitch_threshold -pin_type all -failure_point {input} -glitch_type {both} -value 0.25
  set_db si_glitch_input_threshold 0.25
  set_db si_delay_enable_double_clocking_check true
  set_db si_enable_glitch_propagation true
  set_db si_glitch_enable_report true
}

# Tieoff attributes  [get_db -category add_tieoffs]
#-------------------------------------------------------------------------------
set_db add_tieoffs_cells              {TIEHBWP40P140HVT TIELBWP40P140HVT}

# Optimization attributes  [get_db -category opt]
#-------------------------------------------------------------------------------
set_db opt_new_inst_prefix            "PNR_${stage}_"

# Clock attributes  [get_db -category cts]
#-------------------------------------------------------------------------------
set_db cts_target_skew                0.1
set_db cts_target_max_transition_time 0.25
set_db cts_max_fanout    16

set_db cts_buffer_cells               {CKBD4BWP40P140LVT CKBD8BWP40P140LVT CKBD12BWP40P140LVT}
set_db cts_inverter_cells             {CKND4BWP40P140LVT CKND8BWP40P140LVT CKND12BWP40P140LVT}


if {[get_db route_types] ne ""} {
  set_db cts_route_type_leaf    "leaf"
  set_db cts_route_type_trunk   "trunk"
  set_db cts_route_type_top     "top"
}

###Hold fix cells
#set_db opt_hold_cells {gf180mcu_fd_sc_mcu7t5v0__dlya_1 gf180mcu_fd_sc_mcu7t5v0__dlya_2 gf180mcu_fd_sc_mcu7t5v0__dlya_4 gf180mcu_fd_sc_mcu7t5v0__dlyb_1 gf180mcu_fd_sc_mcu7t5v0__dlyb_2 gf180mcu_fd_sc_mcu7t5v0__dlyb_4 gf180mcu_fd_sc_mcu7t5v0__dlyc_1 gf180mcu_fd_sc_mcu7t5v0__dlyc_2 gf180mcu_fd_sc_mcu7t5v0__dlyc_4 gf180mcu_fd_sc_mcu7t5v0__dlyd_1 gf180mcu_fd_sc_mcu7t5v0__dlyd_2 gf180mcu_fd_sc_mcu7t5v0__dlyd_4 gf180mcu_fd_sc_mcu7t5v0__buf_1 gf180mcu_fd_sc_mcu7t5v0__buf_2 gf180mcu_fd_sc_mcu7t5v0__buf_3}

set_db add_fillers_cells {DCAP64BWP40P140 DCAP64BWP40P140HVT DCAP64BWP40P140LVT DCAP32BWP40P140HVT DCAP16BWP40P140HVT DCAP8BWP40P140HVT DCAP4BWP40P140HVT FILL32BWP40P140HVT FILL16BWP40P140HVT FILL8BWP40P140HVT FILL4BWP40P140HVT FILL3BWP40P140HVT FILL2BWP40P140HVT}

