# ==============================================================================
# YAML Configuration Helper Functions - Simplified
# ==============================================================================
# Provides accessor and helper functions for YAML configuration
#
# Generic Accessors (4):
#   - zget_tconfig_var    - Get from TECH_CONFIG
#   - zget_pconfig_var    - Get from PROJECT_CONFIG
#   - zget_mconfig_var    - Get from METAL_STACK_CONFIG
#   - zget_vconfig_var    - Get from VT_CONFIGS
#
# Complex Helpers (5):
#   - zget_lib_paths      - Build library list from enabled VTs
#   - zget_lef_paths      - Collect LEFs from enabled VTs
#   - zget_gds_paths      - Collect GDS from enabled VTs
#   - zget_filler_cells   - Merge and deduplicate fillers
#   - zget_cts_cells      - Get CTS buffers/inverters
#
# SRAM Functions (6):
#   - zget_all_sram_lefs     - Get all SRAM LEF files
#   - zget_all_sram_libs     - Get all SRAM timing libs for corner
#   - zget_all_sram_gds      - Get all SRAM GDS files
#   - zget_all_sram_verilog  - Get all SRAM Verilog models
#   - zhas_sram_macros       - Check if block has SRAMs
#   - zshow_sram_summary     - Display SRAM summary
#
# Prerequisites:
#   - Source yaml_config_reader.tcl
#   - Call init_yaml_configs
#   - Global variables: TECH_CONFIG, PROJECT_CONFIG, METAL_STACK_CONFIG, VT_CONFIGS
# ==============================================================================

# ==============================================================================
# Generic Config Accessors
# ==============================================================================

proc zget_tconfig_var {args} {
    # Get value from TECH_CONFIG
    # Usage: zget_tconfig_var technology name
    global TECH_CONFIG
    return [dict get $TECH_CONFIG {*}$args]
}

proc zget_pconfig_var {args} {
    # Get value from PROJECT_CONFIG (includes block overrides)
    # Usage: zget_pconfig_var synthesis_settings corner
    global PROJECT_CONFIG
    return [dict get $PROJECT_CONFIG {*}$args]
}

proc zget_mconfig_var {args} {
    # Get value from METAL_STACK_CONFIG
    # Usage: zget_mconfig_var pdk_files tech_lef
    global METAL_STACK_CONFIG
    return [dict get $METAL_STACK_CONFIG {*}$args]
}

proc zget_vconfig_var {vt_type args} {
    # Get value from VT_CONFIGS for a specific VT type
    # Usage: zget_vconfig_var SVT pdk_files lef
    global VT_CONFIGS
    set vt_config [dict get $VT_CONFIGS $vt_type]
    return [dict get $vt_config {*}$args]
}

# ==============================================================================
# Complex Helper Functions
# ==============================================================================

proc zget_lib_paths {stage corner} {
    # Get library paths for enabled VT types for a stage and corner
    # Usage: zget_lib_paths synthesis slow0p81vm40c
    # Returns: List of full library paths

    global VT_CONFIGS

    # Get enabled VT types for this stage
    set enabled_vts [zget_pconfig_var vt_configuration per_stage_control $stage enabled_vt_types]

    # Build library list
    set lib_list {}
    foreach vt_type $enabled_vts {
        if {[dict exists $VT_CONFIGS $vt_type]} {
            set base_path [zget_vconfig_var $vt_type stdcell timing_libs base_path]
            set lib_file [zget_vconfig_var $vt_type stdcell timing_libs $corner]
            lappend lib_list "$base_path/$lib_file"
        }
    }

    return $lib_list
}

proc zget_lef_paths {stage} {
    # Get LEF paths for enabled VT types for a stage
    # Usage: zget_lef_paths synthesis
    # Returns: List of LEF file paths

    global VT_CONFIGS

    set enabled_vts [zget_pconfig_var vt_configuration per_stage_control $stage enabled_vt_types]

    set lef_list {}
    foreach vt_type $enabled_vts {
        if {[dict exists $VT_CONFIGS $vt_type]} {
            lappend lef_list [zget_vconfig_var $vt_type stdcell pdk_files lef]
        }
    }

    return $lef_list
}

proc zget_gds_paths {stage} {
    # Get GDS paths for enabled VT types for a stage
    # Usage: zget_gds_paths place
    # Returns: List of GDS file paths

    global VT_CONFIGS

    set enabled_vts [zget_pconfig_var vt_configuration per_stage_control $stage enabled_vt_types]

    set gds_list {}
    foreach vt_type $enabled_vts {
        if {[dict exists $VT_CONFIGS $vt_type]} {
            lappend gds_list [zget_vconfig_var $vt_type stdcell pdk_files gds]
        }
    }

    return $gds_list
}

# ==============================================================================
# Physical Cells Helper Functions
# ==============================================================================

proc zget_filler_cells {stage} {
    # Get filler cells from all enabled VT types (merged and deduplicated)
    # Usage: zget_filler_cells place
    # Returns: Sorted unique list of filler cell names

    global VT_CONFIGS

    set enabled_vts [zget_pconfig_var vt_configuration per_stage_control $stage enabled_vt_types]
    set all_fillers {}

    foreach vt_type $enabled_vts {
        if {[dict exists $VT_CONFIGS $vt_type]} {
            set vt_config [dict get $VT_CONFIGS $vt_type]
            if {[dict exists $vt_config physical_cells fillers]} {
                set fillers [zget_vconfig_var $vt_type physical_cells fillers]
                set all_fillers [concat $all_fillers $fillers]
            }
        }
    }

    return [lsort -unique $all_fillers]
}

proc zget_cts_cells {cell_type} {
    # Get CTS cells (buffers or inverters) - typically from LVT
    # Usage: zget_cts_cells buffers  OR  zget_cts_cells inverters
    # Returns: List of CTS cell names

    global VT_CONFIGS

    # Map cell_type to actual dict key
    if {$cell_type eq "buffers"} {
        set dict_key "cts_buffers"
    } elseif {$cell_type eq "inverters"} {
        set dict_key "cts_inverters"
    } else {
        error "Invalid cell_type: $cell_type. Use 'buffers' or 'inverters'"
    }

    # CTS cells typically from LVT
    if {[dict exists $VT_CONFIGS LVT]} {
        if {[catch {zget_vconfig_var LVT physical_cells $dict_key} result] == 0} {
            return $result
        }
    }

    return {}
}

# ==============================================================================
# SRAM Macro Query Functions
# ==============================================================================

proc zget_all_sram_lefs {} {
    # Get all SRAM LEF files (unique list)
    global SRAM_MACRO_TYPES
    set lef_list {}

    dict for {macro_type macro_def} $SRAM_MACRO_TYPES {
        if {[dict exists $macro_def macro pdk_files lef]} {
            lappend lef_list [dict get $macro_def macro pdk_files lef]
        }
    }
    return [lsort -unique $lef_list]
}

proc zget_all_sram_libs {corner_name} {
    # Get all SRAM timing libraries for specific corner (unique list)
    global SRAM_MACRO_TYPES
    set lib_list {}

    dict for {macro_type macro_def} $SRAM_MACRO_TYPES {
        if {[dict exists $macro_def macro timing_libs $corner_name]} {
            set lib_file [dict get $macro_def macro timing_libs $corner_name]
            set base_path [dict get $macro_def macro timing_libs base_path]
            lappend lib_list "$base_path/$lib_file"
        }
    }
    return [lsort -unique $lib_list]
}

proc zget_all_sram_gds {} {
    # Get all SRAM GDS files (unique list)
    global SRAM_MACRO_TYPES
    set gds_list {}

    dict for {macro_type macro_def} $SRAM_MACRO_TYPES {
        if {[dict exists $macro_def macro pdk_files gds]} {
            lappend gds_list [dict get $macro_def macro pdk_files gds]
        }
    }
    return [lsort -unique $gds_list]
}

proc zget_all_sram_verilog {} {
    # Get all SRAM Verilog files (unique list)
    global SRAM_MACRO_TYPES
    set verilog_list {}

    dict for {macro_type macro_def} $SRAM_MACRO_TYPES {
        if {[dict exists $macro_def macro pdk_files verilog]} {
            lappend verilog_list [dict get $macro_def macro pdk_files verilog]
        }
    }
    return [lsort -unique $verilog_list]
}

proc zhas_sram_macros {} {
    # Check if block has SRAM macros
    global SRAM_MACRO_TYPES
    return [expr {[dict size $SRAM_MACRO_TYPES] > 0}]
}

proc zget_sram_macro_types {} {
    # Get list of unique macro types used in this block
    global SRAM_MACRO_TYPES
    return [dict keys $SRAM_MACRO_TYPES]
}

proc zshow_sram_summary {} {
    # Print SRAM summary
    global SRAM_MACRO_TYPES

    puts "\n===================================================================="
    puts "SRAM Macro Summary"
    puts "===================================================================="

    if {[dict size $SRAM_MACRO_TYPES] == 0} {
        puts "No SRAM macros in this block"
        puts "===================================================================="
        return
    }

    puts "Total macro types: [dict size $SRAM_MACRO_TYPES]\n"

    dict for {macro_type macro_def} $SRAM_MACRO_TYPES {
        puts "Macro Type: $macro_type"

        if {[dict exists $macro_def macro configuration depth] && [dict exists $macro_def macro configuration width]} {
            set depth [dict get $macro_def macro configuration depth]
            set width [dict get $macro_def macro configuration width]
            puts "  Size:        ${depth} x ${width}"
        }

        if {[dict exists $macro_def macro pdk_files lef]} {
            set lef [dict get $macro_def macro pdk_files lef]
            puts "  LEF:         [file tail $lef]"
        }

        if {[dict exists $macro_def macro pdk_files gds]} {
            set gds [dict get $macro_def macro pdk_files gds]
            puts "  GDS:         [file tail $gds]"
        }

        puts ""
    }

    puts "===================================================================="
}

# ==============================================================================
# Block Override Inspector
# ==============================================================================

proc zlist_block_overrides {} {
    # List all top-level keys defined in block config
    # These represent sections that override project defaults
    # Usage: zlist_block_overrides
    # Returns: List of top-level keys in BLOCK_CONFIG

    global BLOCK_CONFIG

    if {[dict size $BLOCK_CONFIG] == 0} {
        return {}
    }

    return [dict keys $BLOCK_CONFIG]
}

proc zshow_block_overrides {} {
    # Show which sections are overridden by block config
    # Usage: zshow_block_overrides

    global BLOCK_CONFIG

    puts "\n===================================================================="
    puts "Block Configuration Overrides"
    puts "===================================================================="

    if {[dict size $BLOCK_CONFIG] == 0} {
        puts "No block config - using all project defaults"
        puts "===================================================================="
        return
    }

    set overrides [dict keys $BLOCK_CONFIG]
    puts "Block config defines [llength $overrides] section(s):\n"

    foreach key $overrides {
        puts "  • $key"

        # Show nested keys for better visibility
        set value [dict get $BLOCK_CONFIG $key]
        if {[string is list $value] && [llength $value] % 2 == 0 && [llength $value] > 0} {
            # It's a dict - show top-level keys
            catch {
                dict for {subkey subvalue} $value {
                    puts "      - $subkey"
                }
            }
        }
        puts ""
    }

    puts "===================================================================="
}

# ==============================================================================
puts "INFO: Simplified configuration helper functions loaded"
puts "INFO: Generic accessors: zget_tconfig_var, zget_pconfig_var, zget_mconfig_var, zget_vconfig_var"
puts "INFO: Complex helpers: zget_lib_paths, zget_lef_paths, zget_gds_paths, zget_filler_cells, zget_cts_cells"
puts "INFO: SRAM functions: zget_all_sram_lefs, zget_all_sram_libs, zhas_sram_macros, zshow_sram_summary"
puts "INFO: Block override inspector: zlist_block_overrides, zshow_block_overrides"
# ==============================================================================
