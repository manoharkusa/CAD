set stage postroute
set OUTDIR ./outputs/
ui_status "Generating PNR outputs at $stage stage"

ui_status "Writing output netlists"
write_netlist -exclude_leaf_cells ${OUTDIR}/${stage}/[get_db [current_design] .name].vg
write_netlist -include_pg_ports -exclude_leaf_cells ${OUTDIR}/${stage}/[get_db [current_design] .name].pg.vg
write_netlist -include_phys_insts -include_pg_ports -exclude_leaf_cells ${OUTDIR}/${stage}/[get_db [current_design] .name].fill.pg.vg
ui_info "Netlists written"

ui_status "Writing DEF files"
write_def ${OUTDIR}/${stage}/[get_db [current_design] .name].def
write_def -routing ${OUTDIR}/${stage}/[get_db [current_design] .name].IR.def
ui_info "DEF files written"

ui_status "Writing LEF abstract"
write_lef_abstract ${OUTDIR}/${stage}/[get_db [current_design] .name]_abstract.lef

ui_status "Writing GDS stream"
write_stream ${OUTDIR}/${stage}/[get_db [current_design] .name].pnr.gds.gz -map_file /proj1/dataIn/Rock_R2G/TSMC_28nm_collaterals/PDK/apr/PRTF_EDI_28nm_Cad_V19_1a/PR_tech/Cadence/GdsOutMap/gdsout_6X2Z.map -unit 1000
ui_info "GDS stream written"

##hcell list (for LVS)
if {[file exists ${OUTDIR}/${stage}/hcell.list]} {[file delete ${OUTDIR}/${stage}/hcell.list] }
foreach cl [lsort -unique [get_db insts .base_cell.name]] {puts "$cl $cl" >> ${OUTDIR}/${stage}/hcell.list}

###setting effort level signoff to generate spefs from Quantus
if {[regexp postroute $stage]} {
###Write no dummy fill spef only during postroute stage
ui_status "Extracting parasitics"
set_db extract_rc_effort_level signoff
extract_rc
foreach rcm [get_db rc_corners .name] {
        write_parasitics -rc_corner $rcm -spef_file ${OUTDIR}/${stage}/[get_db [current_design] .name].$rcm.spef
}
ui_info "Parasitic extraction complete"
}

##To generate merged GDS
ui_status "Generating merged GDS"
write_stream ${OUTDIR}/${stage}/[get_db [current_design] .name].merged.gds.gz -merge {/proj1/pd/users/testcase/Bharath/gf_data_processing/combined_gds/gf180mcu_fd_sc_mcu7t5v0_all_std_cells.gds /proj1/pd/users/testcase/Bharath/GF180_PDK/gf180mcu-pdk/macros/gf180mcu_fd_ip_sram/latest/cells/gf180mcu_fd_ip_sram__sram128x8m8wm1/gf180mcu_fd_ip_sram__sram128x8m8wm1.gds /proj1/pd/users/testcase/Bharath/GF180_PDK/gf180mcu-pdk/macros/gf180mcu_fd_ip_sram/latest/cells/gf180mcu_fd_ip_sram__sram512x8m8wm1/gf180mcu_fd_ip_sram__sram512x8m8wm1.gds /home/bharath/Downloads/RING_PAD.gds} -map_file /proj1/pd/users/testcase/Bharath/GF180_PDK/innovus_gdsout.map -unit 1000
ui_info "Merged GDS generated"

ui_status "Generating dummy fill GDS"
run_pvs_metal_fill -rule_file "/proj/users/deva/rockley_rp_top/pdk_local/PDK/dummy_fill/Dummy_Metal_Via_PVS_28nm.20a.encrypt" -stream_file "${OUTDIR}/${stage}/[get_db [current_design] .name].merged.gds.gz" -cell "[get_db [current_design] .name]" -distributed 16 -def_out_file [get_db [current_design] .name].fill.def -def_map_file ./scripts/def_map_fill.file -keep_pvs_output -no_via_fills -working_dir ../PV/dummyfill
ui_info "Dummy fill complete"

ui_status "Reading dummy fill DEF"
read_def ../PV/dummyfill/[get_db [current_design] .name].fill.def

ui_status "Writing final merged GDS with fill"
write_stream ${OUTDIR}/${stage}/[get_db [current_design] .name].merged.fill.gds.gz -merge {/proj1/dataIn/Rock_R2G/TSMC_28nm_collaterals/std_cells_and_memory/tsmc28nm_9track_hvt_BE_FE/TSMCHOME/digital/Back_End/gds/tcbn28hpcplusbwp30p140hvt_110a/tcbn28hpcplusbwp30p140hvt.gds /proj1/dataIn/Rock_R2G/TSMC_28nm_collaterals/std_cells_and_memory/ts1n28hpcpuhdhvtb2048x129m4swbso_170a/GDSII/ts1n28hpcpuhdhvtb2048x129m4swbso_170a.gds /proj1/dataIn/Rock_R2G/TSMC_28nm_collaterals/std_cells_and_memory/tsdn28hpcpuhdb4096x33m4mwa_170a/GDSII/tsdn28hpcpuhdb4096x33m4mwa_170a.gds} -map_file /proj1/dataIn/Rock_R2G/TSMC_28nm_collaterals/PDK/apr/PRTF_EDI_28nm_Cad_V19_1a/PR_tech/Cadence/GdsOutMap/gdsout_6X2Z.map -unit 1000
ui_info "Final GDS with fill generated"

ui_status "Extracting parasitics with dummy fill"
set_db extract_rc_effort_level signoff
extract_rc
foreach rcm [get_db rc_corners .name] {
        write_parasitics -rc_corner $rcm -spef_file ${OUTDIR}/${stage}/[get_db [current_design] .name].dmfill.$rcm.spef
}
ui_info "Parasitic extraction with fill complete"
