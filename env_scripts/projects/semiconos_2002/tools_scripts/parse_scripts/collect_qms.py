#!/usr/bin/env python3
"""
QMS (Quality Management System) Collector for ASIC Design Flow
Orchestrates quality checks across all design stages
Runs independently from metrics collection...
"""

import argparse
import json
import os
import sys
from pathlib import Path
from datetime import datetime

# Import QMS modules
try:
    import syn_qms
    #import pnr_qms
except ImportError as e:
    print(f"[ERROR] Failed to import QMS modules: {e}")
    sys.exit(1)


def collect_qms_checks(stage: str, stage_dir: Path, block_name: str, 
                      rtl_tag: str, project: str, run_dir: Path, runtag: str) -> bool:
    """
    Collect QMS checks for specified stage
    
    Args:
        stage: Design stage (syn, place, cts, route, etc.)
        stage_dir: Path to stage directory
        block_name: Block/design name
        rtl_tag: RTL version tag
        project: Project name
        run_dir: Run directory for output files
        runtag: Run tag for file naming
        
    Returns:
        bool: True if successful, False otherwise
    """
    
    print(f"\n{'='*80}")
    print(f"QMS Quality Checks: {block_name} - {runtag} - {stage}")
    print(f"{'='*80}\n")
    
    try:
        # Run stage-specific QMS checks
        if stage == 'syn':
            qms_results = syn_qms.run_synthesis_qms_checks(
                stage_dir, block_name, rtl_tag, project
            )
        elif stage in ['init', 'floorplan', 'place', 'cts', 'postcts', 'route', 'postroute', 'signoff']:
            qms_results = pnr_qms.run_pnr_qms_checks(
                stage, stage_dir, block_name, rtl_tag, project
            )
        else:
            print(f"[ERROR] Unknown stage for QMS: {stage}")
            return False
        
        # Save QMS results
        qms_json_file = run_dir / f"{runtag}_{stage}_qms.json"
        with open(qms_json_file, 'w') as f:
            json.dump(qms_results, f, indent=2)
        
        print(f"[INFO] QMS results saved to: {qms_json_file}")
        
        # Also create a consolidated QMS file across all stages
        update_consolidated_qms(run_dir, runtag, stage, qms_results)
        
        # Print final summary
        summary = qms_results['summary']
        print(f"\n{'='*60}")
        print(f"QMS Summary for {stage}:")
        print(f"{'='*60}")
        print(f"Overall Status: {summary['overall_status']}")
        print(f"Pass Rate: {summary['pass_rate']}%")
        print(f"Critical Failures: {len(summary['critical_failures'])}")
        
        if summary['overall_status'] == 'FAIL':
            print(f"[WARNING] QMS checks FAILED for {stage}")
            if summary['recommendations']:
                print("Recommendations:")
                for rec in summary['recommendations'][:3]:  # Show top 3
                    print(f"  - {rec}")
        
        print(f"{'='*60}\n")
        
        return True
        
    except Exception as e:
        print(f"[ERROR] QMS collection failed for {stage}: {e}")
        import traceback
        traceback.print_exc()
        return False


def update_consolidated_qms(run_dir: Path, runtag: str, stage: str, qms_results: dict):
    """Update consolidated QMS file with results from all stages"""
    
    consolidated_file = run_dir / f"{runtag}_qms_summary.json"
    
    # Load existing consolidated data
    if consolidated_file.exists():
        try:
            with open(consolidated_file, 'r') as f:
                consolidated_data = json.load(f)
        except:
            consolidated_data = {}
    else:
        consolidated_data = {
            'project': qms_results.get('project', 'N/A'),
            'block_name': qms_results.get('block_name', 'N/A'),
            'runtag': runtag,
            'last_updated': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'stages': {}
        }
    
    # Add current stage results
    consolidated_data['stages'][stage] = qms_results
    consolidated_data['last_updated'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    # Generate overall summary across all stages
    consolidated_data['overall_summary'] = generate_overall_qms_summary(consolidated_data['stages'])
    
    # Save consolidated data
    with open(consolidated_file, 'w') as f:
        json.dump(consolidated_data, f, indent=2)
    
    print(f"[INFO] Consolidated QMS updated: {consolidated_file}")


def generate_overall_qms_summary(stages_data: dict) -> dict:
    """Generate overall QMS summary across all stages"""
    
    overall_stats = {
        'total_stages': len(stages_data),
        'stages_passed': 0,
        'stages_failed': 0,
        'stages_warned': 0,
        'total_checks': 0,
        'total_passed': 0,
        'total_failed': 0,
        'total_warned': 0,
        'overall_pass_rate': 0,
        'critical_issues': [],
        'stage_status': {}
    }
    
    for stage_name, stage_data in stages_data.items():
        summary = stage_data.get('summary', {})
        status = summary.get('overall_status', 'UNKNOWN')
        
        # Count stage statuses
        overall_stats['stage_status'][stage_name] = status
        if status == 'PASS':
            overall_stats['stages_passed'] += 1
        elif status == 'FAIL':
            overall_stats['stages_failed'] += 1
        elif status == 'WARN':
            overall_stats['stages_warned'] += 1
        
        # Accumulate check counts
        overall_stats['total_checks'] += summary.get('total_checks', 0)
        overall_stats['total_passed'] += summary.get('passed_checks', 0)
        overall_stats['total_failed'] += summary.get('failed_checks', 0)
        overall_stats['total_warned'] += summary.get('warned_checks', 0)
        
        # Collect critical failures
        critical_failures = summary.get('critical_failures', [])
        for failure in critical_failures:
            overall_stats['critical_issues'].append(f"{stage_name}: {failure}")
    
    # Calculate overall pass rate
    if overall_stats['total_checks'] > 0:
        overall_stats['overall_pass_rate'] = round(
            (overall_stats['total_passed'] / overall_stats['total_checks']) * 100, 1
        )
    
    # Determine overall status
    if overall_stats['stages_failed'] > 0:
        overall_stats['overall_status'] = 'FAIL'
    elif overall_stats['stages_warned'] > overall_stats['stages_passed'] // 2:
        overall_stats['overall_status'] = 'WARN'
    else:
        overall_stats['overall_status'] = 'PASS'
    
    return overall_stats


def main():
    """Main entry point"""
    
    parser = argparse.ArgumentParser(
        description='Collect QMS checks from ASIC design flow stage',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Run QMS checks for synthesis stage
  ./collect_qms.py --stage syn --stage-dir ./run1/syn \\
                   --run-dir ./run1 --runtag run1 --block-name aes_cipher_top

  # Run QMS checks for routing stage  
  ./collect_qms.py --stage route --stage-dir ./run1/pnr/route \\
                   --run-dir ./run1 --runtag run1 --block-name aes_cipher_top
        """
    )
    
    parser.add_argument('--stage', required=True,
                        choices=['syn', 'init', 'floorplan', 'place', 'cts', 'postcts', 'route', 'postroute', 'signoff'],
                        help='Design stage name')
    
    parser.add_argument('--stage-dir', required=True,
                        help='Path to stage directory (contains reports/ and logs/)')
    
    parser.add_argument('--run-dir', required=True,
                        help='Path to run directory (for output files)')
    
    parser.add_argument('--runtag',
                        default=os.environ.get('EXP_NAME', 'run1'),
                        help='Run tag / experiment name (default: $RUNTAG or run1)')
    
    parser.add_argument('--block-name',
                        default=os.environ.get('BLOCK_NAME', 'design'),
                        help='Block/design name (default: $BLOCK_NAME or design)')
    
    parser.add_argument('--project',
                        default=os.environ.get('PROJ_NAME', 'project1'),
                        help='Project name (default: $PROJ_NAME or project1)')
    
    parser.add_argument('--rtl-tag',
                        default=os.environ.get('RTL_TAG', 'v1'),
                        help='RTL version tag (default: $RTL_TAG)')
    
    args = parser.parse_args()
    
    # Validate directories
    stage_dir = Path(args.stage_dir)
    run_dir = Path(args.run_dir)
    
    if not stage_dir.exists():
        print(f"[ERROR] Stage directory does not exist: {stage_dir}")
        sys.exit(1)
    
    if not run_dir.exists():
        print(f"[ERROR] Run directory does not exist: {run_dir}")
        sys.exit(1)
    
    # Run QMS collection
    success = collect_qms_checks(
        args.stage, stage_dir, args.block_name, 
        args.rtl_tag, args.project, run_dir, args.runtag
    )
    
    if not success:
        print(f"[ERROR] QMS collection failed for {args.stage}")
        sys.exit(1)
    
    print(f"[SUCCESS] QMS collection completed for {args.stage}")
    sys.exit(0)


if __name__ == '__main__':
    main()
