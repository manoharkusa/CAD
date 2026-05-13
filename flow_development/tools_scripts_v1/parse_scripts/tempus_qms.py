#!/usr/bin/env python3
"""
Tempus Stage QMS Checks
Stage-specific quality checks for the Tempus STA stage.
Imports reusable functions from qms_utils and qms_utils.
"""

from pathlib import Path
from datetime import datetime
from typing import Dict, Any

from qms_utils import (
    QMSResult,
    read_all_logs,
    generate_qms_summary,
)
from qms_utils import (
    TEMPUS_CHECK_ID_MAP,
    check_sdc_read_stats,
    check_tempus_verilog_log_stats,
    check_tempus_spef_log_stats,
    check_tempus_max_fanout_violations,
    check_tempus_max_tran_violations,
    check_tempus_max_cap_violations,
    check_tempus_annotation_report,
    check_tempus_netlist_report,
    check_tempus_library_consistency,
    check_tempus_design_categories,
    check_tempus_report_constraint_clock,
    check_tempus_timing_report,
)


# ==============================================================================
# MAIN RUNNER
# ==============================================================================

def run_tempus_qms_checks(
    stage_dir: Path,
    block_name: str,
    rtl_tag: str,
    project: str,
) -> Dict[str, Any]:
    """
    Run all Tempus QMS checks and return a unified results dictionary.

    Expected directory layout
    -------------------------
    <stage_dir>/
        logs/
            tempus.log            ? main Tempus log (all sections)
        reports/
            report_constraints.rpt   (report_constraint output)
            check.annotation.rpt     (report_annotated_parasitics)
            check.netlist.rpt        (check_netlist output)
            check_design.rpt         (check_design -type all output)
            check.timing.rpt         (check_timing output)
        outputs/
            <design>_session_timing.db
    """
    print(f"[QMS] Running Tempus quality checks for {block_name}...")

    qms_results: Dict[str, QMSResult] = {}
    logs_dir    = stage_dir / "logs"
    reports_dir = stage_dir / "reports"

    # =========================================================================
    # READ ALL LOGS
    # =========================================================================
    print("[QMS] Reading Tempus log files...")
    all_logs = read_all_logs(logs_dir)

    # Also pick up any tempus.log sitting directly inside reports/
    for extra in [reports_dir / "tempus.log", stage_dir / "tempus.log"]:
        if extra.exists():
            try:
                all_logs += extra.read_text(errors="ignore") + "\n"
            except Exception as e:
                print(f"[WARN] Could not read {extra}: {e}")

    # =========================================================================
    # SDC LOG CHECKS  (TEM-SDC-001 / TEM-SDC-002)
    # =========================================================================
    print("[QMS] Analyzing SDC read stats from logs...")
    if all_logs:
        for result in check_sdc_read_stats(all_logs, logs_dir):
            qms_results[result.check_name] = result
    else:
        for name in ("sdc_no_errors", "sdc_no_warnings"):
            qms_results[name] = QMSResult(name, "SKIP", "No log files found")

    # =========================================================================
    # VERILOG LOG CHECKS  (TEM-VLG-001 / TEM-VLG-002)
    # =========================================================================
    print("[QMS] Analyzing Verilog netlist read stats from logs...")
    if all_logs:
        for result in check_tempus_verilog_log_stats(all_logs, logs_dir):
            qms_results[result.check_name] = result
    else:
        for name in ("verilog_no_errors", "verilog_no_warnings"):
            qms_results[name] = QMSResult(name, "SKIP", "No log files found")

    # =========================================================================
    # SPEF / PARASITICS LOG CHECKS  (TEM-PAR-001/002, TEM-SPF-001/002)
    # =========================================================================
    print("[QMS] Analyzing SPEF read stats from logs...")
    if all_logs:
        for result in check_tempus_spef_log_stats(all_logs, logs_dir):
            qms_results[result.check_name] = result
    else:
        for name in ("spef_read_no_errors", "spef_read_no_warnings"):
            qms_results[name] = QMSResult(name, "SKIP", "No log files found")

    # =========================================================================
    # DRV REPORT  (TEM-DRV-001 / 002 / 003)
    # Source: reports/report_constraints.rpt
    # =========================================================================
    print("[QMS] Analyzing DRV report (report_constraints.rpt)...")
    #for result in check_tempus_drv_report(reports_dir):
     #   qms_results[result.check_name] = result
   



 

    qms_results["tempus_max_fanout_violations"] =check_tempus_max_fanout_violations (reports_dir)
    qms_results["tempus_max_cap_violations"] =check_tempus_max_cap_violations (reports_dir)
    qms_results["tempus_max_tran_violations"] =check_tempus_max_tran_violations (reports_dir)

    # =========================================================================
    # ANNOTATION CHECK  (TEM-PAR-003)
    # Source: reports/check.annotation.rpt
    # =========================================================================
    print("[QMS] Analyzing annotation check report...")
    result = check_tempus_annotation_report(reports_dir)
    qms_results[result.check_name] = result

    # =========================================================================
    # CHECK NETLIST  (TEM-NET-001  TEM-NET-006)
    # Source: reports/check.netlist.rpt
    # =========================================================================
    print("[QMS] Analyzing check_netlist report...")
    for result in check_tempus_netlist_report(reports_dir):
        qms_results[result.check_name] = result

    # =========================================================================
    # TIMING LIBRARY CONSISTENCY  (TEM-LIB-001)
    # Source: tempus.log  (inline output  no separate report file)
    # =========================================================================
    print("[QMS] Analyzing timing library consistency from logs...")
    result = check_tempus_library_consistency(reports_dir)
    qms_results[result.check_name] = result

    # =========================================================================
    # CHECK DESIGN CATEGORIES  (TEM-CD-NET-001  TEM-CD-NET-005)
    # Source: reports/check_design.rpt
    # =========================================================================
    print("[QMS] Analyzing check_design categories...")
    for result in check_tempus_design_categories(reports_dir):
        qms_results[result.check_name] = result

    # =========================================================================
    # REPORT CONSTRAINT  CLOCK  (TEM-RC-CLK-001 / 002 / 003)
    # Source: reports/report_constraints.rpt
    # =========================================================================
    print("[QMS] Analyzing report_constraint clock checks...")
    for result in check_tempus_report_constraint_clock(reports_dir):
        qms_results[result.check_name] = result

    # =========================================================================
    # CHECK TIMING  (TEM-CT-001  TEM-CT-004)
    # Source: reports/check.timing.rpt
    # =========================================================================
    print("[QMS] Analyzing check_timing report...")
    for result in check_tempus_timing_report(reports_dir):
        qms_results[result.check_name] = result

    # =========================================================================
    # Phase-dependent blocking classification
    # =========================================================================
    _TEMPUS_BLOCKING_PHASES = {
        # Always blocking — SDC/netlist/SPEF read errors make timing meaningless
        "sdc_no_errors":               ["bronze", "silver", "gold"],
        "verilog_no_errors":           ["bronze", "silver", "gold"],
        "spef_read_no_errors":         ["bronze", "silver", "gold"],
        "timing_library_consistency":  ["bronze", "silver", "gold"],
        # Silver+ blocking — library and annotation issues affect accuracy
        "annotation_check_clean":      ["silver", "gold"],
        "tempus_max_tran_violations":  ["silver", "gold"],
        "tempus_max_cap_violations":   ["silver", "gold"],
        "tempus_max_fanout_violations":["silver", "gold"],
        # Gold-only blocking — full timing sign-off
        "no_setup_violations":         ["gold"],
        "no_hold_violations":          ["gold"],
        "no_unconstrained_endpoints":  ["gold"],
        # Advisory only
        "sdc_no_warnings":             [],
        "verilog_no_warnings":         [],
        "spef_read_no_warnings":       [],
        "no_tri_state_drivers":        [],
    }
    for check_name, result in qms_results.items():
        result.blocking_phases = _TEMPUS_BLOCKING_PHASES.get(
            check_name, ["bronze", "silver", "gold"]
        )

    # =========================================================================
    # GENERATE SUMMARY
    # =========================================================================
    summary = generate_qms_summary(qms_results)

    final_result = {
        "stage":           "tempus",
        "block_name":      block_name,
        "rtl_tag":         rtl_tag,
        "project":         project,
        "timestamp":       datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "stage_directory": str(stage_dir),
        "summary":         summary,
        "checks": {
            TEMPUS_CHECK_ID_MAP.get(k, k): v.to_dict()
            for k, v in qms_results.items()
        },
    }

    _print_summary(summary)
    return final_result


# ==============================================================================
# PRETTY PRINTER
# ==============================================================================

def _print_summary(summary: Dict[str, Any]) -> None:
    print(f"\n{'=' * 60}")
    print("Tempus QMS Summary:")
    print(f"{'=' * 60}")
    print(f"Overall Status : {summary['overall_status']}")
    print(f"Pass Rate      : {summary['pass_rate']}%")
    print(f"Passed         : {summary['passed_checks']}/{summary['total_checks']}")
    print(f"Failed         : {summary['failed_checks']}")
    print(f"Warnings       : {summary['warned_checks']}")
    print(f"Skipped        : {summary['skipped_checks']}")
    if summary.get("critical_failures"):
        print("\nCritical Failures:")
        for f in summary["critical_failures"]:
            print(f"  - {f}")
    if summary.get("recommendations"):
        print("\nRecommendations:")
        for r in summary["recommendations"]:
            print(f"  - {r}")
    print(f"{'=' * 60}\n")


# ==============================================================================
# CLI ENTRY POINT
# ==============================================================================

def main() -> None:
    import argparse, json

    parser = argparse.ArgumentParser(description="Run Tempus STA QMS checks")
    parser.add_argument("--stage-dir",  required=True, help="Tempus stage directory")
    parser.add_argument("--block-name", required=True, help="Design / block name")
    parser.add_argument("--rtl-tag",    default="v1",       help="RTL tag (default: v1)")
    parser.add_argument("--project",    default="project1", help="Project name")
    parser.add_argument("--output",     help="Output JSON file (default: <block>_tempus_qms.json)")
    args = parser.parse_args()

    results = run_tempus_qms_checks(
        Path(args.stage_dir), args.block_name, args.rtl_tag, args.project)

    output_file = args.output or f"{args.block_name}_tempus_qms.json"
    with open(output_file, "w") as fh:
        json.dump(results, fh, indent=2)
    print(f"Tempus QMS results saved to: {output_file}")

    exit(1 if results["summary"]["overall_status"] == "FAIL" else 0)


if __name__ == "__main__":
    main()

