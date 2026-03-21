#################pg################
ui_status "Creating power stripes"
#To remove existing vias
#update_power_vias -delete_vias true -top_layer M7 -bottom_layer M6 -nets {v09 vss}
#M8 & M9 extend till design boundary
set_db add_stripes_stacked_via_bottom_layer M8
set_db add_stripes_stacked_via_top_layer M9
add_stripes -layer M9 -set_to_set_distance 7.3 -width 3.0 -direction horizontal -nets {VSS VDD} -spacing 0.65 -start 0.9 -extend_to design_boundary

set_db add_stripes_stacked_via_bottom_layer M7
set_db add_stripes_stacked_via_top_layer M9
add_stripe -layer M8 -set_to_set_distance 7.3 -width 3.0 -direction vertical -nets {VSS VDD} -spacing 0.65 -start 0.84 -extend_to design_boundary

set_db add_stripes_stacked_via_top_layer M8
set_db add_stripes_stacked_via_bottom_layer M6
add_stripe -layer M7 -set_to_set_distance 5.0 -width 0.5 -direction horizontal -nets {VSS VDD} -spacing 0.16 -start 1.0

set_db add_stripes_stacked_via_top_layer M7
set_db add_stripes_stacked_via_bottom_layer M5
add_stripe -layer M6 -set_to_set_distance 5.0 -width 0.5 -direction vertical -nets {VSS VDD} -spacing 0.16 -start 1.0

###Avoid M5 stripes over macros as macro M4 pins are horizontal
foreach minst [get_db insts -if {.is_macro==true}] {
     set macro_name [get_db $minst .name]
     set bbox [get_db $minst .bbox]
     puts "Info: Creating routing blockage over $macro_name in $bbox"
     create_route_blockage -layer {M5 M4} -name RB_mem_ -rect $bbox
}

set_db add_stripes_stacked_via_top_layer M6
set_db add_stripes_stacked_via_bottom_layer M4
add_stripe -layer M5 -set_to_set_distance 1.8 -width 0.15 -direction horizontal -nets {VDD VSS} -spacing 0.6 -start 0.9

set_db add_stripes_stacked_via_top_layer M5
set_db add_stripes_stacked_via_bottom_layer M3
add_stripe -layer M4 -set_to_set_distance 1.8 -width 0.15 -direction vertical -nets {VSS VDD} -spacing 0.08 -start 0.84

set_db add_stripes_stacked_via_top_layer M4
set_db add_stripes_stacked_via_bottom_layer M1
ui_status "Routing special nets"
route_special -nets {VDD VSS} -allow_jogging false -allow_layer_change false -target_via_layer_range {1 4} -crossover_via_layer_range {M1 M4}
ui_info "Power stripes complete"

####To insert vias over macro pins
##delete existing routing blockages
delete_obj [get_db route_blockages RB_*]
ui_status "Adding power vias over macros"
foreach minst [get_db insts -if {.is_macro==true}] {
     set macro_name [get_db $minst .name]
     set bbox [get_db $minst .bbox]
     puts "Info: Creating PG vias over $macro_name in $bbox"
     update_power_vias -add true -top_layer M6 -bottom_layer M4 -nets {VDD VSS}
}
ui_info "Power vias added"
