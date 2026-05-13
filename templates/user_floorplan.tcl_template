create_floorplan -stdcell_density_size {1.0 0.5 0.9 0.84 0.9 0.84}

##port placement
edit_pin -edge 1 -layer {M2 M4} -spread_direction clockwise -pattern fill_layer -pin [get_db [get_ports *] .name] -offset_start 10 -fix_overlap 1 -pin_depth 1.0 -spacing 2
#
###macro placement
#source ./scripts/macro_placement.tcl
#
##read_def /proj/users/syed/03SYN09MBIST/release_to_pd_postscan_0905/rp_top_top_netlist_scn.def 
###Macro halos
#create_place_halo -halo_deltas 1.4 1.2 1.4 1.2 -snap_to_site -all_macros
###Hard placement blockages
##create_place_blockage -type hard -area {1003.04 20.1 1380 321.8} -name PB_HARD1
###Soft blockages in channel regions
#create_place_blockage -type soft -area {0.84 319.26050 164.14200 339.60200} -name PB_SOFT1
#create_place_blockage -type soft -area {656 319.26050 820 339.60200} -name PB_SOFT2
#
