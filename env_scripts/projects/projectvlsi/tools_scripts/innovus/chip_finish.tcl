
set design_name $env(BLOCK_NAME)
set tool_scripts $env(ENV_SCRIPTS)/innovus
set prev_stage_dir $env(POSTROUTE_DIR)
set cur_stage_dir $env(CHIP_FINISH_DIR)

set stage chip_finish

read_db ${prev_stage_dir}/outputs/postroute.db

set OUTDIR ${cur_stage_dir}/outputs
puts "INFO: Generating PNR outputs at $stage stage"

write_netlist -exclude_leaf_cells ${OUTDIR}/[get_db [current_design] .name].vg
write_netlist -include_pg_ports -exclude_leaf_cells ${OUTDIR}/[get_db [current_design] .name].pg.vg
write_netlist -include_phys_insts -include_pg_ports -exclude_leaf_cells ${OUTDIR}/[get_db [current_design] .name].fill.pg.vg
write_def ${OUTDIR}/[get_db [current_design] .name].def
write_def -routing ${OUTDIR}/[get_db [current_design] .name].IR.def
write_lef_abstract ${OUTDIR}/[get_db [current_design] .name]_abstract.lef
write_stream ${OUTDIR}/[get_db [current_design] .name].pnr.gds.gz -map_file /proj1/dataIn/Rock_R2G/TSMC_28nm_collaterals/PDK/apr/PRTF_EDI_28nm_Cad_V19_1a/PR_tech/Cadence/GdsOutMap/gdsout_4X2Y2R.map -unit 1000
##hcell list (for LVS)
if {[file exists ${OUTDIR}/hcell.list]} {[file delete ${OUTDIR}/hcell.list] }
foreach cl [lsort -unique [get_db insts .base_cell.name]] {puts "$cl $cl" >> ${OUTDIR}/hcell.list}

##To generate merged GDS
write_stream ${OUTDIR}/[get_db [current_design] .name].merged.gds.gz -merge {/proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140lvt_180b/AN61001_20180509/TSMCHOME/digital/Back_End/gds/tcbn28hpcplusbwp40p140lvt_110a/tcbn28hpcplusbwp40p140lvt.gds /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140_180b/AN61001_20180509/TSMCHOME/digital/Back_End/gds/tcbn28hpcplusbwp40p140_110a/tcbn28hpcplusbwp40p140.gds /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140hvt_180a/AN61001_20180829/TSMCHOME/digital/Back_End/gds/tcbn28hpcplusbwp40p140hvt_110a/tcbn28hpcplusbwp40p140hvt.gds} -map_file /proj1/dataIn/Rock_R2G/TSMC_28nm_collaterals/PDK/apr/PRTF_EDI_28nm_Cad_V19_1a/PR_tech/Cadence/GdsOutMap/gdsout_4X2Y2R.map -unit 1000

exit
