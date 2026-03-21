# Metrics Collection Scripts - Working Method

## Quick Overview

**Two Python files work together:**
1. **collect_metrics.py** - Main script (orchestrator)
2. **metrics_utils.py** - Parsing library (utilities)

**Input:** EDA tool reports (Genus/Innovus)
**Output:** JSON + CSV files for dashboard

---

## Detailed Working Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: USER RUNS COMMAND                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  $ python3 collect_metrics.py \                                 │
│      --stage syn \                                              │
│      --stage-dir /path/to/run1/syn \                            │
│      --run-dir /path/to/run1 \                                  │
│      --runtag run1 \                                            │
│      --block-name aes_cipher_top                                │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: PARSE ARGUMENTS & INITIALIZE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  collect_metrics.py (main):                                     │
│    1. Parse command-line arguments                              │
│    2. Create MetricsCollector instance                          │
│    3. Store paths:                                              │
│       - stage_dir = /path/to/run1/syn                           │
│       - run_dir = /path/to/run1                                 │
│       - stage = "syn"                                           │
│    4. Load existing metrics JSON (if exists)                    │
│       - Allows incremental collection                           │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: LOOKUP STAGE CONFIGURATION                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STAGE_CONFIG['syn'] = {                                        │
│    'reports_subdir': 'reports',                                 │
│    'logs_subdir': 'logs',                                       │
│    'parsers': [                                                 │
│      'setup_timing',      ← Will call this parser               │
│      'drv_violations',    ← Will call this parser               │
│      'area',              ← Will call this parser               │
│      'instance_count'     ← Will call this parser               │
│    ]                                                            │
│  }                                                              │
│                                                                  │
│  → Determines which parsers to run for this stage               │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: INITIALIZE METRICS WITH "N/A" DEFAULTS                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  stage_metrics = {                                              │
│    'stage': 'syn',                                              │
│    'timestamp': '2025-12-23 10:00:00',                          │
│    'project': 'project1',                                       │
│    'block_name': 'aes_cipher_top',                              │
│    'run_directory': '/path/to/run1',                            │
│    'stage_directory': '/path/to/run1/syn',                      │
│                                                                  │
│    'internal_timing_r2r_wns': "N/A",  ← Default                 │
│    'internal_timing_r2r_tns': "N/A",  ← Default                 │
│    'internal_timing_r2r_nvp': "N/A",  ← Default                 │
│    'interface_timing_i2r_wns': "N/A",                           │
│    'interface_timing_r2o_wns': "N/A",                           │
│    'hold_wns': "N/A",                                           │
│    'max_tran_wns': "N/A",                                       │
│    'max_cap_wns': "N/A",                                        │
│    'area': "N/A",                                               │
│    'inst_count': "N/A",                                         │
│    'drc_violations': "N/A",                                     │
│    'ir_static': "N/A",                                          │
│    'em_power': "N/A",                                           │
│    'em_signal': "N/A",                                          │
│    'pv_drc_base': "N/A",                                        │
│    'lvs': "N/A",                                                │
│    'lec': "N/A",                                                │
│    ... (all 40+ fields initialized)                            │
│  }                                                              │
│                                                                  │
│  → Ensures ALL fields exist with default "N/A"                  │
│  → No NULL values will appear in output                         │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 5: RUN PARSERS (Loop through configured parsers)           │
└─────────────────────────────────────────────────────────────────┘
                             │
         ┌───────────────────┼───────────────────┬────────────────┐
         │                   │                   │                │
         ▼                   ▼                   ▼                ▼
    ┌─────────┐        ┌─────────┐        ┌─────────┐      ┌─────────┐
    │ Parser  │        │ Parser  │        │ Parser  │      │ Parser  │
    │   #1    │        │   #2    │        │   #3    │      │   #4    │
    └─────────┘        └─────────┘        └─────────┘      └─────────┘

┌─────────────────────────────────────────────────────────────────┐
│ PARSER #1: setup_timing                                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Call: path_groups = utils.parse_timing_path_groups(            │
│            reports_dir, 'setup')                                │
│                                                                  │
│  metrics_utils.py executes:                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. Check for report files:                                │  │
│  │    - timing_summary.rpt (Genus)                           │  │
│  │    - setup.analysis_summary.rpt (Innovus)                 │  │
│  │    - report_qor.rpt (Genus)                               │  │
│  │                                                            │  │
│  │ 2. Read file content                                      │  │
│  │                                                            │  │
│  │ 3. Parse using regex:                                     │  │
│  │    View:   ALL     7420.8    0.0      0                   │  │
│  │    Group:  clk     7420.8    0.0      0                   │  │
│  │    Group:  in2reg  N/A       N/A      0                   │  │
│  │                                                            │  │
│  │ 4. Extract ALL path groups:                               │  │
│  │    {                                                       │  │
│  │      'all': {'wns': 7420.8, 'tns': 0.0, 'nvp': 0},       │  │
│  │      'clk': {'wns': 7420.8, 'tns': 0.0, 'nvp': 0},       │  │
│  │      'in2reg': {'wns': "N/A", 'tns': "N/A", 'nvp': 0},   │  │
│  │      'reg2out': {'wns': "N/A", 'tns': "N/A", 'nvp': 0}   │  │
│  │    }                                                       │  │
│  │                                                            │  │
│  │ 5. Return dictionary to caller                            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Back in collect_metrics.py:                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. Extract specific path groups:                          │  │
│  │                                                            │  │
│  │    if 'reg2reg' in path_groups:                           │  │
│  │      update_if_valid('internal_timing_r2r_wns',           │  │
│  │                      path_groups['reg2reg']['wns'])       │  │
│  │                                                            │  │
│  │    if 'in2reg' in path_groups:                            │  │
│  │      update_if_valid('interface_timing_i2r_wns',          │  │
│  │                      path_groups['in2reg']['wns'])        │  │
│  │                                                            │  │
│  │ 2. update_if_valid() checks:                              │  │
│  │    - If value is not None AND not "N/A"                   │  │
│  │    - Then: stage_metrics[key] = value                     │  │
│  │    - Else: Keep "N/A" default                             │  │
│  │                                                            │  │
│  │ 3. Result:                                                 │  │
│  │    stage_metrics['internal_timing_r2r_wns'] = 7420.8      │  │
│  │    stage_metrics['interface_timing_i2r_wns'] = "N/A"      │  │
│  │                                      ^^^                   │  │
│  │                                      Stays as "N/A"        │  │
│  │                                      because parser        │  │
│  │                                      returned "N/A"        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ PARSER #2: drv_violations                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Call: drv = utils.parse_drv_violations(reports_dir)            │
│                                                                  │
│  metrics_utils.py executes:                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. Read timing_summary.rpt                                │  │
│  │                                                            │  │
│  │ 2. Find DRV section:                                      │  │
│  │    Check : max_transition     N/A      N/A      0         │  │
│  │    Check : max_capacitance  -15.0    -45.0      3         │  │
│  │    Check : max_fanout         N/A      N/A      0         │  │
│  │                                                            │  │
│  │ 3. Parse and return:                                      │  │
│  │    {                                                       │  │
│  │      'max_transition': {                                  │  │
│  │        'wns': "N/A", 'tns': "N/A", 'nvp': 0              │  │
│  │      },                                                    │  │
│  │      'max_capacitance': {                                 │  │
│  │        'wns': -15.0, 'tns': -45.0, 'nvp': 3              │  │
│  │      }                                                     │  │
│  │    }                                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Back in collect_metrics.py:                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Update metrics:                                            │  │
│  │   stage_metrics['max_tran_wns'] = "N/A"  (stays default)  │  │
│  │   stage_metrics['max_tran_nvp'] = 0                       │  │
│  │   stage_metrics['max_cap_wns'] = -15.0   (updated!)       │  │
│  │   stage_metrics['max_cap_nvp'] = 3       (updated!)       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ PARSER #3: area                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Call: result = utils.parse_area(reports_dir)                   │
│                                                                  │
│  metrics_utils.py executes:                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. Read report_qor.rpt                                    │  │
│  │                                                            │  │
│  │ 2. Search for:                                            │  │
│  │    Total Cell Area (Cell+Physical)    6303.150            │  │
│  │                                                            │  │
│  │ 3. Return:                                                 │  │
│  │    {'total_area': 6303.15, 'utilization': None}           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Back in collect_metrics.py:                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Update metrics:                                            │  │
│  │   if total_area is not None:                              │  │
│  │     stage_metrics['area'] = 6303.15                       │  │
│  │   if utilization is not None:                             │  │
│  │     stage_metrics['utilization'] = ... (stays "N/A")      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ PARSER #4: instance_count                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Call: result = utils.parse_instance_count(reports_dir)         │
│                                                                  │
│  metrics_utils.py executes:                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. Read report_qor.rpt                                    │  │
│  │                                                            │  │
│  │ 2. Search for:                                            │  │
│  │    Leaf Instance Count             9846                   │  │
│  │                                                            │  │
│  │ 3. Return:                                                 │  │
│  │    {'inst_count': 9846}                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Back in collect_metrics.py:                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Update metrics:                                            │  │
│  │   stage_metrics['inst_count'] = 9846                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 6: PARSE LOG FILES                                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Call: log_metrics = utils.parse_log_errors_warnings(logs_dir)  │
│                                                                  │
│  metrics_utils.py executes:                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. Find all *.log* files in logs/ directory              │  │
│  │                                                            │  │
│  │ 2. For each log file:                                     │  │
│  │    - Count: \bERROR\b, \bFATAL\b, \bFAILED\b             │  │
│  │    - Count: \bWARN(ING)?\b                                │  │
│  │    - Count: \bCRITICAL\b, \bSEVERE\b                      │  │
│  │                                                            │  │
│  │ 3. Return total counts:                                   │  │
│  │    {'errors': 0, 'warnings': 71, 'critical': 0}           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  stage_metrics['log_errors'] = 0                                │
│  stage_metrics['log_warnings'] = 71                             │
│  stage_metrics['log_critical'] = 0                              │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 7: CALCULATE RUNTIME                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Call: runtime = utils.calculate_runtime(stage_dir)             │
│                                                                  │
│  metrics_utils.py executes:                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. Find first and last log files (by timestamp)          │  │
│  │                                                            │  │
│  │ 2. Get modification times:                                │  │
│  │    start_time = first_log.stat().st_mtime                 │  │
│  │    end_time = last_log.stat().st_mtime                    │  │
│  │                                                            │  │
│  │ 3. Calculate difference and format:                       │  │
│  │    runtime_seconds = end_time - start_time                │  │
│  │    Format as "HH:MM:SS"                                   │  │
│  │                                                            │  │
│  │ 4. Return: "00:15:32" (example)                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  stage_metrics['runtime'] = "00:15:32"                          │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 8: DETERMINE RUN STATUS                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Call: status = utils.determine_run_status(stage_metrics)       │
│                                                                  │
│  metrics_utils.py executes:                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Decision tree:                                            │  │
│  │                                                            │  │
│  │ if errors > 0:                                            │  │
│  │   return 'fail'                                           │  │
│  │                                                            │  │
│  │ if setup_wns < -0.5 or hold_wns < -0.5:                  │  │
│  │   return 'fail'                                           │  │
│  │                                                            │  │
│  │ if drc_violations > 100:                                  │  │
│  │   return 'fail'                                           │  │
│  │                                                            │  │
│  │ if warnings > 50:                                         │  │
│  │   return 'continue_with_error'                            │  │
│  │                                                            │  │
│  │ if setup_wns < 0 or hold_wns < 0:                        │  │
│  │   return 'continue_with_error'                            │  │
│  │                                                            │  │
│  │ return 'pass'                                             │  │
│  │                                                            │  │
│  │ Note: Handles "N/A" values safely using get_numeric()    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  In our example:                                                │
│    errors = 0 ✓                                                 │
│    setup_wns = 7420.8 (positive) ✓                             │
│    warnings = 71 (> 50) → return 'continue_with_error'         │
│                                                                  │
│  stage_metrics['run_status'] = "continue_with_error"            │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 9: FINAL METRICS STRUCTURE                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  stage_metrics = {                                              │
│    'stage': 'syn',                                              │
│    'timestamp': '2025-12-23 10:15:32',                          │
│    'project': 'project1',                                       │
│    'block_name': 'aes_cipher_top',                              │
│    'run_directory': '/path/to/run1',                            │
│    'stage_directory': '/path/to/run1/syn',                      │
│                                                                  │
│    'internal_timing_r2r_wns': 7420.8,       ← Updated           │
│    'internal_timing_r2r_tns': 0.0,          ← Updated           │
│    'internal_timing_r2r_nvp': 0,            ← Updated           │
│    'interface_timing_i2r_wns': "N/A",       ← Stayed default    │
│    'interface_timing_r2o_wns': "N/A",       ← Stayed default    │
│    'hold_wns': "N/A",                       ← Stayed default    │
│    'max_tran_wns': "N/A",                   ← Stayed default    │
│    'max_cap_wns': -15.0,                    ← Updated           │
│    'max_cap_nvp': 3,                        ← Updated           │
│    'area': 6303.15,                         ← Updated           │
│    'inst_count': 9846,                      ← Updated           │
│    'drc_violations': "N/A",                 ← Stayed default    │
│    'log_errors': 0,                         ← Updated           │
│    'log_warnings': 71,                      ← Updated           │
│    'runtime': "00:15:32",                   ← Updated           │
│    'run_status': "continue_with_error",     ← Updated           │
│    'ir_static': "N/A",                      ← Stayed default    │
│    'em_power': "N/A",                       ← Stayed default    │
│    'lvs': "N/A",                            ← Stayed default    │
│    'lec': "N/A",                            ← Stayed default    │
│    ...                                                           │
│  }                                                              │
│                                                                  │
│  KEY OBSERVATION: No NULL values - all have valid data or "N/A" │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 10: ADD TO OVERALL METRICS                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  self.all_metrics['stages'][self.stage] = stage_metrics         │
│                                                                  │
│  Overall structure:                                             │
│  {                                                              │
│    "project": "project1",                                       │
│    "block_name": "aes_cipher_top",                              │
│    "experiment": "run1",                                        │
│    "rtl_tag": "v1",                                             │
│    "run_directory": "/path/to/run1",                            │
│    "stages": {                                                  │
│      "syn": { ... stage_metrics ... }   ← Just added            │
│    },                                                           │
│    "last_updated": "2025-12-23 10:15:32"                        │
│  }                                                              │
│                                                                  │
│  Note: If JSON already has other stages (place, route),         │
│        they are preserved. This enables incremental collection. │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 11: EXPORT TO JSON                                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Call: utils.export_to_json(all_metrics, json_file)             │
│                                                                  │
│  metrics_utils.py executes:                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ with open(json_file, 'w') as f:                           │  │
│  │   json.dump(all_metrics, f, indent=2)                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Output: run1_metrics.json                                      │
│                                                                  │
│  {                                                              │
│    "project": "project1",                                       │
│    "block_name": "aes_cipher_top",                              │
│    "experiment": "run1",                                        │
│    "stages": {                                                  │
│      "syn": {                                                   │
│        "stage": "syn",                                          │
│        "internal_timing_r2r_wns": 7420.8,                       │
│        "area": 6303.15,                                         │
│        ...                                                      │
│      }                                                          │
│    }                                                            │
│  }                                                              │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 12: EXPORT TO CSV                                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Call: utils.export_to_csv(all_metrics, csv_file)               │
│                                                                  │
│  metrics_utils.py executes:                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ For each stage in all_metrics['stages']:                 │  │
│  │                                                            │  │
│  │   1. Call format_csv_row(stage_metrics)                  │  │
│  │      Converts to flat dictionary:                         │  │
│  │      {                                                     │  │
│  │        'project': 'project1',                             │  │
│  │        'block_name': 'aes_cipher_top',                    │  │
│  │        'internal_timing_r2r': '7420.800/0',  ← Combined!  │  │
│  │        'interface_timing_i2r': 'N/A',                     │  │
│  │        'max_cap': '-15.000/3',               ← Combined!  │  │
│  │        'area': '6303.15',                                 │  │
│  │        'ir_static': 'N/A',                                │  │
│  │        'em_power': 'N/A',                                 │  │
│  │        'lvs': 'N/A',                                      │  │
│  │        ...                                                 │  │
│  │      }                                                     │  │
│  │                                                            │  │
│  │   2. Write as CSV row                                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Output: run1_metrics.csv                                       │
│                                                                  │
│  project,block_name,...,internal_timing_r2r,...,lvs,lec         │
│  project1,aes_cipher_top,...,7420.800/0,...,N/A,N/A             │
│                                                                  │
│  Format notes:                                                  │
│  - WNS/NVP combined: "7420.800/0"                               │
│  - Missing values: "N/A" (never NULL or empty)                  │
│  - 34 columns total                                             │
│                                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 13: COMPLETION                                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Script outputs:                                                │
│                                                                  │
│  ============================================================   │
│  Metrics Summary for syn:                                       │
│  ============================================================   │
│    Setup WNS: 7420.8 ns                                         │
│    Hold WNS:  N/A ns                                            │
│    Area:      6303.15 um²                                       │
│    Inst Count:9846                                              │
│    DRC Viols: N/A                                               │
│    Status:    continue_with_error                               │
│  ============================================================   │
│                                                                  │
│  [INFO] JSON exported to: /path/to/run1_metrics.json            │
│  [INFO] CSV exported to: /path/to/run1_metrics.csv              │
│                                                                  │
│  ============================================================   │
│  Metrics Collection Complete!                                   │
│  ============================================================   │
│                                                                  │
│  Exit code: 0 (success)                                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

```

---

## Key Design Principles

### 1. "N/A" Default Strategy
```
Problem: Missing metrics → NULL in JSON → Dashboard errors

Solution: Initialize ALL fields with "N/A"
         Only update if parser returns valid value
         Never overwrite "N/A" with None/NULL

Result: Clean output, no NULL values, dashboard-friendly
```

### 2. Single Consolidated Parsers
```
Old approach: parse_timing_r2r(), parse_timing_i2r(), parse_timing_r2o()
              → Multiple file reads, redundant code

New approach: parse_timing_path_groups() returns ALL path groups
              → Single file read, extract what you need

Benefits: Faster, more maintainable, comprehensive data
```

### 3. Incremental Collection
```
Run 1: Collect syn metrics  → Creates JSON with syn stage
Run 2: Collect place metrics → Adds place stage to existing JSON
Run 3: Collect route metrics → Adds route stage to existing JSON

Final JSON has all stages:
{
  "stages": {
    "syn": { ... },
    "place": { ... },
    "route": { ... }
  }
}

CSV has 3 rows (one per stage)
```

### 4. Safe Value Updates
```python
# Helper function prevents overwriting defaults with invalid values
def update_if_valid(key, value):
    if value is not None and value != "N/A":
        stage_metrics[key] = value
    # else: Keep existing "N/A" default

Examples:
  update_if_valid('wns', 7420.8)   → Updates to 7420.8
  update_if_valid('wns', None)     → Keeps "N/A"
  update_if_valid('wns', "N/A")    → Keeps "N/A"
```

---

## Data Transformation Examples

### Example 1: Timing Path Groups

**Report File (timing_summary.rpt):**
```
View:     ALL        7420.8      0.0       0
Group:    clk        7420.8      0.0       0
Group:    in2reg     N/A         N/A       0
Group:    reg2out    N/A         N/A       0
```

**After parse_timing_path_groups():**
```python
{
  'all': {'wns': 7420.8, 'tns': 0.0, 'nvp': 0},
  'clk': {'wns': 7420.8, 'tns': 0.0, 'nvp': 0},
  'in2reg': {'wns': "N/A", 'tns': "N/A", 'nvp': 0},
  'reg2out': {'wns': "N/A", 'tns': "N/A", 'nvp': 0}
}
```

**After collect_metrics extraction:**
```python
stage_metrics = {
  'internal_timing_r2r_wns': 7420.8,    # From 'clk' group
  'internal_timing_r2r_tns': 0.0,
  'internal_timing_r2r_nvp': 0,
  'interface_timing_i2r_wns': "N/A",    # From 'in2reg' group
  'interface_timing_r2o_wns': "N/A"     # From 'reg2out' group
}
```

**In CSV:**
```
internal_timing_r2r,interface_timing_i2r,interface_timing_r2o
7420.800/0,N/A,N/A
```

---

### Example 2: DRV Violations

**Report File (timing_summary.rpt):**
```
Check : max_transition        N/A       N/A       0
Check : max_capacitance    -15.000   -45.000      3
```

**After parse_drv_violations():**
```python
{
  'max_transition': {'wns': "N/A", 'tns': "N/A", 'nvp': 0},
  'max_capacitance': {'wns': -15.0, 'tns': -45.0, 'nvp': 3}
}
```

**After collect_metrics extraction:**
```python
stage_metrics = {
  'max_tran_wns': "N/A",
  'max_tran_nvp': 0,
  'max_cap_wns': -15.0,
  'max_cap_nvp': 3
}
```

**In CSV:**
```
max_tran,max_cap
N/A/0,-15.000/3
```

---

## Summary of Responsibilities

### collect_metrics.py Responsibilities:
1. ✅ Parse command-line arguments
2. ✅ Initialize metrics dictionary with "N/A" defaults
3. ✅ Determine which parsers to run (based on stage)
4. ✅ Call parser functions from metrics_utils.py
5. ✅ Extract specific metrics from parser results
6. ✅ Safely update metrics (only if valid values)
7. ✅ Aggregate metrics from multiple stages
8. ✅ Orchestrate export to JSON and CSV

### metrics_utils.py Responsibilities:
1. ✅ Read and parse EDA tool reports (Genus/Innovus)
2. ✅ Extract metrics using regex patterns
3. ✅ Return "N/A" for missing/invalid values
4. ✅ Parse log files for errors/warnings
5. ✅ Calculate runtime from timestamps
6. ✅ Determine run status based on metrics
7. ✅ Format data for CSV export
8. ✅ Write JSON and CSV files

---

## Engineer Quick Reference

**To collect metrics for a stage:**
```bash
python3 collect_metrics.py \
    --stage <stage_name> \
    --stage-dir <path/to/stage> \
    --run-dir <path/to/run> \
    --runtag <run_tag> \
    --block-name <block_name>
```

**What happens internally:**
1. Initializes all 40+ fields with "N/A"
2. Runs configured parsers for the stage
3. Updates fields with actual values (keeps "N/A" if not found)
4. Calculates runtime and status
5. Exports to JSON (hierarchical) and CSV (flat)

**Expected output:**
- JSON: `/path/to/run/<runtag>_metrics.json`
- CSV: `/path/to/run/<runtag>_metrics.csv`
- No NULL values anywhere
- All stages incrementally added to JSON
- CSV has one row per stage
