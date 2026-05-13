#!/usr/bin/env python3
"""
Post-Route Stage QMS Checks
Stage-specific quality checks for post-routing using reusable functions from qms_utils
"""

from pathlib import Path
from datetime import datetime
from typing import Dict, Any
from qms_utils import *

def run_postroute_qms_checks(stage_dir: Path, block_name: str, rtl_tag: str, project: str) -> Dict[str, Any]:
    """
    Run post-route-specific QMS checks
    """
    print(f"[QMS] Running post-route quality checks for {block_name}...")
    
    qms_results = {}
    logs_dir = stage_dir / "logs"
    reports_dir = stage_dir / "reports"
    
    # Fallback for reports directory
    if not reports_dir.exists():
        reports_dir = stage_dir / "postroute" / "reports"
    
    # =========================================================================
    # TOOL LOGS & GENERAL DB CHECKS
    # =========================================================================
    print("[QMS] Analyzing tool logs and general metrics...")
    all_logs = read_all_logs(logs_dir)
    
    if all_logs:
        qms_results["correct_tool_version"] = check_tool_version(all_logs, "pnr")
    else:
        qms_results["correct_tool_version"] = QMSResult(
            "correct_tool_version",
            "SKIP",
            "No logs found"
        )

    qms_results["SI"] = check_SI(logs_dir)
    qms_results["postroute_log_errors"] = check_postroute_log_errors(stage_dir)
    qms_results["postroute_db_exists"] = check_postroute_db_exists(stage_dir)

    # =========================================================================
    # POST-ROUTE METRICS
    # =========================================================================
    print("[QMS] Analyzing basic post-route metrics...")
    qms_results["postroute_total_drc_count"] = check_postroute_total_drc_count(reports_dir)
    qms_results["postroute_floating_nets"] = check_postroute_floating_nets(reports_dir)    
    qms_results["forbidden_layers"] = check_forbidden_layers(reports_dir)
    qms_results["max_net_length"] = check_max_net_length(reports_dir)
    qms_results["filler_gap"] = check_filler_gaps(reports_dir)
        
    # =========================================================================
    # POST-ROUTE DRV & CLOCK SHIELDING METRICS
    # =========================================================================
    print("[QMS] Analyzing Post-Route DRV metrics and Clock Shielding...")
    drv_results = check_route_drv_metrics(reports_dir)
    for result in drv_results:
        qms_results[result.check_name] = result

   
    # =========================================================================
    # TIMING VIOLATIONS (SETUP & HOLD)
    # =========================================================================
    print("[QMS] Analyzing Post-Route Timing violations...")
    # Setup Checks
    qms_results["postroute_in2out_setup_violations"] = check_postroute_in2out_setup_violations(reports_dir)
    qms_results["postroute_in2reg_setup_violations"] = check_postroute_in2reg_setup_violations(reports_dir)
    qms_results["postroute_reg2cgate_setup_violations"] = check_postroute_reg2cgate_setup_violations(reports_dir)
    qms_results["postroute_reg2out_setup_violations"] = check_postroute_reg2out_setup_violations(reports_dir)
    qms_results["postroute_reg2reg_setup_violations"] = check_postroute_reg2reg_setup_violations(reports_dir)
    
    # Hold Checks
    qms_results["postroute_in2out_hold_violations"] = check_postroute_in2out_hold_violations(reports_dir)
    qms_results["postroute_in2reg_hold_violations"] = check_postroute_in2reg_hold_violations(reports_dir)
    qms_results["postroute_reg2out_hold_violations"] = check_postroute_reg2out_hold_violations(reports_dir)
    qms_results["postroute_reg2reg_hold_violations"] = check_postroute_reg2reg_hold_violations(reports_dir)

    # =========================================================================
    # Phase-dependent blocking classification
    # =========================================================================
    _POSTROUTE_BLOCKING_PHASES = {
        # Always blocking — missing DB or DRC blocks chip_finish
        "postroute_log_errors":                   ["bronze", "silver", "gold"],
        "postroute_db_exists":                    ["bronze", "silver", "gold"],
        "postroute_total_drc_count":              ["bronze", "silver", "gold"],
        # Silver+ blocking — floating nets and DRV
        "postroute_floating_nets":                ["silver", "gold"],
        "no_max_tran_violations":                 ["silver", "gold"],
        "no_max_cap_violations":                  ["silver", "gold"],
        # Gold-only blocking — timing closure
        "postroute_reg2reg_setup_violations":     ["gold"],
        "postroute_in2reg_setup_violations":      ["gold"],
        "postroute_reg2cgate_setup_violations":   ["gold"],
        "postroute_reg2out_setup_violations":     ["gold"],
        "postroute_in2out_setup_violations":      ["gold"],
        "postroute_reg2reg_hold_violations":      ["gold"],
        "postroute_in2reg_hold_violations":       ["gold"],
        "postroute_reg2out_hold_violations":      ["gold"],
        "postroute_in2out_hold_violations":       ["gold"],
        # Advisory only
        "forbidden_layers":                       [],
        "max_net_length":                         [],
        "filler_gap":                             [],
        "SI":                                     [],
        "correct_tool_version":                   [],
    }
    for check_name, result in qms_results.items():
        result.blocking_phases = _POSTROUTE_BLOCKING_PHASES.get(
            check_name, ["bronze", "silver", "gold"]
        )

    # =========================================================================
    # GENERATE SUMMARY
    # =========================================================================
    summary = generate_qms_summary(qms_results)
    
    final_result = {
        'stage': 'postroute',
        'block_name': block_name,
        'rtl_tag': rtl_tag,
        'project': project,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'stage_directory': str(stage_dir),
        'summary': summary,
        'checks': {
            POSTROUTE_CHECK_ID_MAP.get(k, k): v.to_dict() for k, v in qms_results.items()
        }
    }    
        
    # Print summary
    print(f"\n{'='*60}")
    print(f"Post-Route QMS Summary:")
    print(f"{'='*60}")
    print(f"Overall Status: {summary['overall_status']}")
    print(f"Pass Rate: {summary['pass_rate']}%")
    print(f"Passed: {summary['passed_checks']}/{summary['total_checks']}")
    print(f"Failed: {summary['failed_checks']}")
    print(f"Skipped: {summary['skipped_checks']}")
    print(f"{'='*60}\n")
    
    return final_result

if __name__ == '__main__':
    import argparse
    import json
    
    parser = argparse.ArgumentParser(description='Run post-route QMS checks')
    parser.add_argument('--stage-dir', required=True, help='Post-route stage directory path')
    parser.add_argument('--block-name', required=True, help='Block name')
    parser.add_argument('--rtl-tag', default='v1', help='RTL tag')
    parser.add_argument('--project', default='project1', help='Project name')
    parser.add_argument('--output', help='Output JSON file path')
    
    args = parser.parse_args()
    
    results = run_postroute_qms_checks(Path(args.stage_dir), args.block_name, args.rtl_tag, args.project)
    
    output_file = args.output or f"{args.block_name}_postroute_qms.json"
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"Post-Route QMS results saved to: {output_file}")
    if results['summary']['overall_status'] == 'FAIL':
        exit(1)
    else:
        exit(0)
