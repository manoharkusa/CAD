#!/usr/bin/env python3
"""
QMS (Quality Management System) Collector - ASIC Design Flow
Single orchestrator for all design stages.

Architecture:
    collect_qms.py          - this file (orchestrator)
    qms_utils.py            - shared utility functions (all stages)
    syn_qms.py              - synthesis stage checks
    init_qms.py             - PnR init stage checks
    floorplan_qms.py        - floorplan stage checks
    place_qms.py            - placement stage checks
    cts_qms.py              - CTS stage checks
    postcts_qms.py          - post-CTS stage checks
    route_qms.py            - routing stage checks
    postroute_qms.py        - post-route stage checks
    chip_finish_qms.py      - chip finish stage checks
    tempus_qms.py           - Tempus STA signoff checks

Usage:
    python3 collect_qms.py --stage sta \\
        --stage-dir /path/to/sta \\
        --run-dir   /path/to/rundir \\
        --runtag    exp1 \\
        --block-name aes_cipher_top \\
        --project   ganga
"""

import argparse
import json
import os
import sys
import importlib
import traceback
from pathlib import Path
from datetime import datetime


# ==============================================================================
# STAGE - MODULE MAP
# Add new stages here - no other changes needed.
# ==============================================================================

STAGE_MODULE_MAP = {
    "syn":         ("syn_qms",         "run_synthesis_qms_checks"),
    "init":        ("init_qms",        "run_init_qms_checks"),
    "floorplan":   ("floorplan_qms",   "run_floorplan_qms_checks"),
    "place":       ("place_qms",       "run_place_qms_checks"),
    "cts":         ("cts_qms",         "run_cts_qms_checks"),
    "postcts":     ("postcts_qms",     "run_postcts_qms_checks"),
    "route":       ("route_qms",       "run_route_qms_checks"),
    "postroute":   ("postroute_qms",   "run_postroute_qms_checks"),
    "chip_finish": ("chip_finish_qms", "run_chip_finish_qms_checks"),
    "sta":      ("tempus_qms",      "run_tempus_qms_checks"),
}

ALL_STAGES = list(STAGE_MODULE_MAP.keys())


# ==============================================================================
# DYNAMIC IMPORT HELPER
# ==============================================================================

def _load_stage_function(stage: str):
    """
    Dynamically import the stage module and return its runner function.
    Raises ImportError with a clear message if the module is missing.
    """
    module_name, func_name = STAGE_MODULE_MAP[stage]
    try:
        module = importlib.import_module(module_name)
    except ImportError as e:
        raise ImportError(
            f"Cannot import '{module_name}' for stage '{stage}'. "
            f"Make sure {module_name}.py is in the same directory. Error: {e}"
        )
    if not hasattr(module, func_name):
        raise AttributeError(
            f"Module '{module_name}' has no function '{func_name}'. "
            f"Check that {module_name}.py is the correct version."
        )
    return getattr(module, func_name)


# ==============================================================================
# QMS COLLECTION
# ==============================================================================

def collect_qms_checks(stage: str, stage_dir: Path, block_name: str,
                       rtl_tag: str, project: str,
                       run_dir: Path, runtag: str) -> bool:
    """
    Run QMS checks for a single stage, save results, and update the
    consolidated summary file.

    Returns True on success, False on failure.
    """
    print(f"\n{'=' * 80}")
    print(f"QMS Quality Checks")
    print(f"  Block      : {block_name}")
    print(f"  Stage      : {stage}")
    print(f"  Runtag     : {runtag}")
    print(f"  Stage Dir  : {stage_dir}")
    print(f"  Run Dir    : {run_dir}")
    print(f"{'=' * 80}\n")

    try:
        # -- Load and run stage function --------------------------------------
        run_stage = _load_stage_function(stage)
        qms_results = run_stage(stage_dir, block_name, rtl_tag, project)

        # -- Save per-stage JSON ----------------------------------------------
        qms_json_file = run_dir / f"{project}_{block_name}_{runtag}_{stage}_qms.json"
        with open(qms_json_file, "w") as fh:
            json.dump(qms_results, fh, indent=2)
        print(f"[INFO] QMS results saved to: {qms_json_file}")

        # -- Update consolidated summary --------------------------------------
        _update_consolidated_qms(run_dir, runtag, stage, qms_results, project, block_name)

        # -- Print stage summary ----------------------------------------------
        _print_stage_summary(stage, qms_results["summary"])

        return True

    except Exception as e:
        print(f"[ERROR] QMS collection failed for stage '{stage}': {e}")
        traceback.print_exc()
        return False


# ==============================================================================
# CONSOLIDATED SUMMARY
# ==============================================================================

def _update_consolidated_qms(run_dir: Path, runtag: str,
                              stage: str, qms_results: dict,
                              project: str = "", block_name: str = "") -> None:
    """Merge this stage's results into the run-level consolidated JSON."""
    consolidated_file = run_dir / f"{project}_{block_name}_{runtag}_metrics.json"

    # Load existing data
    if consolidated_file.exists():
        try:
            with open(consolidated_file, "r") as fh:
                data = json.load(fh)
        except Exception:
            data = {}
    else:
        data = {
            "project":      qms_results.get("project",    "N/A"),
            "block_name":   qms_results.get("block_name", "N/A"),
            "runtag":       runtag,
            "last_updated": "",
            "stages":       {},
        }

    data["stages"][stage]  = qms_results
    data["last_updated"]   = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    data["overall_summary"] = _generate_overall_summary(data["stages"])

    with open(consolidated_file, "w") as fh:
        json.dump(data, fh, indent=2)

    print(f"[INFO] Consolidated QMS updated: {consolidated_file}")


def _generate_overall_summary(stages_data: dict) -> dict:
    """Roll up per-stage summaries into a single overall summary."""
    stats = {
        "total_stages":    len(stages_data),
        "stages_passed":   0,
        "stages_failed":   0,
        "stages_warned":   0,
        "total_checks":    0,
        "total_passed":    0,
        "total_failed":    0,
        "total_warned":    0,
        "overall_pass_rate": 0.0,
        "critical_issues": [],
        "stage_status":    {},
    }

    for stage_name, stage_data in stages_data.items():
        summary = stage_data.get("summary", {})
        status  = summary.get("overall_status", "UNKNOWN")

        stats["stage_status"][stage_name] = status
        if status == "PASS":
            stats["stages_passed"] += 1
        elif status == "FAIL":
            stats["stages_failed"] += 1
        elif status == "WARN":
            stats["stages_warned"] += 1

        stats["total_checks"] += summary.get("total_checks",   0)
        stats["total_passed"] += summary.get("passed_checks",  0)
        stats["total_failed"] += summary.get("failed_checks",  0)
        stats["total_warned"] += summary.get("warned_checks",  0)

        for failure in summary.get("critical_failures", []):
            stats["critical_issues"].append(f"{stage_name}: {failure}")

    if stats["total_checks"] > 0:
        stats["overall_pass_rate"] = round(
            stats["total_passed"] / stats["total_checks"] * 100, 1)

    if stats["stages_failed"] > 0:
        stats["overall_status"] = "FAIL"
    elif stats["stages_warned"] > stats["stages_passed"] // 2:
        stats["overall_status"] = "WARN"
    else:
        stats["overall_status"] = "PASS"

    return stats


# ==============================================================================
# PRETTY PRINT
# ==============================================================================

def _print_stage_summary(stage: str, summary: dict) -> None:
    print(f"\n{'=' * 60}")
    print(f"QMS Summary - {stage.upper()}")
    print(f"{'=' * 60}")
    print(f"  Overall Status  : {summary.get('overall_status', 'N/A')}")
    print(f"  Pass Rate       : {summary.get('pass_rate', 0)}%")
    print(f"  Passed          : {summary.get('passed_checks', 0)}/{summary.get('total_checks', 0)}")
    print(f"  Failed          : {summary.get('failed_checks', 0)}")
    print(f"  Warnings        : {summary.get('warned_checks', 0)}")
    print(f"  Skipped         : {summary.get('skipped_checks', 0)}")
    critical = summary.get("critical_failures", [])
    if critical:
        print(f"\n  Critical Failures:")
        for f in critical:
            print(f"    - {f}")
    recs = summary.get("recommendations", [])
    if recs:
        print(f"\n  Recommendations (top 3):")
        for r in recs[:3]:
            print(f"    - {r}")
    print(f"{'=' * 60}\n")


# ==============================================================================
# CLI
# ==============================================================================

def main() -> None:
    parser = argparse.ArgumentParser(
        description="QMS collector - run quality checks for any ASIC design stage",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
Supported stages: {', '.join(ALL_STAGES)}

Examples:
  # Synthesis
  python3 collect_qms.py --stage syn \\
      --stage-dir ./run1/syn --run-dir ./run1 \\
      --runtag run1 --block-name aes_cipher_top

  # PnR Init
  python3 collect_qms.py --stage init \\
      --stage-dir ./run1/pnr/init --run-dir ./run1 \\
      --runtag run1 --block-name aes_cipher_top

  # Tempus STA signoff
  python3 collect_qms.py --stage sta \\
      --stage-dir ./run1/sta --run-dir ./run1 \\
      --runtag run1 --block-name aes_cipher_top --project ganga
""")

    parser.add_argument("--stage",      required=True, choices=ALL_STAGES,
                        help="Design stage name")
    parser.add_argument("--stage-dir",  required=True,
                        help="Path to stage directory (must contain logs/ and reports/)")
    parser.add_argument("--run-dir",    required=True,
                        help="Path to run directory (output JSON files go here)")
    parser.add_argument("--runtag",
                        default=os.environ.get("EXP_NAME", "run1"),
                        help="Run tag / experiment name  (default: $EXP_NAME or 'run1')")
    parser.add_argument("--block-name",
                        default=os.environ.get("BLOCK_NAME", "design"),
                        help="Block / design name  (default: $BLOCK_NAME or 'design')")
    parser.add_argument("--project",
                        default=os.environ.get("PROJ_NAME", "project1"),
                        help="Project name  (default: $PROJ_NAME or 'project1')")
    parser.add_argument("--rtl-tag",
                        default=os.environ.get("RTL_TAG", "v1"),
                        help="RTL version tag  (default: $RTL_TAG or 'v1')")

    args = parser.parse_args()

    stage_dir = Path(args.stage_dir)
    run_dir   = Path(args.run_dir)

    if not stage_dir.exists():
        print(f"[ERROR] Stage directory does not exist: {stage_dir}")
        sys.exit(1)

    if not run_dir.exists():
        print(f"[ERROR] Run directory does not exist: {run_dir}")
        sys.exit(1)

    success = collect_qms_checks(
        args.stage, stage_dir, args.block_name,
        args.rtl_tag, args.project, run_dir, args.runtag)

    if not success:
        print(f"[ERROR] QMS collection failed for stage: {args.stage}")
        sys.exit(1)

    print(f"[SUCCESS] QMS collection completed for stage: {args.stage}")
    sys.exit(0)


if __name__ == "__main__":
    main()
