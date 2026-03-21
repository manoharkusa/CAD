#!/usr/bin/env python3
"""
Master Metrics Collector for ASIC Design Flow
Orchestrates metrics collection across all design stages
Updated to use consolidated parsing functions
"""

import argparse
import json
import os
import sys
from pathlib import Path
from datetime import datetime

# Import utility functions
import metrics_utils as utils


# ==============================================================================
# STAGE CONFIGURATION - Define report paths and parsers for each stage
# ==============================================================================

STAGE_CONFIG = {
    'syn': {
        'name': 'Synthesis',
        'reports_subdir': 'reports',
        'logs_subdir': 'logs',
        'parsers': [
            'setup_timing',
            'drv_violations',
            'area',
            'instance_count',
        ]
    },

    'init': {
        'name': 'Design Init',
        'reports_subdir': 'reports',
        'logs_subdir': 'logs',
        'parsers': [
            'area',
            'instance_count',
        ]
    },

    'floorplan': {
        'name': 'Floorplan',
        'reports_subdir': 'reports',
        'logs_subdir': 'logs',
        'parsers': [
            'area',
            'instance_count',
        ]
    },

    'place': {
        'name': 'Placement',
        'reports_subdir': 'reports',
        'logs_subdir': 'logs',
        'parsers': [
            'setup_timing',
            'drv_violations',
            'timing_custom_groups',
            'area',
            'instance_count',
        ]
    },

    'cts': {
        'name': 'Clock Tree Synthesis',
        'reports_subdir': 'reports',
        'logs_subdir': 'logs',
        'parsers': [
            'setup_timing',
            'hold_timing',
            'drv_violations',
            'area',
            'instance_count',
        ]
    },

    'postcts': {
        'name': 'Post-CTS Optimization',
        'reports_subdir': 'reports',
        'logs_subdir': 'logs',
        'parsers': [
            'setup_timing',
            'hold_timing',
            'drv_violations',
            'area',
            'instance_count',
        ]
    },

    'route': {
        'name': 'Routing',
        'reports_subdir': 'reports',
        'logs_subdir': 'logs',
        'parsers': [
            'setup_timing',
            'hold_timing',
            'drv_violations',
            'area',
            'instance_count',
            'congestion_drc',
            'noise_metrics',
            'mpw_metrics',
        ]
    },

    'postroute': {
        'name': 'Post-Route Optimization',
        'reports_subdir': 'reports',
        'logs_subdir': 'logs',
        'parsers': [
            'setup_timing',
            'hold_timing',
            'drv_violations',
            'area',
            'instance_count',
            'congestion_drc',
        ]
    },

    'chip_finish': {
        'name': 'Chip Finish',
        'reports_subdir': 'reports',
        'logs_subdir': 'logs',
        'parsers': [
            'setup_timing',
            'hold_timing',
            'drv_violations',
            'area',
            'instance_count',
            'congestion_drc',
        ]
    },
}


# ==============================================================================
# METRICS COLLECTION ORCHESTRATION
# ==============================================================================

class MetricsCollector:
    """Main orchestrator for metrics collection"""

    def __init__(self, args):
        self.args = args
        self.stage = args.stage
        self.stage_dir = Path(args.stage_dir)
        self.run_dir = Path(args.run_dir)
        self.runtag = args.runtag
        self.block_name = args.block_name
        self.project = args.project
        self.rtl_tag = args.rtl_tag
        self.enable_ai = args.enable_ai

        # Output files
        self.json_file = self.run_dir / f"{self.runtag}_metrics.json"
        self.csv_file = self.run_dir / f"{self.runtag}_metrics.csv"

        # Load existing metrics
        self.all_metrics = self.load_existing_metrics()

    def load_existing_metrics(self):
        """Load existing metrics JSON if available"""
        if self.json_file.exists():
            try:
                with open(self.json_file, 'r') as f:
                    return json.load(f)
            except Exception as e:
                print(f"[WARN] Could not load existing metrics: {e}")

        # Initialize new metrics structure
        return {
            'project': self.project,
            'block_name': self.block_name,
            'experiment': self.runtag,
            'rtl_tag': self.rtl_tag,
            'run_directory': str(self.run_dir),
            'stages': {}
        }

    def collect_stage_metrics(self):
        """Collect metrics for the current stage"""

        print(f"\n{'='*80}")
        print(f"Collecting Metrics: {self.block_name} - {self.runtag} - {self.stage}")
        print(f"{'='*80}\n")

        # Get stage configuration
        if self.stage not in STAGE_CONFIG:
            print(f"[ERROR] Unknown stage: {self.stage}")
            print(f"[ERROR] Valid stages: {', '.join(STAGE_CONFIG.keys())}")
            return False

        config = STAGE_CONFIG[self.stage]

        # Determine report and log directories
        reports_dir = self.stage_dir / config['reports_subdir']
        logs_dir = self.stage_dir / config['logs_subdir']

        if not reports_dir.exists():
            print(f"[WARN] Reports directory not found: {reports_dir}")
            # Continue anyway - some parsers may not need reports

        # Initialize stage metrics with ALL fields (use "N/A" for missing values, not NULL)
        stage_metrics = {
            # Metadata fields (always present)
            'stage': self.stage,
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'project': self.project,
            'block_name': self.block_name,
            'experiment': self.runtag,
            'rtl_tag': self.rtl_tag,
            'user_name': os.environ.get('USER', 'unknown'),
            'run_directory': str(self.run_dir),
            'stage_directory': str(self.stage_dir),

            # Internal timing (R2R)
            'internal_timing_r2r_wns': "N/A",
            'internal_timing_r2r_tns': "N/A",
            'internal_timing_r2r_nvp': "N/A",

            # Interface timing
            'interface_timing_i2r_wns': "N/A",
            'interface_timing_i2r_tns': "N/A",
            'interface_timing_i2r_nvp': "N/A",
            'interface_timing_r2o_wns': "N/A",
            'interface_timing_r2o_tns': "N/A",
            'interface_timing_r2o_nvp': "N/A",
            'interface_timing_i2o_wns': "N/A",
            'interface_timing_i2o_tns': "N/A",
            'interface_timing_i2o_nvp': "N/A",

            # Hold timing
            'hold_wns': "N/A",
            'hold_tns': "N/A",
            'hold_nvp': "N/A",

            # Design rule violations
            'max_tran_wns': "N/A",
            'max_tran_nvp': "N/A",
            'max_cap_wns': "N/A",
            'max_cap_nvp': "N/A",
            'max_fanout_wns': "N/A",
            'max_fanout_nvp': "N/A",

            # Noise
            'noise_violations': "N/A",

            # MPW/min period/double switching
            'min_pulse_width': "N/A",
            'min_period': "N/A",
            'double_switching': "N/A",

            # Congestion/DRC metrics
            'drc_violations': "N/A",
            'congestion_hotspot': "N/A",

            # Area metrics
            'area': "N/A",
            'inst_count': "N/A",
            'utilization': "N/A",

            # Log metrics
            'log_errors': 0,
            'log_warnings': 0,

            # Run status and runtime
            'run_status': "N/A",
            'runtime': "N/A",
            'memory_usage': "N/A",

            # AI summary
            'ai_summary': "",

            # Sign-off metrics
            'ir_static': "N/A",
            'ir_dynamic': "N/A",
            'em_power': "N/A",
            'em_signal': "N/A",
            'pv_drc_base': "N/A",
            'pv_drc_metal': "N/A",
            'pv_drc_antenna': "N/A",
            'lvs': "N/A",
            'erc': "N/A",
            'r2g_lec': "N/A",
            'g2g_lec': "N/A",
        }

        # Helper function to update metric only if value is not None or "N/A"
        def update_if_valid(key, value):
            """Update stage_metrics only if value is valid (not None or 'N/A')"""
            if value is not None and value != "N/A":
                stage_metrics[key] = value

        # Run configured parsers for this stage
        print(f"[INFO] Running parsers: {', '.join(config['parsers'])}\n")

        for parser_name in config['parsers']:
            print(f"[INFO] Parsing {parser_name}...")

            try:
                # Call the appropriate parser function
                if parser_name == 'setup_timing':
                    # Parse all setup timing path groups
                    path_groups = utils.parse_timing_path_groups(reports_dir, 'setup')

                    # Extract specific path groups for dashboard compatibility
                    # R2R timing (reg2reg or clk or fallback to 'all')
                    if 'reg2reg' in path_groups:
                        update_if_valid('internal_timing_r2r_wns', path_groups['reg2reg'].get('wns'))
                        update_if_valid('internal_timing_r2r_tns', path_groups['reg2reg'].get('tns'))
                        update_if_valid('internal_timing_r2r_nvp', path_groups['reg2reg'].get('nvp'))
                    elif 'clk' in path_groups:
                        update_if_valid('internal_timing_r2r_wns', path_groups['clk'].get('wns'))
                        update_if_valid('internal_timing_r2r_tns', path_groups['clk'].get('tns'))
                        update_if_valid('internal_timing_r2r_nvp', path_groups['clk'].get('nvp'))
                    elif 'all' in path_groups:
                        update_if_valid('internal_timing_r2r_wns', path_groups['all'].get('wns'))
                        update_if_valid('internal_timing_r2r_tns', path_groups['all'].get('tns'))
                        update_if_valid('internal_timing_r2r_nvp', path_groups['all'].get('nvp'))

                    # I2R timing (in2reg)
                    if 'in2reg' in path_groups:
                        update_if_valid('interface_timing_i2r_wns', path_groups['in2reg'].get('wns'))
                        update_if_valid('interface_timing_i2r_tns', path_groups['in2reg'].get('tns'))
                        update_if_valid('interface_timing_i2r_nvp', path_groups['in2reg'].get('nvp'))

                    # R2O timing (reg2out)
                    if 'reg2out' in path_groups:
                        update_if_valid('interface_timing_r2o_wns', path_groups['reg2out'].get('wns'))
                        update_if_valid('interface_timing_r2o_tns', path_groups['reg2out'].get('tns'))
                        update_if_valid('interface_timing_r2o_nvp', path_groups['reg2out'].get('nvp'))

                    # I2O timing (in2out)
                    if 'in2out' in path_groups:
                        update_if_valid('interface_timing_i2o_wns', path_groups['in2out'].get('wns'))
                        update_if_valid('interface_timing_i2o_tns', path_groups['in2out'].get('tns'))
                        update_if_valid('interface_timing_i2o_nvp', path_groups['in2out'].get('nvp'))

                    # Store all path groups in raw form for reference
                    stage_metrics['setup_path_groups'] = path_groups

                elif parser_name == 'hold_timing':
                    # Parse all hold timing path groups
                    path_groups = utils.parse_timing_path_groups(reports_dir, 'hold')

                    # Extract overall hold metrics
                    if 'all' in path_groups:
                        update_if_valid('hold_wns', path_groups['all'].get('wns'))
                        update_if_valid('hold_tns', path_groups['all'].get('tns'))
                        update_if_valid('hold_nvp', path_groups['all'].get('nvp'))

                    # Store all hold path groups for reference
                    stage_metrics['hold_path_groups'] = path_groups

                elif parser_name == 'drv_violations':
                    # Parse all DRV violations
                    drv_violations = utils.parse_drv_violations(reports_dir)

                    # Extract specific DRV types for dashboard compatibility
                    if 'max_transition' in drv_violations:
                        update_if_valid('max_tran_wns', drv_violations['max_transition'].get('wns'))
                        update_if_valid('max_tran_nvp', drv_violations['max_transition'].get('nvp'))

                    if 'max_capacitance' in drv_violations:
                        update_if_valid('max_cap_wns', drv_violations['max_capacitance'].get('wns'))
                        update_if_valid('max_cap_nvp', drv_violations['max_capacitance'].get('nvp'))

                    if 'max_fanout' in drv_violations:
                        update_if_valid('max_fanout_wns', drv_violations['max_fanout'].get('wns'))
                        update_if_valid('max_fanout_nvp', drv_violations['max_fanout'].get('nvp'))

                    # Store all DRV violations for reference
                    stage_metrics['drv_violations'] = drv_violations

                elif parser_name == 'area':
                    result = utils.parse_area(reports_dir)
                    total_area = result.get('total_area')
                    utilization = result.get('utilization')
                    if total_area is not None:
                        stage_metrics['area'] = total_area
                    if utilization is not None:
                        stage_metrics['utilization'] = utilization

                elif parser_name == 'instance_count':
                    result = utils.parse_instance_count(reports_dir)
                    inst_count = result.get('inst_count')
                    if inst_count is not None:
                        stage_metrics['inst_count'] = inst_count

                elif parser_name == 'congestion_drc':
                    result = utils.parse_congestion_drc(reports_dir)
                    drc_violations = result.get('drc_violations')
                    metal_density_avg = result.get('metal_density_avg')
                    metal_density_max = result.get('metal_density_max')
                    if drc_violations is not None:
                        stage_metrics['drc_violations'] = drc_violations
                    if metal_density_avg is not None:
                        stage_metrics['metal_density_avg'] = metal_density_avg
                    if metal_density_max is not None:
                        stage_metrics['metal_density_max'] = metal_density_max

                elif parser_name == 'noise_metrics':
                    result = utils.parse_noise_metrics(reports_dir)
                    noise_violations = result.get('noise_violations')
                    if noise_violations is not None:
                        stage_metrics['noise_violations'] = noise_violations

                elif parser_name == 'mpw_metrics':
                    result = utils.parse_mpw_metrics(reports_dir)
                    min_period = result.get('min_period')
                    double_switching = result.get('double_switching')
                    if min_period is not None:
                        stage_metrics['min_period'] = min_period
                    if double_switching is not None:
                        stage_metrics['double_switching'] = double_switching

            except Exception as e:
                print(f"[ERROR] Parser {parser_name} failed: {e}")
                import traceback
                traceback.print_exc()

        # Parse log files for errors/warnings
        print(f"[INFO] Parsing log files...")
        log_metrics = utils.parse_log_errors_warnings(logs_dir)
        stage_metrics['log_errors'] = log_metrics['errors']
        stage_metrics['log_warnings'] = log_metrics['warnings']
        stage_metrics['log_critical'] = log_metrics['critical']

        # Calculate runtime and parse memory usage
        print(f"[INFO] Calculating runtime and memory usage...")
        stage_metrics['runtime'] = utils.calculate_runtime(self.stage_dir)
        stage_metrics['memory_usage'] = utils.parse_memory_usage(self.stage_dir)

        # Determine run status
        print(f"[INFO] Determining run status...")
        stage_metrics['run_status'] = utils.determine_run_status(stage_metrics)

        # Generate AI summary if enabled
        if self.enable_ai:
            print(f"[INFO] Generating AI summary...")
            stage_metrics['ai_summary'] = utils.generate_ai_summary(stage_metrics, self.stage)
        else:
            stage_metrics['ai_summary'] = ''

        # Add to overall metrics
        self.all_metrics['stages'][self.stage] = stage_metrics
        self.all_metrics['last_updated'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        # Print summary of collected metrics
        print(f"\n{'='*60}")
        print(f"Metrics Summary for {self.stage}:")
        print(f"{'='*60}")
        print(f"  Setup WNS: {stage_metrics.get('internal_timing_r2r_wns', 'N/A')} ns")
        print(f"  Hold WNS:  {stage_metrics.get('hold_wns', 'N/A')} ns")
        print(f"  Area:      {stage_metrics.get('area', 'N/A')} um²")
        print(f"  Inst Count:{stage_metrics.get('inst_count', 'N/A')}")
        print(f"  DRC Viols: {stage_metrics.get('drc_violations', 'N/A')}")
        print(f"  Status:    {stage_metrics.get('run_status', 'N/A')}")
        print(f"{'='*60}\n")

        return True

    def save_metrics(self):
        """Save metrics to JSON and CSV files"""

        print(f"\n[INFO] Saving metrics...")

        # Export to JSON
        utils.export_to_json(self.all_metrics, self.json_file)

        # Export to CSV
        utils.export_to_csv(self.all_metrics, self.csv_file)

        print(f"\n{'='*80}")
        print(f"Metrics Collection Complete!")
        print(f"{'='*80}")
        print(f"JSON: {self.json_file}")
        print(f"CSV:  {self.csv_file}")
        print(f"{'='*80}\n")

        return True


# ==============================================================================
# MAIN ENTRY POINT
# ==============================================================================

def main():
    """Main entry point"""

    parser = argparse.ArgumentParser(
        description='Collect metrics from ASIC design flow stage',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Collect metrics for synthesis stage
  ./collect_metrics.py --stage syn --stage-dir ./aes_cipher_top/v1/run1/syn \\
                       --run-dir ./aes_cipher_top/v1/run1 \\
                       --runtag run1 --block-name aes_cipher_top

  # Collect with AI summary generation
  ./collect_metrics.py --stage route --stage-dir ./run1/pnr/route \\
                       --run-dir ./run1 --enable-ai
        """
    )

    parser.add_argument('--stage', required=True,
                        choices=list(STAGE_CONFIG.keys()),
                        help='Design stage name')

    parser.add_argument('--stage-dir', required=True,
                        help='Path to stage directory (contains reports/ and logs/)')

    parser.add_argument('--run-dir', required=True,
                        help='Path to run directory (for output files)')

    parser.add_argument('--runtag',
                        default=os.environ.get('RUNTAG', 'run1'),
                        help='Run tag / experiment name (default: $RUNTAG or run1)')

    parser.add_argument('--block-name',
                        default=os.environ.get('BLOCK_NAME', 'design'),
                        help='Block/design name (default: $BLOCK_NAME or design)')

    parser.add_argument('--project',
                        default=os.environ.get('PROJECT_NAME', 'project1'),
                        help='Project name (default: $PROJECT_NAME or project1)')

    parser.add_argument('--rtl-tag',
                        default=os.environ.get('RTL_VERSION', 'v1'),
                        help='RTL version tag (default: $RTL_VERSION or v1)')

    parser.add_argument('--enable-ai', action='store_true',
                        help='Enable AI summary generation (requires ANTHROPIC_API_KEY)')

    args = parser.parse_args()

    # Create collector and run
    collector = MetricsCollector(args)

    if not collector.collect_stage_metrics():
        sys.exit(1)

    if not collector.save_metrics():
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()
