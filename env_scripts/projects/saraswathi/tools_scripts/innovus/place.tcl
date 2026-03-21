set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/floorplan
set cur_stage_dir $env(EXP_DIR)/pnr/place

set stage place
puts "MyInfo: Started $stage on $design_name @ [date]"

##Load init db
read_db ${prev_stage_dir}/outputs/floorplan.db

##Common settings
source ${tool_scripts}/innovus_common_settings.tcl

##placeopt
#set_cell_padding -cells BUFFD4BWP40P140 -right_side 4 -left_side 4 -top_side 1 -bottom_side 1
#add_io_buffers -exclude_clock_nets -exclude_nets_file ./scripts/high_drive_port.list  -port -status softfixed  -suffix IO_buff -in_cells BUFFD4BWP40P140 -out_cells BUFFD4BWP40P140
#add_io_buffers -include_nets_file ./scripts/clk_port.list  -port -status softfixed  -suffix CKIO_buff -in_cells CKBD8BWP40P140LVT -out_cells CKBD8BWP40P140LVT
#set_dont_touch [get_cells *IO_buff]
#delete_all_cell_padding
#set_inst_padding -inst *IO_buff -right_side 2 -left_side 2 -top_side 1 -bottom_side 1
##Antenna diode for input ports
#delete_all_cell_padding
#set cell_list {MUX2D4BWP40P140 ND2D6BWP40P140 NR2D6BWP40P140 INVD8BWP40P140 BUFFD8BWP40P140 BUFFD2BWP40P140 DEL025D1BWP40P140 TIEHBWP40P140 TIELBWP40P140 SDFCNQARD1BWP40P140}
#create_spare_module -cells $cell_list -module_name PNR_SPARE
#place_spare_modules -prefix PNR_spare_cell -module_name PNR_SPARE -step_x 50 -step_y 50 -offset_x 5 -offset_y 5 -density 0.4 -max_width 15


###Disable usage of high drive strength cells
set_dont_use [get_lib_cells {*D32BWP* *D24BWP* *D20BWP* *D18BWP* *D0BWP*}]
#
set_db place_detail_check_cut_spacing true
set_db place_detail_use_check_drc true
##User edits can be done in pre_place_opt.tcl and post_place_opt.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_place_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_place_opt.tcl
}
place_opt_design -report_dir ${cur_stage_dir}/reports/${stage} -report_prefix $stage
if {[file exists $env(BLOCK_SCRIPTS)/post_place_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_place_opt.tcl
}

#- Update the timer for setup and write reports
#time_design  -expanded_views -report_only -report_dir debug
source ${tool_scripts}/global_connections.tcl

##save database
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db

#Reports
source ${tool_scripts}/innovus_reports.tcl

exit
