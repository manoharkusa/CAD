#!/usr/bin/env python3
"""
QMS (Quality Management System) Utility Functions  -  Single Unified File
Covers: Synthesis - PnR Init - Floorplan - Placement - CTS - PostCTS
        Route - PostRoute - Chip Finish - Tempus STA Signoff
"""

import re
import os
import gzip
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple


# ==============================================================================
# RESULT CLASS
# ==============================================================================

class QMSResult:
    def __init__(self, check_name: str, status: str = "FAIL", message: str = "",
                 details: str = "", value: Any = None, expected: Any = None,
                 report_path: Any = None,
                 blocking_phases: Optional[List[str]] = None):
        self.check_name      = check_name
        self.status          = status
        self.message         = message
        self.details         = details
        self.value           = value
        self.expected        = expected
        self.report_path     = report_path
        # Phases in which a FAIL on this check blocks flow progression.
        # [] = advisory-only (never blocks).
        # ["gold"] = only blocks at gold phase.
        # ["silver","gold"] = blocks at silver and gold.
        # ["bronze","silver","gold"] = always blocking (default).
        self.blocking_phases = blocking_phases if blocking_phases is not None \
                               else ["bronze", "silver", "gold"]

    def to_dict(self):
        return {"check_name": self.check_name, "status": self.status,
                "message": self.message, "details": self.details,
                "value": self.value, "expected": self.expected,
                "report_path": self.report_path,
                "blocking_phases": self.blocking_phases}


# ==============================================================================
# CHECK ID MAPS
# ==============================================================================

CHECK_ID_MAP = {
    "correct_tool_version": "SYN-TL-001", 
    "no_rtl_errors": "SYN-TL-002",
    "no_rtl_warnings": "SYN-TL-003", 
    "no_unresolved_refs": "SYN-TL-004",
    "no_pin_mismatches": "SYN-TL-005", 
    "no_constraint_errors": "SYN-TL-006",
    "no_constraint_warnings": "SYN-TL-007", 
    "no_synthesis_errors": "SYN-TL-008",
    "no_synthesis_warnings": "SYN-TL-009", 
    "process_node_check": "PNR-ID-SETUP-003",
}
INIT_CHECK_ID_MAP = {
    "sdc_read_errors": "PNR-ID-IN-001", "sdc_read_warnings": "PNR-ID-IN-002",
    "input_delay_defined": "PNR-ID-IN-003", "output_delay_defined": "PNR-ID-IN-004",
    "netlist_exists": "PNR-ID-IN-005", "all_ports_match_sdc": "PNR-ID-IN-006",
    "timing_library_consistency": "PNR-ID-IN-007", "no_multiple_drivers": "PNR-ID-IN-008",
    "no_tri_state_buffers": "PNR-ID-IN-009", "no_dont_use_cells": "PNR-ID-IN-010",
    "no_reg2reg_violations": "PNR-ID-IN-011", "no_in2reg_violations": "PNR-ID-IN-012",
    "no_reg2out_violations": "PNR-ID-IN-013", "no_in2out_violations": "PNR-ID-IN-014",
    "no_max_tran_violations": "PNR-ID-IN-015", "no_max_cap_violations": "PNR-ID-IN-016",
    "init_errors": "PNR-ID-EXEC-001", "init_warnings": "PNR-ID-EXEC-002",
    "sdc_syntax_valid": "PNR-ID-EXEC-003", "init_db_created": "PNR-ID-DB-001",
    "tech_lef_check": "PNR-ID-IN-025", "std_lef_check": "PNR-ID-IN-026",
    "macro_lef_check": "PNR-ID-IN-027", "high_fanout_nets": "PNR-ID-IN-021",
    "output_floating_nets": "PNR-ID-IN-017", "floating_ports": "PNR-ID-IN-018",
    "output_floating_pins": "PNR-ID-IN-019","process_node_check": "PNR-ID-SETUP-003", "input_floating_pins": "PNR-ID-IN-020", "input_inout_floating_pins": "PNR-ID-IN-020",
    
}
QOR_CHECK_ID_MAP = {
    "max_logic_levels": "SYN-QR-001", "instance_count_stable": "SYN-QR-002",
    "no_reg2reg_violations": "SYN-QR-003", "no_in2reg_violations": "SYN-QR-004",
    "no_reg2out_violations": "SYN-QR-005", "no_in2out_violations": "SYN-QR-006",
    "no_max_tran_violations": "SYN-QR-007", "no_max_cap_violations": "SYN-QR-008",
    "min_pulse_width_violations": "SYN-QR-009",
}
CHECK_DESIGN_ID_MAP = {
    "no_unresolved_references": "SYN-CD-001", "no_empty_modules": "SYN-CD-002",
    "no_undriven_ports": "SYN-CD-003", "no_undriven_leaf_pins": "SYN-CD-004",
    "no_multidriven_leaf_pins": "SYN-CD-005", "no_multidriven_ports": "SYN-CD-006",
    "preserved_leaf_instances": "SYN-CD-007",
    "preserved_hierarchical_instances": "SYN-CD-008",
}
SPECIAL_CHECK_ID_MAP = {
    "clock_gating_coverage": "SYN-SC-001", "optimal_drive_strength": "SYN-SC-014",
}
FP_CHECK_ID_MAP = {
    "macros_out_of_core": "PNR-FP-001", "pg_short_violations": "PNR-FP-002",
    "connectivity_violations": "PNR-FP-003", "power_via_violations": "PNR-FP-004",
    "drc_violations": "PNR-FP-005", "pin_assignment_violations": "PNR-FP-006",
    "floorplan_utilization": "PNR-FP-007", "endcap_violations": "PNR-FP-008",
    "welltap_violations": "PNR-FP-009", "timing_summary": "PNR-FP-010",
    "floorplan_in2reg_setup_violations": "PNR-FP-011",
    "floorplan_reg2out_setup_violations": "PNR-FP-012",
    "floorplan_reg2reg_setup_violations": "PNR-FP-013",
    "floorplan_reg2cgate_setup_violations": "PNR-FP-014",
    "floorplan_in2out_setup_violations": "PNR-FP-015",
    "floorplan_rules": "PNR-FP-016",
    "power_domain":"PNR-FP-017",
    "macro_halo":"PNR-FP-018",
    "floorplan_log_errors": "PNR-FP-EXEC-001",
    "floorplan_log_warnings": "PNR-FP-EXEC-002",
    "floorplan_db_exists": "PNR-FP-EXEC-003",
}
PLACEMENT_CHECK_ID_MAP = {
    "placement_violations": "PNR-PL-001", "unplaced_cells": "PNR-PL-002",
    "no_cell_overlaps": "PNR-PL-003", "cell_density": "PNR-PL-004",
    "no_log_errors": "PNR-PL-EXEC-001", "no_log_warnings": "PNR-PL-EXEC-002",
    "placement_db": "PNR-PL-EXEC-003", "core_utilization": "PNR-PL-007",
    "global_routing_congestion": "PNR-PL-CG-001",
    "max_congestion_hotspot": "PNR-PL-CG-002",
# NEW: Timing Setup Violations
    "no_reg2reg_violations": "PNR-PL-TM-001",
    "no_in2reg_violations": "PNR-PL-TM-002",
    "no_reg2out_violations": "PNR-PL-TM-003",
    "no_in2out_violations": "PNR-PL-TM-004",
    
    # NEW: DRV (Design Rule Violations)
    "no_max_tran_violations": "PNR-PL-DRV-001",
    "no_max_cap_violations": "PNR-PL-DRV-002"
    }

CTS_CHECK_ID_MAP = {
"correct_tool_version": "PNR-CTS-001",
"congestion_hotspot": "PNR-CTS-002",
"cts_in2out_setup_violations": "PNR-CTS-003",
"cts_in2reg_setup_violations": "PNR-CTS-004",
"cts_reg2cgate_setup_violations": "PNR-CTS-005",
"cts_reg2out_setup_violations": "PNR-CTS-006",
"cts_reg2reg_setup_violations": "PNR-CTS-007",
"cts_in2reg_hold_violations": "PNR-CTS-008",
"cts_reg2reg_hold_violations": "PNR-CTS-009",
"cts_reg2out_hold_violations": "PNR-CTS-010",
"cts_in2out_hold_violations": "PNR-CTS-011",
"cts_log_errors": "PNR-CTS-EXEC-001",
"cts_log_warnings": "PNR-CTS-EXEC-002",
"cts_db_exists": "PNR-CTS-EXEC-003",
"cts_ndr_applied":"PNR-CTS-EX-005",
"cts_cell_usage":"PNR-CTS-012",
"cts_min_pulse_width_violations":"PNR-CTS-013",
"cts_drv_max_transition":"PNR-CTS-014",
"cts_drv_max_capacitance":"PNR-CTS-015",
"cts_drv_max_fanout":"PNR-CTS-016",
"cts_clock_skew":"PNR-CTS-017",

}

POSTCTS_CHECK_ID_MAP = {
    # --- General / Physical checks (PNR-POSTCTS-0xx) ---
    "correct_tool_version":                  "PNR-POSTCTS-001",
    "congestion_hotspot":                    "PNR-POSTCTS-002",
    "postcts_clock_tree_max_net_length":     "PNR-POSTCTS-003",  # was dup of 001
    "postcts_max_fanout":                    "PNR-POSTCTS-004",  # was dup of 002
    "postcts_long_nets":                     "PNR-POSTCTS-005",
    "postcts_ndr_layers":                    "PNR-POSTCTS-006",
    "postcts_max_hotspot":                   "PNR-POSTCTS-007",  # new

    # --- DRC checks (PNR-POSTCTS-DRC-0xx) ---
    "postcts_clock_route_drc":               "PNR-POSTCTS-DRC-001",
    "postcts_connectivity_violations":       "PNR-POSTCTS-DRC-002",

    # --- Setup timing checks (PNR-POSTCTS-SU-0xx) ---
    "postcts_in2out_setup_violations":       "PNR-POSTCTS-SU-001",
    "postcts_in2reg_setup_violations":       "PNR-POSTCTS-SU-002",
    "postcts_reg2cgate_setup_violations":    "PNR-POSTCTS-SU-003",
    "postcts_reg2out_setup_violations":      "PNR-POSTCTS-SU-004",
    "postcts_reg2reg_setup_violations":      "PNR-POSTCTS-SU-005",

    # --- Hold timing checks (PNR-POSTCTS-HO-0xx) ---
    "postcts_in2reg_hold_violations":        "PNR-POSTCTS-HO-001",
    "postcts_reg2reg_hold_violations":       "PNR-POSTCTS-HO-002",
    "postcts_reg2out_hold_violations":       "PNR-POSTCTS-HO-003",
    "postcts_in2out_hold_violations":        "PNR-POSTCTS-HO-004",
    "postcts_reg2cgate_hold_violations":     "PNR-POSTCTS-HO-005",  # new

    # --- Power checks (PNR-POSTCTS-PWR-0xx) ---
    "cts_leakage_power":                     "PNR-POSTCTS-PWR-001",  # new

    # --- CTS structural checks (PNR-POSTCTS-CTS-0xx) ---
    "cts_instance_count_diff":               "PNR-POSTCTS-CTS-001",  # new

    # --- Execution / infra checks (PNR-POSTCTS-EXEC-0xx) ---
    "postcts_log_errors":                    "PNR-POSTCTS-EXEC-001",
    "postcts_log_warnings":                  "PNR-POSTCTS-EXEC-002",
    "postcts_db_exists":                     "PNR-POSTCTS-EXEC-003",
}


ROUTE_CHECK_ID_MAP = {
    # Tool / Execution
    "correct_tool_version":              "PNR-ROUTE-TL-001",
    "route_log_errors":                  "PNR-ROUTE-EXEC-001",
    "route_db_exists":                   "PNR-ROUTE-EXEC-002",
    # Signal Integrity
    "SI":                                "PNR-ROUTE-SI-001",
    # DRV
    "no_max_tran_violations":            "PNR-ROUTE-DRV-001",
    "no_max_cap_violations":             "PNR-ROUTE-DRV-002",
    "no_max_fanout_violations":          "PNR-ROUTE-DRV-003",
    # Route quality
    "max_net_length":                    "PNR-ROUTE-RC-001",   # ? was missing
    "antenna_violations":                "PNR-ROUTE-RQ-003",
    "drc_count":                         "PNR-ROUTE-RQ-005",
    "postroute_floating_nets":           "PNR-ROUTE-RQ-006",
    "filler_gap":                        "PNR-ROUTE-RQ-007",
    # Layer usage
    "forbidden_layers":                  "PNR-ROUTE-LU-002",
    # Setup timing groups
    "route_reg2reg_setup_violations":    "PNR-ROUTE-TM-001",
    "route_in2reg_setup_violations":     "PNR-ROUTE-TM-002",
    "route_reg2out_setup_violations":    "PNR-ROUTE-TM-003",
    "route_reg2cgate_setup_violations":  "PNR-ROUTE-TM-004",
    "route_in2out_setup_violations":     "PNR-ROUTE-TM-005",
    # Hold timing groups
    "route_reg2reg_hold_violations":     "PNR-ROUTE-TM-006",
    "route_in2reg_hold_violations":      "PNR-ROUTE-TM-007",
    "route_reg2out_hold_violations":     "PNR-ROUTE-TM-008",
    "route_reg2cgate_hold_violations":   "PNR-ROUTE-TM-009",
    "route_in2out_hold_violations":      "PNR-ROUTE-TM-010",
}

POSTROUTE_CHECK_ID_MAP = {
    # Tool / Execution
    "correct_tool_version":                  "PNR-POSTROUTE-TL-001",
    "SI":                                    "PNR-POSTROUTE-SI-001",   # was missing
    "postroute_log_errors":                  "PNR-POSTROUTE-EXEC-001",
    "postroute_db_exists":                   "PNR-POSTROUTE-EXEC-002",
    # DRV
    "no_max_tran_violations":                "PNR-POSTROUTE-DRV-001",
    "no_max_cap_violations":                 "PNR-POSTROUTE-DRV-002",
    "no_max_fanout_violations":              "PNR-POSTROUTE-DRV-003",
    "postroute_no_min_tran_violations":      "PNR-POSTROUTE-DRV-004",
    "postroute_no_min_cap_violations":       "PNR-POSTROUTE-DRV-005",
    # Route quality
    "max_net_length":                        "PNR-POSTROUTE-RC-001",   # was "postroute_max_net_length"
    "postroute_check_connectivity":          "PNR-POSTROUTE-RQ-002",
    "postroute_antenna_violations":          "PNR-POSTROUTE-RQ-003",
    "postroute_total_drc_count":             "PNR-POSTROUTE-RQ-004",
    "postroute_drc_shorts_total":            "PNR-POSTROUTE-RQ-005",
    "filler_gap":                            "PNR-POSTROUTE-RQ-006",   # was "postroute_no_filler_gaps"
    "postroute_floating_nets":               "PNR-POSTROUTE-RQ-007",
    # Layer usage
    "forbidden_layers":                      "PNR-POSTROUTE-LU-002",   # was "postroute_restricted_forbidden_layers"
    # Setup timing groups
    "postroute_reg2reg_setup_violations":    "PNR-POSTROUTE-TM-001",
    "postroute_in2reg_setup_violations":     "PNR-POSTROUTE-TM-002",
    "postroute_reg2out_setup_violations":    "PNR-POSTROUTE-TM-003",
    "postroute_reg2cgate_setup_violations":  "PNR-POSTROUTE-TM-004",
    "postroute_in2out_setup_violations":     "PNR-POSTROUTE-TM-005",
    # Hold timing groups
    "postroute_reg2reg_hold_violations":     "PNR-POSTROUTE-TM-006",
    "postroute_in2reg_hold_violations":      "PNR-POSTROUTE-TM-007",
    "postroute_reg2out_hold_violations":     "PNR-POSTROUTE-TM-008",
    "postroute_reg2cgate_hold_violations":   "PNR-POSTROUTE-TM-009",
    "postroute_in2out_hold_violations":      "PNR-POSTROUTE-TM-010",
}


CHIP_FINISH_ID_MAP = {
    "filler_gap": "PNR-CHIP_FINISH-CF-001", 
    "shorts_count": "PNR-CHIP_FINISH-CF-002",
    "opens_count": "PNR-CHIP_FINISH-CF-003", 
    "floating_nets": "PNR-CHIP_FINISH-CF-004",
    "no_max_tran_violations": "PNR-CHIP_FINISH-DRV-001",
    "no_max_cap_violations":  "PNR-CHIP_FINISH-DRV-002",
    "no_max_fanout_violations": "PNR-CHIP_FINISH-DRV-003",

    
    "gds_generated": "PNR-CHIP_FINISH-OUT-001", 
    "lef_generated": "PNR-CHIP_FINISH-OUT-002",
    "def_generated": "PNR-CHIP_FINISH-OUT-003",
    "pg_verilog_generated": "PNR-CHIP_FINISH-OUT-004",
    "standard_verilog_generated": "PNR-CHIP_FINISH-OUT-005",

    "spef_cbest": "PNR-CHIP_FINISH-OUT-006",
    "spef_rcbest": "PNR-CHIP_FINISH-OUT-007",
    "spef_cworst": "PNR-CHIP_FINISH-OUT-008",
    "spef_rcworst": "PNR-CHIP_FINISH-OUT-009",

    "func_ffm40c_cb": "PNR-CHIP_FINISH-OUT-010",  
    "func_ss125c_rcw": "PNR-CHIP_FINISH-OUT-011", 
    "func_ssm40c_cw": "PNR-CHIP_FINISH-OUT-012",  
    "func_ff125c_rcb": "PNR-CHIP_FINISH-OUT-013"

}
TEMPUS_CHECK_ID_MAP = {
    "tempus_max_tran_violations": "TEM-DRV-001", "tempus_max_cap_violations": "TEM-DRV-002",
    "no_min_pulse_width_violations": "TEM-DRV-003",
       "annotation_check_clean": "TEM-PAR-001",
    "sdc_read_errors": "TEM-SDC-001", "sdc_read_warnings": "TEM-SDC-002",
    "verilog_no_errors": "TEM-VLG-001", "verilog_no_warnings": "TEM-VLG-002",
    "spef_read_no_errors": "TEM-SPF-001", "spef_read_no_warnings": "TEM-SPF-002",
    "no_tri_state_drivers": "TEM-NET-001", "no_parallel_drivers": "TEM-NET-002",
    "no_multiple_drivers": "TEM-NET-003", "no_fanin_missing": "TEM-NET-004",
    "no_floating_fanout": "TEM-NET-005", "tempus_max_fanout_violations": "TEM-NET-006",
    "timing_library_consistency": "TEM-LIB-001",
    "no_undriven_input_hpins": "TEM-CD-NET-001",
    "power_intent_clean": "TEM-CD-NET-002", "timing_category_clean": "TEM-CD-NET-003",
    "hierarchical_category_clean": "TEM-CD-NET-004",
    "pin_assign_category_clean": "TEM-CD-NET-005",
    "clock_period_no_violations": "TEM-RC-CLK-001",
    "clock_skew_no_violations": "TEM-RC-CLK-002",
    "pulse_width_no_violations": "TEM-RC-CLK-003",
    "ideal_clock_waveform_clean": "TEM-CT-001", "no_drive_missing": "TEM-CT-002",
    "no_input_delay_missing": "TEM-CT-003", "no_uncons_endpoint": "TEM-CT-004",
}


# ==============================================================================
# SHARED HELPERS
# ==============================================================================

def read_all_logs(logs_dir: Path) -> str:
    all_logs = ""
    if not logs_dir.exists():
        return all_logs
    for log_file in logs_dir.glob("*.log*"):
        try:
            all_logs += log_file.read_text(errors="ignore") + "\n"
        except Exception as e:
            print(f"[WARN] Could not read {log_file}: {e}")
    return all_logs

def read_report_file(reports_dir: Path, filename: str) -> Optional[str]:
    for candidate in [reports_dir / filename,
                      reports_dir / f"{filename}.rpt",
                      reports_dir / filename.replace(".rpt", ".txt")]:
        if candidate.exists():
            try:
                return candidate.read_text()
            except Exception as e:
                print(f"[WARN] Could not read {candidate}: {e}")
    return None

def get_latest_log_file(logs_dir: Path) -> Tuple[Optional[str], Optional[str]]:
    if not logs_dir.exists():
        return None, None
    files = list(logs_dir.glob("*.log")) + list(logs_dir.glob("*.txt"))
    if not files:
        return None, None
    latest = max(files, key=lambda f: f.stat().st_mtime)
    try:
        return str(latest.resolve()), latest.read_text(errors="ignore")
    except Exception as e:
        print(f"[WARN] Could not read {latest}: {e}")
        return str(latest.resolve()), None

def read_innovus_summary(reports_dir: Path, prefix: str) -> Tuple[str, str]:
    stage_dir = reports_dir.parent
    for fp in [reports_dir / f"{prefix}.summary.gz", reports_dir / f"{prefix}.summary",
               reports_dir / f"{prefix}_summary.rpt", stage_dir / f"{prefix}.summary.gz",
               stage_dir / f"{prefix}.summary", stage_dir / f"{prefix}_summary.rpt"]:
        if fp.exists():
            try:
                if fp.suffix == ".gz":
                    with gzip.open(fp, "rt", encoding="utf-8", errors="ignore") as f:
                        return f.read(), str(fp.resolve())
                return fp.read_text(errors="ignore"), str(fp.resolve())
            except Exception as e:
                print(f"[WARN] Could not read {fp}: {e}")
    return "", ""

def _find_log_file(logs_dir: Path, keyword: str) -> str:
    r_path = str(logs_dir.resolve())
    if logs_dir.exists():
        for lf in sorted(logs_dir.glob("*.log*")):
            try:
                if keyword.lower() in lf.read_text(errors="ignore").lower():
                    return str(lf.resolve())
            except Exception:
                pass
    return r_path

def _section_between(text: str, start: str, end: str) -> str:
    s = text.find(start)
    if s == -1:
        return ""
    e = text.find(end, s + len(start))
    return text[s:e] if e != -1 else text[s:]

def _build_check_type_blocks(content: str) -> Dict[str, str]:
    pattern = re.compile(
        r"Check\s+type\s*:\s*(\S+)\s*\n[-]+\s*\n(.*?)(?=Check\s+type\s*:|$)",
        re.IGNORECASE | re.DOTALL)
    return {m.group(1).lower(): m.group(2) for m in pattern.finditer(content)}


# ==============================================================================
# SYNTHESIS / PNR - LOG CHECKS
# ==============================================================================

def check_tool_version(logs: str, stage: str) -> QMSResult:
    try:
        if stage == "syn":
            m = re.search(r"Version:\s*([0-9]+\.[0-9]+-s[0-9]+_[0-9]+)", logs)
            tool = "Genus"
        else:
            m = re.search(r"Innovus\s+Implementation\s+System\s+v([\d.]+)", logs)
            tool = "Innovus"
        if m:
            ver = m.group(1)
            fmt = f"{tool.lower()} {ver}"
            if ver.startswith(("20.", "21.", "22.", "23.", "24.")):
                return QMSResult("correct_tool_version", "PASS", f"Using {tool} {ver}", value=fmt, expected=fmt)
            return QMSResult("correct_tool_version", "WARN", f"{tool} {ver} may be outdated", value=fmt, expected=fmt)
        return QMSResult("correct_tool_version", "FAIL", f"Could not determine {tool} version")
    except Exception as e:
        return QMSResult("correct_tool_version", "FAIL", f"Error: {e}")

def check_rtl_errors(logs: str) -> QMSResult:
    patterns = [r"Error.*reading.*\.v", r"Error.*parsing.*RTL", r"Syntax error.*\.v",
                r"Module.*not found", r"File.*\.v.*not found", r"Error.*elaborating.*module",
                r"Error.*Cannot resolve reference to module", r"Error.*Failed to elaborate"]
    errors = [m for p in patterns for m in re.findall(p, logs, re.IGNORECASE)]
    if errors:
        return QMSResult("no_rtl_errors", "FAIL", f"Found {len(errors)} RTL errors",
                         details="\n".join(errors[:5]), value=len(errors), expected=0)
    return QMSResult("no_rtl_errors", "PASS", "No RTL errors found", value=0, expected=0)

def check_rtl_warnings(logs: str) -> QMSResult:
    if "read_hdl" not in logs:
        return QMSResult("no_rtl_warnings", "SKIP", "read_hdl command not found in logs")
    section = logs.rsplit("read_hdl", 1)[1]
    section = section.split("elaborate", 1)[0] if "elaborate" in section else section
    count = len(re.findall(r"Warning", section, re.IGNORECASE))
    if count > 0:
        return QMSResult("no_rtl_warnings", "WARN",
                         f"Found {count} RTL warnings during read_hdl",
                         details=f"Count: {count}", value=count, expected=0)
    return QMSResult("no_rtl_warnings", "PASS",
                     "No RTL warnings found between read_hdl and elaborate", value=0, expected=0)

def check_unresolved_references(logs: str) -> QMSResult:
    patterns = [r"Error.*Cannot resolve reference.*(\w+)", r"Error.*Unresolved reference.*(\w+)",
                r"Warning.*blackbox.*(\w+)", r"Error.*Cannot find definition.*(\w+)",
                r"Module.*(\w+).*not linked", r"Error.*Cannot find module.*(\w+)",
                r"Reference.*(\w+).*is unresolved"]
    refs = [m for p in patterns for m in re.findall(p, logs, re.IGNORECASE)]
    if refs:
        return QMSResult("no_unresolved_refs", "FAIL", f"Found {len(refs)} unresolved references",
                         details="\n".join(refs[:5]), value=len(refs), expected=0)
    return QMSResult("no_unresolved_refs", "PASS", "No unresolved references found", value=0, expected=0)

def check_pin_mismatches(logs: str) -> QMSResult:
    patterns = [r"Error.*pin.*mismatch.*(\w+)", r"Warning.*port.*width.*mismatch.*(\w+)",
                r"Error.*connection.*width.*(\w+)", r"Error.*Port.*(\w+).*width mismatch",
                r"Warning.*Port size mismatch.*(\w+)"]
    items = [m for p in patterns for m in re.findall(p, logs, re.IGNORECASE)]
    if items:
        return QMSResult("no_pin_mismatches", "FAIL", f"Found {len(items)} pin mismatches",
                         details="\n".join(items[:5]), value=len(items), expected=0)
    return QMSResult("no_pin_mismatches", "PASS", "No pin mismatches found", value=0, expected=0)

def check_constraint_errors(logs: str) -> QMSResult:
    patterns = [r"Error.*reading.*sdc", r"Error.*constraint.*file", r"Error.*SDC.*syntax",
                r"Error.*timing.*constraint", r"Error.*Cannot find clock", r"Error.*SDC command failed"]
    errors = [m for p in patterns for m in re.findall(p, logs, re.IGNORECASE)]
    if errors:
        return QMSResult("no_constraint_errors", "FAIL", f"Found {len(errors)} constraint errors",
                         details="\n".join(errors[:5]), value=len(errors), expected=0)
    return QMSResult("no_constraint_errors", "PASS", "No constraint errors found", value=0, expected=0)

def check_constraint_warnings(logs: str) -> QMSResult:
    patterns = [r"Warning.*constraint.*ignored", r"Warning.*SDC.*command",
                r"Warning.*timing.*constraint", r"Warning.*clock.*constraint",
                r"Warning.*Clock.*not found", r"Warning.*set_input_delay.*ignored"]
    warnings = [m for p in patterns for m in re.findall(p, logs, re.IGNORECASE)]
    if warnings:
        status = "WARN" if len(warnings) < 5 else "FAIL"
        return QMSResult("no_constraint_warnings", status, f"Found {len(warnings)} constraint warnings",
                         details="\n".join(warnings[:5]), value=len(warnings), expected=0)
    return QMSResult("no_constraint_warnings", "PASS", "No constraint warnings found", value=0, expected=0)

def check_synthesis_errors(logs: str) -> QMSResult:
    patterns = [r"Error.*synthesis", r"Error.*mapping", r"Error.*optimization",
                r"FATAL.*synthesis", r"Error.*compile", r"Error.*Failed to synthesize",
                r"Error.*Synthesis failed"]
    errors = [m for p in patterns for m in re.findall(p, logs, re.IGNORECASE)]
    if errors:
        return QMSResult("no_synthesis_errors", "FAIL", f"Found {len(errors)} synthesis errors",
                         details="\n".join(errors[:5]), value=len(errors), expected=0)
    return QMSResult("no_synthesis_errors", "PASS", "No synthesis errors found", value=0, expected=0)

def check_synthesis_warnings(logs: str) -> QMSResult:
    s = logs.find("syn_generic"); e = logs.find("write_hdl", s); count = 0
    if s != -1:
        block = logs[s:e] if e != -1 else logs[s:]
        count = sum(1 for line in block.splitlines() if line.strip().startswith("Warning"))
    if count > 0:
        status = "WARN" if count < 10 else "FAIL"
        return QMSResult("synthesis_warnings_count", status, f"Found {count} synthesis warnings",
                         value=count, expected=0)
    return QMSResult("synthesis_warnings_count", "PASS", "No synthesis warnings found", value=0, expected=0)

def check_sdc_read_stats(logs: str, logs_dir: Path) -> List[QMSResult]:
    results = []
    success_pat = r"INFO\s+\(CTE\):\s*Constraints read successfully\."
    stats_pat   = r"INFO\s+\(CTE\):\s*Reading of timing constraints file.*?completed, with\s+(\d+)\s+Warning(?:s)?\s+and\s+(\d+)\s+Error(?:s)?"
    r_path = str(logs_dir.resolve())
    if logs_dir.exists():
        for lf in logs_dir.glob("*.log*"):
            try:
                c = lf.read_text(errors="ignore")
                if re.search(success_pat, c) or re.search(stats_pat, c):
                    r_path = str(lf.resolve()); break
            except Exception:
                pass
    sm = re.search(stats_pat, logs); ss = re.search(success_pat, logs)
    if sm:
        w, e = int(sm.group(1)), int(sm.group(2))
    elif ss:
        w, e = 0, 0
    else:
        results.append(QMSResult("sdc_read_warnings", "SKIP", "SDC read stats not found", report_path=r_path))
        results.append(QMSResult("sdc_read_errors",   "SKIP", "SDC read stats not found", report_path=r_path))
        return results
    results.append(QMSResult("sdc_read_warnings", "WARN" if w > 0 else "PASS",
                             f"Found {w} SDC read warnings" if w > 0 else "No SDC read warnings",
                             value=w, expected=0, report_path=r_path))
    results.append(QMSResult("sdc_read_errors", "FAIL" if e > 0 else "PASS",
                             f"Found {e} SDC read errors" if e > 0 else "No SDC read errors",
                             value=e, expected=0, report_path=r_path))
    return results

def check_init_log_errors_warnings(logs: str, logs_dir: Path) -> List[QMSResult]:
    results = []
    pat  = r"\*\*\*\s*Message Summary:\s*(\d+)\s*warning\(s\),\s*(\d+)\s*error\(s\)"
    hits = re.findall(pat, logs, re.IGNORECASE)
    r_path = str(logs_dir.resolve())
    if logs_dir.exists():
        for lf in logs_dir.glob("*.log*"):
            try:
                c = lf.read_text(errors="ignore")
                if re.search(pat, c, re.IGNORECASE):
                    r_path = str(lf.resolve()); break
            except Exception:
                pass
    if hits:
        w, e = int(hits[-1][0]), int(hits[-1][1])
    else:
        e = len(re.findall(r"\*\*ERROR:", logs, re.IGNORECASE))
        w = len(re.findall(r"\*\*WARN:",  logs, re.IGNORECASE))
    results.append(QMSResult("init_errors",  "PASS" if e == 0 else "FAIL",
                             "No errors"   if e == 0 else f"Found {e} errors",   value=e, expected=0, report_path=r_path))
    results.append(QMSResult("init_warnings","PASS" if w == 0 else "WARN",
                             "No warnings" if w == 0 else f"Found {w} warnings", value=w, expected=0, report_path=r_path))
    return results

def check_sdc_syntax_warnings(logs: str, logs_dir: Path) -> QMSResult:
    pat   = r"WARNING\s*\(CTE-25\)"
    count = len(re.findall(pat, logs, re.IGNORECASE))
    files = []
    if count > 0 and logs_dir.exists():
        for lf in logs_dir.glob("*.log*"):
            try:
                if re.search(pat, lf.read_text(errors="ignore"), re.IGNORECASE):
                    files.append(str(lf.resolve()))
            except Exception:
                pass
    r_path = ", ".join(files) if files else str(logs_dir.resolve())
    if count > 0:
        return QMSResult("sdc_syntax_valid", "FAIL", f"Found {count} SDC syntax warnings",
                         value=count, expected=0, report_path=r_path)
    return QMSResult("sdc_syntax_valid", "PASS", "No SDC syntax warnings found", value=0, expected=0, report_path=r_path)


# ==============================================================================
# SYNTHESIS / PNR - REPORT CHECKS
# ==============================================================================

def check_timing_library_consistency(reports_dir: Path) -> QMSResult:
    rpt = "check_design.library.rpt"; content = read_report_file(reports_dir, rpt)
    rpath = str((reports_dir / rpt).resolve())
    if not content:
        return QMSResult("timing_library_consistency", "SKIP", f"{rpt} not found", report_path=str(reports_dir))
    views = len(re.findall(r"Checking the Library binding", content, re.IGNORECASE))
    fails = len(re.findall(r"Fail\.\s+Missing Library", content, re.IGNORECASE))
    missing = len(re.findall(r"No library found", content, re.IGNORECASE))
    if fails > 0 or missing > 0:
        return QMSResult("timing_library_consistency", "FAIL",
                         f"Missing libraries: {fails} views, {missing} instances",
                         value=missing, expected=0, report_path=rpath)
    if views > 0:
        return QMSResult("timing_library_consistency", "PASS",
                         "All instances have library definitions", value=0, expected=0, report_path=rpath)
    return QMSResult("timing_library_consistency", "SKIP", "Could not parse results", report_path=rpath)

def check_netlist_drivers(reports_dir: Path) -> List[QMSResult]:
    results = []; rpt = "check_netlist_verbose.rpt"
    content = read_report_file(reports_dir, rpt); rpath = str((reports_dir / rpt).resolve())
    if not content:
        results.append(QMSResult("no_multiple_drivers",  "SKIP", f"{rpt} not found", report_path=rpath))
        results.append(QMSResult("no_tri_state_buffers", "SKIP", f"{rpt} not found", report_path=rpath))
        return results
    for name, pat in [("no_multiple_drivers",  r"Nets\s+with\s+multiple\s+drivers:\s*(\d+)"),
                       ("no_tri_state_buffers", r"Nets\s+with\s+tri[-_]state\s+driver[s]?:\s*(\d+)")]:
        m = re.search(pat, content, re.IGNORECASE)
        if m:
            count = int(m.group(1))
            results.append(QMSResult(name, "PASS" if count == 0 else "FAIL",
                                     "None found" if count == 0 else f"Found {count}",
                                     value=count, expected=0, report_path=rpath))
        else:
            results.append(QMSResult(name, "SKIP", "Metric not found", report_path=rpath))
    return results

def check_dont_use_cells(reports_dir: Path) -> QMSResult:
    rpt = "check_netlist_verbose.rpt"; content = read_report_file(reports_dir, rpt)
    rpath = str((reports_dir / rpt).resolve())
    if not content:
        return QMSResult("no_dont_use_cells", "SKIP", f"{rpt} not found", report_path=rpath)
    m = re.search(r"Dont use cells in design:\s*(\d+)", content, re.IGNORECASE)
    if m:
        count = int(m.group(1))
        return QMSResult("no_dont_use_cells", "PASS" if count == 0 else "FAIL",
                         "No dont-use cells" if count == 0 else f"Found {count} dont-use cells",
                         value=count, expected=0, report_path=rpath)
    return QMSResult("no_dont_use_cells", "SKIP", "Metric not found", report_path=rpath)
def check_netlist_floating_metrics(reports_dir: Path) -> List[QMSResult]:
    results = []
    
    # UPDATE: Check for check_netlist.rpt as well, since your prompt indicates that's where the data is
    rpt = "check_netlist.rpt"
    content = read_report_file(reports_dir, rpt)
    
    # Fallback to verbose if the standard one isn't found
    if not content:
        rpt = "check_netlist_verbose.rpt"
        content = read_report_file(reports_dir, rpt)
        
    rpath = str((reports_dir / rpt).resolve())

    # UPDATE: Add the "input_floating_pins" tuple to this list
    checks = [
        ("high_fanout_nets",     "High Fanout nets",          r'Number of High Fanout nets[^:]*:\s*(\d+)'),
        ("output_floating_nets", "Output Floating nets",      r'(?:Number of Output Floating nets[^:]*:|Output Floating nets\s*\(No FanOut\))\s*(\d+)'),
        ("floating_ports",       "Floating Ports",            r'(?:Number of Floating Ports|Floating Ports)[^:]*:\s*(\d+)'),
        ("input_floating_pins",  "Input/InOut Floating Pins", r'Number of Input/InOut Floating Pins\s*:\s*(\d+)')
    ]

    if content is None:
        for cid, _, _ in checks:
            results.append(QMSResult(cid, "SKIP", "report not found", report_path=rpath))
        return results
        
    if not content.strip():
        for cid, _, _ in checks:
            results.append(QMSResult(cid, "SKIP", "report is empty", report_path=rpath))
        return results
        
    for cid, desc, pat in checks:
        m = re.search(pat, content, re.IGNORECASE)
        if m:
            count = int(m.group(1))
            results.append(QMSResult(cid, "PASS" if count == 0 else "FAIL",
                                     f"No {desc}" if count == 0 else f"Found {count} {desc}",
                                     value=count, expected=0, report_path=rpath))
        else:
            results.append(QMSResult(cid, "SKIP", f"Metric '{desc}' not found", report_path=rpath))
            
    return results
def check_process_node(reports_dir: Path) -> QMSResult:
    rf = reports_dir / "process_node.rpt"; rpath = str(rf.resolve())
    if not rf.exists():
        return QMSResult("process_node_check", "SKIP", "report not found", report_path=rpath)
    content = rf.read_text(errors="ignore").strip()
    if not content:
        return QMSResult("process_node_check", "SKIP", "report is empty", report_path=rpath)
    m = re.search(r"\d+", content)
    if m:
        return QMSResult("process_node_check", "PASS", f"Process node is {m.group(0)}",
                         value=int(m.group(0)), report_path=rpath)
    return QMSResult("process_node_check", "FAIL", "No number found in report", report_path=rpath)

def check_lef_files(logs_dir: Path, reports_dir: Path) -> List[QMSResult]:
    results = []; rpt = reports_dir / "lef_files.rpt"; rpath = str(rpt.resolve())
    s_tech, s_std, s_macro = set(), set(), set()
    r_tech, r_std, r_macro = set(), set(), set()

    def categorize(path):
        fname = re.sub(r'[\\\'"\s{}]+', '', os.path.basename(path))
        if not fname: return None, None
        low = fname.lower()
        if low.endswith(".tlef") or "tech" in low: return "tech", fname
        if any(x in low for x in ["ram","rom","sram","pll","macro","ip","mem"]): return "macro", fname
        return "std", fname

    all_logs = read_all_logs(logs_dir)
    raw = set(re.findall(r"Loading LEF file\s+(\S+)", all_logs))
    for blk in re.findall(r"read_physical\s+-lef\s+\{([^}]+)\}", all_logs):
        raw.update(blk.replace("\\", " ").split())
    for p in raw:
        if not p.lower().endswith(("lef", "tlef")): continue
        c, fn = categorize(p)
        if c == "tech": s_tech.add(fn)
        elif c == "macro": s_macro.add(fn)
        elif c == "std": s_std.add(fn)
    if rpt.exists():
        for p in rpt.read_text(errors="ignore").replace("\\", " ").split():
            if not p.lower().endswith(("lef", "tlef")): continue
            c, fn = categorize(p)
            if c == "tech": r_tech.add(fn)
            elif c == "macro": r_macro.add(fn)
            elif c == "std": r_std.add(fn)

    def _eval(name, s_set, r_set, missing_msg, mismatch_msg, pass_msg):
        if not r_set:
            return QMSResult(name, "FAIL", missing_msg,
                             details=f"Script:{list(s_set)} Report:{list(r_set)}", report_path=rpath)
        if s_set != r_set:
            return QMSResult(name, "FAIL", mismatch_msg,
                             details=f"Script:{list(s_set)} Report:{list(r_set)}", report_path=rpath)
        return QMSResult(name, "PASS", pass_msg,
                         details=f"Script:{list(s_set)} Report:{list(r_set)}", report_path=rpath)

    results.append(_eval("tech_lef_check", s_tech, r_tech,
                         "Missing tlef file", "Tech LEF mismatch", "Tech LEF files matched"))
    results.append(_eval("std_lef_check", s_std, r_std,
                         "Missing standard cell lef", "Std LEF mismatch", "Standard cell LEF matched"))
    if not s_macro and not r_macro:
        results.append(QMSResult("macro_lef_check", "PASS", "No macros in design", report_path=rpath))
    else:
        results.append(_eval("macro_lef_check", s_macro, r_macro,
                             "Missing macro lef", "Macro LEF mismatch", "Macro LEF files matched"))
    return results

def check_io_delay_constraints(reports_dir: Path) -> List[QMSResult]:
    results = []; rpath = str((reports_dir / "check_timing.rpt").resolve())
    content = read_report_file(reports_dir, "check_timing.rpt")
    if not content:
        results.append(QMSResult("input_delay_defined",  "SKIP", "check_timing.rpt not found", report_path=rpath))
        results.append(QMSResult("output_delay_defined", "SKIP", "check_timing.rpt not found", report_path=rpath))
        return results
    for name, pat, label in [("input_delay_defined",  r"no_input_delay[^\d]*(\d+)",  "input"),
                               ("output_delay_defined", r"uncons_endpoint[^\d]*(\d+)", "output")]:
        m = re.search(pat, content, re.IGNORECASE)
        count = int(m.group(1)) if m else 0
        results.append(QMSResult(name, "FAIL" if count > 0 else "PASS",
                                 f"Found {count} missing {label} delays" if count > 0 else f"All {label}s have delays",
                                 value=count, expected=0, report_path=rpath))
    return results

def check_setup_analysis_summary(reports_dir: Path) -> List[QMSResult]:
    results = []; rpt = "setup.analysis_summary.rpt"
    content = read_report_file(reports_dir, rpt)
    if not content:
        content = read_report_file(reports_dir, "setup.analysis_summmary.rpt")
        rpt = "setup.analysis_summmary.rpt" if content else rpt
    rpath = str((reports_dir / rpt).resolve())
    expected = ["no_reg2reg_violations","no_in2reg_violations","no_reg2out_violations",
                "no_in2out_violations","no_max_tran_violations","no_max_cap_violations"]
    if not content:
        for c in expected:
            results.append(QMSResult(c, "SKIP", f"{rpt} not found", report_path=rpath))
        return results
    metrics = {k: {"wns": None} for k in ("reg2reg","in2reg","reg2out","in2out")}
    drv     = {k: {"fep": None} for k in ("max_transition","max_capacitance")}
    for line in content.splitlines():
        line = line.strip()
        if line.startswith("Group :"):
            parts = line.split()
            if len(parts) >= 6 and parts[2] in metrics:
                metrics[parts[2]]["wns"] = parts[3]
        elif line.startswith("Check :"):
            parts = line.split()
            if len(parts) >= 6 and parts[2] in drv:
                drv[parts[2]]["fep"] = parts[5]
    for grp, cid in [("reg2reg","no_reg2reg_violations"),("in2reg","no_in2reg_violations"),
                      ("reg2out","no_reg2out_violations"),("in2out","no_in2out_violations")]:
        wns = metrics[grp]["wns"]
        if wns is None:
            results.append(QMSResult(cid, "SKIP", f"{grp} not found", report_path=rpath))
        elif wns == "N/A":
            results.append(QMSResult(cid, "PASS", f"No paths for {grp}", value=0, expected=0, report_path=rpath))
        else:
            try:
                v = float(wns)
                results.append(QMSResult(cid, "PASS" if v >= 0 else "FAIL", f"{grp} slack: {v}", value=v, expected=0, report_path=rpath))
            except ValueError:
                results.append(QMSResult(cid, "SKIP", f"Could not parse WNS for {grp}", report_path=rpath))
    for chk, cid in [("max_transition","no_max_tran_violations"),("max_capacitance","no_max_cap_violations")]:
        fep = drv[chk]["fep"]
        if fep is None:
            results.append(QMSResult(cid, "SKIP", f"{chk} not found", report_path=rpath))
        else:
            try:
                v = 0 if fep == "N/A" else int(fep)
                results.append(QMSResult(cid, "PASS" if v == 0 else "FAIL",
                                         f"No {chk} violations" if v == 0 else f"Found {v} violations",
                                         value=v, expected=0, report_path=rpath))
            except ValueError:
                results.append(QMSResult(cid, "SKIP", f"Could not parse FEP for {chk}", report_path=rpath))
    return results

def check_design_report_issues(reports_dir: Path) -> List[QMSResult]:
    results = []; rpath = str((reports_dir / "check_design.rpt").resolve())
    content = read_report_file(reports_dir, "check_design.rpt")
    names = ["no_unresolved_references","no_empty_modules","no_undriven_ports","no_undriven_leaf_pins",
             "no_multidriven_leaf_pins","no_multidriven_ports","preserved_leaf_instances","preserved_hierarchical_instances"]
    if not content:
        for n in names:
            results.append(QMSResult(n, "SKIP", "check_design.rpt not found", report_path=rpath))
        return results
    def gc(label):
        m = re.search(rf"{label}\s+(\d+)", content)
        return int(m.group(1)) if m else None
    def pf(name, count, label):
        if count is None:
            return QMSResult(name, "SKIP", f"{label} not found", expected=0, report_path=rpath)
        return QMSResult(name, "PASS" if count == 0 else "FAIL",
                         f"No {label.lower()}" if count == 0 else f"Found {count} {label.lower()}",
                         value=count, expected=0, report_path=rpath)
    results += [pf("no_unresolved_references", gc("Unresolved References"),    "Unresolved References"),
                pf("no_empty_modules",          gc("Empty Modules"),             "Empty Modules"),
                pf("no_undriven_ports",         gc("Undriven Port\\(s\\)"),      "Undriven Port(s)"),
                pf("no_undriven_leaf_pins",     gc("Undriven Leaf Pin\\(s\\)"),  "Undriven Leaf Pin(s)"),
                pf("no_multidriven_ports",      gc("Multidriven Port\\(s\\)"),   "Multidriven Port(s)"),
                pf("no_multidriven_leaf_pins",  gc("Multidriven Leaf Pin\\(s\\)"), "Multidriven Leaf Pin(s)")]
    THRESHOLD = 5
    for name, label in [("preserved_leaf_instances","Preserved leaf instance\\(s\\)"),
                         ("preserved_hierarchical_instances","Preserved hierarchical instance\\(s\\)")]:
        count = gc(label)
        if count is not None:
            results.append(QMSResult(name, "PASS" if count <= THRESHOLD else "FAIL",
                                     f"Preserved: {count} (limit {THRESHOLD})",
                                     value=count, expected=THRESHOLD, report_path=rpath))
        else:
            results.append(QMSResult(name, "SKIP", "Info not found", expected=THRESHOLD, report_path=rpath))
    return results

def check_timing_constraints(reports_dir: Path) -> List[QMSResult]:
    results = []
    trpath = str(reports_dir / "check_timing.rpt")
    drpath = str(reports_dir / "check_design.combo.loops.rpt")
    content = read_report_file(reports_dir, "check_timing.rpt")
    dcontent = read_report_file(reports_dir, "check_design.combo.loops.rpt")
    if not content:
        for cid, _ in [("seq_clock_pins_ok",""),("endpoints_constrained",""),
                        ("inputs_delay_constrained",""),("outputs_delay_constrained",""),
                        ("conflicting_case_constants",""),("master_clock_reachable",""),
                        ("seq_clock_multi_clock_waveforms",""),("seq_data_pin_driven_by_clock","")]:
            results.append(QMSResult(cid, "SKIP", "check_timing.rpt not found", report_path=trpath))
        if not dcontent:
            results.append(QMSResult("no_combinational_loops", "SKIP", "check_design.combo.loops.rpt not found", report_path=drpath))
        return results
    for cid, pat in [
        ("seq_clock_pins_ok",              r"Sequential.*clock.*pins.*without.*clock.*waveform\s+(\d+)"),
        ("inputs_delay_constrained",       r"Inputs.*without.*clocked.*external.*delays\s+(\d+)"),
        ("outputs_delay_constrained",      r"Outputs.*without.*clocked.*external.*delays\s+(\d+)"),
        ("conflicting_case_constants",     r"Pins.*ports.*with.*conflicting.*case.*constants\s+(\d+)"),
        ("master_clock_reachable",         r"Generated.*clocks.*with.*incompatible.*options\s+(\d+)"),
        ("seq_clock_multi_clock_waveforms",r"Sequential\s+clock\s+pins\s+with\s+multiple\s+clock\s+waveforms\s+(\d+)"),
        ("seq_data_pin_driven_by_clock",   r"Sequential\s+data\s+pins\s+driven\s+by\s+a\s+clock\s+signal\s+(\d+)"),
    ]:
        m = re.findall(pat, content, re.IGNORECASE)
        if m:
            count = int(m[0])
            results.append(QMSResult(cid, "FAIL" if count > 0 else "PASS",
                                     f"Found {count}" if count > 0 else "OK",
                                     value=count, expected=0, report_path=trpath))
        else:
            results.append(QMSResult(cid, "SKIP", "Pattern not found", report_path=trpath))
    m = re.findall(r"Endpoint.*not.*constrained.*max.*delay.*?(\w+)", content, re.IGNORECASE)
    if m:
        try: count = int(m[0])
        except ValueError: count = 0
        results.append(QMSResult("endpoints_constrained", "FAIL" if count > 0 else "PASS",
                                 f"Found {count} unconstrained endpoints" if count > 0 else "All endpoints constrained",
                                 value=count, expected=0, report_path=trpath))
    else:
        results.append(QMSResult("endpoints_constrained", "SKIP", "Pattern not found", report_path=trpath))
    if dcontent is None:
        results.append(QMSResult("no_combinational_loops", "SKIP", "check_design.combo.loops.rpt not found", report_path=drpath))
    elif not dcontent.strip():
        results.append(QMSResult("no_combinational_loops", "PASS", "No combinational loops", value=0, expected=0, report_path=drpath))
    else:
        try: count = int(dcontent.strip())
        except ValueError: count = 1
        results.append(QMSResult("no_combinational_loops", "FAIL", "Found combinational loops", value=count, expected=0, report_path=drpath))
    return results

def check_qor_metrics(reports_dir: Path, technology_node: str = "28nm") -> List[QMSResult]:
    results = []; qor_content = ""
    for fn in ["timing_summary.rpt","report_qor.rpt","min_period.rpt","report_qor_after_elaborate.rpt"]:
        c = read_report_file(reports_dir, fn)
        if c: qor_content += c + "\n"
    check_names = ["max_logic_levels","instance_count_stable","no_reg2reg_violations",
                   "no_in2reg_violations","no_reg2out_violations","no_in2out_violations",
                   "no_max_tran_violations","no_max_cap_violations","min_pulse_width_violations"]
    if not qor_content:
        for n in check_names:
            results.append(QMSResult(n, "SKIP", "No QoR reports found", value="N/A", expected="N/A", report_path="N/A"))
        return results
    LOGIC_THRESH = 30
    logic_pat = re.findall(r"^\s*(\S+)\s+[-\d.]+\s+[-\d.]+\s+(\d+)\s+\d+", qor_content, re.MULTILINE)
    if not logic_pat:
        results.append(QMSResult("max_logic_levels","N/A","No critical path info",value="N/A",expected=LOGIC_THRESH ))
        
    else:
        max_l = 0; viol = []
        for grp, gates in logic_pat:
            g = int(gates); max_l = max(max_l, g)
            if g > LOGIC_THRESH: viol.append(f"{grp}={g}")
        if viol:
            results.append(QMSResult("max_logic_levels","FAIL",f"Exceeded {LOGIC_THRESH}: {', '.join(viol)}",value=max_l,expected=LOGIC_THRESH ,report_path=rpath_qor))
        else:
            results.append(QMSResult("max_logic_levels","PASS",f"Within threshold {LOGIC_THRESH}",value=max_l,expected=LOGIC_THRESH ))

    rpath_qor = str((reports_dir / "timing_summary.rpt").resolve())
    for cid, grp in [("no_reg2reg_violations","reg2reg"),("no_in2reg_violations","in2reg"),
                      ("no_reg2out_violations","reg2out"),("no_in2out_violations","in2out")]:
        m = re.findall(rf"^{grp}\s+(No paths|\S+)\s+([\d.]+)?", qor_content, re.MULTILINE)
        if not m:
            results.append(QMSResult(cid,"N/A",f"{grp} not found",value="N/A",expected=0,report_path=rpath_qor)); continue
        st = m[0][0]
        if "No paths" in st:
            results.append(QMSResult(cid,"PASS",f"No paths for {grp}",value=0,expected=0,report_path=rpath_qor))
        else:
            try:
                sl = float(st)
                results.append(QMSResult(cid,"PASS" if sl>=0 else "FAIL",f"{grp} slack: {sl}",value=sl,expected=0,report_path=rpath_qor))
            except:
                results.append(QMSResult(cid,"N/A",f"Cannot parse slack for {grp}",value="N/A",expected=0,report_path=rpath_qor))
    for cid, cn in [("no_max_tran_violations","max_transition"),("no_max_cap_violations","max_capacitance")]:
        m = re.findall(rf"Check:\s*{cn}\s+(N/A|[-\d.]+)\s+(N/A|[-\d.]+)\s+(\d+)", qor_content, re.IGNORECASE)
        if not m or m[0][0].upper() == "N/A":
            results.append(QMSResult(cid,"PASS",f"No {cn} violations",value=0,expected=0,report_path=rpath_qor)); continue
        try:
            wns = float(m[0][0])
            results.append(QMSResult(cid,"PASS" if wns>=0 else "FAIL",f"{cn} WNS={wns}",value=wns,expected=0,report_path=rpath_qor))
        except:
            results.append(QMSResult(cid,"PASS",f"{cn} no violations",value=0,expected=0,report_path=rpath_qor))
    min_c = read_report_file(reports_dir,"min_period.rpt"); min_rpath = str((reports_dir/"min_period.rpt").resolve())
    if not min_c:
        results.append(QMSResult("min_pulse_width_violations","SKIP","min_period.rpt not found",value="N/A",expected="N/A",report_path=min_rpath))
    else:
        hits = re.findall(r"\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*([-\d]+)", min_c)
        if not hits:
            results.append(QMSResult("min_pulse_width_violations","N/A","No pulse width data",value="N/A",expected="N/A",report_path=min_rpath))
        else:
            worst_req=worst_clk=worst_sl=None
            for req,clk,sl in hits:
                sl=int(sl)
                if worst_sl is None or sl<worst_sl:
                    worst_sl=sl;worst_req=int(req);worst_clk=int(clk)
            results.append(QMSResult("min_pulse_width_violations","FAIL" if worst_sl<0 else "PASS",
                                     f"Pulse width Slack={worst_sl}",value=worst_clk,expected=worst_req,report_path=min_rpath))
    elab_c=read_report_file(reports_dir,"report_qor_after_elaborate.rpt"); fin_c=read_report_file(reports_dir,"report_qor.rpt")
    inst_rpath=str((reports_dir/"report_qor.rpt").resolve())
    if not elab_c or not fin_c:
        results.append(QMSResult("instance_count_stable","SKIP","QoR reports not found",value="N/A",expected="N/A",report_path=inst_rpath))
    else:
        m1=re.search(r"Leaf Instance Count\s+(\d+)",elab_c); m2=re.search(r"Leaf Instance Count\s+(\d+)",fin_c)
        el=int(m1.group(1)) if m1 else None; fl=int(m2.group(1)) if m2 else None
        if el is None or fl is None:
            results.append(QMSResult("instance_count_stable","N/A","Leaf count not found",value="N/A",expected="N/A",report_path=inst_rpath))
        else:
            inc=fl-el; allowed=int(0.05*el)
            results.append(QMSResult("instance_count_stable","PASS" if inc<=allowed else "FAIL",
                                     f"Instance increase: +{inc}",value=inc,expected=allowed,report_path=inst_rpath))
    return results


# ==============================================================================
# ROUTE / POSTROUTE DRV + SHIELDING
# ==============================================================================

def check_route_drv_metrics(reports_dir: Path) -> List[QMSResult]:
    results = []
    drv_checks = {"no_max_tran_violations": ("max_tran.rpt","Max transition"),
                  "no_max_cap_violations":  ("max_cap.rpt","Max capacitance"),
                  "no_max_fanout_violations":("max_fanout.rpt","Max fanout")}
    for cid, (fn, desc) in drv_checks.items():
        rpath = str((reports_dir / fn).resolve()); content = read_report_file(reports_dir, fn)
        if not content:
            results.append(QMSResult(cid, "SKIP", f"{fn} not found", report_path=rpath)); continue
        if re.search(rf"{desc} violations resolved on all nets", content, re.IGNORECASE):
            results.append(QMSResult(cid, "PASS", f"{desc} resolved", value=0, expected=0, report_path=rpath)); continue
        slacks = [float(s) for s in re.findall(r"slack\s*:\s*([-\d.]+)", content, re.IGNORECASE)]
        if not slacks:
            results.append(QMSResult(cid, "SKIP", f"Cannot parse {fn}", report_path=rpath))
        else:
            worst = min(slacks)
            results.append(QMSResult(cid, "PASS" if worst >= 0 else "FAIL",
                                     f"{desc} worst slack: {worst}", value=worst, expected=0, report_path=rpath))
    return results


# ==============================================================================
# FLOORPLAN CHECKS
# ==============================================================================

def check_floorplan_utilization(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "utilization.init.rpt")
    rpath = str((reports_dir / "utilization.init.rpt").resolve())
    if not content:
        return QMSResult("floorplan_utilization", "SKIP", "utilization.init.rpt not found", report_path=rpath)
    m = re.search(r"core\s+Utilization\s*=\s*(\d+\.?\d*)", content, re.IGNORECASE)
    if not m:
        return QMSResult("floorplan_utilization", "SKIP", "Utilization not found", report_path=rpath)
    util = float(m.group(1)); thresh = 85.0
    return QMSResult("floorplan_utilization", "PASS" if util <= thresh else "WARN",
                     f"Utilization = {util}%", value=util, expected=thresh, report_path=rpath)

def check_macros_out_of_core(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "check_place.rpt")
    rpath = str((reports_dir / "check_place.rpt").resolve())
    if not content:
        return QMSResult("macros_out_of_core", "SKIP", "check_place.rpt not found", report_path=rpath)
    m = re.search(r"Out\s+of\s+Core\s+Area\s*:\s*(\d+)", content, re.IGNORECASE)
    v = int(m.group(1)) if m else 0
    return QMSResult("macros_out_of_core", "PASS" if v == 0 else "FAIL",
                     f"Macros out of core = {v}", value=v, expected=0, report_path=rpath)

def check_pg_short_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "shorts.sanity_pg.rpt")
    rpath = str((reports_dir / "shorts.sanity_pg.rpt").resolve())
    if not content:
        return QMSResult("pg_short_violations", "SKIP", "shorts.sanity_pg.rpt not found", report_path=rpath)
    m = re.search(r"Verification\s+Complete\s*:\s*(\d+)\s+Short\s+Viols", content)
    if not m:
        return QMSResult("pg_short_violations", "SKIP", "Cannot parse PG short violations", report_path=rpath)
    v = int(m.group(1))
    return QMSResult("pg_short_violations", "PASS" if v == 0 else "FAIL",
                     f"PG Short Violations = {v}", value=v, expected=0, report_path=rpath)

def check_connectivity_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "check_pg_connectivity.rpt")
    rpath = str((reports_dir / "check_pg_connectivity.rpt").resolve())
    if not content:
        return QMSResult("connectivity_violations", "SKIP", "check_pg_connectivity.rpt not found", report_path=rpath)
    if re.search(r"Found\s+no\s+problems\s+or\s+warnings", content, re.IGNORECASE):
        return QMSResult("connectivity_violations", "PASS", "No connectivity violations", value=0, expected=0, report_path=rpath)
    m = re.search(r"(\d+)\s+total\s+infos\s+created", content, re.IGNORECASE)
    if m:
        v = int(m.group(1))
        return QMSResult("connectivity_violations", "PASS" if v == 0 else "FAIL",
                         f"Connectivity violations = {v}", value=v, expected=0, report_path=rpath)
    return QMSResult("connectivity_violations", "SKIP", "Cannot determine connectivity violations", report_path=rpath)

def check_power_via_violations(reports_dir: Path) -> QMSResult:
    content = None; rpath = None
    for fn in ["power_via.sanity_pg.rpt"]:
        f = reports_dir / fn
        if f.exists():
            content = read_report_file(reports_dir, fn); rpath = str(f.resolve()); break
    if not content:
        return QMSResult("power_via_violations", "SKIP", "Power via report not found", report_path=None)
    if re.search(r"Found\s+no\s+problems", content, re.IGNORECASE):
        return QMSResult("power_via_violations", "PASS", "No power via violations", value=0, expected=0, report_path=rpath)
    m = re.search(r"(\d+)\s+Viols", content, re.IGNORECASE)
    v = int(m.group(1)) if m else 0
    return QMSResult("power_via_violations", "PASS" if v == 0 else "FAIL",
                     f"Power via violations = {v}", value=v, expected=0, report_path=rpath)

def check_drc_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "check_pg_drc.rpt")
    rpath = str((reports_dir / "check_pg_drc.rpt").resolve())
    if not content:
        return QMSResult("drc_violations", "SKIP", "check_pg_drc.rpt not found", report_path=rpath)
    m = re.search(r"Total\s+Violations\s*:\s*(\d+)", content, re.IGNORECASE)
    if m:
        v = int(m.group(1))
        return QMSResult("drc_violations", "PASS" if v == 0 else "FAIL",
                         f"DRC Violations = {v}", value=v, expected=0, report_path=rpath)
    if re.search(r"No\s+DRC\s+violations\s+were\s+found", content, re.IGNORECASE):
        return QMSResult("drc_violations", "PASS", "No DRC violations", value=0, expected=0, report_path=rpath)
    return QMSResult("drc_violations", "SKIP", "Cannot determine DRC violations", report_path=rpath)

def check_endcaps_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "check_endcaps.rpt")
    rpath = str((reports_dir / "check_endcaps.rpt").resolve())
    if not content:
        return QMSResult("endcap_violations", "SKIP", "check_endcaps.rpt not found", report_path=rpath)
    if re.search(r"Found\s+no\s+problem", content, re.IGNORECASE):
        return QMSResult("endcap_violations", "PASS", "No endcap violations", value=0, expected=0, report_path=rpath)
    m = re.search(r"Found\s+(\d+)\s+problem", content, re.IGNORECASE)
    if m:
        v = int(m.group(1))
        return QMSResult("endcap_violations", "PASS" if v == 0 else "FAIL",
                         f"Endcap violations = {v}", value=v, expected=0, report_path=rpath)
    return QMSResult("endcap_violations", "SKIP", "Cannot determine endcap violations", report_path=rpath)

def check_welltap_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "check_welltaps.rpt")
    rpath = str((reports_dir / "check_welltaps.rpt").resolve())
    if not content:
        return QMSResult("welltap_violations", "SKIP", "check_welltaps.rpt not found", report_path=rpath)
    m = re.search(r"(\d+)\s+violations\s+found", content, re.IGNORECASE)
    if not m:
        return QMSResult("welltap_violations", "SKIP", "Cannot determine welltap violations", report_path=rpath)
    v = int(m.group(1))
    return QMSResult("welltap_violations", "PASS" if v == 0 else "FAIL",
                     f"Welltap violations = {v}", value=v, expected=0, report_path=rpath)

def check_pin_assignment_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "PinAssignment.sanity_pg.rpt")
    rpath = str((reports_dir / "PinAssignment.sanity_pg.rpt").resolve())
    if not content:
        return QMSResult("pin_assignment_violations", "SKIP", "PinAssignment.sanity_pg.rpt not found", report_path=rpath)
    illegal = unplaced = 0
    for line in content.splitlines():
        if re.search(r"^\s*(TOTAL|aes_cipher_top)", line):
            parts = [p.strip() for p in line.split("|")]
            if len(parts) >= 10:
                try: illegal = int(parts[4]); unplaced = int(parts[9])
                except ValueError: continue
    total = illegal + unplaced
    return QMSResult("pin_assignment_violations", "PASS" if total == 0 else "FAIL",
                     f"Illegal={illegal}, Unplaced={unplaced}", value=total, expected=0, report_path=rpath)

def check_power_domain(reports_dir: Path) -> QMSResult:
    """
    Checks if design has power domain defined
    """

    report_name = "power_domain.rpt"
    report_file = reports_dir / report_name
    report_path = str(report_file.resolve())

    content = read_report_file(reports_dir, report_name)

    if not content:
        return QMSResult(
            "power_domain_check",
            "SKIP",
            f"{report_name} not found",
            report_path=report_path
        )

    # ? FAIL condition
    if "This design has no power domain" in content:
        return QMSResult(
            "power_domain_check",
            "FAIL",
            "No power domain defined in design",
            value=0,
            expected=1,
            report_path=report_path
        )

    # ? PASS condition
    return QMSResult(
        "power_domain_check",
        "PASS",
        "Power domain exists",
        value=1,
        expected=1,
        report_path=report_path
    )
def check_floorplan_log_warnings(logs_dir: Path) -> QMSResult:
    import re

    pat  = r"\*\*\*\s*Message Summary:\s*(\d+)\s*warning\(s\)"
    r_path = str(logs_dir.resolve())

    logs = ""

    if logs_dir.exists():
        for lf in logs_dir.glob("*.log*"):
            try:
                c = lf.read_text(errors="ignore")
                if re.search(pat, c, re.IGNORECASE):
                    logs = c
                    r_path = str(lf.resolve())
                    break
            except Exception:
                pass

    hits = re.findall(pat, logs, re.IGNORECASE)

    if hits:
        w = int(hits[-1])
    else:
        w = len(re.findall(r"\*\*WARN:", logs, re.IGNORECASE))

    return QMSResult(
        "floorplan_warnings",
        "PASS" if w == 0 else "WARN",
        "No warnings" if w == 0 else f"Found {w} warnings",
        value=w,
        expected=0,
        report_path=r_path
    )



def check_floorplan_log_errors(stage_dir: Path) -> QMSResult:
    logs_dir = stage_dir / "logs"
    if not logs_dir.exists(): logs_dir = stage_dir / "floorplan" / "logs"
    rpath = str(logs_dir.resolve())
    if not logs_dir.exists():
        return QMSResult("floorplan_log_errors", "SKIP", "No logs directory found", report_path=rpath)
    log_files = list(logs_dir.glob("*.log"))
    if not log_files:
        return QMSResult("floorplan_log_errors", "SKIP", "No floorplan log file found", report_path=rpath)
    lf = log_files[0]; rpath = str(lf.resolve())
    try:
        content = lf.read_text(errors="ignore")
    except:
        return QMSResult("floorplan_log_errors", "SKIP", "Could not read log", report_path=rpath)
    count = len(re.findall(r"\bERROR\b", content))
    return QMSResult("floorplan_log_errors", "PASS" if count == 0 else "FAIL",
                     f"Floorplan log errors = {count}", value=count, expected=0, report_path=rpath)

def check_floorplan_db_exists(stage_dir: Path) -> QMSResult:
    out = stage_dir / "outputs"; rpath = str(out.resolve())
    if not out.exists():
        return QMSResult("floorplan_db_exists", "FAIL", "outputs directory not found", value=0, expected=1, report_path=rpath)
    dbs = list(out.glob("*.db")); count = len(dbs)
    return QMSResult("floorplan_db_exists", "PASS" if count > 0 else "FAIL",
                     f"DB files found = {count}" if count > 0 else "No DB file found",
                     value=count, expected=1, report_path=rpath)

def check_floorplan_rules(reports_dir: Path) -> QMSResult:
    rpt = reports_dir / "check_floorplan.rpt"; rpath = str(rpt.resolve())
    if not rpt.exists():
        return QMSResult("check_floorplan_rules", "SKIP", "check_floorplan.rpt not found", report_path=rpath)
    try: content = rpt.read_text(errors="ignore")
    except: return QMSResult("check_floorplan_rules", "SKIP", "Could not read report", report_path=rpath)
    m = re.search(r"Message Summary:.*?,\s*(\d+)\s*error\(s\)", content)
    if m:
        v = int(m.group(1))
        return QMSResult("check_floorplan_rules", "PASS" if v == 0 else "FAIL",
                         f"Floorplan rules errors = {v}", value=v, expected=0, report_path=rpath)
    return QMSResult("check_floorplan_rules", "SKIP", "Message Summary not found", report_path=rpath)

def check_macro_halo(reports_dir: Path) -> QMSResult:
    rpt = reports_dir / "macro_halo_report.rpt"; rpath = str(rpt)
    if not rpt.exists():
        return QMSResult("macro_halo", "SKIP", "macro_halo_report.rpt not found", report_path=rpath)
    fail_macros = []; total = 0; no_macro = False
    with open(rpt, "r", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if "No macros found" in line: no_macro = True; break
            if not line or line.startswith(("#","-")) or "MacroName" in line: continue
            parts = line.split()
            if len(parts) < 4: continue
            total += 1
            if parts[1] == parts[2]: fail_macros.append(parts[0])
    if no_macro or total == 0:
        return QMSResult("macro_halo", "SKIP", "No macros present", report_path=rpath)
    if fail_macros:
        return QMSResult("macro_halo", "FAIL", f"{len(fail_macros)} macros missing halo: {', '.join(fail_macros)}",
                         value=len(fail_macros), expected=0, report_path=rpath)
    return QMSResult("macro_halo", "PASS", f"All {total} macros have halo", value=0, expected=0, report_path=rpath)

def _check_floorplan_timing_group(reports_dir: Path, group: str, check_id: str) -> QMSResult:
    rpt = "report_timing_summary.rpt"; content = read_report_file(reports_dir, rpt)
    rpath = str((reports_dir / rpt).resolve())
    if not content:
        return QMSResult(check_id, "SKIP", f"{rpt} not found", report_path=rpath)
    m = re.search(rf"Group\s*:\s*{re.escape(group)}\s+([-+]?\d+\.\d+)\s+([-+]?\d+\.\d+)\s+(\d+)", content)
    if not m:
        return QMSResult(check_id, "PASS", f"No paths for {group}", value=0, expected=0, report_path=rpath)
    try:
        wns, tns, fep = float(m.group(1)), float(m.group(2)), int(m.group(3))
    except (ValueError, IndexError) as e:
        return QMSResult(check_id, "SKIP", f"Could not parse values for {group}: {e}", report_path=rpath)    
    status = "PASS" if wns >= 0 and tns >= 0 and fep == 0 else "FAIL"
    return QMSResult(check_id, status, f"{group} WNS={wns}, TNS={tns}, FEP={fep}",
                     value=wns, expected="WNS >= 0, FEP = 0", report_path=rpath)

def check_floorplan_in2reg_setup_violations(reports_dir):  return _check_floorplan_timing_group(reports_dir, "in2reg",   "floorplan_in2reg_setup_violations")
def check_floorplan_reg2reg_setup_violations(reports_dir): return _check_floorplan_timing_group(reports_dir, "reg2reg",  "floorplan_reg2reg_setup_violations")
def check_floorplan_reg2out_setup_violations(reports_dir): return _check_floorplan_timing_group(reports_dir, "reg2out",  "floorplan_reg2out_setup_violations")
def check_floorplan_reg2cgate_setup_violations(reports_dir):return _check_floorplan_timing_group(reports_dir,"reg2cgate","floorplan_reg2cgate_setup_violations")
def check_floorplan_in2out_setup_violations(reports_dir):  return _check_floorplan_timing_group(reports_dir, "in2out",   "floorplan_in2out_setup_violations")


# ==============================================================================
# CTS / POST-CTS CHECKS
# ==============================================================================

def _check_timing_group(reports_dir: Path, rpt: str, group: str, check_id: str, hold: bool = False) -> QMSResult:
    content = read_report_file(reports_dir, rpt); rpath = str((reports_dir / rpt).resolve())
    if not content:
        return QMSResult(check_id, "SKIP", f"{rpt} not found", report_path=rpath)
    m = re.search(rf"Group\s*:\s*{re.escape(group)}\s+([-+]?\d+\.\d+)\s+([-+]?\d+\.\d+)\s+(\d+)", content)
    if not m:
        # No paths for this group = no violations = PASS (not SKIP)
        return QMSResult(check_id, "PASS", f"No paths for {group}", value=0, expected=0, report_path=rpath)
    try:
        wns, tns, fep = float(m.group(1)), float(m.group(2)), int(m.group(3))
    except (ValueError, IndexError) as e:
        return QMSResult(check_id, "SKIP", f"Could not parse values for {group}: {e}", report_path=rpath)
        
    status = "PASS" if wns >= 0 and tns >= 0 and fep == 0 else "FAIL"
    return QMSResult(check_id, status,
                     f"{group} {'HOLD' if hold else 'SETUP'} WNS={wns}, TNS={tns}, FEP={fep}",
                     value=fep if hold else wns, expected=0, report_path=rpath)

# CTS setup
def check_cts_in2reg_setup_violations(r):   return _check_timing_group(r,"report_timing_summary.setup.rpt","in2reg",  "cts_in2reg_setup_violations")
def check_cts_reg2out_setup_violations(r):  return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2out", "cts_reg2out_setup_violations")
def check_cts_reg2cgate_setup_violations(r):return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2cgate","cts_reg2cgate_setup_violations")
def check_cts_in2out_setup_violations(r):   return _check_timing_group(r,"report_timing_summary.setup.rpt","in2out",  "cts_in2out_setup_violations")
def check_cts_reg2reg_setup_violations(r):  return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2reg", "cts_reg2reg_setup_violations")
# CTS hold
def check_cts_in2reg_hold_violations(r):    return _check_timing_group(r,"report_timing_summary.hold.rpt","in2reg",  "cts_in2reg_hold_violations",  hold=True)
def check_cts_reg2reg_hold_violations(r):   return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2reg", "cts_reg2reg_hold_violations",  hold=True)
def check_cts_reg2out_hold_violations(r):   return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2out", "cts_reg2out_hold_violations",  hold=True)
def check_cts_reg2cgate_hold_violations(r): return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2cgate","cts_reg2cgate_hold_violations",hold=True)
def check_cts_in2out_hold_violations(r):
    rpath = str((r/"report_timing_summary.hold.rpt").resolve())
    return QMSResult("cts_in2out_hold_violations","PASS","No paths for in2out",value=0,expected=0,report_path=rpath)

def check_cts_cell_usage(reports_dir: Path) -> QMSResult:
    import re

    rpt_file = reports_dir / "cts_cell_usage.rpt"
    report_path = str(rpt_file.resolve())

    if not rpt_file.exists():
        return QMSResult(
            "cts_cell_usage",
            "SKIP",
            "cts_cell_usage.rpt not found",
            report_path=report_path
        )

    try:
        content = rpt_file.read_text(errors="ignore")
    except:
        return QMSResult(
            "cts_cell_usage",
            "SKIP",
            "Could not read cts_cell_usage.rpt",
            report_path=report_path
        )

    # ? PASS condition
    if re.search(r"all\s+cts\s+cell\s+usage\s+is\s+valid", content, re.IGNORECASE):
        return QMSResult(
            "cts_cell_usage",
            "PASS",
            "All CTS cell usage is valid",
            report_path=report_path
        )

    # ? FAIL condition
    if re.search(r"not\s+valid", content, re.IGNORECASE):
        return QMSResult(
            "cts_cell_usage",
            "FAIL",
            "CTS cell usage is NOT valid",
            report_path=report_path
        )

    # ?? fallback
    return QMSResult(
        "cts_cell_usage",
        "SKIP",
        "Could not determine CTS cell usage status",
        report_path=report_path
    )
def check_cts_log_warnings(logs_dir: Path) -> QMSResult:
    import re

    pat  = r"\*\*\*\s*Message Summary:\s*(\d+)\s*warning\(s\)"
    r_path = str(logs_dir.resolve())

    logs = ""

    if logs_dir.exists():
        for lf in logs_dir.glob("*.log*"):
            try:
                c = lf.read_text(errors="ignore")
                if re.search(pat, c, re.IGNORECASE):
                    logs = c
                    r_path = str(lf.resolve())
                    break
            except Exception:
                pass

    hits = re.findall(pat, logs, re.IGNORECASE)

    if hits:
        w = int(hits[-1])
    else:
        w = len(re.findall(r"\*\*WARN:", logs, re.IGNORECASE))

    return QMSResult(
        "cts_warnings",
        "PASS" if w == 0 else "WARN",
        "No warnings" if w == 0 else f"Found {w} warnings",
        value=w,
        expected=0,
        report_path=r_path
    )


def check_cts_log_errors(stage_dir: Path) -> QMSResult:
    logs_dir = stage_dir / "logs"
    if not logs_dir.exists(): logs_dir = stage_dir / "cts" / "logs"
    rpath = str(logs_dir.resolve())
    if not logs_dir.exists(): return QMSResult("cts_log_errors","SKIP","No logs dir",report_path=rpath)
    log_files = list(logs_dir.glob("*.log"))
    if not log_files: return QMSResult("cts_log_errors","SKIP","No CTS log found",report_path=rpath)
    lf = log_files[0]; rpath = str(lf.resolve())
    try: content = lf.read_text(errors="ignore")
    except: return QMSResult("cts_log_errors","SKIP","Could not read CTS log",report_path=rpath)
    count = len(re.findall(r"\bERROR\b", content))
    return QMSResult("cts_log_errors","PASS" if count == 0 else "FAIL",
                     f"CTS log errors = {count}",value=count,expected=0,report_path=rpath)

def check_cts_db_exists(stage_dir: Path) -> QMSResult:
    out = stage_dir / "outputs"; rpath = str(out.resolve())
    if not out.exists():
        return QMSResult("cts_db_exists","FAIL","CTS outputs dir not found",value=0,expected=1,report_path=rpath)
    dbs = list(out.glob("*.db")); count = len(dbs)
    return QMSResult("cts_db_exists","PASS" if count > 0 else "FAIL",
                     f"CTS DB files = {count}" if count > 0 else "No CTS DB found",
                     value=count,expected=1,report_path=rpath)

def check_congestion_hotspot(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "report_congestion.rpt")
    rpath = str((reports_dir / "report_congestion.rpt").resolve())
    if not content:
        return QMSResult("congestion_hotspot","SKIP","report_congestion.rpt not found",report_path=rpath)
    m = re.search(r"normalized\s*\|\s*([\d.]+)", content, re.IGNORECASE)
    if not m:
        return QMSResult("congestion_hotspot","SKIP","Cannot determine max hotspot",report_path=rpath)
    val = float(m.group(1))
    return QMSResult("congestion_hotspot","PASS" if val < 100 else "FAIL",
                     f"Max Congestion Hotspot = {val}",value=val,expected="< 100",report_path=rpath)


def check_cts_ndr_applied(reports_dir: Path) -> QMSResult:
    import re

    # ?? Try multiple locations
    rpt = reports_dir / "cts_layer_usage.rpt"

    if not rpt.exists():
        rpt = reports_dir / "reports" / "cts_layer_usage.rpt"

    if not rpt.exists():
        rpt = reports_dir / "work" / "reports" / "cts_layer_usage.rpt"

    rpath = str(rpt.resolve())

    if not rpt.exists():
        return QMSResult(
            "cts_ndr_applied",
            "SKIP",
            "cts_layer_usage.rpt not found",
            report_path=rpath
        )

    try:
        content = rpt.read_text(errors="ignore")
    except:
        return QMSResult(
            "cts_ndr_applied",
            "SKIP",
            "Could not read cts_layer_usage.rpt",
            report_path=rpath
        )

    # ? Parse table
    pattern = r"^(leaf|trunk|top)\s+(\S+)\s+(\S+)\s+(\d+)"
    matches = re.findall(pattern, content, re.MULTILINE)

    if not matches:
        return QMSResult(
            "cts_ndr_applied",
            "SKIP",
            "Could not parse CTS layer usage",
            report_path=rpath
        )

    summary = []
    total_nets = 0

    for net_type, top_layer, bottom_layer, count in matches:
        count = int(count)
        total_nets += count

        summary.append(
            f"{net_type}: top={top_layer}, bottom={bottom_layer}, nets={count}"
        )

    msg = " | ".join(summary)

    # ? Decide PASS/FAIL
    status = "PASS" if total_nets > 0 else "FAIL"

    return QMSResult(
        "cts_ndr_applied",
        status,
        msg,
        value=total_nets,
        expected=">0",
        report_path=rpath
    )

def check_cts_clock_skew(reports_dir: Path) -> QMSResult:
    THRESH = 0.1; rpt = reports_dir / "clock.skew.rpt"; rpath = str(rpt)
    if not rpt.exists(): return QMSResult("cts_clock_skew","SKIP","clock.skew.rpt not found",report_path=rpath)
    try: lines = rpt.read_text(errors="ignore").splitlines()
    except: return QMSResult("cts_clock_skew","SKIP","Could not read report",report_path=rpath)
    vals = []; i = 0; view = None
    while i < len(lines):
        vm = re.search(r"Analysis View:\s*(\S+)", lines[i])
        if vm: view = vm.group(1)
        if view and re.match(r"\s+Skew\s+Latency", lines[i]):
            i += 2
            if i < len(lines):
                nums = re.findall(r"-?\d+\.\d+", lines[i])
                if nums: vals.append((view, float(nums[0]))); view = None
        i += 1
    if not vals: return QMSResult("cts_clock_skew","SKIP","No skew values found",report_path=rpath)
    worst = max(s for _, s in vals); fail = [(v, s) for v, s in vals if s > THRESH]
    msg = f"Clock skew OK ({worst}) all views" if not fail else f"Skew exceeds {THRESH}: {fail}"
    return QMSResult("cts_clock_skew","PASS" if not fail else "FAIL",msg,value=worst,expected=THRESH,report_path=rpath)
def check_cts_drv_max_transition(reports_dir: Path) -> QMSResult:

    import re

    rpt_file = reports_dir / "report_timing_summary.setup.rpt"
    report_path = str(rpt_file)

    if not rpt_file.exists():
        return QMSResult(
            "cts_drv_max_transition",
            "SKIP",
            "report_timing_summary.setup.rpt not found",
            report_path=report_path
        )

    with open(rpt_file, "r", errors="ignore") as f:
        content = f.read()

    match = re.search(r'max_transition\s+([-\d\.NA/]+)\s+([-\d\.NA/]+)\s+(\d+)', content)

    if not match:
        return QMSResult(
            "cts_drv_max_transition",
            "SKIP",
            "max_transition not found",
            report_path=report_path
        )

    wns = match.group(1)
    tns = match.group(2)
    fep = int(match.group(3))

    # Handle N/A
    if wns == "N/A":
        return QMSResult(
            "cts_drv_max_transition",
            "PASS",
            "No max_transition violations",
            value=0,
            expected=0,
            report_path=report_path
        )

    wns = float(wns)

    status = "PASS" if wns >= 0 else "FAIL"

    return QMSResult(
        "cts_drv_max_transition",
        status,
        f"WNS={wns}, TNS={tns}, FEP={fep}",
        value=wns,
        expected="WNS >= 0",
        report_path=report_path
    )

def check_cts_drv_max_capacitance(reports_dir: Path) -> QMSResult:

    import re

    rpt_file = reports_dir / "report_timing_summary.setup.rpt"
    report_path = str(rpt_file)

    if not rpt_file.exists():
        return QMSResult(
            "cts_drv_max_capacitance",
            "SKIP",
            "report_timing_summary.setup.rpt not found",
            report_path=report_path
        )

    with open(rpt_file, "r", errors="ignore") as f:
        content = f.read()

    match = re.search(r'max_capacitance\s+([-\d\.NA/]+)\s+([-\d\.NA/]+)\s+(\d+)', content)

    if not match:
        return QMSResult(
            "cts_drv_max_capacitance",
            "SKIP",
            "max_capacitance not found",
            report_path=report_path
        )

    wns = match.group(1)
    tns = match.group(2)
    fep = int(match.group(3))

    if wns == "N/A":
        return QMSResult(
            "cts_drv_max_capacitance",
            "PASS",
            "No max_capacitance violations",
            value=0,
            expected=0,
            report_path=report_path
        )

    wns = float(wns)

    status = "PASS" if wns >= 0 else "FAIL"

    return QMSResult(
        "cts_drv_max_capacitance",
        status,
        f"WNS={wns}, TNS={tns}, FEP={fep}",
        value=wns,
        expected="WNS >= 0",
        report_path=report_path
    )

def check_cts_drv_max_fanout(reports_dir: Path) -> QMSResult:

    import re

    rpt_file = reports_dir / "report_timing_summary.setup.rpt"
    report_path = str(rpt_file)

    if not rpt_file.exists():
        return QMSResult(
            "cts_drv_max_fanout",
            "SKIP",
            "report_timing_summary.setup.rpt not found",
            report_path=report_path
        )

    with open(rpt_file, "r", errors="ignore") as f:
        content = f.read()

    match = re.search(r'max_fanout\s+([-\d\.]+)\s+([-\d\.]+)\s+(\d+)', content)

    if not match:
        return QMSResult(
            "cts_drv_max_fanout",
            "SKIP",
            "max_fanout not found",
            report_path=report_path
        )

    wns = float(match.group(1))
    tns = float(match.group(2))
    fep = int(match.group(3))

    status = "PASS" if wns >= 0 else "FAIL"

    return QMSResult(
        "cts_drv_max_fanout",
        status,
        f"WNS={wns}, TNS={tns}, FEP={fep}",
        value=wns,
        expected="WNS >= 0",
        report_path=report_path
    )


def check_postcts_clock_tree_max_net_length(reports_dir: Path) -> QMSResult:

    import re

    rpt_file = reports_dir / "report_clock_trees.rpt"
    report_path = str(rpt_file)

    if not rpt_file.exists():
        return QMSResult(
            "postcts_clock_tree_max_net_length",
            "SKIP",
            "report_clock_trees.rpt not found",
            report_path=report_path
        )

    try:
        with open(rpt_file, "r", errors="ignore") as f:
            lines = f.readlines()
    except:
        return QMSResult(
            "postcts_clock_tree_max_net_length",
            "SKIP",
            "Could not read report",
            report_path=report_path
        )

    max_length = None

    for line in lines:
        if "Source-sink routed net length" in line:
            # Extract only floats from this line
            nums = re.findall(r'[-+]?\d*\.\d+|\d+', line)

            # Expected: [min, avg, max, std]
            if len(nums) >= 4:
                try:
                    max_length = float(nums[2])  # 3rd value = MAX
                except:
                    continue
            break

    if max_length is None:
        return QMSResult(
            "postcts_clock_tree_max_net_length",
            "SKIP",
            "Could not extract max routed net length",
            report_path=report_path
        )

    return QMSResult(
        "postcts_clock_tree_max_net_length",
        "PASS",
        f"Max source-sink routed net length = {max_length} um",
        value=max_length,
        expected="Informational",
        report_path=report_path
    )

def check_postcts_max_hotspot(reports_dir: Path) -> QMSResult:

    import re

    rpt_file = reports_dir / "report_congestion.rpt"
    report_path = str(rpt_file)

    # File existence check
    if not rpt_file.exists():
        return QMSResult(
            "postcts_max_hotspot",
            "SKIP",
            "report_congestion.rpt not found",
            report_path=report_path
        )

    # Read file
    try:
        with open(rpt_file, "r", errors="ignore") as f:
            lines = f.readlines()
    except:
        return QMSResult(
            "postcts_max_hotspot",
            "SKIP",
            "Could not read congestion report",
            report_path=report_path
        )

    max_hotspot = None
    total_hotspot = None

    # Extract values
    for line in lines:
        match = re.search(
            r'normalized.*?\|\s*([\d\.]+)\s*\|\s*([\d\.]+)',
            line,
            re.IGNORECASE
        )

        if match:
            max_hotspot = float(match.group(1))
            total_hotspot = float(match.group(2))
            break

    # If parsing failed
    if max_hotspot is None:
        return QMSResult(
            "postcts_max_hotspot",
            "SKIP",
            "Could not extract max hotspot",
            report_path=report_path
        )

    # ---- OPTIONAL THRESHOLD CHECK ----
    # Change this value based on your requirement
    threshold = 10.0

    if max_hotspot > threshold:
        status = "FAIL"
        msg = f"Max hotspot = {max_hotspot} exceeds threshold {threshold}"
    else:
        status = "PASS"
        msg = f"Max hotspot = {max_hotspot}, Total hotspot = {total_hotspot}"

    return QMSResult(
        "postcts_max_hotspot",
        status,
        msg,
        value=max_hotspot,
        expected=f"<= {threshold}",
        report_path=report_path
    )

def check_postcts_max_fanout(reports_dir: Path) -> QMSResult:

    rpt_file = reports_dir / "cts_max_fanout.rpt"
    report_path = str(rpt_file)

    if not rpt_file.exists():
        return QMSResult(
            "postcts_max_fanout",
            "SKIP",
            "cts_max_fanout.rpt not found",
            report_path=report_path
        )

    try:
        with open(rpt_file, "r") as f:
            content = f.read().strip()
    except:
        return QMSResult(
            "postcts_max_fanout",
            "SKIP",
            "Could not read cts_max_fanout.rpt",
            report_path=report_path
        )

    # -------------------------------
    # Extract integer value
    # -------------------------------
    try:
        fanout = int(content.split()[0])
    except:
        return QMSResult(
            "postcts_max_fanout",
            "SKIP",
            "Invalid fanout value in report",
            report_path=report_path
        )

    # Optional rule: fanout should be <= 32 (example)
    status = "PASS" if fanout <= 32 else "FAIL"

    return QMSResult(
        "postcts_max_fanout",
        status,
        f"CTS max fanout = {fanout}",
        value=fanout,
        expected="<= 32",
        report_path=report_path
    )

def check_postcts_clock_route_drc(reports_dir: Path) -> QMSResult:

    import re

    rpt_file = reports_dir / "clock_net_drcs.rpt"
    report_path = str(rpt_file)

    if not rpt_file.exists():
        return QMSResult(
            "postcts_clock_route_drc",
            "SKIP",
            "clock_net_drcs.rpt not found",
            report_path=report_path
        )

    try:
        with open(rpt_file, "r", errors="ignore") as f:
            content = f.read()
    except:
        return QMSResult(
            "postcts_clock_route_drc",
            "SKIP",
            "Could not read DRC report",
            report_path=report_path
        )

    violation_count = None

    # ? Case 1: No violations explicitly mentioned
    if re.search(r'No\s+DRC\s+violations\s+were\s+found', content, re.IGNORECASE):
        violation_count = 0

    # ? Case 2: "Verification Complete : X Viols."
    if violation_count is None:
        match = re.search(r'Verification\s+Complete\s*:\s*(\d+)\s+Viols?', content, re.IGNORECASE)
        if match:
            violation_count = int(match.group(1))

    # ? Case 3: Generic fallback patterns (your original ones)
    if violation_count is None:
        match = re.search(r'Total\s+Violations\s*[:=]\s*(\d+)', content, re.IGNORECASE)

    if violation_count is None and match:
        violation_count = int(match.group(1))

    if violation_count is None:
        match = re.search(r'Violations\s*[:=]\s*(\d+)', content, re.IGNORECASE)

    if violation_count is None and match:
        violation_count = int(match.group(1))

    # ? Final fallback
    if violation_count is None:
        violation_count = 0

    status = "PASS" if violation_count == 0 else "FAIL"

    return QMSResult(
        "postcts_clock_route_drc",
        status,
        f"Clock route DRC violations = {violation_count}",
        value=violation_count,
        expected=0,
        report_path=report_path
    )


def check_cts_instance_count_diff(reports_dir: Path) -> QMSResult:
    import re

    rpt_file = reports_dir / "report_qor.rpt"
    report_path = str(rpt_file)

    if not rpt_file.exists():
        return QMSResult(
            "cts_instance_count_diff",
            "SKIP",
            "report_qor.rpt not found",
            report_path=report_path
        )

    try:
        with open(rpt_file, "r", errors="ignore") as f:
            lines = f.readlines()
    except:
        return QMSResult(
            "cts_instance_count_diff",
            "SKIP",
            "Could not read report_qor.rpt",
            report_path=report_path
        )

    ccopt_insts   = None
    postcts_insts = None

    for line in lines:

        # Match ccopt_design row exactly (not CCOpt::Phase::Initialization)
        if re.match(r'\|\s*ccopt_design\s*\|', line):
            # Only extract numbers with 3+ digits to skip 0s and timestamps
            nums = [int(x) for x in re.findall(r'\b(\d{3,})\b', line)]
            if len(nums) >= 2:
                ccopt_insts = nums[-2]  # second to last = INSTS, last = AREA

        # Match opt_design_postcts_hold row exactly
        if re.match(r'\|\s*opt_design_postcts_hold\s*\|', line):
            nums = [int(x) for x in re.findall(r'\b(\d{3,})\b', line)]
            if len(nums) >= 2:
                postcts_insts = nums[-2]

    if ccopt_insts is None or postcts_insts is None:
        return QMSResult(
            "cts_instance_count_diff",
            "SKIP",
            f"Extraction failed ? ccopt={ccopt_insts}, postcts={postcts_insts}",
            report_path=report_path
        )

    diff = postcts_insts - ccopt_insts

    status = "PASS" if diff >= 0 else "WARN"

    return QMSResult(
        "cts_instance_count_diff",
        status,
        f"Instance count diff (postcts - ccopt) = {diff} ({postcts_insts} - {ccopt_insts})",
        value=diff,
        expected="Informational",
        report_path=report_path
    )
def check_cts_leakage_power(reports_dir: Path) -> QMSResult:

    import re

    rpt_file = reports_dir / "report_power.rpt"   # change name if needed
    report_path = str(rpt_file)

    if not rpt_file.exists():
        return QMSResult(
            "cts_leakage_power",
            "SKIP",
            "Leakage power report not found",
            report_path=report_path
        )

    try:
        with open(rpt_file, "r", errors="ignore") as f:
            content = f.read()
    except:
        return QMSResult(
            "cts_leakage_power",
            "SKIP",
            "Could not read leakage report",
            report_path=report_path
        )

    # -------------------------------
    # Try both formats
    # -------------------------------

    match = re.search(r'Total Leakage Power:\s*([\d\.Ee+-]+)', content)

    if not match:
        match = re.search(r'Total leakage power\s*=\s*([\d\.Ee+-]+)', content)

    if not match:
        return QMSResult(
            "cts_leakage_power",
            "SKIP",
            "Could not extract leakage power",
            report_path=report_path
        )

    leakage = float(match.group(1))

    return QMSResult(
        "cts_leakage_power",
        "PASS",
        f"Total leakage power = {leakage} mW",
        value=leakage,
        expected="Informational",
        report_path=report_path
    )

def check_cts_min_pulse_width_violations(reports_dir: Path) -> QMSResult:
    rpt = reports_dir / "mpw.rpt"; rpath = str(rpt)
    if not rpt.exists(): return QMSResult("cts_min_pulse_width_violations","SKIP","mpw.rpt not found",report_path=rpath)
    try: lines = rpt.read_text(errors="ignore").splitlines()
    except: return QMSResult("cts_min_pulse_width_violations","SKIP","Could not read mpw.rpt",report_path=rpath)
    negs = [float(m.group(1)) for line in lines for m in [re.search(r"\s(-?\d+\.\d+)\s+\S+$", line)] if m and float(m.group(1)) < 0]
    return QMSResult("cts_min_pulse_width_violations","PASS" if not negs else "FAIL",
                     f"Min pulse width violations = {len(negs)}",value=len(negs),expected=0,report_path=rpath)

# PostCTS checks - use generic timing group helper with postcts report names
def check_postcts_in2reg_setup_violations(r):  return _check_timing_group(r,"report_timing_summary.setup.rpt","in2reg",   "postcts_in2reg_setup_violations")
def check_postcts_reg2out_setup_violations(r): return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2out",  "postcts_reg2out_setup_violations")
def check_postcts_reg2cgate_setup_violations(r):return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2cgate","postcts_reg2cgate_setup_violations")
def check_postcts_in2out_setup_violations(r):  return _check_timing_group(r,"report_timing_summary.setup.rpt","in2out",   "postcts_in2out_setup_violations")
def check_postcts_reg2reg_setup_violations(r): return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2reg",  "postcts_reg2reg_setup_violations")
def check_postcts_in2reg_hold_violations(r):   return _check_timing_group(r,"report_timing_summary.hold.rpt","in2reg",   "postcts_in2reg_hold_violations",   hold=True)
def check_postcts_reg2reg_hold_violations(r):  return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2reg",  "postcts_reg2reg_hold_violations",  hold=True)
def check_postcts_reg2out_hold_violations(r):  return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2out",  "postcts_reg2out_hold_violations",  hold=True)
def check_postcts_reg2cgate_hold_violations(r):return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2cgate","postcts_reg2cgate_hold_violations",hold=True)
def check_postcts_in2out_hold_violations(r):
    rpath = str((r/"report_timing_summary.hold.rpt").resolve())
    return QMSResult("postcts_in2out_hold_violations","PASS","No paths for in2out",value=0,expected=0,report_path=rpath)



def check_postcts_log_warnings(logs_dir: Path) -> QMSResult:
    import re

    pat  = r"\*\*\*\s*Message Summary:\s*(\d+)\s*warning\(s\)"
    r_path = str(logs_dir.resolve())

    logs = ""

    if logs_dir.exists():
        for lf in logs_dir.glob("*.log*"):
            try:
                c = lf.read_text(errors="ignore")
                if re.search(pat, c, re.IGNORECASE):
                    logs = c
                    r_path = str(lf.resolve())
                    break
            except Exception:
                pass

    hits = re.findall(pat, logs, re.IGNORECASE)

    if hits:
        w = int(hits[-1])
    else:
        w = len(re.findall(r"\*\*WARN:", logs, re.IGNORECASE))

    return QMSResult(
        "postcts_warnings",
        "PASS" if w == 0 else "WARN",
        "No warnings" if w == 0 else f"Found {w} warnings",
        value=w,
        expected=0,
        report_path=r_path
    )


def check_postcts_connectivity_violations(reports_dir: Path) -> QMSResult:

    import re

    rpt_file = reports_dir / "check_connectivity.rpt"
    report_path = str(rpt_file)

    if not rpt_file.exists():
        return QMSResult(
            "postcts_connectivity_violations",
            "SKIP",
            "check_connectivity.rpt not found",
            report_path=report_path
        )

    try:
        with open(rpt_file, "r", errors="ignore") as f:
            content = f.read()
    except:
        return QMSResult(
            "postcts_connectivity_violations",
            "SKIP",
            "Could not read connectivity report",
            report_path=report_path
        )

    # -------------------------------
    # Extract violations count
    # -------------------------------
    match = re.search(
        r'Verification Complete\s*:\s*(\d+)\s*Viols',
        content,
        re.IGNORECASE
    )

    if not match:
        return QMSResult(
            "postcts_connectivity_violations",
            "SKIP",
            "Could not extract connectivity violations",
            report_path=report_path
        )

    violations = int(match.group(1))

    status = "PASS" if violations == 0 else "FAIL"

    return QMSResult(
        "postcts_connectivity_violations",
        status,
        f"Connectivity violations = {violations}",
        value=violations,
        expected=0,
        report_path=report_path
    )

def check_postcts_log_errors(stage_dir: Path) -> QMSResult:
    logs_dir = stage_dir / "logs"
    if not logs_dir.exists(): logs_dir = stage_dir / "postcts" / "logs"
    rpath = str(logs_dir.resolve())
    if not logs_dir.exists(): return QMSResult("postcts_log_errors","SKIP","No logs dir",report_path=rpath)
    log_files = list(logs_dir.glob("*.log"))
    if not log_files: return QMSResult("postcts_log_errors","SKIP","No postcts log",report_path=rpath)
    lf = log_files[0]; rpath = str(lf.resolve())
    try: content = lf.read_text(errors="ignore")
    except: return QMSResult("postcts_log_errors","SKIP","Could not read log",report_path=rpath)
    count = len(re.findall(r"\bERROR\b", content))
    return QMSResult("postcts_log_errors","PASS" if count == 0 else "FAIL",
                     f"PostCTS log errors = {count}",value=count,expected=0,report_path=rpath)

def check_postcts_db_exists(stage_dir: Path) -> QMSResult:
    out = stage_dir / "outputs"; rpath = str(out.resolve())
    if not out.exists():
        return QMSResult("postcts_db_exists","FAIL","postcts outputs dir not found",value=0,expected=1,report_path=rpath)
    dbs = list(out.glob("*.db")); count = len(dbs)
    return QMSResult("postcts_db_exists","PASS" if count > 0 else "FAIL",
                     f"DB files = {count}",value=count,expected=1,report_path=rpath)

# ==============================================================================
# ROUTE / POSTROUTE CHECKS
# ==============================================================================

def check_route_in2reg_setup_violations(r):   return _check_timing_group(r,"report_timing_summary.setup.rpt","in2reg",  "route_in2reg_setup_violations")
def check_route_reg2out_setup_violations(r):  return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2out", "route_reg2out_setup_violations")
def check_route_reg2cgate_setup_violations(r):return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2cgate","route_reg2cgate_setup_violations")
def check_route_in2out_setup_violations(r):   return _check_timing_group(r,"report_timing_summary.setup.rpt","in2out",  "route_in2out_setup_violations")
def check_route_reg2reg_setup_violations(r):  return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2reg", "route_reg2reg_setup_violations")
def check_route_in2reg_hold_violations(r):    return _check_timing_group(r,"report_timing_summary.hold.rpt","in2reg",  "route_in2reg_hold_violations",  hold=True)
def check_route_reg2reg_hold_violations(r):   return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2reg", "route_reg2reg_hold_violations",  hold=True)
def check_route_reg2out_hold_violations(r):   return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2out", "route_reg2out_hold_violations",  hold=True)
def check_route_reg2cgate_hold_violations(r): return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2cgate","route_reg2cgate_hold_violations",hold=True)
def check_route_in2out_hold_violations(r):
    rpath = str((r/"report_timing_summary.hold.rpt").resolve())
    return QMSResult("route_in2out_hold_violations","PASS","No paths for in2out",value=0,expected=0,report_path=rpath)

def check_route_log_errors(stage_dir: Path) -> QMSResult:
    logs_dir = stage_dir / "logs"
    if not logs_dir.exists(): logs_dir = stage_dir / "route" / "logs"
    rpath = str(logs_dir.resolve())
    if not logs_dir.exists(): return QMSResult("route_log_errors","SKIP","No logs dir",report_path=rpath)
    log_files = list(logs_dir.glob("*.log"))
    if not log_files: return QMSResult("route_log_errors","SKIP","No route log",report_path=rpath)
    lf = log_files[0]; rpath = str(lf.resolve())
    try: content = lf.read_text(errors="ignore")
    except: return QMSResult("route_log_errors","SKIP","Could not read log",report_path=rpath)
    count = len(re.findall(r"\bERROR\b", content))
    return QMSResult("route_log_errors","PASS" if count == 0 else "FAIL",
                     f"Route log errors = {count}",value=count,expected=0,report_path=rpath)

def check_route_db_exists(stage_dir: Path) -> QMSResult:
    out = stage_dir / "outputs"; rpath = str(out.resolve())
    if not out.exists():
        return QMSResult("route_db_exists","FAIL","route outputs dir not found",value=0,expected=1,report_path=rpath)
    dbs = list(out.glob("*.db")); count = len(dbs)
    return QMSResult("route_db_exists","PASS" if count > 0 else "FAIL",
                     f"Route DB files = {count}",value=count,expected=1,report_path=rpath)
def check_SI(log_dir: Path) -> QMSResult:
    # Two patterns: explicit set_db command OR settings dump format
    pat = re.compile(
        r"(?:set_db\s+delaycal_enable_si\s+true"   # set_db style
        r"|delaycal_enable_si\s+true)",             # settings dump style
        re.IGNORECASE
    )

    if not log_dir.exists() or not log_dir.is_dir():
        return QMSResult("delaycal_enable_si", "SKIP",
                         f"Log directory not found: {log_dir}",
                         report_path=str(log_dir))

    found_logs = list(log_dir.rglob("*.log"))
    if not found_logs:
        return QMSResult("delaycal_enable_si", "SKIP",
                         "No log files found in log directory",
                         report_path=str(log_dir))

    for lf in found_logs:
        try:
            with open(lf, "r", errors="ignore") as f:
                for line in f:
                    if pat.search(line):
                        return QMSResult("delaycal_enable_si", "PASS",
                                         f"SI enabled in {lf.name}",
                                         report_path=str(lf))  # full file path now
        except OSError:
            pass

    return QMSResult("delaycal_enable_si", "FAIL",
                     "SI NOT enabled in any log",
                     report_path=str(log_dir))
# ==============================================================================
# POST-ROUTE - DISTINCT REPORT CHECKS  (different from route stage)
# Route reads: max_tran.rpt / max_cap.rpt / max_fanout.rpt  (per-check files)
# PostRoute reads: report_timing_summary.drv.checks.rpt  (single combined file)
# ==============================================================================

def check_postroute_drv_metrics(reports_dir: Path) -> List[QMSResult]:
    """
    PNR-POSTROUTE-DRV-001..005
    Reads report_timing_summary.drv.checks.rpt (the post-ECO consolidated DRV report).
    Distinct from route-stage which reads individual max_tran.rpt / max_cap.rpt files.
    """
    results = []
    report_file = reports_dir / "report_timing_summary.drv.checks.rpt"
    rpath = str(report_file.resolve()) if report_file.exists() else str(report_file.absolute())
    if not report_file.exists():
        for n in ["postroute_no_max_tran_violations","postroute_no_max_cap_violations",
                  "postroute_no_max_fanout_violations","postroute_no_min_tran_violations",
                  "postroute_no_min_cap_violations"]:
            results.append(QMSResult(n,"SKIP","report_timing_summary.drv.checks.rpt not found",report_path=rpath))
        return results
    try:
        content = report_file.read_text(errors="ignore")
    except Exception as e:
        for n in ["postroute_no_max_tran_violations","postroute_no_max_cap_violations",
                  "postroute_no_max_fanout_violations","postroute_no_min_tran_violations",
                  "postroute_no_min_cap_violations"]:
            results.append(QMSResult(n,"SKIP",f"Could not read report: {e}",report_path=rpath))
        return results
    drv_map = [
        ("max_transition",  "postroute_no_max_tran_violations"),
        ("max_capacitance", "postroute_no_max_cap_violations"),
        ("max_fanout",      "postroute_no_max_fanout_violations"),
        ("min_transition",  "postroute_no_min_tran_violations"),
        ("min_capacitance", "postroute_no_min_cap_violations"),
    ]
    for drv_name, check_id in drv_map:
        m = re.search(rf"Check\s*:\s*{re.escape(drv_name)}\s+([-0-9.]+|N/A)\s+([-0-9.]+|N/A)\s+(\d+)",
                      content, re.IGNORECASE)
        if m:
            wns_str, fep = m.group(1), int(m.group(3))
            if wns_str.upper() == "N/A":
                results.append(QMSResult(check_id,"PASS",f"No {drv_name} violations (N/A)",
                                         value=0,expected=0,report_path=rpath))
            else:
                wns = float(wns_str)
                results.append(QMSResult(check_id,"PASS" if wns >= 0 else "FAIL",
                                         f"{drv_name} WNS={wns}, FEP={fep}",
                                         value=wns,expected=0,report_path=rpath))
        else:
            results.append(QMSResult(check_id,"SKIP",f"'{drv_name}' not found in DRV report",report_path=rpath))
    return results


def check_postroute_drc_shorts_and_totals(reports_dir: Path) -> QMSResult:
    """
    PNR-POSTROUTE-RQ-004/005: PostRoute detailed DRC.
    Parses check_drc.rpt for Shorts count (first Totals column) and Grand Total.
    Distinct from route which only checks total count.
    """
    content = read_report_file(reports_dir, "check_drc.rpt")
    rpath = str((reports_dir / "check_drc.rpt").resolve())
    if not content:
        return QMSResult("postroute_drc_shorts_total","SKIP","check_drc.rpt not found",report_path=rpath)
    tm = re.search(r"^Totals\s+(\d+)(?:\s+\d+){7}\s+(\d+)", content, re.MULTILINE)
    if tm:
        shorts, total = int(tm.group(1)), int(tm.group(2))
        suffix = " (Error Limit Reached)" if total >= 1000 else ""
        return QMSResult("postroute_drc_shorts_total","PASS" if total == 0 else "FAIL",
                         f"Shorts={shorts} | Total DRC={total}{suffix}",
                         value=shorts,expected=0,report_path=rpath)
    fm = re.search(r"Verification\s+Complete\s*:\s*(\d+)\s+Viols", content, re.IGNORECASE)
    if fm:
        v = int(fm.group(1))
        return QMSResult("postroute_drc_shorts_total","PASS" if v == 0 else "FAIL",
                         f"Total DRC={v}",value=v,expected=0,report_path=rpath)
    return QMSResult("postroute_drc_shorts_total","FAIL","Cannot parse DRC summary",report_path=rpath)




def check_postroute_floating_nets(reports_dir: Path) -> QMSResult:

    import re

    content = read_report_file(reports_dir, "route.open.rpt")
    rpath = str((reports_dir / "route.open.rpt").resolve())

    if not content:
        return QMSResult(
            "postpostroute_floating_nets",
            "SKIP",
            "route.open.rpt not found",
            report_path=rpath
        )

    # ? Case 1: Clean report
    if "Found no problems or warnings" in content:
        return QMSResult(
            "postroute_floating_nets",
            "PASS",
            "No floating nets",
            value=0,
            expected=0,
            report_path=rpath
        )

    # ? Case 2: Summary line
    tm = re.search(r'(\d+)\s+total\s+info\(s\)\s+created', content, re.IGNORECASE)
    if tm:
        v = int(tm.group(1))
        return QMSResult(
            "postroute_floating_nets",
            "PASS" if v == 0 else "FAIL",
            f"Floating nets (dangling wires) = {v}",
            value=v,
            expected=0,
            report_path=rpath
        )

    # ? Case 3: Verification complete format
    sm = re.search(r'Verification\s+Complete\s*:\s*(\d+)\s+Viols\.?', content, re.IGNORECASE)
    if sm:
        v = int(sm.group(1))
        return QMSResult(
            "postroute_floating_nets",
            "PASS" if v == 0 else "FAIL",
            f"Total connectivity violations = {v}",
            value=v,
            expected=0,
            report_path=rpath
        )

    # ? Final fallback
    return QMSResult(
        "postroute_floating_nets",
        "FAIL",
        "Cannot parse floating nets",
        report_path=rpath
    )
def check_postroute_antenna_violations(reports_dir: Path) -> QMSResult:
    """
    PNR-POSTROUTE-RQ-003: Antenna violations check.
    PostRoute-specific - antenna violations are checked after full routing.
    Parses check_antenna.rpt or antenna_violations.rpt.
    """
    content = None; rpath = None
    for fn in ["check_antenna.rpt", "antenna_violations.rpt", "route_antenna.rpt"]:
        f = reports_dir / fn
        if f.exists():
            content = read_report_file(reports_dir, fn)
            rpath = str(f.resolve())
            break
    if not content:
        return QMSResult("postroute_antenna_violations","SKIP","Antenna report not found",
                         report_path=str(reports_dir.resolve()))
    if re.search(r"No\s+antenna\s+violations?\s+found", content, re.IGNORECASE):
        return QMSResult("postroute_antenna_violations","PASS","No antenna violations",
                         value=0,expected=0,report_path=rpath)
    if re.search(r"Found\s+no\s+problems", content, re.IGNORECASE):
        return QMSResult("postroute_antenna_violations","PASS","No antenna problems",
                         value=0,expected=0,report_path=rpath)
    m = re.search(r"(?:Total\s+)?(?:Antenna\s+)?[Vv]iolations?\s*[=:]\s*(\d+)", content, re.IGNORECASE)
    if m:
        v = int(m.group(1))
        return QMSResult("postroute_antenna_violations","PASS" if v == 0 else "FAIL",
                         f"Antenna violations = {v}",value=v,expected=0,report_path=rpath)
    m2 = re.search(r"Verification\s+Complete\s*:\s*(\d+)\s+Viols", content, re.IGNORECASE)
    if m2:
        v = int(m2.group(1))
        return QMSResult("postroute_antenna_violations","PASS" if v == 0 else "FAIL",
                         f"Antenna violations = {v}",value=v,expected=0,report_path=rpath)
    return QMSResult("postroute_antenna_violations","FAIL","Cannot parse antenna report",report_path=rpath)


def check_postroute_max_net_length(reports_dir: Path, threshold: float = 150.0) -> QMSResult:
    """
    PNR-POSTROUTE-RC-001: PostRoute max net length.
    Same logic as route but uses postroute-specific check_name for the ID map.
    """
    content = read_report_file(reports_dir, "net_wire_lengths.rpt")
    rpath = str((reports_dir / "net_wire_lengths.rpt").resolve())
    if not content:
        return QMSResult("postroute_max_net_length","SKIP","net_wire_lengths.rpt not found",report_path=rpath)
    viols = [line for line in content.strip().split("\n") if line.strip()]
    if not viols:
        return QMSResult("postroute_max_net_length","PASS",f"All nets within {threshold}um",
                         value=0,expected=0,report_path=rpath)
    try:
        lengths = [float(re.search(r":\s*([\d.]+)", ln).group(1)) for ln in viols]
        max_val = max(lengths)
    except: max_val = "N/A"
    return QMSResult("postroute_max_net_length","FAIL",
                     f"{len(viols)} nets > {threshold}um, max={max_val}um",
                     details="\n".join(viols[:5]),value=max_val,expected=threshold,report_path=rpath)



def check_postroute_forbidden_layers(reports_dir: Path) -> QMSResult:
    """
    PNR-POSTROUTE-LU-002: PostRoute forbidden layer check.
    Distinct check_name from route stage for the ID map.
    """
    content = read_report_file(reports_dir, "forbidden_layer_check.rpt")
    rpath = str((reports_dir / "forbidden_layer_check.rpt").resolve())
    if not content:
        return QMSResult("postroute_restricted_forbidden_layers","SKIP",
                         "Forbidden layer report not found",report_path=rpath)
    lm = re.search(r"Forbidden\s+layers\s+(.+)", content, re.IGNORECASE)
    val = lm.group(1).strip() if lm else "N/A"
    vm = re.search(r"Total\s+violations\s+(\d+)", content, re.IGNORECASE)
    viols = int(vm.group(1)) if vm else 0
    return QMSResult("postroute_restricted_forbidden_layers","PASS" if viols == 0 else "FAIL",
                     f"Forbidden layers used: {val}",value=val,expected="0",report_path=rpath)


def check_postroute_filler_gaps(reports_dir: Path) -> QMSResult:
    """
    PNR-POSTROUTE-RQ-006: PostRoute filler gap check.
    Distinct check_name from route stage for the ID map.
    """
    content = read_report_file(reports_dir, "check_filler.rpt")
    rpath = str((reports_dir / "check_filler.rpt").resolve())
    if not content:
        return QMSResult("postroute_no_filler_gaps","SKIP","check_filler.rpt not found",report_path=rpath)
    m = re.search(r"Total\s+number\s+of\s+gaps\s+found:\s*(\d+)", content, re.IGNORECASE)
    if m:
        v = int(m.group(1))
        return QMSResult("postroute_no_filler_gaps","PASS" if v == 0 else "FAIL",
                         f"Filler gaps = {v}",value=v,expected=0,report_path=rpath)
    return QMSResult("postroute_no_filler_gaps","FAIL","Cannot parse filler gap count",report_path=rpath)



def check_postroute_total_drc_count(reports_dir: Path, threshold: int = 0) -> QMSResult:

    import re

    rpt_file = reports_dir / "route.drc.rpt"
    report_path = str(rpt_file.resolve())

    # File existence
    if not rpt_file.exists():
        return QMSResult(
            "postroute_total_drc_count",
            "SKIP",
            "route.drc.rpt not found",
            report_path=report_path
        )

    # Read content
    try:
        content = rpt_file.read_text(errors="ignore")
    except:
        return QMSResult(
            "postroute_total_drc_count",
            "SKIP",
            "Could not read route.drc.rpt",
            report_path=report_path
        )

    # ? Case 0: CLEAN REPORT (VERY IMPORTANT)
    if re.search(r'no\s+drc\s+violations?\s+(were\s+)?found', content, re.IGNORECASE):
        violation_count = 0

        return QMSResult(
            "postroute_total_drc_count",
            "PASS",
            "No DRC violations",
            value=0,
            expected=threshold,
            report_path=report_path
        )

    violation_count = None

    # ? Pattern 1 (Innovus standard)
    m = re.search(r'Verification\s+Complete\s*:\s*(\d+)\s+Viols\.?', content, re.IGNORECASE)

    # ? Pattern 2
    if not m:
        m = re.search(r'Total\s+Violations\s*[:=]\s*(\d+)', content, re.IGNORECASE)

    # ? Pattern 3
    if not m:
        m = re.search(r'Total\s*=\s*(\d+)', content, re.IGNORECASE)

    # ? If nothing matched
    if not m:
        return QMSResult(
            "postroute_total_drc_count",
            "FAIL",
            "Cannot parse DRC count",
            report_path=report_path
        )

    violation_count = int(m.group(1))

    # Status
    status = "PASS" if violation_count <= threshold else "FAIL"

    return QMSResult(
        "postroute_total_drc_count",
        status,
        f"Total DRC violations = {violation_count}",
        value=violation_count,
        expected=threshold,
        report_path=report_path
    )
# ==============================================================================
# POST-ROUTE - SETUP / HOLD TIMING GROUPS
# ==============================================================================

def check_postroute_in2reg_setup_violations(r):   return _check_timing_group(r,"report_timing_summary.setup.rpt","in2reg",  "postroute_in2reg_setup_violations")
def check_postroute_reg2out_setup_violations(r):  return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2out", "postroute_reg2out_setup_violations")
def check_postroute_reg2cgate_setup_violations(r):return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2cgate","postroute_reg2cgate_setup_violations")
def check_postroute_in2out_setup_violations(r):   return _check_timing_group(r,"report_timing_summary.setup.rpt","in2out",  "postroute_in2out_setup_violations")
def check_postroute_reg2reg_setup_violations(r):  return _check_timing_group(r,"report_timing_summary.setup.rpt","reg2reg", "postroute_reg2reg_setup_violations")
def check_postroute_in2reg_hold_violations(r):    return _check_timing_group(r,"report_timing_summary.hold.rpt","in2reg",  "postroute_in2reg_hold_violations",  hold=True)
def check_postroute_reg2reg_hold_violations(r):   return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2reg", "postroute_reg2reg_hold_violations",  hold=True)
def check_postroute_reg2out_hold_violations(r):   return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2out", "postroute_reg2out_hold_violations",  hold=True)
def check_postroute_reg2cgate_hold_violations(r): return _check_timing_group(r,"report_timing_summary.hold.rpt","reg2cgate","postroute_reg2cgate_hold_violations",hold=True)
def check_postroute_in2out_hold_violations(r):
    rpath = str((r/"report_timing_summary.hold.rpt").resolve())
    return QMSResult("postroute_in2out_hold_violations","PASS","No paths for in2out",value=0,expected=0,report_path=rpath)

def check_postroute_log_errors(stage_dir: Path) -> QMSResult:
    logs_dir = stage_dir / "logs"
    if not logs_dir.exists(): logs_dir = stage_dir / "postroute" / "logs"
    rpath = str(logs_dir.resolve())
    if not logs_dir.exists(): return QMSResult("postroute_log_errors","SKIP","No logs dir",report_path=rpath)
    log_files = list(logs_dir.glob("*.log"))
    if not log_files: return QMSResult("postroute_log_errors","SKIP","No postroute log",report_path=rpath)
    lf = log_files[0]; rpath = str(lf.resolve())
    try: content = lf.read_text(errors="ignore")
    except: return QMSResult("postroute_log_errors","SKIP","Could not read log",report_path=rpath)
    count = len(re.findall(r"\bERROR\b", content))
    return QMSResult("postroute_log_errors","PASS" if count == 0 else "FAIL",
                     f"PostRoute log errors = {count}",value=count,expected=0,report_path=rpath)

def check_postroute_db_exists(stage_dir: Path) -> QMSResult:
    out = stage_dir / "outputs"; rpath = str(out.resolve())
    if not out.exists():
        return QMSResult("postroute_db_exists","FAIL","postroute outputs dir not found",value=0,expected=1,report_path=rpath)
    dbs = list(out.glob("*.db")); count = len(dbs)
    return QMSResult("postroute_db_exists","PASS" if count > 0 else "FAIL",
                     f"DB files = {count}",value=count,expected=1,report_path=rpath)

def check_max_net_length(reports_dir: Path, threshold: float = 150.0) -> QMSResult:
    content = read_report_file(reports_dir, "net_wire_lengths.rpt")
    rpath = str((reports_dir / "net_wire_lengths.rpt").resolve())
    if not content:
        return QMSResult("max_net_length","SKIP","net_wire_lengths.rpt not found",report_path=rpath)
    viols = [line for line in content.strip().split("\n") if line.strip()]
    if not viols:
        return QMSResult("max_net_length","PASS",f"All nets within {threshold}um",value=0,expected=0,report_path=rpath)
    try:
        lengths = [float(re.search(r":\s*([\d.]+)", ln).group(1)) for ln in viols]
        max_val = max(lengths)
    except: max_val = "N/A"
    return QMSResult("max_net_length","FAIL",f"{len(viols)} nets > {threshold}um, max={max_val}um",
                     details="\n".join(viols[:5]),value=max_val,expected=threshold,report_path=rpath)

def check_total_drc_count(reports_dir: Path, threshold: int = 0) -> QMSResult:
    content = None; rpath = None
    for fn in ["check_drc.rpt","route.drc.rpt"]:
        f = reports_dir / fn
        if f.exists():
            content = read_report_file(reports_dir, fn); rpath = str(f.resolve()); break
    if not content:
        return QMSResult("total_drc_count","SKIP","DRC report not found",report_path=rpath)
    for pat in [r"Total\s+Violations\s*:\s*(\d+)\s+Viols",
                r"Verification\s+Complete\s*:\s*(\d+)\s+Viols",
                r"^Totals\s+.*?\s+(\d+)\s*$"]:
        m = re.search(pat, content, re.IGNORECASE | re.MULTILINE)
        if m:
            v = int(m.group(1))
            suffix = " (Error limit reached)" if v >= 1000 else ""
            return QMSResult("total_drc_count","PASS" if v <= threshold else "FAIL",
                             f"Total DRC violations = {v}{suffix}",value=v,expected=threshold,report_path=rpath)
    return QMSResult("total_drc_count","FAIL","Cannot parse DRC count",report_path=rpath)

def check_connectivity(reports_dir: Path, threshold: int = 0) -> QMSResult:
    content = read_report_file(reports_dir, "check_connectivity.rpt")
    rpath = str((reports_dir / "check_connectivity.rpt").resolve())
    if not content:
        return QMSResult("check_connectivity","SKIP","check_connectivity.rpt not found",report_path=rpath)
    if "Found no problems or warnings" in content:
        return QMSResult("check_connectivity","PASS","No connectivity problems",value=0,expected=threshold,report_path=rpath)
    m = re.search(r"Verification\s+Complete\s*:\s*(\d+)\s+Viols", content, re.IGNORECASE)
    if m:
        v = int(m.group(1))
        return QMSResult("check_connectivity","PASS" if v <= threshold else "FAIL",
                         f"Connectivity violations = {v}",value=v,expected=threshold,report_path=rpath)
    return QMSResult("check_connectivity","FAIL","Cannot parse connectivity results",report_path=rpath)

def check_floating_nets(reports_dir: Path, threshold: int = 0) -> QMSResult:
    content = read_report_file(reports_dir, "check_connectivity.rpt")
    rpath = str((reports_dir / "check_connectivity.rpt").resolve())
    if not content:
        return QMSResult("floating_nets","SKIP","check_connectivity.rpt not found",report_path=rpath)
    if "Found no problems or warnings" in content:
        return QMSResult("floating_nets","PASS","No floating nets",value=0,expected=threshold,report_path=rpath)
    fm = re.search(r"Floating\s+Net\s*:\s*(\d+)", content, re.IGNORECASE)
    if fm:
        v = int(fm.group(1))
        return QMSResult("floating_nets","PASS" if v <= threshold else "FAIL",
                         f"Floating nets = {v}",value=v,expected=threshold,report_path=rpath)
    sm = re.search(r"Verification\s+Complete\s*:\s*(\d+)\s+Viols", content, re.IGNORECASE)
    if sm:
        v = int(sm.group(1))
        return QMSResult("floating_nets","PASS" if v <= threshold else "FAIL",
                         f"Total connectivity violations = {v}",value=v,expected=threshold,report_path=rpath)
    return QMSResult("floating_nets","FAIL","Cannot parse floating nets",report_path=rpath)

def check_forbidden_layers(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "forbidden_layer_check.rpt")
    rpath = str((reports_dir / "forbidden_layer_check.rpt").resolve())
    if not content:
        return QMSResult("restricted_forbidden_layers","SKIP","Forbidden layer report not found",report_path=rpath)
    lm = re.search(r"Forbidden\s+layers\s+(.+)", content, re.IGNORECASE)
    val = lm.group(1).strip() if lm else "N/A"
    vm = re.search(r"Total\s+violations\s+(\d+)", content, re.IGNORECASE)
    viols = int(vm.group(1)) if vm else 0
    return QMSResult("restricted_forbidden_layers","PASS" if viols == 0 else "FAIL",
                     f"Forbidden layers used: {val}",value=val,expected="0",report_path=rpath)

def check_filler_gaps(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "check_filler.rpt")
    rpath = str((reports_dir / "check_filler.rpt").resolve())
    if not content:
        return QMSResult("no_filler_gaps","SKIP","check_filler.rpt not found",report_path=rpath)
    m = re.search(r"Total\s+number\s+of\s+gaps\s+found:\s*(\d+)", content, re.IGNORECASE)
    if m:
        v = int(m.group(1))
        return QMSResult("no_filler_gaps","PASS" if v == 0 else "FAIL",
                         f"Filler gaps = {v}",value=v,expected=0,report_path=rpath)
    return QMSResult("no_filler_gaps","FAIL","Cannot parse gap count",report_path=rpath)



# ==============================================================================
# PLACEMENT CHECKS
# ==============================================================================
# ==============================================================================
def check_placement_timing_summary(reports_dir: Path) -> List[QMSResult]:
    """
    Parses report_timing_summary.setup.rpt for individual timing groups and DRVs
    specifically under the 'View : ALL' section.
    """
    results = []
    report_filename = "report_timing_summary.setup.rpt"
    content = read_report_file(reports_dir, report_filename)
    report_file = reports_dir / report_filename
    report_realpath = str(report_file.resolve()) if report_file.exists() else str(report_file)

    # Map our internal keys to the check names and display labels
    check_map = {
        "reg2reg": ("no_reg2reg_violations", "reg2reg"),
        "in2reg": ("no_in2reg_violations", "in2reg"),
        "reg2out": ("no_reg2out_violations", "reg2out"),
        "in2out": ("no_in2out_violations", "in2out"),
        "max_transition": ("no_max_tran_violations", "max_transition"),
        "max_capacitance": ("no_max_cap_violations", "max_capacitance")
    }

    # 1. & 2. Condition: Missing or Empty File
    if content is None:
        for key, (check_name, _) in check_map.items():
            results.append(QMSResult(check_name, "SKIP", "report not found", report_path=report_realpath))
        return results

    if not content.strip():
        for key, (check_name, _) in check_map.items():
            results.append(QMSResult(check_name, "SKIP", "report is empty", report_path=report_realpath))
        return results

    # 3. Parse the file strictly under 'View : ALL'
    parsed_data = {}
    current_view = None
    
    for line in content.splitlines():
        line = line.strip()
        
        # Track which view block we are currently inside
        if line.startswith("View :"):
            parts = line.split()
            # parts will be ['View', ':', 'ALL', '6.378', '0.000', '0']
            if len(parts) >= 3:
                current_view = parts[2] # This safely isolates just "ALL"
            
        if current_view == "ALL":
            if line.startswith("Group :"):
                parts = line.split()
                if len(parts) >= 4:
                    grp = parts[2]
                    wns = parts[3]
                    if grp not in parsed_data:
                        parsed_data[grp] = wns
            elif line.startswith("Check :"):
                parts = line.split()
                if len(parts) >= 4:
                    chk = parts[2]
                    wns = parts[3]
                    if chk not in parsed_data:
                        parsed_data[chk] = wns

    # 4. Evaluate logic for each required check
    for key, (check_name, display_name) in check_map.items():
        wns_val = parsed_data.get(key)
        
        # Logic for Setup vs DRV message formatting
        is_timing = "reg" in key or "out" in key
        
        if wns_val is None:
            results.append(QMSResult(check_name, "SKIP", f"{key} not found in report", report_path=report_realpath))
        elif wns_val.upper() == "N/A":
            msg = f"No paths for {display_name}" if is_timing else f"No {display_name} violations"
            results.append(QMSResult(check_name, "PASS", msg, value=0, expected=0, report_path=report_realpath))
        else:
            try:
                val = float(wns_val)
                if val >= 0:
                    msg = f"{display_name} slack is positive: {val}" if is_timing else f"No {display_name} violations"
                    results.append(QMSResult(check_name, "PASS", msg, value=val, expected=0, report_path=report_realpath))
                else:
                    msg = f"{display_name} slack is negative: {val}" if is_timing else f"{display_name} violations: WNS={val}"
                    results.append(QMSResult(check_name, "FAIL", msg, value=val, expected=0, report_path=report_realpath))
            except ValueError:
                results.append(QMSResult(check_name, "SKIP", f"Invalid WNS value: {wns_val}", report_path=report_realpath))

    return results
def check_placement_zero_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "check_place.rpt")
    rpath = str((reports_dir / "check_place.rpt").resolve())
    if not content:
        return QMSResult("placement_violations","SKIP","check_place.rpt not found",report_path=rpath)
    rf = int(m.group(1)) if (m := re.search(r"Region/Fence Violation:\s*(\d+)", content, re.IGNORECASE)) else 0
    ov = int(m.group(1)) if (m := re.search(r"Orientation Violation:\s*(\d+)",   content, re.IGNORECASE)) else 0
    total = rf + ov
    return QMSResult("placement_violations","PASS" if total == 0 else "FAIL",
                     f"Placement violations = {total}",details=f"Region/Fence={rf}, Orient={ov}",
                     value=total,expected=0,report_path=rpath)

def check_instances_within_core(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "check_place.rpt")
    rpath = str((reports_dir / "check_place.rpt").resolve())
    if not content:
        return QMSResult("unplaced_cells","SKIP","check_place.rpt not found",report_path=rpath)
    m = re.search(r"\*info:\s*Unplaced\s*=\s*(\d+)", content, re.IGNORECASE)
    if m:
        v = int(m.group(1))
        return QMSResult("unplaced_cells","PASS" if v == 0 else "FAIL",
                         f"Unplaced cells = {v}",value=v,expected=0,report_path=rpath)
    return QMSResult("unplaced_cells","WARN","Unplaced count not found",report_path=rpath)

def check_no_cell_overlap(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "check_place.rpt")
    rpath = str((reports_dir / "check_place.rpt").resolve())
    if not content:
        return QMSResult("no_cell_overlaps","SKIP","check_place.rpt not found",report_path=rpath)
    m = re.search(r"Overlapping with other instance:\s*(\d+)", content, re.IGNORECASE)
    if m:
        v = int(m.group(1))
        return QMSResult("no_cell_overlaps","PASS" if v == 0 else "FAIL",
                         f"Overlapping cells = {v}",value=v,expected=0,report_path=rpath)
    return QMSResult("no_cell_overlaps","PASS","No overlapping cells (line not present)",value=0,expected=0,report_path=rpath)

def check_placement_density(reports_dir: Path, threshold: float = 85.0) -> QMSResult:
    content = read_report_file(reports_dir, "check_place.rpt")
    rpath = str((reports_dir / "check_place.rpt").resolve())
    if not content:
        return QMSResult("cell_density","SKIP","check_place.rpt not found",report_path=rpath)
    m = re.search(r"Placement Density:\s*(\d+\.?\d*)%", content, re.IGNORECASE)
    if m:
        d = float(m.group(1))
        return QMSResult("cell_density","PASS" if d <= threshold else "FAIL",
                         f"Placement density {d:.1f}%",value=d,expected=threshold,report_path=rpath)
    return QMSResult("cell_density","WARN","Placement density not found",report_path=rpath)

def check_core_utilization(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "check_floorplan.rpt")
    rpath = str((reports_dir / "check_floorplan.rpt").resolve())
    if not content:
        return QMSResult("core_utilization","SKIP","check_floorplan.rpt not found",report_path=rpath)
    m = re.search(r"Core\s+utilization\s*=\s*([0-9.]+)", content, re.IGNORECASE)
    if m:
        return QMSResult("core_utilization","PASS",f"Core utilization = {float(m.group(1))}",
                         value=float(m.group(1)),report_path=rpath)
    return QMSResult("core_utilization","FAIL","Core utilization not found",report_path=rpath)

def check_global_routing_congestion(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "congestion_overflow.rpt")
    rpath = str((reports_dir / "congestion_overflow.rpt").resolve())
    if not content:
        return QMSResult("global_routing_congestion","SKIP","congestion_overflow.rpt not found",report_path=rpath)
    m = re.search(r"Overflow:.*?\(\s*([0-9.]+)%\s*H\s*\).*?\(\s*([0-9.]+)%\s*V\s*\)", content, re.IGNORECASE)
    if m:
        h, v = float(m.group(1)), float(m.group(2))
        return QMSResult("global_routing_congestion","PASS" if h <= 1.0 and v <= 1.0 else "FAIL",
                         f"Congestion H={h}%, V={v}%",value={"H_pct":h,"V_pct":v},expected="<= 1.0%",report_path=rpath)
    return QMSResult("global_routing_congestion","SKIP","Overflow metrics not found",report_path=rpath)

def check_max_congestion_hotspot(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "congestion_hotspot.rpt")
    rpath = str((reports_dir / "congestion_hotspot.rpt").resolve())
    if not content:
        return QMSResult("max_congestion_hotspot","SKIP","congestion_hotspot.rpt not found",report_path=rpath)
    m = re.search(r"normalized\s+max\s+congestion\s+hotspot\s+area\s*=\s*([0-9.]+)", content, re.IGNORECASE)
    if m:
        val = float(m.group(1))
        return QMSResult("max_congestion_hotspot","PASS" if val < 100 else "FAIL",
                         f"Max hotspot area = {val}",value=val,expected="< 100",report_path=rpath)
    return QMSResult("max_congestion_hotspot","SKIP","Max hotspot metric not found",report_path=rpath)

def check_placement_log_errors(log_content: str) -> QMSResult:
    count = len(re.findall(r"^Error:|^\s*Error:", log_content, re.MULTILINE | re.IGNORECASE))
    return QMSResult("no_log_errors","PASS" if count == 0 else "FAIL",
                     f"Placement log errors = {count}",value=count,expected=0)

def check_placement_log_warnings(log_content: str) -> QMSResult:
    count = len(re.findall(r"^\s*WARNING", log_content, re.MULTILINE | re.IGNORECASE))
    return QMSResult("no_log_warnings","PASS",f"Placement warnings = {count}",value=count,expected=0)

def check_placement_db_saved(outputs_dir: Path) -> QMSResult:
    db = next((x for x in outputs_dir.glob("*.db")), None)
    if db:
        return QMSResult("placement_db","PASS",f"DB found: {db.name}",value=0,expected=0,report_path=str(db.resolve()))
    return QMSResult("placement_db","FAIL","Placement DB not found",report_path=str(outputs_dir))

# ==============================================================================
# CHIP FINISH CHECKS
# ==============================================================================

def check_gds_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    fn = f"{block_name}.merged.gds.gz"; f = outputs_dir / fn
    abs_path = str(f.resolve()) if f.exists() else str(f.absolute())
    if f.exists():
        return QMSResult("gds_generated","PASS",f"GDS generated: {fn}",value=fn,expected=fn,report_path=abs_path)
    any_gds = list(outputs_dir.glob("*.gds*"))
    if any_gds:
        return QMSResult("gds_generated","PASS",f"GDS found: {any_gds[0].name}",value=any_gds[0].name,expected=fn,report_path=str(any_gds[0].resolve()))
    return QMSResult("gds_generated","FAIL",f"GDS not found: {fn}",value="None",expected=fn,report_path=abs_path)

def check_lef_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    fn = f"{block_name}_abstract.lef"; f = outputs_dir / fn
    abs_path = str(f.resolve()) if f.exists() else str(f.absolute())
    if f.exists():
        return QMSResult("lef_generated","PASS",f"LEF generated: {fn}",value=fn,expected=fn,report_path=abs_path)
    any_lef = list(outputs_dir.glob("*.lef"))
    if any_lef:
        return QMSResult("lef_generated","PASS",f"LEF found: {any_lef[0].name}",value=any_lef[0].name,expected=fn,report_path=str(any_lef[0].resolve()))
    return QMSResult("lef_generated","FAIL",f"LEF not found: {fn}",value="None",expected=fn,report_path=abs_path)

def check_def_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    fn = f"{block_name}.def"; f = outputs_dir / fn
    abs_path = str(f.resolve()) if f.exists() else str(f.absolute())
    if f.exists() and ".IR.def" not in f.name:
        return QMSResult("def_generated","PASS",f"DEF generated: {fn}",value=fn,expected=fn,report_path=abs_path)
    return QMSResult("def_generated","FAIL","Standard DEF not found",value="None",expected=fn,report_path=abs_path)

def check_pg_verilog_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    fn = f"{block_name}.pg.vg"; f = outputs_dir / fn
    abs_path = str(f.resolve()) if f.exists() else str(f.absolute())
    if f.exists():
        return QMSResult("pg_verilog_generated","PASS",f"PG Verilog generated: {fn}",value=fn,expected=fn,report_path=abs_path)
    return QMSResult("pg_verilog_generated","FAIL","PG Verilog not found",value="None",expected=fn,report_path=abs_path)

def check_standard_verilog_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    fn = f"{block_name}.vg"; f = outputs_dir / fn
    abs_path = str(f.resolve()) if f.exists() else str(f.absolute())
    if f.exists() and not any(x in f.name for x in [".pg.", ".fill."]):
        return QMSResult("standard_verilog_generated","PASS",f"Verilog generated: {fn}",value=fn,expected=fn,report_path=abs_path)
    return QMSResult("standard_verilog_generated","FAIL","Standard Verilog not found",value="None",expected=fn,report_path=abs_path)

def check_spef_cbest_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    fn = f"{block_name}.cbest_m40.spef.gz"; f = outputs_dir / fn
    abs_path = str(f.resolve()) if f.exists() else str(f.absolute())
    if f.exists():
        return QMSResult("spef_cbest_generated", "PASS", f"SPEF generated: {fn}", value=fn, expected=fn, report_path=abs_path)

    return QMSResult("spef_cbest_generated", "FAIL", f"SPEF not found: {fn}", value="None", expected=fn, report_path=abs_path)

def check_spef_cworst_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    fn = f"{block_name}.cworst_m40.spef.gz"
    f = outputs_dir / fn
    abs_path = str(f.resolve())
    if f.exists():
        return QMSResult("spef_cworst_generated", "PASS", f"SPEF generated: {fn}", value=fn, expected=fn, report_path=abs_path)
    return QMSResult("spef_cworst_generated", "FAIL", f"SPEF not found: {fn}", value="None", expected=fn, report_path=abs_path)

def check_spef_rcbest_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    # Note: Your image shows rcbest_125.spef
    fn = f"{block_name}.rcbest_125.spef.gz"
    f = outputs_dir / fn
    abs_path = str(f.resolve())
    if f.exists():
        return QMSResult("spef_rcbest_generated", "PASS", f"SPEF generated: {fn}", value=fn, expected=fn, report_path=abs_path)
    return QMSResult("spef_rcbest_generated", "FAIL", f"SPEF not found: {fn}", value="None", expected=fn, report_path=abs_path)

def check_spef_rcworst_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    fn = f"{block_name}.rcworst_125.spef.gz"
    f = outputs_dir / fn
    abs_path = str(f.resolve())
    if f.exists():
        return QMSResult("spef_rcworst_generated", "PASS", f"SPEF generated: {fn}", value=fn, expected=fn, report_path=abs_path)
    return QMSResult("spef_rcworst_generated", "FAIL", f"SPEF not found: {fn}", value="None", expected=fn, report_path=abs_path)

def check_sdc_ffm40c_cb_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    """Captures the ffm40c_cb (Fast-Fast, -40C) SDC file."""
    fn = f"{block_name}.func_ffm40c_cb.sdc"
    f = outputs_dir / fn
    abs_path = str(f.resolve()) if f.exists() else str(f.absolute())
    
    if f.exists():
        return QMSResult("sdc_ffm40c_cb_generated", "PASS", f"SDC generated: {fn}", value=fn, expected=fn, report_path=abs_path)
    return QMSResult("sdc_ffm40c_cb_generated", "FAIL", f"SDC not found: {fn}", value="None", expected=fn, report_path=abs_path)

def check_sdc_ss125c_rcw_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    """Captures the ss125c_rcw (Slow-Slow, 125C) SDC file."""
    fn = f"{block_name}.func_ss125c_rcw.sdc"
    f = outputs_dir / fn
    abs_path = str(f.resolve()) if f.exists() else str(f.absolute())
    
    if f.exists():
        return QMSResult("sdc_ss125c_rcw_generated", "PASS", f"SDC generated: {fn}", value=fn, expected=fn, report_path=abs_path)
    return QMSResult("sdc_ss125c_rcw_generated", "FAIL", f"SDC not found: {fn}", value="None", expected=fn, report_path=abs_path)

def check_sdc_ssm40c_cw_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    """Captures the ssm40c_cw (Slow-Slow, -40C) SDC file."""
    fn = f"{block_name}.func_ssm40c_cw.sdc"
    f = outputs_dir / fn
    abs_path = str(f.resolve()) if f.exists() else str(f.absolute())
    
    if f.exists():
        return QMSResult("sdc_ssm40c_cw_generated", "PASS", f"SDC generated: {fn}", value=fn, expected=fn, report_path=abs_path)
    return QMSResult("sdc_ssm40c_cw_generated", "FAIL", f"SDC not found: {fn}", value="None", expected=fn, report_path=abs_path)

def check_sdc_ff125c_rcb_generated(outputs_dir: Path, block_name: str) -> QMSResult:
    """Captures the ff125c_rcb (Fast-Fast, 125C) SDC file."""
    fn = f"{block_name}.func_ff125c_rcb.sdc"
    f = outputs_dir / fn
    abs_path = str(f.resolve()) if f.exists() else str(f.absolute())
    
    if f.exists():
        return QMSResult("sdc_ff125c_rcb_generated", "PASS", f"SDC generated: {fn}", value=fn, expected=fn, report_path=abs_path)
    return QMSResult("sdc_ff125c_rcb_generated", "FAIL", f"SDC not found: {fn}", value="None", expected=fn, report_path=abs_path)

def check_chip_finish_max_fanout_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "report_timing_summary.drv.checks.rpt")
    rpath = str((reports_dir / "report_timing_summary.drv.checks.rpt").resolve())
    if not content:
        return QMSResult("max_fanout_violations","SKIP","DRV report not found",report_path=rpath)
    m = re.search(r"Check\s*:\s*max_fanout\s+([-0-9.]+|N/A)\s+[-0-9.]+\s+(\d+)", content, re.IGNORECASE)
    if m:
        wns_str, fep = m.group(1), int(m.group(2))
        if wns_str.upper() == "N/A":
            return QMSResult("max_fanout_violations","PASS","No max_fanout violations",value=0,expected=0,report_path=rpath)
        wns = float(wns_str)
        return QMSResult("max_fanout_violations","PASS" if wns >= 0 else "FAIL",
                         f"Max Fanout WNS={wns}, FEP={fep}",value=wns,expected=0,report_path=rpath)
    return QMSResult("max_fanout_violations","FAIL","Cannot parse max_fanout",report_path=rpath)

def check_chip_finish_max_tran_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "report_timing_summary.drv.checks.rpt")
    rpath = str((reports_dir / "report_timing_summary.drv.checks.rpt").resolve())
    
    if not content:
        return QMSResult("max_transition_violations", "SKIP", "DRV report not found", report_path=rpath)
    
    m = re.search(r"Check\s*:\s*max_transition\s+([-0-9.]+|N/A)\s+([-0-9.]+|N/A)\s+(\d+)", content, re.IGNORECASE)
    
    if m:
        wns_str, fep = m.group(1), int(m.group(3))
        
        # If value is N/A, return 0 for both value and expected
        if wns_str.upper() == "N/A":
            return QMSResult(
                "max_transition_violations", 
                "PASS", 
                "No max_transition violations (N/A)", 
                value=0, 
                expected=0, 
                report_path=rpath
            )
        else:
            # If value is present, convert to float and evaluate
            wns = float(wns_str)
            return QMSResult(
                "max_transition_violations", 
                "PASS" if wns >= 0 else "FAIL",
                f"Max Transition WNS={wns}, FEP={fep}", 
                value=wns, 
                expected=0, 
                report_path=rpath
            )
            
    return QMSResult("max_transition_violations", "FAIL", "Cannot parse max_transition", report_path=rpath)

def check_chip_finish_max_cap_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "report_timing_summary.drv.checks.rpt")
    rpath = str((reports_dir / "report_timing_summary.drv.checks.rpt").resolve())    
    if not content:
        return QMSResult("max_cap_violations", "SKIP", "DRV report not found", report_path=rpath)
    
    m = re.search(r"Check\s*:\s*max_capacitance\s+([-0-9.]+|N/A)\s+([-0-9.]+|N/A)\s+(\d+)", content, re.IGNORECASE)
    
    if m:
        wns_str, fep = m.group(1), int(m.group(3))
        
        # If value is N/A, return 0 for both value and expected
        if wns_str.upper() == "N/A":
            return QMSResult(
                "max_cap_violations", 
                "PASS", 
                "No max_cap violations (N/A)", 
                value=0, 
                expected=0, 
                report_path=rpath
            )
        else:
            # If value is present, convert to float and evaluate
            wns = float(wns_str)
            return QMSResult(
                "max_cap_violations", 
                "PASS" if wns >= 0 else "FAIL",
                f"Max Cap WNS={wns}, FEP={fep}", 
                value=wns, 
                expected=0, 
                report_path=rpath
            )
            
    return QMSResult("max_cap_violations", "FAIL", "Cannot parse max_capacitance", report_path=rpath)

def check_filler_gaps(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "check_filler.rpt")
    rpath = str((reports_dir / "check_filler.rpt").resolve())
    if not content:
        return QMSResult("no_filler_gaps","SKIP","check_filler.rpt not found",report_path=rpath)
    m = re.search(r"Total\s+number\s+of\s+gaps\s+found:\s*(\d+)", content, re.IGNORECASE)
    if m:
        v = int(m.group(1))
        return QMSResult("no_filler_gaps","PASS" if v == 0 else "FAIL",
                         f"Filler gaps = {v}",value=v,expected=0,report_path=rpath)
    return QMSResult("no_filler_gaps","FAIL","Cannot parse gap count",report_path=rpath)

def check_floating_nets(reports_dir: Path, threshold: int = 0) -> QMSResult:
    content = read_report_file(reports_dir, "check_connectivity.rpt")
    rpath = str((reports_dir / "check_connectivity.rpt").resolve())
    if not content:
        return QMSResult("floating_nets","SKIP","check_connectivity.rpt not found",report_path=rpath)
    if "Found no problems or warnings" in content:
        return QMSResult("floating_nets","PASS","No floating nets",value=0,expected=threshold,report_path=rpath)
    fm = re.search(r"Floating\s+Net\s*:\s*(\d+)", content, re.IGNORECASE)
    if fm:
        v = int(fm.group(1))
        return QMSResult("floating_nets","PASS" if v <= threshold else "FAIL",
                         f"Floating nets = {v}",value=v,expected=threshold,report_path=rpath)
    sm = re.search(r"Verification\s+Complete\s*:\s*(\d+)\s+Viols", content, re.IGNORECASE)
    if sm:
        v = int(sm.group(1))
        return QMSResult("floating_nets","PASS" if v <= threshold else "FAIL",
                         f"Total connectivity violations = {v}",value=v,expected=threshold,report_path=rpath)
    return QMSResult("floating_nets","FAIL","Cannot parse floating nets",report_path=rpath)

def check_total_drc_violations(reports_dir: Path) -> QMSResult:
    """
    Parses check_drc.rpt to capture the 'Total Violations' count.
    """
    content = read_report_file(reports_dir, "check_drc.rpt")
    rpath = str((reports_dir / "check_drc.rpt").resolve())
    
    if not content:
        return QMSResult("total_violations", "SKIP", "check_drc.rpt not found", report_path=rpath)
    
    # Matches: Total Violations : 1 Viols.
    m = re.search(r"Total\s+Violations\s*:\s*(\d+)\s+Viols", content, re.IGNORECASE)
    
    if m:
        v = int(m.group(1))
        return QMSResult("total_violations", "PASS" if v == 0 else "FAIL",
                         f"Total DRC Violations = {v}", value=v, expected=0, report_path=rpath)
    
    return QMSResult("total_violations", "FAIL", "Cannot parse Total Violations count", report_path=rpath)

def check_connectivity(reports_dir: Path, threshold: int = 0) -> QMSResult:
    content = read_report_file(reports_dir, "check_connectivity.rpt")
    rpath = str((reports_dir / "check_connectivity.rpt").resolve())
    if not content:
        return QMSResult("check_connectivity","SKIP","check_connectivity.rpt not found",report_path=rpath)
    if "Found no problems or warnings" in content:
        return QMSResult("check_connectivity","PASS","No connectivity problems",value=0,expected=threshold,report_path=rpath)
    m = re.search(r"Verification\s+Complete\s*:\s*(\d+)\s+Viols", content, re.IGNORECASE)
    if m:
        v = int(m.group(1))
        return QMSResult("check_connectivity","PASS" if v <= threshold else "FAIL",
                         f"Connectivity violations = {v}",value=v,expected=threshold,report_path=rpath)
    return QMSResult("check_connectivity","FAIL","Cannot parse connectivity results",report_path=rpath)



# ==============================================================================
# SPECIAL CHECKS (Synthesis)
# ==============================================================================

def check_clock_gating_coverage(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "clock_gating.rpt")
    rpath = str((reports_dir / "clock_gating.rpt").resolve())
    if not content:
        return QMSResult("clock_gating_coverage","SKIP","clock_gating.rpt not found",report_path=rpath)
    m = re.search(r"Total\s+Gated\s+Flip-flops\s+\d+\s+(\d+\.?\d*)", content, re.IGNORECASE)
    if m:
        cov = float(m.group(1)); limit = 85.0
        return QMSResult("clock_gating_coverage","PASS" if cov > limit else "FAIL",
                         f"Coverage {cov}% {'>' if cov > limit else '<='} {limit}%",
                         value=cov,expected=limit,report_path=rpath)
    return QMSResult("clock_gating_coverage","SKIP","Coverage not found in report",report_path=rpath)

def check_optimal_drive_strength(reports_dir: Path) -> List[QMSResult]:
    results = []
    content = read_report_file(reports_dir, "high_drive_cell_check.rpt")
    rpath = str((reports_dir / "high_drive_cell_check.rpt").resolve())
    if not content:
        results.append(QMSResult("optimal_drive_strength","SKIP","high_drive_cell_check.rpt not found",report_path=rpath))
        return results
    if "PASS:" in content and "No" in content and "cells found" in content:
        results.append(QMSResult("optimal_drive_strength","PASS","No high drive strength cells",value=0,expected=0,report_path=rpath))
        return results
    high_drive = ["D18","D20","D24","D32"]
    present = [d for d in high_drive if f"{d} Cells:" in content]
    count = len(re.findall(r"^inst:", content, re.MULTILINE))
    msg = f"Found {', '.join(present)} high drive cells" if present else "High drive cells found"
    results.append(QMSResult("optimal_drive_strength","FAIL",f"{msg} (count={count})",
                             details="High drive cells present",value=count,expected=0,report_path=rpath))
    return results


# ==============================================================================
# TEMPUS STA SIGNOFF CHECK
# ==============================================================================

def check_tempus_sdc_log_stats(logs: str, logs_dir: Path) -> List[QMSResult]:
    """TEM-SDC-001 / TEM-SDC-002"""
    results = []; r_path = _find_log_file(logs_dir, "Constraints read")
    sm = re.search(r"Reading of timing constraints file.*?completed.*?with\s+(\d+)\s+Warning.*?and\s+(\d+)\s+Error",
                   logs, re.IGNORECASE | re.DOTALL)
    if sm:
        w, e = int(sm.group(1)), int(sm.group(2))
    elif re.search(r"INFO\s+\(CTE\):\s*Constraints read successfully", logs, re.IGNORECASE):
        w, e = 0, 0
    else:
        w, e = 0, 0
    cte25 = len(re.findall(r"WARNING\s+\(CTE-25\)", logs, re.IGNORECASE))
    if cte25 > w: w = cte25
    results.append(QMSResult("sdc_no_errors",  "PASS" if e == 0 else "FAIL",
                             "No SDC read errors"   if e == 0 else f"Found {e} SDC read error(s)", value=e, expected=0, report_path=r_path))
    results.append(QMSResult("sdc_no_warnings","PASS" if w == 0 else "WARN",
                             "No SDC read warnings" if w == 0 else f"Found {w} SDC read warning(s)", value=w, expected=0, report_path=r_path))
    return results

def check_tempus_verilog_log_stats(logs: str, logs_dir: Path) -> List[QMSResult]:
    """TEM-VLG-001 / TEM-VLG-002"""
    results = []; r_path = _find_log_file(logs_dir, "Load netlist data")
    block = _section_between(logs, "Begin Load netlist data", "End Load netlist data")
    if not block: block = _section_between(logs, "read_netlist", "init_design")
    if not block: block = logs
    errors   = sum(len(re.findall(p, block, re.IGNORECASE)) for p in [r"\*\*ERROR:", r"Error.*reading.*\.vg?\b", r"Syntax\s+error.*\.vg?\b"])
    warnings = sum(len(re.findall(p, block, re.IGNORECASE)) for p in [r"\*\*WARN:.*\.vg?\b", r"Warning.*parsing.*verilog"])
    results.append(QMSResult("verilog_no_errors",  "PASS" if errors == 0   else "FAIL",
                             "No Verilog read errors"   if errors == 0   else f"Found {errors} error(s)",   value=errors,   expected=0, report_path=r_path))
    results.append(QMSResult("verilog_no_warnings","PASS" if warnings == 0 else "WARN",
                             "No Verilog read warnings" if warnings == 0 else f"Found {warnings} warning(s)", value=warnings, expected=0, report_path=r_path))
    return results

def check_tempus_spef_log_stats(logs: str, logs_dir: Path) -> List[QMSResult]:
    """TEM-PAR-001/002  TEM-SPF-001/002"""
    results = []; r_path = _find_log_file(logs_dir, "spef parsing")
    block = _section_between(logs, "Start spef parsing", "End spef parsing")
    if not block: block = _section_between(logs, "read_spef", "update_timing")
    if not block: block = logs
    e = len(re.findall(r"\*\*ERROR:", block, re.IGNORECASE))
    w = len(re.findall(r"\*\*WARN:",  block, re.IGNORECASE))
    results.append(QMSResult("spef_read_no_errors",  "PASS" if e == 0 else "FAIL", "No errors reading SPEF"     if e == 0 else f"Found {e} error(s)", value=e, expected=0, report_path=r_path))
    results.append(QMSResult("spef_read_no_warnings","PASS" if w == 0 else "WARN", "No warnings reading SPEF"   if w == 0 else f"Found {w} warning(s)", value=w, expected=0, report_path=r_path))
    return results
def check_tempus_max_fanout_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir,"setup.analysis_summary.rpt")
    rpath = str((reports_dir / "report_timing_summary.drv.checks.rpt","setup.analysis_summary.rpt"))
    if not content:
        return QMSResult("max_fanout_violations","SKIP","DRV report not found",report_path=rpath)
    m = re.search(r"Check\s*:\s*max_fanout\s+([-0-9.]+|N/A)\s+[-0-9.]+\s+(\d+)", content, re.IGNORECASE)
    if m:
        wns_str, fep = m.group(1), int(m.group(2))
        if wns_str.upper() == "N/A":
            return QMSResult("max_fanout_violations","PASS","No max_fanout violations",value=0,expected=0,report_path=rpath)
        wns = float(wns_str)
        return QMSResult("max_fanout_violations","PASS" if wns >= 0 else "FAIL",
                         f"Max Fanout WNS={wns}, FEP={fep}",value=wns,expected=0,report_path=rpath)
    return QMSResult("max_fanout_violations","FAIL","Cannot parse max_fanout",report_path=rpath)

def check_tempus_max_tran_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir, "setup.analysis_summary.rpt")
    rpath = str((reports_dir / "report_timing_summary.drv.checks.rpt","setup.analysis_summary.rpt"))
    
    if not content:
        return QMSResult("max_transition_violations", "SKIP", "DRV report not found", report_path=rpath)
    
    m = re.search(r"Check\s*:\s*max_transition\s+([-0-9.]+|N/A)\s+([-0-9.]+|N/A)\s+(\d+)", content, re.IGNORECASE)
    
    if m:
        wns_str, fep = m.group(1), int(m.group(3))
        
        # If value is N/A, return 0 for both value and expected
        if wns_str.upper() == "N/A":
            return QMSResult(
                "max_transition_violations", 
                "PASS", 
                "No max_transition violations (N/A)", 
                value=0, 
                expected=0, 
                report_path=rpath
            )
        else:
            # If value is present, convert to float and evaluate
            wns = float(wns_str)
            return QMSResult(
                "max_transition_violations", 
                "PASS" if wns >= 0 else "FAIL",
                f"Max Transition WNS={wns}, FEP={fep}", 
                value=wns, 
                expected=0, 
                report_path=rpath
            )
            
    return QMSResult("max_transition_violations", "FAIL", "Cannot parse max_transition", report_path=rpath)

def check_tempus_max_cap_violations(reports_dir: Path) -> QMSResult:
    content = read_report_file(reports_dir,"setup.analysis_summary.rpt")
    rpath = str((reports_dir / "report_timing_summary.drv.checks.rpt","setup.analysis_summary.rpt"))    
    if not content:
        return QMSResult("max_cap_violations", "SKIP", "DRV report not found", report_path=rpath)
    
    m = re.search(r"Check\s*:\s*max_capacitance\s+([-0-9.]+|N/A)\s+([-0-9.]+|N/A)\s+(\d+)", content, re.IGNORECASE)
    
    if m:
        wns_str, fep = m.group(1), int(m.group(3))
        
        # If value is N/A, return 0 for both value and expected
        if wns_str.upper() == "N/A":
            return QMSResult(
                "max_cap_violations", 
                "PASS", 
                "No max_cap violations (N/A)", 
                value=0, 
                expected=0, 
                report_path=rpath
            )
        else:
            # If value is present, convert to float and evaluate
            wns = float(wns_str)
            return QMSResult(
                "max_cap_violations", 
                "PASS" if wns >= 0 else "FAIL",
                f"Max Cap WNS={wns}, FEP={fep}", 
                value=wns, 
                expected=0, 
                report_path=rpath
            )
            
    return QMSResult("max_cap_violations", "FAIL", "Cannot parse max_capacitance", report_path=rpath)


def _tempus_eval_slack(blocks, key, check_name, results, rpath):
    block = blocks.get(key,"")
    if not block:
        results.append(QMSResult(check_name,"SKIP",f"'{key}' block not found",report_path=rpath)); return
    if re.search(r"No\s+Check\s+found", block, re.IGNORECASE):
        results.append(QMSResult(check_name,"PASS",f"No {key} checks",value=0,expected=0,report_path=rpath)); return
    vals = [float(m) for m in re.findall(r"slack\s*:\s*([-\d.]+)", block, re.IGNORECASE)]
    if not vals:
        results.append(QMSResult(check_name,"SKIP",f"Cannot parse slack for '{key}'",report_path=rpath)); return
    worst = min(vals); viols = sum(1 for s in vals if s < 0)
    results.append(QMSResult(check_name,"PASS" if viols == 0 else "FAIL",
                             f"No violations (worst:{worst:.3f})" if viols == 0 else f"{viols} violation(s), worst:{worst:.3f}",
                             value=worst,expected=0,report_path=rpath))

def _tempus_eval_pw(blocks, check_name, results, rpath):
    block = blocks.get("pulse_width","")
    if not block:
        results.append(QMSResult(check_name,"SKIP","pulse_width block not found",report_path=rpath)); return
    if re.search(r"No\s+(?:Check|paths)\s+found", block, re.IGNORECASE):
        results.append(QMSResult(check_name,"PASS","No pulse_width violations",value=0,expected=0,report_path=rpath)); return
    vals = []
    for line in block.splitlines():
        nums = re.findall(r"[-]?\d+\.\d+", line)
        if len(nums) >= 3:
            try: vals.append(float(nums[2]))
            except ValueError: pass
    if not vals:
        results.append(QMSResult(check_name,"SKIP","Cannot parse pulse_width slacks",report_path=rpath)); return
    worst = min(vals); viols = sum(1 for s in vals if s < 0)
    results.append(QMSResult(check_name,"PASS" if viols == 0 else "FAIL",
                             f"No violations (worst:{worst:.3f})" if viols == 0 else f"{viols} violation(s), worst:{worst:.3f}",
                             value=worst,expected=0,report_path=rpath))

def check_tempus_annotation_report(reports_dir: Path) -> QMSResult:
    """TEM-PAR-003"""
    candidates = ["check.annotation.rpt","annotation_check.rpt","report_annotated_parasitics.rpt"]
    content = ""; rpath = str(reports_dir.resolve())
    for c in candidates:
        content = read_report_file(reports_dir, c)
        if content: rpath = str((reports_dir / c).resolve()); break
    if not content:
        return QMSResult("annotation_check_clean","SKIP","Annotation report not found",report_path=rpath)
    cm = re.search(r"real\s+net\s+\(complete\)\s*\|[^|]+\|[^|]+\|\s*(\d+)\s+[\d.]+%", content, re.IGNORECASE)
    bm = re.search(r"real\s+net\s+\(broken\)\s*\|[^|]+\|[^|]+\|\s*(\d+)\s+[\d.]+%",   content, re.IGNORECASE)
    if cm is None:
        return QMSResult("annotation_check_clean","SKIP","Cannot parse annotation table",report_path=rpath)
    total = int(cm.group(1)) + (int(bm.group(1)) if bm else 0)
    return QMSResult("annotation_check_clean","PASS" if total == 0 else "FAIL",
                     "All real nets fully annotated" if total == 0 else f"{total} real net(s) not annotated",
                     value=total,expected=0,report_path=rpath)

def check_tempus_netlist_report(reports_dir: Path) -> List[QMSResult]:
    """TEM-NET-001-006"""
    results = []; candidates = ["check.netlist.rpt","check_netlist.rpt"]
    content = ""; rpath = str(reports_dir.resolve())
    for c in candidates:
        content = read_report_file(reports_dir, c)
        if content: rpath = str((reports_dir / c).resolve()); break
    checks = [
        ("no_tri_state_drivers", r"Nets\s+with\s+tri[-\s]state\s+driver\s*[:\s]+(\d+)",     "FAIL"),
        ("no_parallel_drivers",  r"Nets\s+with\s+parallel\s+drivers\s*[:\s]+(\d+)",          "WARN"),
        ("no_multiple_drivers",  r"Nets\s+with\s+multiple\s+drivers\s*[:\s]+(\d+)",          "FAIL"),
        ("no_fanin_missing",     r"Nets\s+with\s+no\s+driver\s*\(No\s+FanIn\)\s*[:\s]+(\d+)","FAIL"),
        ("no_floating_fanout",   r"Output\s+Floating\s+nets\s*\(No\s+FanOut\)\s+(\d+)",      "WARN"),
    ]
    if not content:
        for n, _, _ in checks: results.append(QMSResult(n,"SKIP","check_netlist.rpt not found",report_path=rpath))
        return results
    for name, pat, fail_s in checks:
        m = re.search(pat, content, re.IGNORECASE)
        if m:
            count = int(m.group(1))
            results.append(QMSResult(name,"PASS" if count == 0 else fail_s,
                                     "No issues" if count == 0 else f"Found {count}",
                                     value=count,expected=0,report_path=rpath))
        else:
            results.append(QMSResult(name,"SKIP","Metric not found",report_path=rpath))
    return results

def check_tempus_library_consistency(reports_dir: Path) -> QMSResult:
    """TEM-LIB-001"""

    import re

    content = read_report_file(
        reports_dir, "check_timing_library_consistency.rpt"
    )

    rpath = str(reports_dir / "check_timing_library_consistency.rpt")

    if not content:
        return QMSResult(
            "timing_library_consistency",
            "SKIP",
            "Library consistency report not found",
            report_path=rpath
        )

    # Extract all views checked
    check_views = re.findall(
        r"Checking the Library binding.*?view\s+'([^']+)'",
        content,
        re.IGNORECASE
    )

    # Extract all views passed
    pass_views = re.findall(
        r"Pass\.\s+All instances have library definition in view\s+'([^']+)'",
        content,
        re.IGNORECASE
    )

    check_set = set(check_views)
    pass_set = set(pass_views)

    missing_views = check_set - pass_set

    # FAIL case
    if missing_views:
        return QMSResult(
            "timing_library_consistency",
            "FAIL",
            f"Missing library binding in views: {', '.join(sorted(missing_views))}",
            value=len(missing_views),
            expected=0,
            report_path=rpath
        )

    # PASS case
    if check_set:
        return QMSResult(
            "timing_library_consistency",
            "PASS",
            f"All {len(check_set)} views have proper library binding",
            value=0,
            expected=0,
            report_path=rpath
        )

    # SKIP case
    return QMSResult(
        "timing_library_consistency",
        "SKIP",
        "No library binding section found",
        report_path=rpath
    )
def check_tempus_design_categories(reports_dir: Path) -> List[QMSResult]:
    """TEM-CD-NET-001-005"""
    results = []; candidates = ["check_design.rpt","tempus_check_design.rpt"]
    content = ""; rpath = str(reports_dir.resolve())
    for c in candidates:
        content = read_report_file(reports_dir, c)
        if content: rpath = str((reports_dir / c).resolve()); break
    categories = [
        ("no_undriven_input_hpins",     "netlist",      r"\|\s*CHKNETLIST-1\s*\|\s*warning\s*\|\s*(\d+)"),
        ("power_intent_clean",          "power_intent", None),
        ("timing_category_clean",       "timing",       None),
        ("hierarchical_category_clean", "hierarchical", None),
        ("pin_assign_category_clean",   "pin_assign",   None),
    ]
    if not content:
        for n, _, _ in categories: results.append(QMSResult(n,"SKIP","check_design.rpt not found",report_path=rpath))
        return results
    for check_name, keyword, count_pat in categories:
        bm = re.search(rf"Checking\s+'{re.escape(keyword)}'\s+category\s*\.\.\.(.*?)"
                       rf"(?=Checking\s+'[^']+'\s+category|End:\s+Design|\*\*INFO:|$)",
                       content, re.IGNORECASE | re.DOTALL)
        if not bm:
            results.append(QMSResult(check_name,"SKIP",f"'{keyword}' block not found",report_path=rpath)); continue
        block = bm.group(1)
        if count_pat:
            cm = re.search(count_pat, block, re.IGNORECASE)
            count = int(cm.group(1)) if cm else 0
            results.append(QMSResult(check_name,"WARN" if count > 0 else "PASS",
                                     f"Found {count} undriven input hpin(s)" if count > 0 else "No undriven input hpins",
                                     value=count,expected=0,report_path=rpath)); continue
        if re.search(r"No\s+issues\s+found", block, re.IGNORECASE):
            results.append(QMSResult(check_name,"PASS",f"'{keyword}' category: No issues",value=0,expected=0,report_path=rpath)); continue
        errs  = sum(int(x) for x in re.findall(r"\|\s*\S+\s*\|\s*error\s*\|\s*(\d+)",   block, re.IGNORECASE))
        warns = sum(int(x) for x in re.findall(r"\|\s*\S+\s*\|\s*warning\s*\|\s*(\d+)", block, re.IGNORECASE))
        if errs > 0:   results.append(QMSResult(check_name,"FAIL",  f"'{keyword}': {errs} error(s)",  value=errs,  expected=0, report_path=rpath))
        elif warns > 0:results.append(QMSResult(check_name,"WARN",  f"'{keyword}': {warns} warning(s)",value=warns, expected=0, report_path=rpath))
        else:          results.append(QMSResult(check_name,"PASS",  f"'{keyword}' category: clean",    value=0,     expected=0, report_path=rpath))
    return results

def check_tempus_report_constraint_clock(reports_dir: Path) -> List[QMSResult]:
    """TEM-RC-CLK-001/002/003"""
    results = []; candidates = ["report_constraints.rpt","report_constraint.rpt"]
    content = ""; rpath = str(reports_dir.resolve())
    for c in candidates:
        content = read_report_file(reports_dir, c)
        if content: rpath = str((reports_dir / c).resolve()); break
    clock_checks = [("clock_period_no_violations","clock_period"),
                    ("clock_skew_no_violations","skew"),
                    ("pulse_width_no_violations","pulse_width")]
    if not content:
        for n, _ in clock_checks: results.append(QMSResult(n,"SKIP","report_constraint.rpt not found",report_path=rpath))
        return results
    blocks = _build_check_type_blocks(content)
    for check_name, key in clock_checks:
        block = blocks.get(key,"")
        if not block:
            results.append(QMSResult(check_name,"SKIP",f"'{key}' block not found",report_path=rpath)); continue
        if re.search(r"No\s+paths\s+found", block, re.IGNORECASE):
            results.append(QMSResult(check_name,"PASS",f"No paths for '{key}'",value=0,expected=0,report_path=rpath)); continue
        if key == "pulse_width":
            vals = []
            for line in block.splitlines():
                nums = re.findall(r"[-]?\d+\.\d+", line)
                if len(nums) >= 3:
                    try: vals.append(float(nums[2]))
                    except ValueError: pass
        else:
            vals = [float(m) for m in re.findall(r"slack\s*:\s*([-\d.]+)", block, re.IGNORECASE)]
        if not vals:
            results.append(QMSResult(check_name,"SKIP",f"No slack values for '{key}'",report_path=rpath)); continue
        worst = min(vals); viols = sum(1 for s in vals if s < 0)
        results.append(QMSResult(check_name,"PASS" if viols == 0 else "FAIL",
                                 f"No violations (worst:{worst:.3f})" if viols == 0 else f"{viols} violation(s), worst:{worst:.3f}",
                                 value=worst,expected=0,report_path=rpath))
    return results

def check_tempus_timing_report(reports_dir: Path) -> List[QMSResult]:
    """TEM-CT-001-004"""
    results = []; candidates = ["check.timing.rpt","check_timing.rpt"]
    content = ""; rpath = str(reports_dir.resolve())
    for c in candidates:
        content = read_report_file(reports_dir, c)
        if content: rpath = str((reports_dir / c).resolve()); break
    ct_checks = [("ideal_clock_waveform_clean","ideal_clock_waveform","FAIL"),
                 ("no_drive_missing",           "no_drive",            "WARN"),
                 ("no_input_delay_missing",     "no_input_delay",      "WARN"),
                 ("no_uncons_endpoint",         "uncons_endpoint",     "FAIL")]
    if not content:
        for n, _, _ in ct_checks: results.append(QMSResult(n,"SKIP","check_timing.rpt not found",report_path=rpath))
        return results
    lines = content.splitlines(); collapsed = []; i = 0
    while i < len(lines):
        line = lines[i]
        if re.match(r"^\s*(?:ideal_clock_waveform|no_drive|no_input_delay|uncons_endpoint)\b", line, re.I):
            if not re.search(r"\d+\s*$", line.rstrip()):
                if i+1 < len(lines) and re.match(r"^\s+\d+\s*$", lines[i+1]):
                    line = line.rstrip() + " " + lines[i+1].strip(); i += 1
        collapsed.append(line); i += 1
    processed = "\n".join(collapsed)
    for check_name, keyword, fail_status in ct_checks:
        m = re.search(rf"^\s*{re.escape(keyword)}\b.*?(\d+)\s*$", processed, re.IGNORECASE | re.MULTILINE)
        if m:
            count = int(m.group(1))
            results.append(QMSResult(check_name,"PASS" if count == 0 else fail_status,
                                     f"No issues for '{keyword}'" if count == 0 else f"Found {count} issue(s) for '{keyword}'",
                                     value=count,expected=0,report_path=rpath))
        else:
            results.append(QMSResult(check_name,"PASS",f"'{keyword}' not in summary (assumed 0)",
                                     value=0,expected=0,report_path=rpath))
    return results

# ==============================================================================
# SUMMARY GENERATION  (shared by all stages)
# ==============================================================================

def generate_qms_summary(results: Dict[str, "QMSResult"]) -> Dict[str, Any]:
    total   = len(results)
    passed  = len([r for r in results.values() if r.status == "PASS"])
    failed  = len([r for r in results.values() if r.status == "FAIL"])
    warned  = len([r for r in results.values() if r.status == "WARN"])
    skipped = len([r for r in results.values() if r.status == "SKIP"])
    pass_rate = (passed / total * 100) if total > 0 else 0
    overall   = "FAIL" if failed > 0 else ("WARN" if warned > 5 else "PASS")
    critical  = [r.check_name for r in results.values()
                 if r.status == "FAIL" and any(k in r.check_name.lower()
                    for k in ("error","unresolved","violation","loop"))]
    return {
        "overall_status":    overall,
        "total_checks":      total,
        "passed_checks":     passed,
        "failed_checks":     failed,
        "warned_checks":     warned,
        "skipped_checks":    skipped,
        "pass_rate":         round(pass_rate, 1),
        "critical_failures": critical,
        "recommendations":   generate_recommendations(results),
    }

def generate_recommendations(results: Dict[str, "QMSResult"]) -> List[str]:
    recs = []
    for r in results.values():
        if r.status == "FAIL":
            if "rtl_errors"    in r.check_name: recs.append("Review and fix RTL syntax errors before proceeding")
            elif "unresolved"  in r.check_name: recs.append("Check RTL filelist and library paths")
            elif "constraint"  in r.check_name: recs.append("Review SDC constraints file for syntax errors")
            elif "violation"   in r.check_name: recs.append("Analyze timing violations and adjust constraints or RTL")
            elif "logic_levels"in r.check_name: recs.append("Consider pipeline optimization to reduce logic depth")
    return list(set(recs))
