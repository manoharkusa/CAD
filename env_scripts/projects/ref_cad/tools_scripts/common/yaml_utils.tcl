
package require yaml


# ==============================================================================
# YAML Loading
# ==============================================================================

proc load_yaml_file {yaml_file} {
    if {![file exists $yaml_file]} {
        ui_error "YAML file not found: $yaml_file"
    }
    set fp [open $yaml_file r]
    set yaml_content [read $fp]
    close $fp
    return [::yaml::yaml2dict $yaml_content]
}


# ==============================================================================
# Helper to safely extract values without throwing errors
# Throws FATAL error if key is missing. Optional context for debugging.
# ==============================================================================
proc get_required {dict key {context ""}} {
    if {![dict exists $dict $key]} {
        set msg "FATAL: Missing required key '$key'"
        if {$context ne ""} { append msg " in $context" }
        ui_error $msg
    }
    return [dict get $dict $key]
}
