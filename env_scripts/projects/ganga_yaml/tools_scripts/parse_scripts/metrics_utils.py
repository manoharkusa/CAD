#!/usr/bin/env python3
"""
Metrics Utilities for ASIC Design Flow
Contains all parsing functions and utilities for metrics collection
Updated to handle actual Genus and Innovus report formats from TSMC 28nm flow
"""

import re
import os
import json
from pathlib import Path
from datetime import datetime
from collections import defaultdict


# ==============================================================================
# TIMING PARSERS - CONSOLIDATED
# ==============================================================================

def parse_timing_path_groups(reports_dir, analysis_type='setup'):
    """
    Parse all path groups from timing reports (setup or hold)
    Returns a dictionary with all path groups and their metrics

    IMPORTANT: Assumes all timing values in reports are in NANOSECONDS (ns).
    Ensure your EDA tools are configured to report timing in ns.

    Args:
        reports_dir: Path to reports directory
        analysis_type: 'setup' or 'hold'

    Returns:
        dict: {
            'all': {'wns': X, 'tns': Y, 'nvp': Z},
            'reg2reg': {'wns': X, 'tns': Y, 'nvp': Z},
            'in2reg': {'wns': X, 'nvp': Z},
            'reg2out': {'wns': X, 'nvp': Z},
            'in2out': {'wns': X, 'nvp': Z},
            'clk': {'wns': X, 'tns': Y, 'nvp': Z},
            ...
        }
    """
    path_groups = {}

    def parse_value(value_str):
        """
        Parse timing value (assumes nanoseconds)
        Returns "N/A" for N/A or invalid values
        """
        if value_str in ["N/A", "No paths"]:
            return "N/A"
        try:
            return float(value_str)
        except (ValueError, TypeError):
            return "N/A"

    # Determine which report files to check based on analysis type
    if analysis_type == 'setup':
        report_files = [
            reports_dir / "timing_summary.rpt",          # Genus synthesis
            reports_dir / "setup.analysis_summary.rpt",  # Innovus P&R
            reports_dir / "report_qor.rpt"               # Genus QoR
        ]
    else:  # hold
        report_files = [
            reports_dir / "hold.analysis_summary.rpt"    # Innovus hold
        ]

    for report_file in report_files:
        if not report_file.exists():
            continue

        try:
            content = report_file.read_text()

            # Parse timing reports (Genus or Innovus format)
            # All values assumed to be in nanoseconds (ns)

            # Try Genus format first: View: ALL
            match = re.search(r'View:\s+ALL\s+([-\d.]+|\s+N/A)\s+([-\d.]+|\s+N/A)\s+(\d+)', content)
            if match:
                wns_str, tns_str, fep_str = match.group(1).strip(), match.group(2).strip(), match.group(3).strip()
                path_groups['all'] = {
                    'wns': parse_value(wns_str),
                    'tns': parse_value(tns_str),
                    'nvp': int(fep_str) if fep_str != "N/A" else "N/A"
                }

                # Parse all Group lines (Genus format)
                group_pattern = r'Group\s*:\s*(\w+)\s+([-\d.]+|\s+N/A|No paths)\s+([-\d.]+|\s+N/A)\s+(\d+)'
                for match in re.finditer(group_pattern, content):
                    group_name = match.group(1).strip()
                    wns_str = match.group(2).strip()
                    tns_str = match.group(3).strip()
                    fep_str = match.group(4).strip()

                    path_groups[group_name] = {
                        'wns': parse_value(wns_str),
                        'tns': parse_value(tns_str),
                        'nvp': int(fep_str) if fep_str != "N/A" else "N/A"
                    }

                break  # Found and parsed report

            # Try Innovus format: View : ALL
            match = re.search(r'View\s*:\s*ALL\s+([-\d.]+|\s+N/A)\s+([-\d.]+|\s+N/A)\s+(\d+)', content)
            if match:
                wns_str, tns_str, fep_str = match.group(1).strip(), match.group(2).strip(), match.group(3).strip()
                path_groups['all'] = {
                    'wns': parse_value(wns_str),
                    'tns': parse_value(tns_str),
                    'nvp': int(fep_str) if fep_str != "N/A" else "N/A"
                }

                # Parse all Group lines (Innovus format)
                group_pattern = r'Group\s*:\s*(\w+)\s+([-\d.]+|\s+N/A)\s+([-\d.]+|\s+N/A)\s+(\d+)'
                for match in re.finditer(group_pattern, content):
                    group_name = match.group(1).strip()
                    wns_str = match.group(2).strip()
                    tns_str = match.group(3).strip()
                    fep_str = match.group(4).strip()

                    path_groups[group_name] = {
                        'wns': parse_value(wns_str),
                        'tns': parse_value(tns_str),
                        'nvp': int(fep_str) if fep_str != "N/A" else "N/A"
                    }

                break  # Found and parsed report

        except Exception as e:
            print(f"[WARN] Error parsing {analysis_type} timing from {report_file.name}: {e}")

    return path_groups


# ==============================================================================
# DESIGN RULE VIOLATION PARSERS
# ==============================================================================

def parse_drv_violations(reports_dir):
    """
    Parse all design rule violations (max_tran, max_cap, max_fanout, etc.)
    Returns a dictionary with all DRV types and their metrics

    Returns:
        dict: {
            'max_transition': {'wns': X, 'tns': Y, 'nvp': Z},
            'max_capacitance': {'wns': X, 'tns': Y, 'nvp': Z},
            'max_fanout': {'wns': X, 'tns': Y, 'nvp': Z},
            ...
        }
    """
    drv_violations = {}

    # Try different report files
    report_files = [
        reports_dir / "timing_summary.rpt",                      # Genus
        reports_dir / "setup.analysis_summary.rpt",               # Innovus
        reports_dir / "report_constraint.all_violators.rpt"       # Both
    ]

    for report_file in report_files:
        if not report_file.exists():
            continue

        try:
            content = report_file.read_text()

            # Skip if file is empty or just header
            if len(content.strip()) < 10:
                continue

            # Parse all DRV checks from DRV section
            # Format:    Check : max_transition        N/A       N/A     0
            #           Check : max_capacitance    -15.000   -45.000     3
            drv_pattern = r'(?:Check\s*:)?\s*(max_transition|min_transition|max_capacitance|min_capacitance|max_fanout|min_fanout)\s+([-\d.]+|\s+N/A)\s+([-\d.]+|\s+N/A)\s+(\d+)'

            for match in re.finditer(drv_pattern, content, re.IGNORECASE):
                check_type = match.group(1).strip().lower().replace(' ', '_')
                wns_str = match.group(2).strip()
                tns_str = match.group(3).strip()
                fep_str = match.group(4).strip()

                drv_violations[check_type] = {
                    'wns': float(wns_str) if wns_str != "N/A" else "N/A",
                    'tns': float(tns_str) if tns_str != "N/A" else "N/A",
                    'nvp': int(fep_str) if fep_str != "N/A" else "N/A"
                }

            if drv_violations:  # Found DRV section
                break

        except Exception as e:
            print(f"[WARN] Error parsing DRV violations from {report_file.name}: {e}")

    return drv_violations


# ==============================================================================
# AREA & UTILIZATION PARSERS
# ==============================================================================

def parse_area(reports_dir):
    """Parse area and utilization metrics"""
    metrics = {'total_area': None, 'utilization': None}

    # Try different area report names
    report_files = [
        reports_dir / "report_area.rpt",      # Genus
        reports_dir / "area.summary.rpt",     # Innovus
        reports_dir / "report_qor.rpt"        # Genus QoR
    ]

    for report_file in report_files:
        if not report_file.exists():
            continue

        try:
            content = report_file.read_text()

            # Innovus area.summary.rpt format:
            if "area.summary.rpt" in report_file.name:
                match = re.search(r'^[a-zA-Z_]\w+\s+\d+\s+([\d.]+)', content, re.MULTILINE)
                if match:
                    metrics['total_area'] = float(match.group(1))
                    break

            # Genus report_area.rpt format - similar
            elif "report_area.rpt" in report_file.name:
                match = re.search(r'^[a-zA-Z_]\w+\s+\d+\s+([\d.]+)', content, re.MULTILINE)
                if match:
                    metrics['total_area'] = float(match.group(1))
                    break

            # Genus report_qor.rpt format:
            # Total Cell Area (Cell+Physical)    6303.150
            elif "report_qor.rpt" in report_file.name:
                match = re.search(r'Total\s+Cell\s+Area\s+\(Cell\+Physical\)\s+([\d.]+)', content)
                if not match:
                    match = re.search(r'Cell Area\s+([\d.]+)', content)
                if match:
                    metrics['total_area'] = float(match.group(1))
                    break

            # Generic pattern for other formats
            else:
                area_match = re.search(r'Total\s+(?:cell\s+)?area\s*[:=]?\s*([\d.]+)', content, re.IGNORECASE)
                if area_match:
                    metrics['total_area'] = float(area_match.group(1))

                util_match = re.search(r'Utilization\s*[:=]?\s*([\d.]+)\s*%?', content, re.IGNORECASE)
                if util_match:
                    metrics['utilization'] = float(util_match.group(1))

                if area_match:
                    break

        except Exception as e:
            print(f"[WARN] Error parsing area from {report_file.name}: {e}")

    return metrics


def parse_instance_count(reports_dir):
    """Parse instance/cell count"""
    metrics = {'inst_count': None}

    report_files = [
        reports_dir / "report_qor.rpt",       # Genus QoR
        reports_dir / "area.summary.rpt",     # Innovus
        reports_dir / "report_gates.rpt",     # Genus
        reports_dir / "report_area.rpt"       # Genus area
    ]

    for report_file in report_files:
        if not report_file.exists():
            continue

        try:
            content = report_file.read_text()

            # Genus report_qor.rpt format:
            # Leaf Instance Count             9846
            match = re.search(r'Leaf Instance Count\s+(\d+)', content)
            if match:
                metrics['inst_count'] = int(match.group(1))
                break

            # Innovus area.summary.rpt format:
            # aes_cipher_top                                      9839             6301.134
            match = re.search(r'^[a-zA-Z_]\w+\s+(\d+)\s+[\d.]+', content, re.MULTILINE)
            if match:
                metrics['inst_count'] = int(match.group(1))
                break

            # General patterns
            cell_match = re.search(r'(?:Total\s+)?(?:Number of\s+)?(?:cells?|instances?)\s*[:=]?\s*(\d+)', content, re.IGNORECASE)
            if cell_match:
                metrics['inst_count'] = int(cell_match.group(1))
                break

        except Exception as e:
            print(f"[WARN] Error parsing instance count from {report_file.name}: {e}")

    return metrics


# ==============================================================================
# ROUTING & CONGESTION PARSERS
# ==============================================================================

def parse_congestion_drc(reports_dir):
    """Parse congestion and DRC metrics"""
    metrics = {'drc_violations': None, 'metal_density_avg': None, 'metal_density_max': None}

    # Parse DRC violations
    # Format:  Total Violations : 4 Viols.
    drc_file = reports_dir / "route.drc.rpt"
    if drc_file.exists():
        try:
            content = drc_file.read_text()

            # Look for "Total Violations : N Viols."
            viol_match = re.search(r'Total\s+Violations?\s*[:=]?\s*(\d+)\s*Viols?\.?', content, re.IGNORECASE)
            if viol_match:
                metrics['drc_violations'] = int(viol_match.group(1))
            else:
                # Try alternative pattern
                viol_match = re.search(r'(?:Total\s+)?(?:DRC\s+)?Violations?\s*[:=]?\s*(\d+)', content, re.IGNORECASE)
                if viol_match:
                    metrics['drc_violations'] = int(viol_match.group(1))
                else:
                    # Count violation types (lines containing specific DRC violation keywords)
                    viol_lines = [line for line in content.split('\n')
                                 if any(keyword in line for keyword in ['EndOfLine:', 'Spacing:', 'Short:'])
                                 and not line.strip().startswith('#')]
                    if viol_lines:
                        metrics['drc_violations'] = len(viol_lines)
                    else:
                        # If file exists but no violations found, assume 0
                        metrics['drc_violations'] = 0

        except Exception as e:
            print(f"[WARN] Error parsing DRC: {e}")

    # Parse metal density
    density_file = reports_dir / "route.metal_density.rpt"
    if density_file.exists():
        try:
            content = density_file.read_text()

            avg_match = re.search(r'Average\s+Density\s*[:=]?\s*([\d.]+)', content, re.IGNORECASE)
            if avg_match:
                metrics['metal_density_avg'] = float(avg_match.group(1))

            max_match = re.search(r'(?:Max|Maximum)\s+Density\s*[:=]?\s*([\d.]+)', content, re.IGNORECASE)
            if max_match:
                metrics['metal_density_max'] = float(max_match.group(1))

        except Exception as e:
            print(f"[WARN] Error parsing metal density: {e}")

    return metrics


def parse_noise_metrics(reports_dir):
    """Parse noise analysis metrics"""
    metrics = {'noise_violations': None}

    noise_file = reports_dir / "report_noise.rpt"
    if not noise_file.exists():
        return metrics

    try:
        content = noise_file.read_text()

        # Extract noise violations
        noise_match = re.search(r'(?:Total\s+)?Noise\s+Violations?\s*[:=]?\s*(\d+)', content, re.IGNORECASE)
        if noise_match:
            metrics['noise_violations'] = int(noise_match.group(1))

    except Exception as e:
        print(f"[WARN] Error parsing noise: {e}")

    return metrics


def parse_mpw_metrics(reports_dir):
    """Parse minimum pulse width and double switching metrics"""
    metrics = {'min_period': None, 'double_switching': None}

    report_file = reports_dir / "report_timing_summary.setup.rpt"
    if not report_file.exists():
        return metrics

    try:
        content = report_file.read_text()

        # Extract minimum period violations
        mpw_match = re.search(r'(?:Min|Minimum)\s+(?:Pulse|Period)\s+(?:Width)?\s*[:=]?\s*([-\d.]+)', content, re.IGNORECASE)
        if mpw_match:
            metrics['min_period'] = float(mpw_match.group(1))

        # Double switching from double clocking report
        dbl_clk_file = reports_dir / "report_double_clocking.rpt"
        if dbl_clk_file.exists():
            dbl_content = dbl_clk_file.read_text()
            dbl_match = re.search(r'Double\s+Clock(?:ing)?\s*[:=]?\s*(\d+)', dbl_content, re.IGNORECASE)
            if dbl_match:
                metrics['double_switching'] = int(dbl_match.group(1))

    except Exception as e:
        print(f"[WARN] Error parsing MPW metrics: {e}")

    return metrics


# ==============================================================================
# LOG FILE PARSERS
# ==============================================================================

def parse_log_errors_warnings(logs_dir):
    """Parse log files for errors and warnings"""
    metrics = {'errors': 0, 'warnings': 0, 'critical': 0}

    if not logs_dir.exists():
        return metrics

    try:
        # Get all log files in the directory
        log_files = list(logs_dir.glob("*.log*"))

        for log_file in log_files:
            try:
                content = log_file.read_text(errors='ignore')  # Ignore encoding errors

                # Count errors (case-insensitive)
                errors = len(re.findall(r'\b(?:ERROR|FATAL|FAILED)\b', content, re.IGNORECASE))
                metrics['errors'] += errors

                # Count warnings
                warnings = len(re.findall(r'\bWARN(?:ING)?\b', content, re.IGNORECASE))
                metrics['warnings'] += warnings

                # Count critical issues
                critical = len(re.findall(r'\b(?:CRITICAL|SEVERE)\b', content, re.IGNORECASE))
                metrics['critical'] += critical

            except Exception as e:
                print(f"[WARN] Could not read log file {log_file.name}: {e}")

    except Exception as e:
        print(f"[WARN] Error parsing logs: {e}")

    return metrics


def determine_run_status(metrics):
    """Determine overall run status based on metrics"""

    # Helper to safely get numeric value
    def get_numeric(val):
        if val is None or val == "N/A":
            return None
        try:
            return float(val)
        except (ValueError, TypeError):
            return None

    # Check for critical errors
    if metrics.get('log_errors', 0) > 0:
        return 'fail'

    # Check for timing violations (handle None and "N/A" values)
    setup_wns = get_numeric(metrics.get('internal_timing_r2r_wns'))
    hold_wns = get_numeric(metrics.get('hold_wns'))
    drc_violations = get_numeric(metrics.get('drc_violations'))

    # Significant timing violations (< -0.5ns)
    if setup_wns is not None and setup_wns < -0.5:
        return 'fail'
    if hold_wns is not None and hold_wns < -0.5:
        return 'fail'

    # Check for DRC violations (post-route only)
    if drc_violations is not None and drc_violations > 100:
        return 'fail'

    # Check for warnings
    if metrics.get('log_warnings', 0) > 50:
        return 'continue_with_error'

    # Minor timing violations (< 0ns)
    if setup_wns is not None and setup_wns < 0:
        return 'continue_with_error'
    if hold_wns is not None and hold_wns < 0:
        return 'continue_with_error'

    return 'pass'


# ==============================================================================
# RUNTIME CALCULATION
# ==============================================================================

def calculate_runtime(stage_dir):
    """
    Calculate runtime for a stage from session_memory_usage_runtime.rpt

    Expected format in report:
        Memory usage: 1,051M
        RUNTIME: 9

    Returns runtime in HH:MM:SS format
    """
    try:
        # Check for runtime report in reports directory
        reports_dir = stage_dir / "reports"
        runtime_file = reports_dir / "session_memory_usage_runtime.rpt"

        if not runtime_file.exists():
            print(f"[WARN] Runtime report not found: {runtime_file}")
            return "N/A"

        content = runtime_file.read_text()

        # Parse RUNTIME line (in seconds)
        runtime_match = re.search(r'RUNTIME:\s*(\d+)', content)
        if runtime_match:
            runtime_seconds = int(runtime_match.group(1))

            # Format as HH:MM:SS
            hours = runtime_seconds // 3600
            minutes = (runtime_seconds % 3600) // 60
            seconds = runtime_seconds % 60

            return f"{hours:02d}:{minutes:02d}:{seconds:02d}"
        else:
            print(f"[WARN] Could not parse RUNTIME from {runtime_file.name}")
            return "N/A"

    except Exception as e:
        print(f"[WARN] Could not calculate runtime: {e}")
        return "N/A"


def parse_memory_usage(stage_dir):
    """
    Parse memory usage from session_memory_usage_runtime.rpt

    Expected format in report:
        Memory usage: 1,051M
        RUNTIME: 9

    Returns memory usage as string (e.g., "1,051M" or "N/A")
    """
    try:
        # Check for runtime report in reports directory
        reports_dir = stage_dir / "reports"
        runtime_file = reports_dir / "session_memory_usage_runtime.rpt"

        if not runtime_file.exists():
            return "N/A"

        content = runtime_file.read_text()

        # Parse Memory usage line
        memory_match = re.search(r'Memory usage:\s*([^\n]+)', content)
        if memory_match:
            memory_usage = memory_match.group(1).strip()
            return memory_usage
        else:
            return "N/A"

    except Exception as e:
        print(f"[WARN] Could not parse memory usage: {e}")
        return "N/A"


# ==============================================================================
# AI SUMMARY GENERATION
# ==============================================================================

def generate_ai_summary(metrics, stage):
    """Generate AI-based summary and suggestions using Claude API"""

    try:
        # Check if anthropic module is available
        try:
            import anthropic
        except ImportError:
            print("[WARN] Anthropic module not installed. Install with: pip install anthropic")
            return "AI summary not available - anthropic module not installed"

        # Get API key from environment
        api_key = os.environ.get('ANTHROPIC_API_KEY')
        if not api_key:
            return "AI summary not available - ANTHROPIC_API_KEY not set"

        # Prepare metrics summary for Claude
        metrics_text = f"""
Stage: {stage}

Timing Metrics:
- Setup WNS: {metrics.get('internal_timing_r2r_wns', 'N/A')} ns
- Setup TNS: {metrics.get('internal_timing_r2r_tns', 'N/A')} ns
- Setup Violations: {metrics.get('internal_timing_r2r_nvp', 'N/A')}
- Hold WNS: {metrics.get('hold_wns', 'N/A')} ns
- Hold TNS: {metrics.get('hold_tns', 'N/A')} ns
- Hold Violations: {metrics.get('hold_nvp', 'N/A')}

Design Rules:
- Max Tran Violations: {metrics.get('max_tran_nvp', 'N/A')}
- Max Cap Violations: {metrics.get('max_cap_nvp', 'N/A')}

Physical:
- Area: {metrics.get('area', 'N/A')} um²
- Utilization: {metrics.get('utilization', 'N/A')}%
- Instance Count: {metrics.get('inst_count', 'N/A')}
- DRC Violations: {metrics.get('drc_violations', 'N/A')}

Quality:
- Errors: {metrics.get('log_errors', 0)}
- Warnings: {metrics.get('log_warnings', 0)}
- Status: {metrics.get('run_status', 'unknown')}
"""

        # Call Claude API
        client = anthropic.Anthropic(api_key=api_key)

        message = client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=200,
            messages=[{
                "role": "user",
                "content": f"Analyze these ASIC design metrics and provide a brief 1-2 sentence summary with key issues and suggestions:\n\n{metrics_text}"
            }]
        )

        summary = message.content[0].text.strip()
        return summary

    except Exception as e:
        print(f"[WARN] Could not generate AI summary: {e}")
        return f"AI summary generation failed: {str(e)}"


# ==============================================================================
# CSV/JSON EXPORT FUNCTIONS
# ==============================================================================

def format_csv_row(metrics):
    """Format metrics into CSV row matching dashboard format"""

    # Helper function to format WNS/NVP
    def fmt_wns_nvp(wns, nvp):
        # Handle "N/A" strings and None values
        if wns == "N/A" or wns is None:
            wns = None
        if nvp == "N/A" or nvp is None:
            nvp = None

        if wns is not None and nvp is not None:
            return f"{wns:.3f}/{nvp}"
        elif wns is not None:
            return f"{wns:.3f}/N/A"
        elif nvp is not None:
            return f"N/A/{nvp}"
        else:
            return "N/A"

    # Helper to format single value
    def fmt_val(val, decimals=3):
        # Handle "N/A" strings and None values
        if val == "N/A" or val is None:
            return "N/A"
        if isinstance(val, (int, float)):
            if isinstance(val, float):
                return f"{val:.{decimals}f}"
            else:
                return str(val)
        return str(val)

    row = {
        'project': metrics.get('project', 'N/A'),
        'block_name': metrics.get('block_name', 'N/A'),
        'experiment': metrics.get('experiment', 'N/A'),
        'RTL_tag': metrics.get('rtl_tag', 'N/A'),
        'user_name': metrics.get('user_name', 'N/A'),
        'run_directory': metrics.get('run_directory', 'N/A'),
        'stage_directory': metrics.get('stage_directory', 'N/A'),
        'run_end_time': metrics.get('timestamp', 'N/A'),
        'stage': metrics.get('stage', 'N/A'),

        # Internal timing - R2R
        'internal_timing_r2r': fmt_wns_nvp(
            metrics.get('internal_timing_r2r_wns'),
            metrics.get('internal_timing_r2r_nvp')
        ),

        # Internal timing - custom path groups
        'internal_timing_custom': metrics.get('internal_timing_custom_groups', 'N/A'),

        # Interface timing
        'interface_timing_i2r': fmt_wns_nvp(
            metrics.get('interface_timing_i2r_wns'),
            metrics.get('interface_timing_i2r_nvp')
        ),
        'interface_timing_r2o': fmt_wns_nvp(
            metrics.get('interface_timing_r2o_wns'),
            metrics.get('interface_timing_r2o_nvp')
        ),
        'interface_timing_i2o': fmt_wns_nvp(
            metrics.get('interface_timing_i2o_wns'),
            metrics.get('interface_timing_i2o_nvp')
        ),

        # Design rules
        'max_tran': fmt_wns_nvp(
            metrics.get('max_tran_wns'),
            metrics.get('max_tran_nvp')
        ),
        'max_cap': fmt_wns_nvp(
            metrics.get('max_cap_wns'),
            metrics.get('max_cap_nvp')
        ),

        # Noise
        'noise': fmt_val(metrics.get('noise_violations'), 0),

        # MPW/min period/double switching
        'mpw_min_period_double_switching': f"{fmt_val(metrics.get('min_period'))}/{fmt_val(metrics.get('double_switching'), 0)}",

        # Congestion/DRC
        'congestion_drc_metrics': fmt_val(metrics.get('drc_violations'), 0),

        # Area
        'area': fmt_val(metrics.get('area'), 2),
        'inst_count': fmt_val(metrics.get('inst_count'), 0),
        'utilization': fmt_val(metrics.get('utilization'), 2),

        # Logs
        'logs_errors_warnings': f"E:{metrics.get('log_errors', 0)} W:{metrics.get('log_warnings', 0)}",

        # Status
        'run_status': metrics.get('run_status', 'N/A'),
        'runtime': metrics.get('runtime', 'N/A'),
        'memory_usage': metrics.get('memory_usage', 'N/A'),

        # AI summary
        'ai_summary': metrics.get('ai_summary', ''),

        # Sign-off metrics
        'ir_static': fmt_val(metrics.get('ir_static')),
        'em_power': fmt_val(metrics.get('em_power')),
        'em_signal': fmt_val(metrics.get('em_signal')),
        'pv_drc_base': fmt_val(metrics.get('pv_drc_base'), 0),
        'pv_drc_metal': fmt_val(metrics.get('pv_drc_metal'), 0),
        'pv_drc_antenna': fmt_val(metrics.get('pv_drc_antenna'), 0),
        'lvs': metrics.get('lvs', 'N/A'),
        'lec': metrics.get('lec', 'N/A')
    }

    return row


def export_to_csv(all_metrics, csv_file):
    """Export metrics to CSV file"""
    import csv

    try:
        # CSV column headers matching dashboard format
        fieldnames = [
            'project', 'block_name', 'experiment', 'RTL_tag', 'user_name',
            'run_directory', 'stage_directory', 'run_end_time', 'stage',
            'internal_timing_r2r', 'internal_timing_custom',
            'interface_timing_i2r', 'interface_timing_r2o', 'interface_timing_i2o',
            'max_tran', 'max_cap', 'noise',
            'mpw_min_period_double_switching', 'congestion_drc_metrics',
            'area', 'inst_count', 'utilization',
            'logs_errors_warnings', 'run_status', 'runtime', 'memory_usage',
            'ai_summary', 'ir_static', 'em_power', 'em_signal',
            'pv_drc_base', 'pv_drc_metal', 'pv_drc_antenna', 'lvs', 'lec'
        ]

        with open(csv_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()

            # Write each stage as a row
            for stage_name, stage_metrics in all_metrics.get('stages', {}).items():
                row = format_csv_row(stage_metrics)
                writer.writerow(row)

        print(f"[INFO] CSV exported to: {csv_file}")
        return True

    except Exception as e:
        print(f"[ERROR] Failed to export CSV: {e}")
        import traceback
        traceback.print_exc()
        return False


def export_to_json(all_metrics, json_file):
    """Export metrics to JSON file"""
    try:
        with open(json_file, 'w') as f:
            json.dump(all_metrics, f, indent=2)

        print(f"[INFO] JSON exported to: {json_file}")
        return True

    except Exception as e:
        print(f"[ERROR] Failed to export JSON: {e}")
        import traceback
        traceback.print_exc()
        return False
