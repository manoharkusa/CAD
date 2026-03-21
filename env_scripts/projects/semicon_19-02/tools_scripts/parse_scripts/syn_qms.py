#!/usr/bin/env python3
"""
Synthesis Stage QMS Checks
Stage-specific quality checks for synthesis using reusable functions from qms_utils
"""

from pathlib import Path
from datetime import datetime
from typing import Dict, Any
from qms_utils import *


def run_synthesis_qms_checks(stage_dir: Path, block_name: str, rtl_tag: str, project: str) -> Dict[str, Any]:
    """
    Run synthesis-specific QMS checks
    
    Args:
        stage_dir: Path to synthesis stage directory
        block_name: Design block name
        rtl_tag: RTL version tag
        project: Project name
        
    Returns:
        Dictionary containing all QMS check results and summary
    """
    
    print(f"[QMS] Running synthesis quality checks for {block_name}...")
    
    # Initialize QMS results dictionary - all checks start as FAIL
    qms_results = {}
    
    # Define directories
    logs_dir = stage_dir / "logs"
    reports_dir = stage_dir / "reports"
    
    # =========================================================================
    # TOOL LOGS & WARNINGS CHECKS
    # =========================================================================
    
    print("[QMS] Analyzing tool logs...")
    all_logs = read_all_logs(logs_dir)
    
    if all_logs:
        # Tool version check
        qms_results["correct_tool_version"] = check_tool_version(all_logs, "syn")
        
        # RTL-related checks
        qms_results["no_rtl_errors"] = check_rtl_errors(all_logs)
        qms_results["no_rtl_warnings"] = check_rtl_warnings(all_logs)
        
        # Linking checks
        qms_results["no_unresolved_refs"] = check_unresolved_references(all_logs)
        qms_results["no_pin_mismatches"] = check_pin_mismatches(all_logs)
        
        # Constraint checks
        qms_results["no_constraint_errors"] = check_constraint_errors(all_logs)
        qms_results["no_constraint_warnings"] = check_constraint_warnings(all_logs)
        
        # Synthesis process checks
        qms_results["no_synthesis_errors"] = check_synthesis_errors(all_logs)
        qms_results["no_synthesis_warnings"] = check_synthesis_warnings(all_logs)
    else:
        # No logs found - mark all log checks as SKIP
        log_check_names = [
            "correct_tool_version", "no_rtl_errors", "no_rtl_warnings", 
            "no_unresolved_refs", "no_pin_mismatches", "no_constraint_errors",
            "no_constraint_warnings", "no_synthesis_errors", "no_synthesis_warnings"
        ]
        for check_name in log_check_names:
            qms_results[check_name] = QMSResult(check_name, "SKIP", "No log files found")
    
    # =========================================================================
    # CAD SCRIPTS AND INPUTS CHECKS
    # =========================================================================
    
    print("[QMS] Checking CAD scripts and inputs...")
    cad_results = check_cad_version_rtl_tag(project, rtl_tag)
    for result in cad_results:
        qms_results[result.check_name] = result
    
    # =========================================================================
    # CHECK DESIGN REPORT ANALYSIS
    # =========================================================================
    
    print("[QMS] Analyzing design reports...")
    design_results = check_design_report_issues(reports_dir)
    for result in design_results:
        qms_results[result.check_name] = result
    
    # =========================================================================
    # CHECK TIMING CONSTRAINTS (Renamed to SYN-CT-XXX)
    # =========================================================================
    
    print("[QMS] Checking timing constraints...")
    timing_results = check_timing_constraints(reports_dir)
    
    # Mapping table from your requirements image
    timing_id_map = {
        "seq_clock_pins_ok":               "SYN-CT-001",
        "endpoints_constrained":           "SYN-CT-002",
        "inputs_delay_constrained":        "SYN-CT-003",
        "outputs_delay_constrained":       "SYN-CT-004",
        "conflicting_case_constants":      "SYN-CT-005",
        "master_clock_reachable":          "SYN-CT-006",
        "seq_clock_multi_clock_waveforms": "SYN-CT-007",
        "seq_data_pin_driven_by_clock":    "SYN-CT-008",
        "no_combinational_loops":          "SYN-CT-009"
    }

    for result in timing_results:
        # If the check name is in our map, use the new ID (e.g., SYN-CT-001)
        if result.check_name in timing_id_map:
            new_id = timing_id_map[result.check_name]
            qms_results[new_id] = result
        else:
            # Fallback for any checks not in the map
            qms_results[result.check_name] = result   
    # =========================================================================
    # QOR AND TIMING ANALYSIS
    # =========================================================================
    
    print("[QMS] Analyzing QoR metrics...")
    qor_results = check_qor_metrics(reports_dir, "28nm")  # Technology node
    for result in qor_results:
        qms_results[result.check_name] = result
    
    # =========================================================================
    # SYNTHESIS-SPECIFIC CHECKS
    # =========================================================================
    
    print("[QMS] Running synthesis-specific checks...")
    
    # Check for synthesis elaboration issues
    qms_results["proper_elaboration"] = check_synthesis_elaboration(reports_dir)
    
    # Check for synthesis mapping completeness
    qms_results["synthesis_mapping_ok"] = check_synthesis_mapping(reports_dir)
    
    # Check for proper optimization
    qms_results["synthesis_optimization_ok"] = check_synthesis_optimization(reports_dir)
    
    # Check for proper clock gating insertion (if enabled)
    qms_results["clock_gating_insertion"] = check_clock_gating_insertion(reports_dir)
    
    # =========================================================================
    # SYNTHESIS OUTPUT VALIDATION
    # =========================================================================
    
    print("[QMS] Validating synthesis outputs...")
    
    # Check netlist generation
    qms_results["SYN-SC-015"] = check_netlist_generation(stage_dir, block_name)
    qms_results["SYN-SC-016"] = check_sdc_generation(stage_dir, block_name)
    
    # Check report generation completeness
    qms_results["reports_complete"] = check_synthesis_reports(reports_dir)
    
    # =========================================================================
    # SPECIAL REQUIREMENTS (subset for synthesis)
    # =========================================================================
    
    print("[QMS] Checking special requirements...")
    special_results = check_special_requirements()
    
    # Filter for synthesis-relevant checks only
    synthesis_special_checks = [
        "clock_gating_coverage", "proper_icg_cells", "valid_parameters",
        "proper_uncertainty", "correct_derating", "optimal_drive_strength"
    ]
    
    for result in special_results:
        if result.check_name in synthesis_special_checks:
            qms_results[result.check_name] = result
    
    # =========================================================================
    # GENERATE SUMMARY
    # =========================================================================
    
    summary = generate_qms_summary(qms_results)
    
    # Create final result structure
    from qms_utils import QOR_CHECK_ID_MAP, CHECK_DESIGN_ID_MAP

    combined_id_map = {}
    combined_id_map.update(QOR_CHECK_ID_MAP)
    combined_id_map.update(CHECK_DESIGN_ID_MAP)

    final_result = {
        'stage': 'syn',
        'block_name': block_name,
        'rtl_tag': rtl_tag,
        'project': project,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'stage_directory': str(stage_dir),
        'summary': summary,
        'checks': {
            combined_id_map.get(k, k): v.to_dict()
            for k, v in qms_results.items()
        }
    }  
    # Print summary
    print(f"\n{'='*60}")
    print(f"Synthesis QMS Summary:")
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
# SYNTHESIS-SPECIFIC HELPER FUNCTIONS
# ==============================================================================

def check_synthesis_elaboration(reports_dir: Path) -> QMSResult:
    """Check if synthesis elaboration completed successfully"""
    
    # Check check_design.rpt for elaboration issues
    content = read_report_file(reports_dir, "check_design.rpt")
    if not content:
        return QMSResult("proper_elaboration", "SKIP", "check_design.rpt not found")
    
    # Look for elaboration errors
    elab_errors = re.findall(r'Error.*elaboration', content, re.IGNORECASE)
    if elab_errors:
        return QMSResult("proper_elaboration", "FAIL",
                       f"Found {len(elab_errors)} elaboration errors",
                       details="\n".join(elab_errors[:3]))
    
    # Look for successful elaboration indicators
    success_patterns = [
        r'Elaboration.*completed',
        r'Design.*elaborated.*successfully',
        r'Elaboration.*successful'
    ]
    
    for pattern in success_patterns:
        if re.search(pattern, content, re.IGNORECASE):
            return QMSResult("proper_elaboration", "PASS", "Elaboration completed successfully")
    
    return QMSResult("proper_elaboration", "WARN", "Elaboration status unclear")


def check_synthesis_mapping(reports_dir: Path) -> QMSResult:
    """Check if synthesis mapping completed successfully"""
    
    # Check report_qor.rpt for mapping information
    content = read_report_file(reports_dir, "report_qor.rpt")
    if not content:
        return QMSResult("synthesis_mapping_ok", "SKIP", "report_qor.rpt not found")
    
    # Look for mapping errors
    mapping_errors = re.findall(r'Error.*mapping', content, re.IGNORECASE)
    if mapping_errors:
        return QMSResult("synthesis_mapping_ok", "FAIL",
                       f"Found {len(mapping_errors)} mapping errors",
                       details="\n".join(mapping_errors[:3]))
    
    # Check if all cells are mapped (no UNMAP entries)
    unmap_cells = re.findall(r'UNMAP.*(\w+)', content, re.IGNORECASE)
    if unmap_cells:
        return QMSResult("synthesis_mapping_ok", "FAIL",
                       f"Found {len(unmap_cells)} unmapped cells",
                       details=", ".join(unmap_cells[:5]))
    
    # Look for successful mapping indicators
    if "Mapping completed" in content or "syn_map" in content:
        return QMSResult("synthesis_mapping_ok", "PASS", "Synthesis mapping completed successfully")
    
    return QMSResult("synthesis_mapping_ok", "WARN", "Mapping status unclear")


def check_synthesis_optimization(reports_dir: Path) -> QMSResult:
    """Check if synthesis optimization completed successfully"""
    
    # Check report_qor.rpt for optimization information
    content = read_report_file(reports_dir, "report_qor.rpt")
    if not content:
        return QMSResult("synthesis_optimization_ok", "SKIP", "report_qor.rpt not found")
    
    # Look for optimization errors
    opt_errors = re.findall(r'Error.*optimization', content, re.IGNORECASE)
    if opt_errors:
        return QMSResult("synthesis_optimization_ok", "FAIL",
                       f"Found {len(opt_errors)} optimization errors",
                       details="\n".join(opt_errors[:3]))
    
    # Check for optimization warnings that might indicate issues
    severe_warnings = re.findall(r'Warning.*optimization.*failed', content, re.IGNORECASE)
    if len(severe_warnings) > 10:  # Too many optimization failures
        return QMSResult("synthesis_optimization_ok", "WARN",
                       f"Found {len(severe_warnings)} optimization warnings",
                       details="\n".join(severe_warnings[:3]))
    
    # Look for successful optimization indicators
    if "syn_opt" in content or "Optimization completed" in content:
        return QMSResult("synthesis_optimization_ok", "PASS", "Synthesis optimization completed successfully")
    
    return QMSResult("synthesis_optimization_ok", "WARN", "Optimization status unclear")


def check_clock_gating_insertion(reports_dir: Path) -> QMSResult:
    """Check if clock gating was inserted properly (if enabled)"""
    
    # Check report_qor.rpt or specific clock gating report
    content = read_report_file(reports_dir, "report_qor.rpt")
    if not content:
        return QMSResult("clock_gating_insertion", "SKIP", "report_qor.rpt not found")
    
    # Look for clock gating information
    cg_pattern = r'Clock.*gating.*(\d+)'
    cg_matches = re.findall(cg_pattern, content, re.IGNORECASE)
    
    if cg_matches:
        cg_count = sum(int(match) for match in cg_matches)
        if cg_count > 0:
            return QMSResult("clock_gating_insertion", "PASS",
                           f"Clock gating inserted: {cg_count} instances",
                           value=cg_count)
        else:
            return QMSResult("clock_gating_insertion", "WARN",
                           "Clock gating enabled but no instances inserted")
    
    # Check if clock gating was disabled
    if "lp_insert_clock_gating false" in content:
        return QMSResult("clock_gating_insertion", "SKIP", "Clock gating disabled")
    
    return QMSResult("clock_gating_insertion", "WARN", "Clock gating status unclear")


def check_netlist_generation(stage_dir: Path, block_name: str) -> QMSResult:
    """Check if synthesis netlist was generated properly"""
    
    outputs_dir = stage_dir / "outputs"
    expected_netlist = outputs_dir / f"{block_name}.v"
    
    if not outputs_dir.exists():
        return QMSResult("netlist_generated", "FAIL", f"Outputs directory not found: {outputs_dir}", report_path=str(expected_netlist))   
    if not expected_netlist.exists():
        return QMSResult("netlist_generated", "FAIL", 
                       f"Expected netlist {expected_netlist.name} not found", report_path=str(expected_netlist))
    
    # Check netlist size (should not be empty)
    try:
        netlist_size = expected_netlist.stat().st_size
        if netlist_size == 0:
            return QMSResult("netlist_generated", "FAIL", "Generated netlist is empty", report_path=str(expected_netlist))
        else:
            return QMSResult("netlist_generated", "PASS",
                           f"Netlist generated successfully ({netlist_size} bytes)",
                           value=netlist_size, report_path=str(expected_netlist))
    except Exception as e:
        return QMSResult("netlist_generated", "FAIL", f"Error checking netlist: {e}")


def check_sdc_generation(stage_dir: Path, block_name: str) -> QMSResult:
    """Check if synthesis sdc was generated properly"""
    
    outputs_dir = stage_dir / "outputs"
    expected_sdc = outputs_dir / f"{block_name}.sdc"
    
    if not outputs_dir.exists():
        return QMSResult("sdc_generated", "FAIL", f"Outputs directory not found: {outputs_dir}", report_path=str(expected_sdc))    
    if not expected_sdc.exists():
        return QMSResult("sdc_generated", "FAIL", 
                       f"Expected sdc {expected_sdc.name} not found", report_path=str(expected_sdc))
    
    # Check sdc size (should not be empty)
    try:
        sdc_size = expected_sdc.stat().st_size
        if sdc_size == 0:
            return QMSResult("sdc_generated", "FAIL", "Generated sdc is empty", report_path=str(expected_sdc))  
        else:
            return QMSResult("sdc_generated", "PASS",
                           f"Sdc generated successfully ({sdc_size} bytes)",
                           value=sdc_size, report_path=str(expected_sdc))
    except Exception as e:
        return QMSResult("sdc_generated", "FAIL", f"Error checking sdc: {e}")


def check_synthesis_reports(reports_dir: Path) -> QMSResult:
    """Check if all expected synthesis reports were generated"""
    
    expected_reports = [
        "report_qor.rpt",
        "report_area.rpt", 
        "timing_summary.rpt",
        "check_design.rpt",
        "check_timing.rpt"
    ]
    
    missing_reports = []
    for report in expected_reports:
        if not (reports_dir / report).exists():
            missing_reports.append(report)
    
    if missing_reports:
        return QMSResult("reports_complete", "WARN",
                       f"Missing {len(missing_reports)} expected reports",
                       details=", ".join(missing_reports), value=missing_reports)
    else:
        return QMSResult("reports_complete", "PASS", "All expected reports generated")


# ==============================================================================
# MAIN FUNCTION FOR STANDALONE EXECUTION
# ==============================================================================

def main():
    """Main function for standalone execution"""
    import argparse
    import json
    
    parser = argparse.ArgumentParser(description='Run synthesis QMS checks')
    parser.add_argument('--stage-dir', required=True, help='Synthesis stage directory path')
    parser.add_argument('--block-name', required=True, help='Block name')
    parser.add_argument('--rtl-tag', default='v1', help='RTL tag')
    parser.add_argument('--project', default='project1', help='Project name')
    parser.add_argument('--output', help='Output JSON file path')
    
    args = parser.parse_args()
    
    # Run synthesis QMS checks
    results = run_synthesis_qms_checks(
        Path(args.stage_dir), args.block_name, args.rtl_tag, args.project
    )
    
    # Save results
    output_file = args.output or f"{args.block_name}_syn_qms.json"
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"Synthesis QMS results saved to: {output_file}")
    
    # Exit with error code if checks failed
    if results['summary']['overall_status'] == 'FAIL':
        exit(1)
    else:
        exit(0)


if __name__ == '__main__':
    main()
