#!/usr/bin/env python3

from pathlib import Path
from datetime import datetime
from typing import Dict, Any

from qms_utils import *


def run_cts_qms_checks(stage_dir: Path,
                             block_name: str,
                             rtl_tag: str,
                             project: str) -> Dict[str, Any]:

    print("[QMS] Running cts checks")

    qms_results = {}

    logs_dir = stage_dir / "logs"

    reports_dir = stage_dir / "reports"

    if not reports_dir.exists():
        reports_dir = stage_dir / "cts" / "reports"

    # ------------------------------------------------
    # TOOL VERSION CHECK
    # ------------------------------------------------

    logs = read_all_logs(logs_dir)

    if logs:
        qms_results["correct_tool_version"] = \
            check_tool_version(logs, "pnr")
    else:
        qms_results["correct_tool_version"] = \
            QMSResult(
                "correct_tool_version",
                "SKIP",
                "No logs found"
            )


    qms_results["cts_db_exists"] = check_cts_db_exists(stage_dir)
    qms_results["cts_log_errors"] = check_cts_log_errors(stage_dir)
    qms_results["cts_log_warnings"] = check_cts_log_warnings(logs_dir)
    qms_results["congestion_hotspot"] = check_congestion_hotspot(reports_dir)
    qms_results["cts_in2out_setup_violations"] = check_cts_in2out_setup_violations(reports_dir)
    qms_results["cts_in2reg_setup_violations"] = check_cts_in2reg_setup_violations(reports_dir)
    qms_results["cts_reg2cgate_setup_violations"] = check_cts_reg2cgate_setup_violations(reports_dir)
    qms_results["cts_reg2out_setup_violations"] = check_cts_reg2out_setup_violations(reports_dir)
    qms_results["cts_reg2reg_setup_violations"] = check_cts_reg2reg_setup_violations(reports_dir)
    qms_results["cts_in2reg_hold_violations"] = check_cts_in2reg_hold_violations(reports_dir)
    qms_results["cts_reg2reg_hold_violations"] = check_cts_reg2reg_hold_violations(reports_dir)
    qms_results["cts_in2reg_hold_violations"] = check_cts_in2reg_hold_violations(reports_dir)
    qms_results["cts_reg2out_hold_violations"] = check_cts_reg2out_hold_violations(reports_dir)
    qms_results["cts_in2out_hold_violations"] = check_cts_in2out_hold_violations(reports_dir)
    qms_results["cts_ndr_applied"] = check_cts_ndr_applied(reports_dir)
    qms_results["cts_ndr_applied"] = check_cts_ndr_applied(reports_dir)
    qms_results["cts_cell_usage"] = check_cts_cell_usage(reports_dir)
    qms_results["cts_min_pulse_width_violations"] = check_cts_min_pulse_width_violations(reports_dir)
    qms_results["cts_drv_max_transition"] = check_cts_drv_max_transition(reports_dir)
    qms_results["cts_drv_max_capacitance"] = check_cts_drv_max_capacitance(reports_dir)
    qms_results["cts_drv_max_fanout"] = check_cts_drv_max_fanout(reports_dir)
    qms_results["cts_clock_skew"] = check_cts_clock_skew(reports_dir)


 

    

    
    # ------------------------------------------------
    # SUMMARY
    # ------------------------------------------------

    # ------------------------------------------------
    # Phase-dependent blocking classification
    # ------------------------------------------------
    _CTS_BLOCKING_PHASES = {
        # Always blocking — clock tree not built = route cannot start
        "cts_db_exists":                   ["bronze", "silver", "gold"],
        "cts_log_errors":                  ["bronze", "silver", "gold"],
        # Silver+ blocking — clock skew this bad will cause hold failures at route
        "cts_clock_skew":                  ["silver", "gold"],
        # Gold-only blocking — timing targets
        "cts_reg2reg_setup_violations":    ["gold"],
        "cts_in2reg_hold_violations":      ["gold"],
        "cts_reg2reg_hold_violations":     ["gold"],
        "cts_min_pulse_width_violations":  ["gold"],
        "cts_drv_max_transition":          ["gold"],
        "cts_drv_max_capacitance":         ["gold"],
        "cts_drv_max_fanout":              ["gold"],
        "cts_in2out_setup_violations":     ["gold"],
        "cts_in2reg_setup_violations":     ["gold"],
        "cts_reg2cgate_setup_violations":  ["gold"],
        "cts_reg2out_setup_violations":    ["gold"],
        "cts_reg2out_hold_violations":     ["gold"],
        "cts_in2out_hold_violations":      ["gold"],
        # Advisory only
        "cts_log_warnings":                [],
        "congestion_hotspot":              [],
        "cts_ndr_applied":                 [],
        "cts_cell_usage":                  [],
        "correct_tool_version":            [],
    }
    for check_name, result in qms_results.items():
        result.blocking_phases = _CTS_BLOCKING_PHASES.get(
            check_name, ["bronze", "silver", "gold"]
        )

    summary = generate_qms_summary(qms_results)

    final_result = {

        "stage": "cts",

        "block_name": block_name,

        "rtl_tag": rtl_tag,

        "project": project,

        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),

        "stage_directory": str(stage_dir),

        "summary": summary,

        "checks": {
            CTS_CHECK_ID_MAP.get(k,k): v.to_dict()
            for k, v in qms_results.items()
        }
    }

    return final_result


