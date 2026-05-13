#!/usr/bin/env python3
"""
Route Stage QMS Checks
Stage-specific quality checks for routing using reusable functions from qms_utils
"""

from pathlib import Path
from datetime import datetime
from typing import Dict, Any
from qms_utils import *

def run_chip_finish_qms_checks(stage_dir: Path, block_name: str, rtl_tag: str, project: str) -> Dict[str, Any]:
    """
    Run route-specific QMS checks
    """
    print(f"[QMS] Running route quality checks for {block_name}...")
    
    qms_results = {}
    logs_dir = stage_dir / "logs"
    reports_dir = stage_dir / "reports"
    outputs_dir = stage_dir / "outputs"
    
    # =========================================================================
    # TOOL LOGS CHECKS
    # =========================================================================
    print("[QMS] Analyzing tool logs...")
    all_logs = read_all_logs(logs_dir)
    
  # Inside run_chip_finish_qms_checks function:
    qms_results["shorts_count"] = check_total_drc_violations(reports_dir) 
    qms_results["filler_gap"] = check_filler_gaps(reports_dir)
    qms_results["opens_count"] = check_connectivity(reports_dir)
    qms_results["floating_nets"] = check_floating_nets(reports_dir)
    
    # =========================================================================
    # COMPREHENSIVE DRV METRICS
    # =========================================================================
    qms_results["no_max_fanout_violations"] = check_chip_finish_max_fanout_violations(reports_dir)
    qms_results["no_max_tran_violations"] = check_chip_finish_max_tran_violations(reports_dir)
    qms_results["no_max_cap_violations"] = check_chip_finish_max_cap_violations(reports_dir)




    # GDS Generation Check
    qms_results["gds_generated"] = check_gds_generated(outputs_dir, block_name)
    qms_results["lef_generated"] = check_lef_generated(outputs_dir, block_name)
    qms_results["def_generated"] = check_def_generated(outputs_dir, block_name)
    qms_results["pg_verilog_generated"] = check_pg_verilog_generated(outputs_dir, block_name)
    qms_results["standard_verilog_generated"] = check_standard_verilog_generated(outputs_dir, block_name)

    qms_results["spef_cbest"] = check_spef_cbest_generated(outputs_dir, block_name)
    qms_results["spef_cworst"] = check_spef_cworst_generated(outputs_dir, block_name)
    qms_results["spef_rcworst"] = check_spef_rcworst_generated(outputs_dir, block_name)
    qms_results["spef_rcbest"] = check_spef_rcbest_generated(outputs_dir, block_name)
    
    qms_results["func_ffm40c_cb"] = check_sdc_ffm40c_cb_generated(outputs_dir, block_name)
    qms_results["func_ss125c_rcw"] = check_sdc_ss125c_rcw_generated(outputs_dir, block_name)
    qms_results["func_ssm40c_cw"] = check_sdc_ssm40c_cw_generated(outputs_dir, block_name)
    qms_results["func_ff125c_rcb"] = check_sdc_ff125c_rcb_generated(outputs_dir, block_name)

    # =========================================================================
    # Phase-dependent blocking classification
    # =========================================================================
    _CF_BLOCKING_PHASES = {
        # Always blocking — shorts/opens or missing GDS/SPEF block signoff
        "shorts_count":                      ["bronze", "silver", "gold"],
        "opens_count":                       ["bronze", "silver", "gold"],
        "gds_generated":                     ["bronze", "silver", "gold"],
        "spef_cbest":                        ["bronze", "silver", "gold"],
        "spef_rcbest":                       ["bronze", "silver", "gold"],
        "spef_cworst":                       ["bronze", "silver", "gold"],
        "spef_rcworst":                      ["bronze", "silver", "gold"],
        # Silver+ blocking — corner SDC files needed for STA
        "func_ffm40c_cb":                    ["silver", "gold"],
        "func_ss125c_rcw":                   ["silver", "gold"],
        "func_ssm40c_cw":                    ["silver", "gold"],
        "func_ff125c_rcb":                   ["silver", "gold"],
        # Gold-only blocking — DRV closure
        "no_max_tran_violations":            ["gold"],
        "no_max_cap_violations":             ["gold"],
        "no_max_fanout_violations":          ["gold"],
        # Advisory only
        "filler_gap":                        [],
        "floating_nets":                     [],
        "lef_generated":                     [],
        "def_generated":                     [],
        "pg_verilog_generated":              [],
        "standard_verilog_generated":        [],
    }
    for check_name, result in qms_results.items():
        result.blocking_phases = _CF_BLOCKING_PHASES.get(
            check_name, ["bronze", "silver", "gold"]
        )

    #====================================================================
    # GENERATE SUMMARY
    # =========================================================================
    summary = generate_qms_summary(qms_results)
    final_result = {
        'stage': 'route',
        'block_name': block_name,
        'rtl_tag': rtl_tag,
        'project': project,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'stage_directory': str(stage_dir),
        'summary': summary,
        'checks': {
                 CHIP_FINISH_ID_MAP.get(k, k): v.to_dict() for k, v in qms_results.items()  
        }
    }    
        
    # Print summary
    print(f"\n{'='*60}")
    print(f"Route QMS Summary:")
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
    
    parser = argparse.ArgumentParser(description='Run route QMS checks')
    parser.add_argument('--stage-dir', required=True, help='Route stage directory path')
    parser.add_argument('--block-name', required=True, help='Block name')
    parser.add_argument('--rtl-tag', default='v1', help='RTL tag')
    parser.add_argument('--project', default='project1', help='Project name')
    parser.add_argument('--output', help='Output JSON file path')
    
    args = parser.parse_args()
    
    results = run_chip_finish_qms_checks(Path(args.stage_dir), args.block_name, args.rtl_tag, args.project)
    
    output_file = args.output or f"{args.block_name}_route_qms.json"
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"Route QMS results saved to: {output_file}")
    if results['summary']['overall_status'] == 'FAIL':
        exit(1)
    else:
        exit(0)



