set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/route
set cur_stage_dir $env(EXP_DIR)/pnr/postroute


set stage postroute
puts "MyInfo: Started $stage on $design_name @ [date]"

read_db ${prev_stage_dir}/outputs/route.db

##Common settings
source ${tool_scripts}/innovus_common_settings.tcl
#

##############################################################################
# STEP run_opt_postroute
##############################################################################
##User edits can be done in pre_postroute_opt.tcl and post_postroute_opt.tcl
if {[file exists $env(BLOCK_SCRIPTS)/pre_postroute_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/pre_postroute_opt.tcl
}
opt_design -post_route -setup -hold -report_dir ./reports -report_prefix $stage
if {[file exists $env(BLOCK_SCRIPTS)/post_postroute_opt.tcl]} {
    source $env(BLOCK_SCRIPTS)/post_postroute_opt.tcl
}
opt_design -post_route -hold -report_dir ./reports -report_prefix ${stage}.hold
set_db write_db_save_timing_contraints_always true

source ${tool_scripts}/global_connections.tcl

##save database
write_db -sdc ${cur_stage_dir}/outputs/${stage}.db
#
##Reports
source ${tool_scripts}/innovus_reports.tcl
exit

