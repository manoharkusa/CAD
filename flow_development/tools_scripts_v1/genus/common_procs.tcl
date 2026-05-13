proc generate_high_drive_cell_report {report_dir} {

    set rpt "$report_dir/high_drive_cell_check.rpt"
    set fh [open $rpt w]

    puts $fh "High Drive Cell Check Report"
    puts $fh "Design: [get_db current_design]"
    puts $fh "Date: [clock format [clock seconds]]"
    puts $fh "-------------------------------------"

    # Configurable list of high drive strength cells
    set highdrive_strength_cells {D18 D20 D24 D32}

    # Dictionary to store results per drive strength
    array set drive_cells {}

    # Search for each drive strength
    foreach drv $highdrive_strength_cells {
        set drive_cells($drv) [get_db insts -if ".base_cell.base_name =~ *$drv*"]
    }

    # Check if all lists are empty
    set found 0
    foreach drv $highdrive_strength_cells {
        if { [llength $drive_cells($drv)] > 0 } {
            set found 1
            break
        }
    }

    if { $found == 0 } {
        puts $fh "PASS: No high drive strength cells found in the design."
    } else {
        puts $fh "FAIL: High drive cells found!"

        foreach drv $highdrive_strength_cells {
            if { [llength $drive_cells($drv)] > 0 } {
                puts $fh "\n$drv Cells:"
                foreach inst $drive_cells($drv) {
                    puts $fh $inst
                }
            }
        }
    }

    close $fh
    puts "Report generated: $rpt"
}
