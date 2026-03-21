# ============================================================
# UI Common Procedures for EDA Scripts
# ============================================================
#
# Purpose:
#   Standardized messaging procedures for real-time UI updates.
#   Lines starting with "UI_MSG" are captured by the executor,
#   trimmed, and sent to Redis for display in the dashboard.
#
# Protocol:
#   Format: UI_MSG <LEVEL> <message>
#   Levels: INFO, WARN, ERROR, STATUS
#
# Usage:
#   source $env(ENV_SCRIPTS)/common/ui_common_procs.tcl
#   ui_info "Starting synthesis"
#   ui_status "Running optimization"
#
# ============================================================

# --- Info Message ---
# General information displayed in UI
# Example: ui_info "Design loaded successfully"
proc ui_info {msg} {
    puts "UI_MSG INFO $msg"
    flush stdout
}

# --- Warning Message ---
# Warning displayed in UI (yellow/orange indicator)
# Example: ui_warn "Clock constraint missing for clk2"
proc ui_warn {msg} {
    puts "UI_MSG WARN $msg"
    flush stdout
}

# --- Error Message ---
# Error displayed in UI (red indicator)
# Example: ui_error "Timing violation detected"
proc ui_error {msg} {
    puts "UI_MSG ERROR $msg"
    flush stdout
}

# --- Status Update ---
# Current status/phase displayed in UI
# Example: ui_status "Running DRC checks"
proc ui_status {msg} {
    puts "UI_MSG STATUS $msg"
    flush stdout
}

# --- Stage Start ---
# Marks beginning of a stage/phase
# Example: ui_stage_start "synthesis"
proc ui_stage_start {stage_name} {
    puts "UI_MSG STAGE_START $stage_name"
    flush stdout
}

# --- Stage End ---
# Marks completion of a stage/phase
# Example: ui_stage_end "synthesis" "success"
proc ui_stage_end {stage_name status} {
    puts "UI_MSG STAGE_END $stage_name $status"
    flush stdout
}

# --- Metric Report ---
# Report a metric value to UI
# Example: ui_metric "cell_count" 15234
# Example: ui_metric "wns" -0.045
proc ui_metric {metric_name value} {
    puts "UI_MSG METRIC $metric_name $value"
    flush stdout
}

# --- QoR Summary ---
# Report QoR data to UI (JSON format)
# Example: ui_qor "{\"wns\":-0.02,\"tns\":-1.5,\"cells\":12000}"
proc ui_qor {json_data} {
    puts "UI_MSG QOR $json_data"
    flush stdout
}

# ============================================================
# Confirmation message when sourced
# ============================================================
ui_info "UI common procedures loaded"
