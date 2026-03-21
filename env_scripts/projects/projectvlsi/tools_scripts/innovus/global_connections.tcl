connect_global_net VDD -type pgpin -pin VDD -inst *
connect_global_net VSS -type pgpin -pin VSS -inst *
connect_global_net VDD -type tiehi
connect_global_net VSS -type tielo

##User edits can be done in global_connections_block.tcl
if {[file exists $env(BLOCK_SCRIPTS)/global_connections_block.tcl]} {
    source $env(BLOCK_SCRIPTS)/global_connections_block.tcl
}

