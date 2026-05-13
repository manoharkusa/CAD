#!/usr/bin/env python3
"""
Init Stage QMS Checks
Stage-specific quality checks for the PnR Init stage using reusable functions from qms_utils
"""

from pathlib import Path
from datetime import datetime
from typing import Dict, Any
from qms_utils import *

def run_init_qms_checks(stage_dir: Path, block_name: str, rtl_tag: str, project: str) -> Dict[str, Any]:
    """
    Run Init-specific QMS checks
    """
    print(f"[QMS] Running Init quality checks for {block_name}...")
    qms_results = {}
    logs_dir = stage_dir / "logs"
    reports_dir = stage_dir / "reports"
    
    # =========================================================================
    # INPUT VALIDATION
    # =========================================================================
    print("[QMS] Validating synthesis netlist...")
    qms_results["netlist_exists"] = check_init_netlist_exists(stage_dir, block_name)
    print("[QMS] Analyzing design database...")
    qms_results["init_db_created"] = check_init_db_exists(stage_dir)
    # NEW: ====================================================================
    # CHECK DESIGN NETLIST (Dont Use Cells)
    # =========================================================================
    print("[QMS] Analyzing design netlist for dont use cells...")
    qms_results["no_dont_use_cells"] = check_dont_use_cells(reports_dir)
    
    print("[QMS] Analyzing netlist drivers...")
    driver_results = check_netlist_drivers(reports_dir)
    for result in driver_results:
        qms_results[result.check_name] = result

    # ADD THIS NEW BLOCK: =====================================================
    print("[QMS] Analyzing netlist for floating nets, ports, and pins...")
    floating_results = check_netlist_floating_metrics(reports_dir)
    for result in floating_results:
        qms_results[result.check_name] = result
    # =========================================================================
    # =========================================================================
    # TOOL LOGS & SDC SYNTAX CHECKS
    # =========================================================================
    print("[QMS] Analyzing Init tool logs...")
    all_logs = read_all_logs(logs_dir)
    
    if all_logs:
        # Check SDC syntax and calculate warning count
        qms_results["sdc_syntax_valid"] = check_sdc_syntax_warnings(all_logs, logs_dir)
        
        # Check if all port definitions match SDC constraints
        qms_results["all_ports_match_sdc"] = check_sdc_port_matching(all_logs, logs_dir)
        
        # NEW: Check total errors and warnings in init log
        log_stats_results = check_init_log_errors_warnings(all_logs, logs_dir)
        for result in log_stats_results:
            qms_results[result.check_name] = result
            
    else:
        qms_results["sdc_syntax_valid"] = QMSResult("sdc_syntax_valid", "SKIP", "No log files found")
        qms_results["all_ports_match_sdc"] = QMSResult("all_ports_match_sdc", "SKIP", "No log files found")
        qms_results["init_errors"] = QMSResult("init_errors", "SKIP", "No log files found")
        qms_results["init_warnings"] = QMSResult("init_warnings", "SKIP", "No log files found")
    print("[QMS] Analyzing SDC read stats...")
    sdc_stats_results = check_sdc_read_stats(all_logs, logs_dir)
    for result in sdc_stats_results:
        qms_results[result.check_name] = result
    # =========================================================================
    # CHECK PROCESS NODE
    # =========================================================================
    print("[QMS] Analyzing process node...")
    qms_results["process_node_check"] = check_process_node(reports_dir)
    # =========================================================================
    # CHECK TIMING CONSTRAINTS (IO Delays)
    # =========================================================================
    print("[QMS] Analyzing timing constraints for IO delays...")
    io_results = check_io_delay_constraints(reports_dir)
    for result in io_results:
        qms_results[result.check_name] = result
    # NEW: ====================================================================
    # CHECK DESIGN NETLIST (Dont Use Cells)
    # =========================================================================
    print("[QMS] Analyzing design netlist for dont use cells...")
    qms_results["no_dont_use_cells"] = check_dont_use_cells(reports_dir)
    print("[QMS] Analyzing netlist drivers...")
    driver_results = check_netlist_drivers(reports_dir)
    for result in driver_results:
        qms_results[result.check_name] = result
    # =========================================================================
    # CHECK TIMING AND DRV METRICS
    # =========================================================================
    print("[QMS] Analyzing setup.analysis_summary.rpt...")
    setup_analysis_results = check_setup_analysis_summary(reports_dir)
    for result in setup_analysis_results:
        qms_results[result.check_name] = result  
    # =========================================================================
    # CHECK LEF FILES CONSISTENCY
    # =========================================================================
    print("[QMS] Analyzing LEF files consistency...")
    lef_results = check_lef_files(logs_dir, reports_dir)
    for result in lef_results:
        qms_results[result.check_name] = result
    # =========================================================================
    # CHECK TIMING LIBRARY CONSISTENCY
    # =========================================================================
    print("[QMS] Analyzing timing library consistency...")
    qms_results["timing_library_consistency"] = check_timing_library_consistency(reports_dir)
    # =========================================================================
    # Phase-dependent blocking classification
    # =========================================================================
    _INIT_BLOCKING_PHASES = {
        # Always blocking — missing netlist/DB means PnR cannot start
        "netlist_exists":              ["bronze", "silver", "gold"],
        "init_db_created":             ["bronze", "silver", "gold"],
        "sdc_read_errors":             ["bronze", "silver", "gold"],
        "init_errors":                 ["bronze", "silver", "gold"],
        "tech_lef_check":              ["bronze", "silver", "gold"],
        "std_lef_check":               ["bronze", "silver", "gold"],
        # Silver+ blocking — port/library issues matter at silver
        "all_ports_match_sdc":         ["silver", "gold"],
        "timing_library_consistency":  ["silver", "gold"],
        "sdc_syntax_valid":            ["silver", "gold"],
        # Gold-only blocking — timing and DRV
        "no_reg2reg_violations":       ["gold"],
        "no_in2reg_violations":        ["gold"],
        "no_reg2out_violations":       ["gold"],
        "no_max_tran_violations":      ["gold"],
        "no_max_cap_violations":       ["gold"],
        "input_delay_defined":         ["gold"],
        "output_delay_defined":        ["gold"],
        # Advisory only
        "sdc_read_warnings":           [],
        "init_warnings":               [],
        "high_fanout_nets":            [],
        "no_dont_use_cells":           [],
        "process_node_check":          [],
        "correct_tool_version":        [],
    }
    for check_name, result in qms_results.items():
        result.blocking_phases = _INIT_BLOCKING_PHASES.get(
            check_name, ["bronze", "silver", "gold"]
        )

    # =========================================================================
    # GENERATE SUMMARY
    # =========================================================================
    summary = generate_qms_summary(qms_results)
    final_result = {
        'stage': 'init',
        'block_name': block_name,
        'rtl_tag': rtl_tag,
        'project': project,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'stage_directory': str(stage_dir),
        'summary': summary,
        'checks': {
            INIT_CHECK_ID_MAP.get(k, k): v.to_dict() for k, v in qms_results.items()
        }
    }    
    # Print summary
    print(f"\n{'='*60}")
    print(f"Init QMS Summary:")
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
# INIT-SPECIFIC HELPER FUNCTIONS
# ==============================================================================
def check_init_db_exists(stage_dir: Path) -> QMSResult:
    """Check if the initial design database was created successfully in the outputs directory"""
    
    # Dynamically resolve the path: <stage_dir>/outputs/init_design.db
    db_path = stage_dir / "outputs" / "init_design.db"
    
    if db_path.exists():
        return QMSResult("init_db_created", "PASS", 
                         "Initial design database created successfully", 
                         value=True, 
                         expected=True, 
                         report_path=str(db_path.resolve()))
    else:
        return QMSResult("init_db_created", "FAIL", 
                         "Initial design database not found", 
                         value=False, 
                         expected=True, 
                         report_path=str(db_path.resolve()))
def check_sdc_port_matching(logs: str, logs_dir: Path) -> QMSResult:
    """Check if all port definitions match SDC constraints (TCLCMD-917)"""
    
    # Pattern to match: **ERROR: (TCLCMD-917): Cannot find 'ports' that match...
    pattern = r'\*\*ERROR:\s+\(TCLCMD-917\):\s+Cannot find \'ports\' that match[^\n]*'
    
    matches = re.findall(pattern, logs, re.IGNORECASE)
    count = len(matches)
    
    # Scan the individual log files to find exactly which one(s) triggered the error
    violating_files = []
    if count > 0 and logs_dir.exists():
        for log_file in logs_dir.glob("*.log*"):
            try:
                content = log_file.read_text(errors='ignore')
                if re.search(pattern, content, re.IGNORECASE):
                    violating_files.append(str(log_file.resolve()))
            except Exception:
                pass
                
    # If we found specific files, join them. Otherwise, default back to the directory.
    if violating_files:
        r_path = ", ".join(violating_files)
    else:
        r_path = str(logs_dir.resolve())
    
    if count > 0:
        return QMSResult("all_ports_match_sdc", "FAIL", 
                       f"Found {count} port matching errors (TCLCMD-917)",
                       details="", 
                       value=count,
                       expected=0,
                       report_path=r_path)
    else:
        return QMSResult("all_ports_match_sdc", "PASS",
                       "All port definitions match SDC constraints",
                       details="",
                       value=0,
                       expected=0,
                       report_path=r_path)
def check_init_netlist_exists(stage_dir: Path, block_name: str) -> QMSResult:
    """Check if the synthesis netlist exists in the syn/outputs directory"""
    
    # Navigate up from .../pnr/init to the base run directory, then into syn/outputs
    # stage_dir.parent is 'pnr', stage_dir.parent.parent is the run base (e.g., 'semiconos1')
    syn_outputs_dir = stage_dir.parent.parent / "syn" / "outputs"
    
    # Common netlist naming conventions (.v, .v.gz, .vg)
    possible_netlists = [
        syn_outputs_dir / f"{block_name}.v",
            ]
    
    # Check if the syn/outputs directory even exists
    if not syn_outputs_dir.exists():
        return QMSResult("netlist_exists", "FAIL", 
                         f"Synthesis outputs directory not found: {syn_outputs_dir}", 
                         expected="Netlist file", 
                         report_path=str(syn_outputs_dir))
        
    # Check if any of the possible netlist files exist inside it
    for netlist in possible_netlists:
        if netlist.exists():
            return QMSResult("netlist_exists", "PASS", 
                           f"Synthesis netlist found: {netlist.name}", 
                           value=True, 
                           expected=True, 
                           report_path=str(netlist.resolve()))
                           
    # If the directory exists but the file does not
    return QMSResult("netlist_exists", "FAIL", 
                   f"Expected synthesis netlist not found for {block_name}", 
                   value=False, 
                   expected=True, 
                   report_path=str(syn_outputs_dir.resolve()))
def main():
    """Main function for standalone execution"""
    import argparse
    import json
    
    parser = argparse.ArgumentParser(description='Run Init QMS checks')
    parser.add_argument('--stage-dir', required=True, help='Init stage directory path')
    parser.add_argument('--block-name', required=True, help='Block name')
    parser.add_argument('--rtl-tag', default='v1', help='RTL tag')
    parser.add_argument('--project', default='project1', help='Project name')
    parser.add_argument('--output', help='Output JSON file path')
    
    args = parser.parse_args()
    
    # Run Init QMS checks
    results = run_init_qms_checks(
        Path(args.stage_dir), args.block_name, args.rtl_tag, args.project
    )
    
    # Save results
    output_file = args.output or f"{args.block_name}_init_qms.json"
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"Init QMS results saved to: {output_file}")
    
    if results['summary']['overall_status'] == 'FAIL':
        exit(1)
    else:
        exit(0)

if __name__ == '__main__':
    main()
