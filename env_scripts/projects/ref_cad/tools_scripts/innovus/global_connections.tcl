

set pwr_net [dict get $PROJ_PDK power_net]
set gnd_net [dict get $PROJ_PDK ground_net]
connect_global_net $pwr_net -type pgpin -pin VDD -inst *
connect_global_net $gnd_net -type pgpin -pin VSS -inst *
connect_global_net $pwr_net -type tiehi
connect_global_net $gnd_net -type tielo

##User edits can be done in global_connections_block.tcl
if {[file exists $env(BLOCK_SCRIPTS)/global_connections_block.tcl]} {
    source $env(BLOCK_SCRIPTS)/global_connections_block.tcl
}

