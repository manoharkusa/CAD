#!/usr/bin/env python3
"""
Route Stage QMS Checks
Merged from all versions - covers tool version, SI, log errors, DB,
DRV metrics, clock shielding, DRC, connectivity, forbidden layers,
net length, filler gaps, and all setup/hold timing groups.
"""

from pathlib import Path
from datetime import datetime
from typing import Dict, Any
from qms_utils import *


def run_route_qms_checks(stage_dir: Path, block_name: str,
                         rtl_tag: str, project: str) -> Dict[str, Any]:

    print(f"[QMS] Running Route quality checks for {block_name}...")

    qms_results = {}
    logs_dir    = stage_dir / "logs"
    reports_dir = stage_dir / "reports"
    if not reports_dir.exists():
        reports_dir = stage_dir / "route" / "reports"

    # =========================================================================
    # TOOL VERSION + SI + LOG ERRORS + DB
    # =========================================================================
    print("[QMS] Analyzing tool logs...")
    all_logs = read_all_logs(logs_dir)

    if all_logs:
        qms_results["correct_tool_version"] = check_tool_version(all_logs, "pnr")
    else:
        qms_results["correct_tool_version"] = QMSResult(
            "correct_tool_version", "SKIP", "No log files found")

    qms_results["SI"]               = check_SI(logs_dir)
    qms_results["route_log_errors"] = check_route_log_errors(stage_dir)
    qms_results["route_db_exists"]  = check_route_db_exists(stage_dir)

    # =========================================================================
    # ROUTE DRV METRICS  (max_tran / max_cap / max_fanout)
    # =========================================================================
    print("[QMS] Analyzing Route DRV metrics...")
    for result in check_route_drv_metrics(reports_dir):
        qms_results[result.check_name] = result

   
    # =========================================================================
    # DRC / CONNECTIVITY / FORBIDDEN LAYERS / NET LENGTH / FILLER GAPS
    # =========================================================================
    print("[QMS] Analyzing DRC, connectivity and physical checks...")
    qms_results["drc_count"]        = check_total_drc_count(reports_dir)
    qms_results["postroute_floating_nets"] = check_postroute_floating_nets(reports_dir)
    qms_results["forbidden_layers"] = check_forbidden_layers(reports_dir)
    qms_results["max_net_length"]   = check_max_net_length(reports_dir)
    qms_results["filler_gap"]       = check_filler_gaps(reports_dir)

    # =========================================================================
    # SETUP TIMING GROUPS
    # =========================================================================
    print("[QMS] Analyzing Setup timing violations...")
    qms_results["route_in2out_setup_violations"]    = check_route_in2out_setup_violations(reports_dir)
    qms_results["route_in2reg_setup_violations"]    = check_route_in2reg_setup_violations(reports_dir)
    qms_results["route_reg2cgate_setup_violations"] = check_route_reg2cgate_setup_violations(reports_dir)
    qms_results["route_reg2out_setup_violations"]   = check_route_reg2out_setup_violations(reports_dir)
    qms_results["route_reg2reg_setup_violations"]   = check_route_reg2reg_setup_violations(reports_dir)

    # =========================================================================
    # HOLD TIMING GROUPS
    # =========================================================================
    print("[QMS] Analyzing Hold timing violations...")
    qms_results["route_in2reg_hold_violations"]    = check_route_in2reg_hold_violations(reports_dir)
    qms_results["route_reg2reg_hold_violations"]   = check_route_reg2reg_hold_violations(reports_dir)
    qms_results["route_reg2out_hold_violations"]   = check_route_reg2out_hold_violations(reports_dir)
    qms_results["route_reg2cgate_hold_violations"] = check_route_reg2cgate_hold_violations(reports_dir)
    qms_results["route_in2out_hold_violations"]    = check_route_in2out_hold_violations(reports_dir)

    # =========================================================================
    # Phase-dependent blocking classification
    # =========================================================================
    _ROUTE_BLOCKING_PHASES = {
        # Always blocking — DRC on final route blocks signoff
        "route_log_errors":                  ["bronze", "silver", "gold"],
        "route_db_exists":                   ["bronze", "silver", "gold"],
        "drc_count":                         ["bronze", "silver", "gold"],
        "postroute_floating_nets":           ["bronze", "silver", "gold"],
        # Silver+ blocking — DRV and antenna at silver+
        "no_max_tran_violations":            ["silver", "gold"],
        "no_max_cap_violations":             ["silver", "gold"],
        "no_max_fanout_violations":          ["silver", "gold"],
        "antenna_violations":                ["silver", "gold"],
        # Gold-only blocking — timing closure
        "route_reg2reg_setup_violations":    ["gold"],
        "route_in2reg_setup_violations":     ["gold"],
        "route_reg2cgate_setup_violations":  ["gold"],
        "route_reg2out_setup_violations":    ["gold"],
        "route_in2out_setup_violations":     ["gold"],
        "route_reg2reg_hold_violations":     ["gold"],
        "route_in2reg_hold_violations":      ["gold"],
        "route_reg2out_hold_violations":     ["gold"],
        "route_reg2cgate_hold_violations":   ["gold"],
        "route_in2out_hold_violations":      ["gold"],
        # Advisory only
        "forbidden_layers":                  [],
        "max_net_length":                    [],
        "filler_gap":                        [],
        "SI":                                [],
        "correct_tool_version":              [],
    }
    for check_name, result in qms_results.items():
        result.blocking_phases = _ROUTE_BLOCKING_PHASES.get(
            check_name, ["bronze", "silver", "gold"]
        )

    # =========================================================================
    # GENERATE SUMMARY
    # =========================================================================
    summary = generate_qms_summary(qms_results)

    final_result = {
        "stage":           "route",
        "block_name":      block_name,
        "rtl_tag":         rtl_tag,
        "project":         project,
        "timestamp":       datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "stage_directory": str(stage_dir),
        "summary":         summary,
        "checks": {
            ROUTE_CHECK_ID_MAP.get(k, k): v.to_dict()
            for k, v in qms_results.items()
        },
    }

    print(f"\n{'=' * 60}")
    print(f"Route QMS Summary:")
    print(f"{'=' * 60}")
    print(f"Overall Status : {summary['overall_status']}")
    print(f"Pass Rate      : {summary['pass_rate']}%")
    print(f"Passed         : {summary['passed_checks']}/{summary['total_checks']}")
    print(f"Failed         : {summary['failed_checks']}")
    print(f"Warnings       : {summary['warned_checks']}")
    print(f"Skipped        : {summary['skipped_checks']}")
    print(f"{'=' * 60}\n")

    return final_result


# ==============================================================================
# CLI
# ==============================================================================

if __name__ == "__main__":
    import argparse
    import json

    parser = argparse.ArgumentParser(description="Run Route QMS checks")
    parser.add_argument("--stage-dir",  required=True, help="Route stage directory path")
    parser.add_argument("--block-name", required=True, help="Block name")
    parser.add_argument("--rtl-tag",    default="v1",       help="RTL tag")
    parser.add_argument("--project",    default="project1", help="Project name")
    parser.add_argument("--output",     help="Output JSON file path")
    args = parser.parse_args()

    results = run_route_qms_checks(
        Path(args.stage_dir), args.block_name, args.rtl_tag, args.project)

    output_file = args.output or f"{args.block_name}_route_qms.json"
    with open(output_file, "w") as f:
        json.dump(results, f, indent=2)

    print(f"Route QMS results saved to: {output_file}")
    exit(1 if results["summary"]["overall_status"] == "FAIL" else 0)
