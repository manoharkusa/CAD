set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/postcts
set cur_stage_dir $env(EXP_DIR)/pnr/route


set stage route
puts "MyInfo: Started $stage on $design_name @ [date]"

read_db ${prev_stage_dir}/outputs/postcts.db



##Common settings
source ${tool_scripts}/innovus_common_settings.tcl
#set_db route_design_via_weight {VIA23_2cut_P2_BLC -1}

##############################################################################
# STEP add_fillers
##############################################################################
  #- insert filler cells before final routing
  if {[get_db add_fillers_cells] ne "" } {
    ##Total decap of 1nF
    #add_decaps -total_cap 1000000 -prefix decap_fill -cells {DCAP4BWP30P140HVT DCAP8BWP30P140HVT DCAP16BWP30P140HVT DCAP32BWP30P140HVT DCAP64BWP30P140HVT}
    add_fillers -fill_gap
    check_filler 
  }

##############################################################################
# STEP run_route
##############################################################################
  #- perform detail routing and DRC cleanup
  ##To insert multi cut via
  set_db route_design_detail_use_multi_cut_via_effort low
  set_db route_design_reserve_space_for_multi_cut true
  ##User edits can be done in pre_route.tcl and post_route.tcl
  if {[file exists $env(BLOCK_SCRIPTS)/pre_route.tcl]} {
      source $env(BLOCK_SCRIPTS)/pre_route.tcl
  }
  route_design
  if {[file exists $env(BLOCK_SCRIPTS)/post_route.tcl]} {
      source $env(BLOCK_SCRIPTS)/post_route.tcl
  }
  set_db route_design_detail_post_route_swap_via true
  set_db route_design_with_timing_driven false
  route_design -via_opt
  set_db route_design_with_timing_driven true
  

source ${tool_scripts}/global_connections.tcl

##save database
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db
#
##Reports
source ${tool_scripts}/innovus_reports.tcl
exit
