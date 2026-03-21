# ==============================================================================
# Genus Synthesis Script - YAML Configuration Based
# ==============================================================================
# This script performs RTL-to-gate synthesis using Genus
#
# Configuration Approach:
#   - Uses YAML-based configuration system (no hardcoded paths)
#   - Libraries, VT types, and constraints loaded from YAML files
#   - Supports per-stage VT type control via project.yaml
#
# YAML Configuration Files Used:
#   - configs/tech/TSMC28HPHP/tech.yaml          (Technology definition)
#   - configs/tech/TSMC28HPHP/std_cells/*.yaml   (VT-specific libraries)
#   - configs/projects/flow28nm_generalize/project.yaml (VT control, constraints)
#
# Key Features:
#   - Automatically selects libraries based on enabled VT types for synthesis
#   - Applies max transition constraints from YAML
#
# Environment Variables Required:
#   - BLOCK_NAME: Top-level design name
#   - RTL_FILELIST: Path to RTL file list
#   - SDC: Path to SDC constraints file
#   - TOOL_SCRIPTS: Path to tool_scripts directory
#   - CONFIGS_DIR: Path to configs directory
# ==============================================================================

# ==============================================================================
# Load YAML Configuration System
# ==============================================================================
source $env(ENV_SCRIPTS)/utils/yaml_config_reader.tcl
init_yaml_configs

# Load helper procs for complex operations
source $env(ENV_SCRIPTS)/utils/config_helpers.tcl

# Make config dicts accessible
global TECH_CONFIG PROJECT_CONFIG METAL_STACK_CONFIG VT_CONFIGS

puts "===================================================================="
puts "Genus Synthesis - YAML-Based Configuration"
puts "===================================================================="

set design_name $env(BLOCK_NAME)
puts "INFO: Design name: $design_name"

# ==============================================================================
# Library Setup from YAML Configuration
# ==============================================================================

# Get synthesis corner from project settings
set synth_corner [zget_pconfig_var synthesis_settings corner]
puts "INFO: Synthesis corner (from project settings): $synth_corner"

# Get enabled VT types
set enabled_vts [zget_pconfig_var vt_configuration per_stage_control synthesis enabled_vt_types]
puts "INFO: Enabled VT types: $enabled_vts"

# Get library paths (complex helper - loops over VTs)
set synth_libs [zget_lib_paths synthesis $synth_corner]

puts "INFO: Synthesis libraries for corner $synth_corner:"
foreach lib $synth_libs {
    puts "  - $lib"
}

# Set library search paths and libraries
set_db init_lib_search_path { }
set_db init_hdl_search_path { }
set_db library $synth_libs

# ==============================================================================
# SRAM Library Integration (Phase 1.1)
# ==============================================================================
if {[zhas_sram_macros]} {
    puts "\n===================================================================="
    puts "INFO: Adding SRAM timing libraries for synthesis..."
    puts "===================================================================="

    # Get SRAM libs for synthesis corner
    set sram_libs [zget_all_sram_libs $synth_corner]

    if {[llength $sram_libs] > 0} {
        # Merge with standard cell libs
        set all_libs [concat $synth_libs $sram_libs]
        set_db library $all_libs

        puts "  Added [llength $sram_libs] SRAM timing libraries:"
        foreach lib $sram_libs {
            puts "    - $lib"
        }
    } else {
        puts "  WARNING: No SRAM libs found for corner: $synth_corner"
        puts "  Check that SRAM YAML files have timing_libs.$synth_corner defined"
    }

    # Note: SRAM Verilog models NOT read in Genus
    # RTL should instantiate SRAMs directly; only .lib files needed for synthesis

    # Show SRAM summary
    zshow_sram_summary
    puts "===================================================================="
} else {
    puts "INFO: No SRAM macros in this design - skipping SRAM integration"
}

set rtl_filelist $env(RTL_FILELIST)
puts "MyInfo: Using rtl file list $rtl_filelist"

read_hdl -f $rtl_filelist 
elaborate $design_name 


# ==============================================================================
# Synthesis Settings from YAML Configuration
# ==============================================================================

# Get timing constraints from YAML
set max_tran_data [zget_pconfig_var timing_constraints default_max_transition_data_ns]
set max_tran_clock [zget_pconfig_var timing_constraints default_max_transition_clock_ns]
puts "INFO: Max transition - Data: ${max_tran_data}ns, Clock: ${max_tran_clock}ns"

# Low power settings
set_db lp_insert_clock_gating true
puts "INFO: Clock gating enabled"

# To avoid scan flops for functional paths
set_db use_scan_seqs_for_non_dft false
puts "INFO: DFT scan sequences disabled for non-DFT mode"

# ==============================================================================
# Generic Synthesis
# ==============================================================================
puts "\nINFO: Starting generic synthesis..."
syn_generic
uniquify $design_name
puts "INFO: Generic synthesis completed"

# ==============================================================================
# Read SDC and Apply Constraints
# ==============================================================================
set sdc_file $env(SDC)
puts "\nINFO: Reading SDC file: $sdc_file"
source -e -v $sdc_file

# Apply max transition constraints from YAML
puts "INFO: Applying max transition constraints from YAML config"
set_db design:$design_name .max_transition $max_tran_data

# Check timing intent and design
puts "\nINFO: Checking timing intent and design..."
check_timing_intent > ./reports/check_timing.rpt
check_design -all > ./reports/check_design.rpt

# ==============================================================================
# Mapping
# ==============================================================================
puts "\nINFO: Starting technology mapping..."
syn_map
puts "INFO: Technology mapping completed"

check_design -unresolved > ./reports/check_design.unresolved.rpt

# ==============================================================================
# Optimization
# ==============================================================================
puts "\nINFO: Starting synthesis optimization..."
syn_opt
puts "INFO: Synthesis optimization completed"

# ==============================================================================
# Write Outputs
# ==============================================================================
puts "\nINFO: Writing netlist..."
write_hdl > ./outputs/$design_name.v
puts "INFO: Netlist written to ./outputs/$design_name.v"

# ==============================================================================
# Generate Reports
# ==============================================================================
puts "\nINFO: Generating synthesis reports..."

report_qor > ./reports/report_qor.rpt
puts "  - report_qor.rpt"

report_timing -max_paths 100 > ./reports/timing-max_100.rpt
puts "  - timing-max.rpt"

report_gates > ./reports/report_gates.rpt
puts "  - report_gates.rpt"

report_area > ./reports/report_area.rpt
puts "  - report_area.rpt"

report_timing_summary -checks {setup drv} > ./reports/timing_summary.rpt
puts "  - timing_summary.rpt"

report_constraint -drv_violation_type {max_transition} -no_wrap > ./reports/report_constraint.all_violators.max_tran.rpt
report_constraint -drv_violation_type {max_capacitance} -no_wrap > ./reports/report_constraint.all_violators.max_cap.rpt
report_constraint -drv_violation_type {max_fanout} -no_wrap > ./reports/report_constraint.all_violators.max_fanout.rpt
puts "  - report_constraint.all_violators.rpt"

# ==============================================================================
# Synthesis Summary
# ==============================================================================
puts "\n===================================================================="
puts "Synthesis Completed Successfully"
puts "===================================================================="
puts "Design: $design_name"
puts "Synthesis Corner: $synth_corner"
puts "Enabled VT Types: $enabled_vts"
puts "Output Netlist: ./outputs/$design_name.v"
puts "Reports Directory: ./reports/"
puts "===================================================================="

exit


