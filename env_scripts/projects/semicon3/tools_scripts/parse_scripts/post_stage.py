#!/usr/bin/env python3
"""
Unified Post-Processing Script for All Stages

This script is called by stage_executor after each stage completes.
It centralizes all post-processing logic (metrics, QMS, uploads).

Usage:
    python3 post_stage.py \
        --stage syn \
        --stage-dir /path/to/exp1/syn \
        --run-dir /path/to/exp1 \
        --project semiconos_2002 \
        --block-name aes_cipher_top \
        --rtl-tag bronze_v1 \
        --exp-name exp1 \
        --env-scripts /path/to/env_scripts \
        --status success

Installation:
    Copy this file to: {ENV_SCRIPTS}/parse_scripts/post_stage.py
"""

import argparse
import subprocess
import sys
from pathlib import Path


def run_command(cmd: list, description: str) -> bool:
    """Run a command and return success status"""
    print(f"[POST] {description}")
    print(f"       Command: {' '.join(cmd)}")

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=300,
        )

        if result.returncode == 0:
            print(f"       [OK] {description} completed")
            return True
        else:
            print(f"       [FAIL] {description} failed")
            print(f"       stderr: {result.stderr[:200]}")
            return False

    except subprocess.TimeoutExpired:
        print(f"       [FAIL] {description} timed out")
        return False
    except Exception as e:
        print(f"       [FAIL] {description} error: {e}")
        return False


def run_metrics(args) -> bool:
    """Run collect_metrics.py"""
    script = Path(args.env_scripts) / "parse_scripts" / "collect_metrics.py"

    if not script.exists():
        print(f"[WARN] Metrics script not found: {script}")
        return True  # Non-fatal

    dashboard_dir = Path(args.run_dir) / "dashboard"
    dashboard_dir.mkdir(parents=True, exist_ok=True)

    cmd = [
        "python3", str(script),
        "--stage", args.stage,
        "--stage-dir", args.stage_dir,
        "--run-dir", str(dashboard_dir),
    ]

    return run_command(cmd, f"Collecting metrics for {args.stage}")


def run_qms(args) -> bool:
    """Run collect_qms.py"""
    script = Path(args.env_scripts) / "parse_scripts" / "collect_qms.py"

    if not script.exists():
        print(f"[WARN] QMS script not found: {script}")
        return True  # Non-fatal

    dashboard_dir = Path(args.run_dir) / "dashboard"
    dashboard_dir.mkdir(parents=True, exist_ok=True)

    cmd = [
        "python3", str(script),
        "--stage", args.stage,
        "--stage-dir", args.stage_dir,
        "--run-dir", str(dashboard_dir),
        "--runtag", args.exp_name,
        "--block-name", args.block_name,
        "--project", args.project,
        "--rtl-tag", args.rtl_tag,
    ]

    return run_command(cmd, f"Collecting QMS for {args.stage}")


def upload_metrics(args) -> bool:
    """Upload metrics to dashboard API"""
    dashboard_dir = Path(args.run_dir) / "dashboard"
    metrics_file = dashboard_dir / f"{args.project}_{args.block_name}_{args.exp_name}_metrics.json"

    if not metrics_file.exists():
        print(f"[WARN] Metrics file not found: {metrics_file}")
        return True  # Non-fatal

    # Get API IP from environment or use default
    import os
    api_ip = os.environ.get("PROJ_CURL_API_IP", "localhost")

    cmd = [
        "curl", "-X", "POST",
        f"http://{api_ip}:3000/api/eda-files/external/upload",
        "-H", "X-API-Key: sitedafilesdata",
        "-F", f"file=@{metrics_file}",
    ]

    return run_command(cmd, f"Uploading metrics for {args.stage}")


def upload_qms(args) -> bool:
    """Upload QMS report to dashboard API"""
    dashboard_dir = Path(args.run_dir) / "dashboard"
    qms_file = dashboard_dir / f"{args.exp_name}_{args.stage}_qms.json"

    if not qms_file.exists():
        print(f"[WARN] QMS file not found: {qms_file}")
        return True  # Non-fatal

    # Get API IP from environment or use default
    import os
    api_ip = os.environ.get("PROJ_CURL_API_IP", "localhost")

    cmd = [
        "curl", "-X", "POST",
        f"http://{api_ip}:3000/api/qms/external-checklists/upload-report",
        "-H", "X-API-Key: sitedafilesdata",
        "-F", f"file=@{qms_file}",
    ]

    return run_command(cmd, f"Uploading QMS for {args.stage}")


# ============================================================
# Stage-Specific Handlers
# ============================================================

def post_syn(args) -> bool:
    """Post-processing for synthesis stage"""
    print(f"\n[POST] === Synthesis Post-Processing ===")

    success = True
    success = run_metrics(args) and success
    success = run_qms(args) and success

    if args.status == "success":
        success = upload_metrics(args) and success
        success = upload_qms(args) and success

    return success


def post_place(args) -> bool:
    """Post-processing for placement stage"""
    print(f"\n[POST] === Placement Post-Processing ===")

    success = True
    success = run_metrics(args) and success
    success = run_qms(args) and success

    if args.status == "success":
        success = upload_metrics(args) and success
        success = upload_qms(args) and success

    return success


def post_route(args) -> bool:
    """Post-processing for routing stage"""
    print(f"\n[POST] === Routing Post-Processing ===")

    success = True
    success = run_metrics(args) and success
    success = run_qms(args) and success

    if args.status == "success":
        success = upload_metrics(args) and success
        success = upload_qms(args) and success

    return success


def post_sta(args) -> bool:
    """Post-processing for STA stage"""
    print(f"\n[POST] === STA Post-Processing ===")

    success = True
    success = run_metrics(args) and success
    success = run_qms(args) and success

    if args.status == "success":
        success = upload_metrics(args) and success
        success = upload_qms(args) and success

    return success


def post_default(args) -> bool:
    """Default post-processing for stages without specific handler"""
    print(f"\n[POST] === Default Post-Processing for {args.stage} ===")

    success = True
    success = run_metrics(args) and success
    success = run_qms(args) and success

    if args.status == "success":
        success = upload_metrics(args) and success
        success = upload_qms(args) and success

    return success


# ============================================================
# Stage Handler Mapping
# ============================================================

STAGE_HANDLERS = {
    "syn": post_syn,
    "place": post_place,
    "route": post_route,
    "sta": post_sta,
    # Add more stage-specific handlers as needed
    # Stages not listed here will use post_default
}


def main():
    parser = argparse.ArgumentParser(
        description="Unified post-processing script for all stages"
    )
    parser.add_argument("--stage", required=True, help="Stage name (syn, place, etc.)")
    parser.add_argument("--stage-dir", required=True, help="Stage directory path")
    parser.add_argument("--run-dir", required=True, help="Run/experiment directory")
    parser.add_argument("--project", required=True, help="Project name")
    parser.add_argument("--block-name", required=True, help="Block name")
    parser.add_argument("--rtl-tag", required=True, help="RTL tag")
    parser.add_argument("--exp-name", required=True, help="Experiment name")
    parser.add_argument("--env-scripts", required=True, help="ENV_SCRIPTS path")
    parser.add_argument("--status", default="success", help="Stage status (success/failed)")

    args = parser.parse_args()

    print(f"\n{'='*60}")
    print(f"[POST] Post-Processing: {args.stage}")
    print(f"{'='*60}")
    print(f"  Stage Dir:   {args.stage_dir}")
    print(f"  Run Dir:     {args.run_dir}")
    print(f"  Project:     {args.project}")
    print(f"  Block:       {args.block_name}")
    print(f"  RTL Tag:     {args.rtl_tag}")
    print(f"  Experiment:  {args.exp_name}")
    print(f"  Status:      {args.status}")
    print(f"{'='*60}")

    # Get handler for this stage (or use default)
    handler = STAGE_HANDLERS.get(args.stage, post_default)

    success = handler(args)

    if success:
        print(f"\n[POST] === Post-processing completed successfully ===")
        sys.exit(0)
    else:
        print(f"\n[POST] === Post-processing completed with errors ===")
        sys.exit(1)


if __name__ == "__main__":
    main()
