process_technology \
	-temperature -40 125 -40 125 25 125 125 \
	-technology_library_file techlib.defs \
	-technology_name tsmc28 \
	-technology_corner cworst rcworst cbest rcbest typical cworst cbest


output_setup -compressed true -directory_name outputs -temporary_directory_name qrc_tmp -file_name $env(BLOCK_NAME) 

##Path to qrc map file...
#include library/qrc.map
input_db -type def -design_file ./inputs/$env(BLOCK_NAME).IR.def \
	 -lef_file_list_file $env(ENV_SCRIPTS)/quantus/lef_file.txt

output_db -type spef -subtype extended -output_incomplete_nets true -output_unrouted_nets true

parasitic_reduction -enable_reduction false

extract -selection all -type rc_coupled

log_file -file_name ./logs/quantus.log -dump_options true

filter_coupling_cap \
         -cap_filtering_mode "absolute_and_relative" \
         -coupling_cap_threshold_absolute 0.1 \
         -coupling_cap_threshold_relative 1.0 \
         -total_cap_threshold 0.0


distributed_processing -multi_cpu 2
extraction_setup -stream_layer_map_file $env(ENV_SCRIPTS)/quantus/layer_map.txt 

input_db -type metal_fill -metal_fill_top_cell $env(BLOCK_NAME)_BEOL_fill -gds_file $env(PV_BASE_DIR)/beol_fill/outputs/$env(BLOCK_NAME)_BEOL.gds
metal_fill -type floating 
