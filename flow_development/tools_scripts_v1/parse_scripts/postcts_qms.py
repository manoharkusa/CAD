#!/usr/bin/env python3

from pathlib import Path
from datetime import datetime
from typing import Dict, Any

from qms_utils import *


def run_postcts_qms_checks(stage_dir: Path,
                             block_name: str,
                             rtl_tag: str,
                             project: str) -> Dict[str, Any]:

    print("[QMS] Running postcts checks")

    qms_results = {}

    logs_dir = stage_dir / "logs"

    reports_dir = stage_dir / "reports"

    if not reports_dir.exists():
        reports_dir = stage_dir / "postcts" / "reports"

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
   
    qms_results["cts_leakage_power"] = check_cts_leakage_power(reports_dir)
    qms_results["postcts_connectivity_violations"] = check_postcts_connectivity_violations(reports_dir)
    qms_results["postcts_log_errors"] = check_postcts_log_errors(stage_dir)
    qms_results["postcts_log_warnings"] = check_postcts_log_warnings(logs_dir)    
    qms_results["postcts_db_exists"] = check_postcts_db_exists(stage_dir)
    qms_results["postcts_clock_tree_max_net_length"] = check_postcts_clock_tree_max_net_length(reports_dir)
    qms_results["postcts_max_fanout"] = check_postcts_max_fanout(reports_dir)
    qms_results["postcts_in2out_setup_violations"] = check_postcts_in2out_setup_violations(reports_dir)
    qms_results["postcts_in2reg_setup_violations"] = check_postcts_in2reg_setup_violations(reports_dir)
    qms_results["postcts_reg2cgate_setup_violations"] = check_postcts_reg2cgate_setup_violations(reports_dir)
    qms_results["postcts_reg2out_setup_violations"] = check_postcts_reg2out_setup_violations(reports_dir)
    qms_results["postcts_reg2reg_setup_violations"] = check_postcts_reg2reg_setup_violations(reports_dir)
    qms_results["postcts_in2reg_hold_violations"] = check_postcts_in2reg_hold_violations(reports_dir)
    qms_results["postcts_reg2reg_hold_violations"] = check_postcts_reg2reg_hold_violations(reports_dir)
    qms_results["postcts_reg2cgate_hold_violations"] = check_postcts_reg2cgate_hold_violations(reports_dir)
    qms_results["postcts_reg2out_hold_violations"] = check_postcts_reg2out_hold_violations(reports_dir)
    qms_results["postcts_in2out_hold_violations"] = check_postcts_in2out_hold_violations(reports_dir)
    qms_results["postcts_max_hotspot"] = check_postcts_max_hotspot(reports_dir)
    qms_results["postcts_clock_route_drc"] = check_postcts_clock_route_drc(reports_dir)
    qms_results["cts_instance_count_diff"] = check_cts_instance_count_diff(reports_dir)

 




    # ------------------------------------------------
    # Phase-dependent blocking classification
    # ------------------------------------------------
    _POSTCTS_BLOCKING_PHASES = {
        # Always blocking — DB missing = route cannot start
        "postcts_log_errors":                ["bronze", "silver", "gold"],
        "postcts_db_exists":                 ["bronze", "silver", "gold"],
        # Silver+ blocking — clock route DRC will propagate to route
        "postcts_clock_route_drc":           ["silver", "gold"],
        # Gold-only blocking — timing targets
        "postcts_reg2reg_setup_violations":  ["gold"],
        "postcts_in2reg_setup_violations":   ["gold"],
        "postcts_reg2cgate_setup_violations":["gold"],
        "postcts_reg2out_setup_violations":  ["gold"],
        "postcts_in2out_setup_violations":   ["gold"],
        "postcts_in2reg_hold_violations":    ["gold"],
        "postcts_reg2reg_hold_violations":   ["gold"],
        "postcts_reg2cgate_hold_violations": ["gold"],
        "postcts_reg2out_hold_violations":   ["gold"],
        "postcts_in2out_hold_violations":    ["gold"],
        # Advisory only
        "postcts_log_warnings":              [],
        "postcts_max_hotspot":               [],
        "postcts_clock_tree_max_net_length": [],
        "postcts_max_fanout":                [],
        "postcts_connectivity_violations":   [],
        "cts_leakage_power":                 [],
        "cts_instance_count_diff":           [],
        "correct_tool_version":              [],
    }
    for check_name, result in qms_results.items():
        result.blocking_phases = _POSTCTS_BLOCKING_PHASES.get(
            check_name, ["bronze", "silver", "gold"]
        )

    # ------------------------------------------------
    # SUMMARY
    # ------------------------------------------------

    summary = generate_qms_summary(qms_results)

    final_result = {

        "stage": "postcts",

        "block_name": block_name,

        "rtl_tag": rtl_tag,

        "project": project,

        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),

        "stage_directory": str(stage_dir),

        "summary": summary,

        "checks": {
            POSTCTS_CHECK_ID_MAP.get(k,k): v.to_dict()
            for k, v in qms_results.items()
        }
    }

    return final_result




