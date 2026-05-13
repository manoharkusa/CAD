#!/usr/bin/env python3

from pathlib import Path
from datetime import datetime
from typing import Dict, Any

from qms_utils import *
from qms_utils import FP_CHECK_ID_MAP

def run_floorplan_qms_checks(stage_dir: Path,
                             block_name: str,
                             rtl_tag: str,
                             project: str) -> Dict[str, Any]:

    print("[QMS] Running floorplan checks")

    qms_results = {}

    logs_dir = stage_dir / "logs"

    reports_dir = stage_dir / "reports"

    if not reports_dir.exists():
        reports_dir = stage_dir / "floorplan" / "reports"

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

    qms_results["floorplan_log_warnings"] = check_floorplan_log_warnings(logs_dir)
    qms_results["floorplan_utilization"] = check_floorplan_utilization(reports_dir)
    qms_results["endcap_violations"] = check_endcaps_violations(reports_dir)
    qms_results["welltap_violations"] = check_welltap_violations(reports_dir)
    qms_results["pin_assignment_violations"] = check_pin_assignment_violations(reports_dir)
    qms_results["power_via_violations"] = check_power_via_violations(reports_dir)
    qms_results["drc_violations"] = check_drc_violations(reports_dir) 
    qms_results["macros_out_of_core"] = check_macros_out_of_core(reports_dir)
    qms_results["floorplan_log_errors"] = check_floorplan_log_errors(stage_dir)
    qms_results["floorplan_db_exists"] = check_floorplan_db_exists(stage_dir)
    qms_results["pg_short_violations"] = check_pg_short_violations(reports_dir)
    qms_results["connectivity_violations"] = check_connectivity_violations(reports_dir)
    qms_results["floorplan_in2reg_setup_violations"] = check_floorplan_in2reg_setup_violations(reports_dir)
    qms_results["floorplan_reg2out_setup_violations"] = check_floorplan_reg2out_setup_violations(reports_dir)
    qms_results["floorplan_reg2reg_setup_violations"] = check_floorplan_reg2reg_setup_violations(reports_dir)
    qms_results["floorplan_reg2cgate_setup_violations"] = check_floorplan_reg2cgate_setup_violations(reports_dir)
    qms_results["floorplan_in2out_setup_violations"] = check_floorplan_in2out_setup_violations(reports_dir)
    qms_results["floorplan_rules"] = check_floorplan_rules(reports_dir)
    qms_results["power_domain"] = check_power_domain(reports_dir)
    qms_results["macro_halo"] = check_macro_halo(reports_dir)
 



    # ------------------------------------------------
    # Phase-dependent blocking classification
    # ------------------------------------------------
    _FP_BLOCKING_PHASES = {
        # Always blocking — macros/PG faults prevent placement from starting
        "macros_out_of_core":                    ["bronze", "silver", "gold"],
        "pg_short_violations":                   ["bronze", "silver", "gold"],
        "floorplan_log_errors":                  ["bronze", "silver", "gold"],
        "floorplan_db_exists":                   ["bronze", "silver", "gold"],
        # Silver+ blocking — connectivity and endcap critical at silver
        "connectivity_violations":               ["silver", "gold"],
        "endcap_violations":                     ["silver", "gold"],
        "welltap_violations":                    ["silver", "gold"],
        # Gold-only blocking — DRC and timing at gold
        "drc_violations":                        ["gold"],
        "pin_assignment_violations":             ["gold"],
        "power_via_violations":                  ["gold"],
        "floorplan_reg2reg_setup_violations":    ["gold"],
        "floorplan_in2reg_setup_violations":     ["gold"],
        "floorplan_reg2out_setup_violations":    ["gold"],
        "floorplan_reg2cgate_setup_violations":  ["gold"],
        "floorplan_in2out_setup_violations":     ["gold"],
        # Advisory only
        "floorplan_log_warnings":                [],
        "floorplan_utilization":                 [],
        "floorplan_rules":                       [],
        "power_domain":                          [],
        "macro_halo":                            [],
        "correct_tool_version":                  [],
    }
    for check_name, result in qms_results.items():
        result.blocking_phases = _FP_BLOCKING_PHASES.get(
            check_name, ["bronze", "silver", "gold"]
        )

    # ------------------------------------------------
    # SUMMARY
    # ------------------------------------------------

    summary = generate_qms_summary(qms_results)

    final_result = {

        "stage": "floorplan",

        "block_name": block_name,

        "rtl_tag": rtl_tag,

        "project": project,

        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),

        "stage_directory": str(stage_dir),

        "summary": summary,

        "checks": {
            FP_CHECK_ID_MAP.get(k,k): v.to_dict()
            for k, v in qms_results.items()
        }
    }

    return final_result

