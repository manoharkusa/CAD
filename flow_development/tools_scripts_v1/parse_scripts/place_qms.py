#!/usr/bin/env python3
"""
Placement Stage QMS Checks
Rows PNR-PL-001 ... PNR-PL-EXEC-003
"""

from pathlib import Path
from datetime import datetime
from typing import Dict, Any
from qms_utils import *
    


def run_place_qms_checks(stage_dir: Path, 
                             block_name: str, 
                             rtl_tag: str, 
                             project: str) -> Dict[str, Any]:
    print(f"[QMS] Running placement quality checks for {block_name}...")

    qms_results = {}
    logs_dir = stage_dir / "logs"
    reports_dir = stage_dir / "reports"
    outputs_dir = stage_dir / "outputs"

    log_path, log_content = get_latest_log_file(logs_dir)

    # ------------------------------------------------------------------
    # Placement Quality (PNR-PL-001, PNR-PL-002, PNR-PL-003)
    # ------------------------------------------------------------------
    qms_results["placement_violations"] = check_placement_zero_violations(reports_dir)
    qms_results["unplaced_cells"] = check_instances_within_core(reports_dir)  # same function? Could separate.
    qms_results["no_cell_overlaps"] = check_no_cell_overlap(reports_dir)  # overlap check

    # PNR-PL-004: Placement density acceptable
    qms_results["cell_density"] = check_placement_density(reports_dir)
    qms_results["core_utilization"] = check_core_utilization(reports_dir)
    # PNR-PL-005: Congestion map reviewed
    #qms_results["congestion_map"] = check_congestion_map(reports_dir)
    # ADD THIS INSTEAD: ================================================
    # PNR-PL-CG-002: Max hotspot congestion area
    qms_results["max_congestion_hotspot"] = check_max_congestion_hotspot(reports_dir)
    # ==================================================================
    # PNR-PL-006: Placement timing slack acceptable pre-CTS
    #qms_results["timing_wns_slack"] = check_placement_timing_slack(reports_dir)
# ADD THIS NEW CHECK: ==============================================
    # PNR-PL-CG-001: Global routing congestion
    qms_results["global_routing_congestion"] = check_global_routing_congestion(reports_dir)
    # PNR-TM-001 to PNR-TM-006: Individual Timing and DRV checks
    timing_results = check_placement_timing_summary(reports_dir)
    for result in timing_results:
        qms_results[result.check_name] = result
    # ==================================================================
    # ==================================================================
    # ------------------------------------------------------------------
    # Execution  Log File Check
    # ------------------------------------------------------------------
    if log_content:
        qms_results["no_log_errors"] = check_placement_log_errors(log_content)
        if qms_results["no_log_errors"]:
            qms_results["no_log_errors"].report_path = log_path

        qms_results["no_log_warnings"] = check_placement_log_warnings(log_content)
        if qms_results["no_log_warnings"]:
            qms_results["no_log_warnings"].report_path = log_path
   
        qms_results["placement_db"] = check_placement_db_saved(outputs_dir )
        

    
    # ------------------------------------------------------------------
    # Phase-dependent blocking classification
    # ------------------------------------------------------------------
    _PLACE_BLOCKING_PHASES = {
        # Always blocking — cells not placed/legal = CTS cannot start
        "placement_violations":      ["bronze", "silver", "gold"],
        "unplaced_cells":            ["bronze", "silver", "gold"],
        "no_cell_overlaps":          ["bronze", "silver", "gold"],
        "no_log_errors":             ["bronze", "silver", "gold"],
        "placement_db":              ["bronze", "silver", "gold"],
        # Silver+ blocking — congestion that will likely cause route failure
        "max_congestion_hotspot":    ["silver", "gold"],
        "global_routing_congestion": ["silver", "gold"],
        # Gold-only blocking — timing/quality targets
        "cell_density":              ["gold"],
        "core_utilization":          ["gold"],
        "no_reg2reg_violations":     ["gold"],
        "no_in2reg_violations":      ["gold"],
        "no_reg2out_violations":     ["gold"],
        "no_max_tran_violations":    ["gold"],
        "no_max_cap_violations":     ["gold"],
        # Advisory only — informational
        "no_log_warnings":           [],
    }
    for check_name, result in qms_results.items():
        result.blocking_phases = _PLACE_BLOCKING_PHASES.get(
            check_name, ["bronze", "silver", "gold"]
        )

    # ------------------------------------------------------------------
    # Summary
    # ------------------------------------------------------------------
    summary = generate_qms_summary(qms_results)

    from qms_utils import PLACEMENT_CHECK_ID_MAP

    #combined_id_map == {}
    #combined_id_map.update(PLACEMENT_CHECK_ID_MAP)

    final_result = {
        'stage': 'place',
        'block_name': block_name,
        'rtl_tag': rtl_tag,
        'project': project,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'stage_directory': str(stage_dir),
        'summary': summary,
        'checks': {
            PLACEMENT_CHECK_ID_MAP.get(k, k): v.to_dict()
            for k, v in qms_results.items()
            }
    }
    print(f"\n{'='*60}")
    print(f"Placement QMS Summary:")
    print(f"{'='*60}")
    print(f"Overall Status: {summary['overall_status']}")
    print(f"Pass Rate: {summary['pass_rate']}%")
    print(f"Passed: {summary['passed_checks']}/{summary['total_checks']}")
    print(f"Failed: {summary['failed_checks']}")
    print(f"Warnings: {summary['warned_checks']}")
    print(f"Skipped: {summary['skipped_checks']}")
    
    if summary['critical_failures']:
        print(f"\nCritical Failures:")
        for failure in summary['critical_failures']:
            print(f"  - {failure}")
    
    if summary['recommendations']:
        print(f"\nRecommendations:")
        for rec in summary['recommendations']:
            print(f"  - {rec}")
    
    print(f"{'='*60}\n")
    
    
    return final_result

# ==============================================================================
# MAIN FUNCTION FOR STANDALONE EXECUTION
# ==============================================================================

def main():
    import argparse 
    import json
    parser = argparse.ArgumentParser(description='Run Placement QMS checks')
    parser.add_argument('--stage-dir', required=True, help='Placement stage directory path')
    parser.add_argument('--block-name', required=True, help='block name')
    parser.add_argument('--rtl-tag', default='v1', help='RTL tag')
    parser.add_argument('--project', default='project1', help='project name')
    parser.add_argument('--output', help='Output JSON file path')

    args = parser.parse_args()

    results = run_placement_qms_checks(
            Path(args.stage_dir), args.block_name, args.rtl_tag, args.project
    )
    out_file = args.output or f"{args.block_name}_place_qms.json"
    with open(out_file, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"Placement QMS results saved to: {out_file}")

    if results['summary']['overall_status'] == 'FAIL': 
        exit(1)
    else:
        exit(0)


if __name__ == '__main__':
    main()







