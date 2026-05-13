source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl
source $env(ENV_SCRIPTS)/common/yaml_utils.tcl
source $env(ENV_SCRIPTS)/common/pdk_loader.tcl

set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(EXP_DIR)/pnr/postroute
set cur_stage_dir $env(EXP_DIR)/pnr/chip_finish

set stage chip_finish
ui_stage_start $stage
ui_info "Design: $design_name"

ui_status "Loading post-route database"
read_db ${prev_stage_dir}/outputs/postroute.db
ui_info "Database loaded"

set OUTDIR ${cur_stage_dir}/outputs
set REPORTS_DIR ${cur_stage_dir}/reports
ui_status "Generating PNR outputs"

ui_status "Writing output netlists"
write_netlist -exclude_leaf_cells ${OUTDIR}/[get_db [current_design] .name].vg
write_netlist -include_pg_ports -exclude_leaf_cells ${OUTDIR}/[get_db [current_design] .name].pg.vg
write_netlist -include_phys_insts -include_pg_ports -exclude_leaf_cells ${OUTDIR}/[get_db [current_design] .name].fill.pg.vg
ui_info "Netlists written"

ui_status "Writing DEF files"
write_def ${OUTDIR}/[get_db [current_design] .name].def
write_def -routing ${OUTDIR}/[get_db [current_design] .name].IR.def
ui_info "DEF files written"

ui_status "Writing LEF abstract"
write_lef_abstract ${OUTDIR}/[get_db [current_design] .name]_abstract.lef

ui_status "Writing GDS stream"
write_stream ${OUTDIR}/[get_db [current_design] .name].pnr.gds.gz -map_file [dict get $metal_cfg gds_map_file innovus] -unit 1000
ui_info "GDS stream written"

##hcell list (for LVS)
if {[file exists ${OUTDIR}/hcell.list]} {file delete ${OUTDIR}/hcell.list}
foreach cl [lsort -unique [get_db insts .base_cell.name]] {puts "$cl $cl" >> ${OUTDIR}/hcell.list}

if {[file exists ${OUTDIR}/cdl_files.list]} {file delete ${OUTDIR}/cdl_files.list}
ui_info "Writing [llength $CELL_CDL] spice netlist to ${OUTDIR}/cdl_files.list"
foreach cdl_file $CELL_CDL {puts "$cdl_file" >> ${OUTDIR}/cdl_files.list }

##To generate merged GDS
ui_status "Generating merged GDS"
write_stream ${OUTDIR}/[get_db [current_design] .name].merged.gds.gz -merge $CELL_GDS  -map_file [dict get $metal_cfg gds_map_file innovus] -unit 1000
ui_info "Merged GDS generated"

write_db -sdc ${OUTDIR}/${stage}.db

write_parasitics -rc_corner cbest_m40 -spef_file  ${OUTDIR}/[get_db [current_design] .name].cbest_m40.spef.gz
write_parasitics -rc_corner rcbest_125 -spef_file  ${OUTDIR}/[get_db [current_design] .name].rcbest_125.spef.gz
write_parasitics -rc_corner cworst_m40 -spef_file  ${OUTDIR}/[get_db [current_design] .name].cworst_m40.spef.gz
write_parasitics -rc_corner rcworst_125 -spef_file  ${OUTDIR}/[get_db [current_design] .name].rcworst_125.spef.gz


write_sdc -view  func_ss125c_rcw  ${OUTDIR}/[get_db [current_design] .name].func_ss125c_rcw.sdc
write_sdc -view  func_ssm40c_cw  ${OUTDIR}/[get_db [current_design] .name].func_ssm40c_cw.sdc
write_sdc -view  func_ff125c_rcb  ${OUTDIR}/[get_db [current_design] .name].func_ff125c_rcb.sdc
write_sdc -view  func_ffm40c_cb  ${OUTDIR}/[get_db [current_design] .name].func_ffm40c_cb.sdc


check_connectivity -ignore_dangling_wires > ${REPORTS_DIR}/check_connectivity.rpt
check_drc > ${REPORTS_DIR}/check_drc.rpt
check_filler > ${REPORTS_DIR}/check_filler.rpt
report_timing_summary -checks drv > ${REPORTS_DIR}/report_timing_summary.drv.checks.rpt


ui_info "Chip finish complete"
ui_stage_end $stage "success"
exec touch ${cur_stage_dir}/work/${stage}_flow_complete
exit
