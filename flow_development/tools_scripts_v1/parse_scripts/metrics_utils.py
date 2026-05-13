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
def parse_timing_and_drvs(reports_dir, analysis_type='setup'):
    """
    Parses both path groups and DRV violations from report files in one pass.
    Assumes all timing values are in nanoseconds (ns).
    """
    results = {
        'path_groups': {},
        'drvs': {}
    }
    def parse_value(value_str):
        """Helper to convert timing strings to floats or N/A."""
        if value_str in ["N/A", "No paths"] or value_str is None:
            return "N/A"
        try:
            return float(value_str)
        except (ValueError, TypeError):
            return "N/A"

    # Define files based on analysis type
    if analysis_type == 'setup':
        report_files = [
            reports_dir / "timing_summary.rpt",
            reports_dir / "setup.analysis_summary.rpt",
            reports_dir / "report_qor.rpt"
        ]
    else: # hold
        report_files = [reports_dir / "hold.analysis_summary.rpt"]
    # Shared patterns
    genus_view_pattern = r'View:\s+ALL\s+([-\d.]+|\s+N/A)\s+([-\d.]+|\s+N/A)\s+(\d+)'
    innovus_view_pattern = r'View\s*:\s*ALL\s+([-\d.]+|\s+N/A)\s+([-\d.]+|\s+N/A)\s+(\d+)'
    group_pattern = r'Group\s*:\s*(\w+)\s+([-\d.]+|\s+N/A|No paths)\s+([-\d.]+|\s+N/A)\s+(\d+)'
    drv_pattern = r'(?:Check\s*:)?\s*(max_transition|min_transition|max_capacitance|min_capacitance|max_fanout|min_fanout)\s+([-\d.]+|\s+N/A)\s+([-\d.]+|\s+N/A)\s+(\d+)'
    for report_file in report_files:
        if not report_file.exists():
            continue

        try:
            content = report_file.read_text()
            if len(content.strip()) < 10:
                continue

            # --- PART 1: TIMING PATH GROUPS ---
            # Check for the main 'ALL' view (Genus or Innovus style)
            view_match = re.search(genus_view_pattern, content) or re.search(innovus_view_pattern, content)
            if view_match:
                results['path_groups']['all'] = {
                    'wns': parse_value(view_match.group(1).strip()),
                    'tns': parse_value(view_match.group(2).strip()),
                    'nvp': int(view_match.group(3).strip()) if view_match.group(3).strip() != "N/A" else "N/A"
                }

                # Parse specific groups
                for g_match in re.finditer(group_pattern, content):
                    name = g_match.group(1).strip()
                    results['path_groups'][name] = {
                        'wns': parse_value(g_match.group(2).strip()),
                        'tns': parse_value(g_match.group(3).strip()),
                        'nvp': int(g_match.group(4).strip()) if g_match.group(4).strip() != "N/A" else "N/A"
                    }

            # --- PART 2: DRV VIOLATIONS ---
            for d_match in re.finditer(drv_pattern, content, re.IGNORECASE):
                check_type = d_match.group(1).strip().lower().replace(' ', '_')
                wns_str = d_match.group(2).strip()
                tns_str = d_match.group(3).strip()
                fep_str = d_match.group(4).strip()

                if fep_str == "0":
                    results['drvs'][check_type] = {'wns': 0.0, 'nvp': 0, 'tns': 0.0}
                else:
                    results['drvs'][check_type] = {
                        'wns': parse_value(wns_str),
                        'tns': parse_value(tns_str),
                        'nvp': int(fep_str) if fep_str != "N/A" else "N/A"
                    }

            # If any data was found, we are done with this stage
            if results['path_groups'] or results['drvs']:
                break

        except Exception as e:
            print(f"[WARN] Error parsing {report_file.name}: {e}")

    return results

#Added for scen view
def parse_path_scenarios(reports_dir, analysis_type='setup'):
    """
    Parses hierarchical timing reports into a multi-view dictionary.
    """
    results = {}

    def parse_value(value_str):
        if value_str in ["N/A", "No paths"] or value_str is None:
            return "N/A"
        try:
            return float(value_str)
        except (ValueError, TypeError):
            return "N/A"

    # Set file based on analysis type
    if analysis_type == 'setup':
        report_files = [reports_dir / "setup.view_summary.rpt"]
    else:
        report_files = [reports_dir / "hold.view_summary.rpt"]

    # Regex patterns for View and Group levels
    view_pattern = r'^\s*View\s*:\s*(\w+)\s+([-\d.]+|N/A)\s+([-\d.]+|N/A)\s+(\d+)'
    group_pattern = r'^\s*Group\s*:\s*(\w+)\s+([-\d.]+|N/A|No paths)\s+([-\d.]+|N/A)\s+(\d+)'
    for report_file in report_files:
        if not report_file.exists():
            continue

        try:
            content = report_file.read_text()
            # Split content by "View :" to handle scenario blocks 
            view_sections = re.split(r'\n(?=\s*View\s*:)', content) 
            for section in view_sections:
                view_match = re.search(view_pattern, section, re.MULTILINE)
                if view_match:
                    view_name = view_match.group(1).strip()
                    results[view_name] = {
                        'summary': {
                            'wns': parse_value(view_match.group(2).strip()),
                            'tns': parse_value(view_match.group(3).strip()),
                            'nvp': int(view_match.group(4).strip())
                        }
                    }

                    # Parse all groups within this view [cite: 18, 62]
                    for g_match in re.finditer(group_pattern, section, re.MULTILINE):
                        g_name = g_match.group(1).strip()
                        results[view_name][g_name] = {
                            'wns': parse_value(g_match.group(2).strip()),
                            'tns': parse_value(g_match.group(3).strip()),
                            'nvp': int(g_match.group(4).strip())
                        }
            
            if results: break # Stop if data found in first file

        except Exception as e:
            print(f"[WARN] Error parsing {report_file.name}: {e}")

    return results


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

                

                if area_match:
                    break

        except Exception as e:
            print(f"[WARN] Error parsing area from {report_file.name}: {e}")

    return metrics



def parse_utilization(reports_dir):
    """Parse utilization metrics"""
    metrics = {'utilization': None}

    report_files = [ 
        reports_dir / "utilization.rpt" 
            ]

    for report_file in report_files:   
        if not report_file.exists():
            continue

    try:
        content = report_file.read_text()

        match = re.search(r'Core\s+Utilization\s*=\s*([\d.]+)', content, re.IGNORECASE) 
        if match:
            metrics['utilization'] = float(match.group(1))
        
    except Exception as e:
        print(f"[WARN] Error parsing utilization: {e}")

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
            viol_match = re.search(r'Total Violations\s*:\s*(\d+)', content, re.IGNORECASE)
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

            avg_match = re.search(r'total of (\d+)', content, re.IGNORECASE)
            if avg_match:
                metrics['metal_density_avg'] = float(avg_match.group(1))

            max_match = re.search(r'Windows\s*>\s*Max\.?\s*Density\s*=\s*(\d+)', content, re.IGNORECASE)
            if max_match:
                metrics['metal_density_max'] = float(max_match.group(1))

        except Exception as e:
            print(f"[WARN] Error parsing metal density: {e}")

    return metrics


def parse_congestion_hotspot(reports_dir):
    """Parse congestion hotspot """
    metrics = {'congestion_hotspot': None}

    report_files = [
        reports_dir / "report_congestion.rpt",     # Innovus
            ]

    for report_file in report_files:
        if not report_file.exists():
            continue 

        try:
            content = report_file.read_text()

            # Example patterns seen in Innovus reports:

            # 1) Hotspot count
            
            match = re.search(r'normalized total congestion hotspot area\s*=\s*([0-9]+(?:\.[0-9]+)?)', content, re.IGNORECASE)
            if match:
                metrics['congestion_hotspot'] = float(match.group(1))
                break    

            # 2) Max congestion (overflow or percentage)
            # Max Congestion : 1.35
            # Max Routing Congestion = 135%
            match = re.search(r'hotspot\s+score\s*\|\s*([0-9]+(?:\.[0-9]+)?)', content, re.IGNORECASE)
            if match:
                metrics['congestion_hotspot'] = float(match.group(1))
                break
                                              
        except Exception as e:
             print(f"[WARN] Error parsing congestion hotspot : {e}")
           

    return metrics



###DRC METRICS
def parse_drc_metrics(reports_dir):
    """Parse DRC results metrics"""
    metrics = {"pv_drc": None}

    report_file = reports_dir / "aes_cipher_top.summary" 
    if not report_file.exists():
        return metrics

    try:
        content = report_file.read_text()

        match = re.search(r"TOTAL\s+DRC\s+Results\s+Generated:\s+(\d+)", content, re.IGNORECASE)

        if match:
            metrics["pv_drc"] = int(match.group(1))

    except Exception as e:
        print(f"[WARN] Error parsing drc_metrics: {e}")

    return metrics

#pv_antenna
def parse_antenna_metrics(reports_dir):
    """Parse ANTENNA results metrics"""
    metrics = {"pv_antenna": None}

    report_file = reports_dir / "aes_cipher_top.summary" 
    if not report_file.exists():
        return metrics

    try:
        content = report_file.read_text()

        match = re.search(r"TOTAL\s+DRC\s+Results\s+Generated:\s+(\d+)", content, re.IGNORECASE)

        if match:
            metrics["pv_antenna"] = int(match.group(1))

    except Exception as e:
        print(f"[WARN] Error parsing antenna_metrics: {e}")

    return metrics

#pv_erc
def parse_erc_metrics(reports_dir):
    """Parse ERC results metrics"""
    metrics = {"pv_erc": None}

    report_file = reports_dir / "calibre_erc.sum" 
    if not report_file.exists():
        return metrics

    try:
        content = report_file.read_text()

        match = re.search(r"TOTAL\s+ERC\s+RuleCheck\s+Results\s+Generated:\s+(\d+)\s*\(\d+\)", content, re.IGNORECASE)

        if match:
            metrics["pv_erc"] = int(match.group(1))

    except Exception as e:
        print(f"[WARN] Error parsing erc_metrics: {e}")

    return metrics


#LVS
import re

def parse_lvs_metrics(reports_dir):
    """Parse LVS results: flag INCORRECT presence"""
    metrics = {"pv_lvs": None}

    report_file = reports_dir / "lvs.rep"
    if not report_file.exists():
        return metrics

    try:
        content = report_file.read_text()

        # Check if the word INCORRECT exists anywhere
        if re.search(r"\bINCORRECT\b", content, re.IGNORECASE):
            metrics["pv_lvs"] = "INCORRECT"
        else:
            metrics["pv_lvs"] = 0

    except Exception as e:
        print(f"[WARN] Error parsing lvs_metrics: {e}")

    return metrics

def parse_noise_metrics(reports_dir):
    """Parse noise analysis metrics"""
    metrics = {'noise_violations': None}

    noise_files = [ reports_dir / "aes_cipher_top_glitch.rpt_func_ssm40c_cw",
		   reports_dir / "reports/aes_cipher_top_glitch.rpt_func_ff125c_cb",
		   reports_dir / "reports/aes_cipher_top_glitch.rpt_func_ffm40c_cb",
		   reports_dir / "reports/aes_cipher_top_glitch.rpt_func_ss125c_rcw",
		   reports_dir / "reports/aes_cipher_top_glitch.rpt_func_tt25c_typ",
		   reports_dir / "reports/aes_cipher_top_glitch.rpt_func_ff125c_rcb",
		   reports_dir / "reports/aes_cipher_top_glitch.rpt_func_ss125c_cw"
		]
				
        
    total = 0
    found_any = False

    try:
        for rpt in noise_files:

            if not rpt.exists():
                continue

            content = rpt.read_text()

            match = re.search(
                r'Number of total problem noise nets\s*=\s*(\d+)',
                content,
                re.IGNORECASE
            )

            if match:
                total += int(match.group(1))
                found_any = True

    except Exception as e:
        print(f"[WARN] Error parsing noise metrics: {e}")

    if found_any:
        metrics['noise_violations'] = total

    return metrics
     

def parse_mpw_metrics(reports_dir):
    """Parse MPW report for min pulse width endpoint violations"""

    metrics = {'min_pulse_width': None, 'double_switching': None}

    report_file = reports_dir / "aes_cipher_top_min_pulse_width.rpt"

    if not report_file.exists():
        return metrics

    try:
        content = report_file.read_text()

        # ---- MIN PULSE WIDTH (endpoints) 4th column ----
        m = re.search(
            r'^\s*Check\s*:\s*min_pulse_width\s*\(endpoints\)\s+\S+\s+\S+\s+(\d+)\s*$',
            content,
            re.MULTILINE
        )

        metrics['min_pulse_width'] = int(m.group(1)) if m else 0


        # ---- DOUBLE SWITCHING ----
        dbl_clk_file = reports_dir / "aes_cipher_top_double_clocking.rpt"

        if dbl_clk_file.exists():
            dbl_content = dbl_clk_file.read_text()
            neg_slopes = re.findall(r'-\d+(?:\.\d+)?', dbl_content)
            metrics['double_switching'] = len(neg_slopes)
        else:
            metrics['double_switching'] = 0

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
        last_warning_count = None
        for log_file in log_files:
            try:
                content = log_file.read_text(errors='ignore') 

                # Count errors (case-insensitive)
                errors = len(re.findall(r"\b([1-9]\d*)\s*error\(s?\)", content, re.IGNORECASE))
                metrics['errors'] += errors

                # Count warnings
                warning_matches = re.findall(r"Message Summary:\s*([0-9]+)\s+warning", content, re.IGNORECASE)
                if warning_matches:
                   last_warning_count = int(warning_matches[-1])
                
                # Count critical issues
                critical = len(re.findall(r"\b([1-9]\d*)\s*(?:critical|severe)\b", content, re.IGNORECASE))
                metrics['critical'] += critical

            except Exception as e:
                print(f"[WARN] Could not read log file {log_file.name}: {e}")
        if last_warning_count is not None:
            metrics["warnings"] = last_warning_count
    
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
from pathlib import Path

def calculate_runtime_memory(stage_dir):
    """
    Parses runtime and memory usage for a stage in one pass.
    
    Priority 1: reports/session_memory_usage_runtime.rpt
    Priority 2: logs/*.log (Extracts 'real' time and 'mem' from Innovus, Calibre, or Quantus)
    
    Returns: (runtime_string, memory_string)
    """
    runtime = "N/A"
    memory = "N/A"
    
    try:
        # --- PRIORITY 1: Check session_memory_usage_runtime.rpt ---
        reports_dir = Path(stage_dir) / "reports"
        runtime_report = reports_dir / "session_memory_usage_runtime.rpt"

        if runtime_report.exists():
            content = runtime_report.read_text()
            
            # Parse Runtime (Seconds to HH:MM:SS)
            runtime_match = re.search(r'RUNTIME:\s*(\d+)', content)
            if runtime_match:
                rt_seconds = int(runtime_match.group(1))
                hours = rt_seconds // 3600
                minutes = (rt_seconds % 3600) // 60
                seconds = rt_seconds % 60
                runtime = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
            
            # Parse Memory Usage
            mem_match = re.search(r'Memory usage:\s*([^\n]+)', content)
            if mem_match:
                memory = mem_match.group(1).strip()
            
            if runtime != "N/A" and memory != "N/A":
                return runtime, memory

        # --- PRIORITY 2: Check log files ---
        logs_dir = Path(stage_dir) / "logs"
        log_files = list(logs_dir.glob("*.log"))
        if not log_files:
            return runtime, memory

        log_file = log_files[0]
        log_content = log_file.read_text()

        # 1. Innovus: real=0:13:47, mem=4800.1M
        innovus_matches = re.findall(r'real=(\d+:\d+:\d+),\s+mem=([^)\s]+)', log_content)
        if innovus_matches:
            runtime, memory = innovus_matches[-1]
            return runtime, memory

        # 2. Quantus: clock time and Max (Total) memory used
        # Format: Run duration: 00:00:44 CPU time, 00:00:54 clock time
        # Format: Max (Total) memory used: 952 MB
        quantus_rt = re.search(r'Run duration:.*?,\s*(\d+:\d+:\d+)\s*clock time', log_content)
        quantus_mem = re.search(r'Max \(Total\) memory used:\s*([\d.]+\s*\w+)', log_content)
        
        if quantus_rt or quantus_mem:
            if quantus_rt:
                runtime = quantus_rt.group(1)
            if quantus_mem:
                memory = quantus_mem.group(1).strip()
            return runtime, memory

        # 3. Calibre/PV: REAL TIME = 6
        pv_matches = re.findall(r'.*?TOTAL CPU TIME\s*=\s*\d+.*?REAL TIME\s*=\s*(\d+)', log_content)
        if pv_matches:
            rt_seconds = int(pv_matches[-1])
            hours = rt_seconds // 3600
            minutes = (rt_seconds % 3600) // 60
            seconds = rt_seconds % 60
            runtime = f"{hours:02d}:{minutes:02d}:{seconds:02d}"

    except Exception as e:
        print(f"[WARN] Error parsing stage metrics: {e}")
    
    return runtime, memory
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
