
##To write a report
proc write_report { filename content } {
    set fp [open $filename w]
    puts $fp $content
    close $fp
}

##net_wire_lengths

set content ""

foreach_in_collection net [get_nets *] {
    set name    [get_db $net .name]
    set lengths [get_db $net .wires.length]

    set total 0.0
    foreach len $lengths {
        set total [expr {$total + $len}]
    }

    # Append to content instead of puts
    append content "$name : $total um\n"
}

##

# Build CTS layer usage report content
proc get_cts_layer_report {} {
    set lines {}

    lappend lines "########################################"
    lappend lines "# CTS Net Type Layer Usage Report"
    lappend lines "########################################"
    lappend lines ""
    lappend lines [format "%-12s %-20s %-20s %-10s" "NetType" "TopLayers" "BottomLayers" "NetCount"]
    lappend lines [string repeat "-" 65]

    foreach type {leaf trunk top} {
        set nets [get_db nets -if ".cts_net_type == $type"]

        if {[llength $nets] == 0} {
            lappend lines [format "%-12s %-20s %-20s %-10s" $type "N/A" "N/A" "0"]
            continue
        }

        set top_layers [join [lsort -unique [get_db $nets .top_preferred_layer.name]]  ","]
        set bot_layers [join [lsort -unique [get_db $nets .bottom_preferred_layer.name]] ","]
        set net_count  [llength $nets]

        lappend lines [format "%-12s %-20s %-20s %-10s" $type $top_layers $bot_layers $net_count]
    }

    lappend lines [string repeat "-" 65]
    return [join $lines "\n"]
}

##clock net drcs
select_routes -use clock

check_drc -check_only selected_net -out_file ../reports/clock_net_drcs.rpt

deselect_routes


proc get_macro_halo_report {} {

    set lines {}

    lappend lines "########################################"
    lappend lines "# Macro Halo Report"
    lappend lines "########################################"
    lappend lines ""
    lappend lines [format "%-25s %-30s %-30s %-10s" "MacroName" "BBox" "HaloBBox" "Halo"]
    lappend lines [string repeat "-" 100]

    # get all macros (insts which are macros)
    set macros [get_db insts -if ".is_macro == true"]

    if {[llength $macros] == 0} {
        lappend lines "No macros found in design"
        return [join $lines "\n"]
    }

    foreach macro $macros {

        set name [get_db $macro .name]

        set bbox [get_db $macro .bbox]
        set halo_bbox [get_db $macro .place_halo_bbox]

        # convert to string for comparison
        set bbox_str [join $bbox ","]
        set halo_str [join $halo_bbox ","]

        if {$bbox_str ne $halo_str} {
            set halo_status "YES"
        } else {
            set halo_status "NO"
        }

        lappend lines [format "%-25s %-30s %-30s %-10s" \
            $name $bbox_str $halo_str $halo_status]
    }

    lappend lines [string repeat "-" 100]

    return [join $lines "\n"]
}

##cts cells usage
# Expected cells
set expected_cells {
    CKBD4BWP40P140LVT CKBD8BWP40P140LVT CKBD12BWP40P140LVT
    CKND4BWP40P140LVT CKND8BWP40P140LVT CKND12BWP40P140LVT
}

# Get used cells
set used_bufs [get_db [get_db insts -if {.base_cell.base_name == *CKBD*}] .base_cell.base_name]
set used_invs [get_db [get_db insts -if {.base_cell.base_name == *CKND*}] .base_cell.base_name]

set used_cells [lsort -unique [concat $used_bufs $used_invs]]

# Compare
set status "valid"

if {[llength $expected_cells] != [llength $used_cells]} {
    set status "not valid"
} else {
    foreach c $expected_cells {
        if {[lsearch -exact $used_cells $c] == -1} {
            set status "not valid"
            break
        }
    }
}

# Report message
if {$status eq "valid"} {
    set context "All CTS cell usage is valid"
} else {
    set context "CTS cell usage is NOT valid"
}



##Forbidden layers
set_db source_verbose false

# -- Output report file --------------------------------------
set rpt_file "../reports/forbidden_layer_check.rpt"
file mkdir reports
set fp [open $rpt_file w]

proc log {msg} {
    global fp
    puts $msg
    puts $fp $msg
}

# -- Get top/bottom layer number and convert to name ---------
set top_layer_num [get_db route_design_top_routing_layer]
set bot_layer_num [get_db route_design_bottom_routing_layer]
set top_layer     "M${top_layer_num}"
set bot_layer     "M${bot_layer_num}"

if {$top_layer_num eq ""} {
    log "ERROR: route_design_top_routing_layer not set -- cannot proceed"
    close $fp
    return
}

# -- Get all routing layer objects then names (two-step) -----
set all_layer_objs      [get_db layers -if {.type == routing}]
set routing_layer_names [get_db $all_layer_objs .name]

# -- Find top/bot layer index --------------------------------
set top_idx [lsearch $routing_layer_names $top_layer]
set bot_idx [lsearch $routing_layer_names $bot_layer]

if {$top_idx < 0} {
    log "ERROR: top layer '$top_layer' not found in: $routing_layer_names"
    close $fp
    return
}

# -- Build forbidden layer list (above top_layer) ------------
set forbidden_layers {}
for {set i [expr {$top_idx + 1}]} \
    {$i < [llength $routing_layer_names]} {incr i} {
    lappend forbidden_layers [lindex $routing_layer_names $i]
}

# -- Header --------------------------------------------------
log "###############################################################"
log "#  Forbidden Layer Check Report"
log "#  Design    : [get_db [get_db designs] .name]"
log "#  Bot Layer : $bot_layer (layer $bot_layer_num)"
log "#  Top Layer : $top_layer (layer $top_layer_num)"
log "#  All Layers: $routing_layer_names"
log "#  Forbidden : $forbidden_layers"
log "###############################################################\n"

if {[llength $forbidden_layers] == 0} {
    log "INFO: No forbidden layers above $top_layer -- PASS"
    close $fp
    puts "\nReport saved: $rpt_file"
    return
}

# -- Check all nets -------------------------------------------
set sig_violations  0
set clk_violations  0
set pg_skipped      0
set pg_net_names    {}

foreach fl $forbidden_layers {
    set layer_count($fl) 0
}

set violation_details {}

foreach net [get_db nets] {

    if {[get_db $net .is_power]} {
        incr pg_skipped
        lappend pg_net_names [get_db $net .name]
        continue
    }

    set net_name  [get_db $net .name]
    set is_clk    [get_db $net .is_clock]
    set type      [expr {$is_clk ? "CLOCK" : "SIGNAL"}]

    set wire_objs [get_db $net .wires]
    if {$wire_objs eq "" || $wire_objs eq "{}"} { continue }

    set used_layers [get_db $wire_objs .layer.name]

    foreach fl $forbidden_layers {
        if {[lsearch $used_layers $fl] >= 0} {
            incr layer_count($fl)
            lappend violation_details [list $net_name $fl $type]
            if {$is_clk} { incr clk_violations } \
            else          { incr sig_violations }
        }
    }
}

set total [expr {$sig_violations + $clk_violations}]

# ------------------------------------------------------------
# OVERALL SUMMARY
# ------------------------------------------------------------
log "\n[string repeat = 75]"
log "OVERALL SUMMARY"
log "[string repeat = 75]"
log [format "  %-35s %s" "Design"             "[get_db [get_db designs] .name]"]
log [format "  %-35s %s" "Allowed range"      "$bot_layer to $top_layer"]
log [format "  %-35s %s" "Forbidden layers"   "$forbidden_layers"]
log [format "  %-35s %d" "Power nets skipped"  $pg_skipped]
log [format "  %-35s %d" "Clock violations"   $clk_violations]
log [format "  %-35s %d" "Signal violations"  $sig_violations]
log [format "  %-35s %d" "Total violations"   $total]
log [format "  %-35s %s" "Status" \
    [expr {$total == 0 \
        ? "PASS -- no signal/clock routes above $top_layer" \
        : "FAIL -- $total nets routed on forbidden layers"}]]
log "[string repeat = 75]"

# ------------------------------------------------------------
# DETAIL 1 -- Power nets skipped
# ------------------------------------------------------------
log "\n[string repeat - 75]"
log "Power nets skipped (not checked):"
log "[string repeat - 75]"
foreach name $pg_net_names {
    log [format "  %s" $name]
}

# ------------------------------------------------------------
# DETAIL 2 -- Violations per forbidden layer
# ------------------------------------------------------------
log "\n[string repeat - 75]"
log "Violations per forbidden layer:"
log "[string repeat - 75]"
foreach fl $forbidden_layers {
    log [format "  %-12s : %d nets" $fl $layer_count($fl)]
}

# ------------------------------------------------------------
# DETAIL 3 -- Full violation list (only if violations > 0)
# ------------------------------------------------------------
if {$total > 0} {
    log "\n[string repeat - 75]"
    log "Violation details:"
    log "[string repeat - 75]"
    log [format "  %-50s %-12s %-10s" "Net" "Layer" "Type"]
    log "  [string repeat . 72]"
    foreach item $violation_details {
        log [format "  %-50s %-12s %-10s" \
            [lindex $item 0] \
            [lindex $item 1] \
            [lindex $item 2]]
    }
    log "  Total: $total violations"
}

log "\n[string repeat = 75]\n"

close $fp
puts "\nReport saved: $rpt_file"





