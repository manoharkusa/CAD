# Metrics Collection Scripts - Testing Guide

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [How the Scripts Work](#how-the-scripts-work)
3. [Testing Plan](#testing-plan)
4. [Common Issues and Troubleshooting](#common-issues-and-troubleshooting)

---

## Architecture Overview

### Component Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                    Design Flow (Genus/Innovus)               │
│                    Generates Reports & Logs                  │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  │ Reports: timing_summary.rpt, report_qor.rpt,
                  │          report_area.rpt, etc.
                  │ Logs: *.log files
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│              collect_metrics.py (Orchestrator)               │
│  • Reads stage configuration (syn, place, route, etc.)      │
│  • Calls appropriate parsers for each stage                 │
│  • Aggregates all metrics into single structure             │
│  • Generates JSON and CSV output                            │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  │ Calls parsing functions
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│              metrics_utils.py (Parser Library)               │
│  • parse_timing_path_groups() - All timing metrics          │
│  • parse_drv_violations() - DRV checks                      │
│  • parse_area() - Area and utilization                      │
│  • parse_instance_count() - Cell count                      │
│  • parse_congestion_drc() - DRC violations                  │
│  • format_csv_row() - CSV formatting                        │
│  • export_to_json() / export_to_csv() - File writers        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  │ Outputs
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│                    Output Files                              │
│  • <runtag>_metrics.json - Hierarchical data                │
│  • <runtag>_metrics.csv  - Flat table for dashboard         │
└─────────────────────────────────────────────────────────────┘
```

---

## How the Scripts Work

### 1. collect_metrics.py - Main Orchestrator

#### Purpose
Main entry point that orchestrates the entire metrics collection process.

#### Key Classes and Functions

**MetricsCollector Class:**
```python
class MetricsCollector:
    def __init__(self, args):
        # Stores configuration
        self.stage = args.stage           # e.g., 'syn', 'place', 'route'
        self.stage_dir = Path(args.stage_dir)  # e.g., /path/to/run1/syn
        self.run_dir = Path(args.run_dir)      # e.g., /path/to/run1
        self.runtag = args.runtag         # e.g., 'run1'
        self.block_name = args.block_name # e.g., 'aes_cipher_top'

    def collect_stage_metrics(self):
        # Main collection logic

    def save_metrics(self):
        # Export to JSON and CSV
```

#### Workflow Step-by-Step

**Step 1: Initialization**
```
User runs: python3 collect_metrics.py --stage syn --stage-dir ./run1/syn \
           --run-dir ./run1 --runtag run1 --block-name aes_cipher_top

Script:
1. Parses command-line arguments
2. Creates MetricsCollector instance
3. Loads existing metrics JSON if available (for incremental updates)
```

**Step 2: Stage Configuration Lookup**
```python
# STAGE_CONFIG dictionary maps stage names to parsers
STAGE_CONFIG = {
    'syn': {
        'name': 'Synthesis',
        'reports_subdir': 'reports',
        'logs_subdir': 'logs',
        'parsers': [
            'setup_timing',      # Parse setup timing
            'drv_violations',    # Parse DRV checks
            'area',              # Parse area metrics
            'instance_count',    # Parse cell count
        ]
    },
    'route': {
        'parsers': [
            'setup_timing',
            'hold_timing',       # Hold timing added for post-CTS stages
            'drv_violations',
            'congestion_drc',    # DRC violations added for routing stages
            'noise_metrics',     # Noise analysis
            ...
        ]
    }
}
```

**Step 3: Initialize ALL Metrics with "N/A" Defaults**
```python
stage_metrics = {
    # Metadata (always present)
    'stage': 'syn',
    'timestamp': '2025-12-23 10:00:00',
    'project': 'project1',
    'block_name': 'aes_cipher_top',
    'run_directory': '/path/to/run1',
    'stage_directory': '/path/to/run1/syn',

    # Timing metrics (default: "N/A")
    'internal_timing_r2r_wns': "N/A",
    'internal_timing_r2r_tns': "N/A",
    'internal_timing_r2r_nvp': "N/A",
    'interface_timing_i2r_wns': "N/A",
    # ... all other fields initialized to "N/A"

    # Sign-off metrics
    'ir_static': "N/A",
    'em_power': "N/A",
    'em_signal': "N/A",
    'pv_drc_base': "N/A",
    'pv_drc_metal': "N/A",
    'pv_drc_antenna': "N/A",
    'lvs': "N/A",
    'lec': "N/A",
}
```

**Step 4: Run Parsers and Update Metrics**
```python
for parser_name in config['parsers']:
    if parser_name == 'setup_timing':
        # Call parser
        path_groups = utils.parse_timing_path_groups(reports_dir, 'setup')

        # Extract metrics - ONLY UPDATE if value is valid (not None or "N/A")
        def update_if_valid(key, value):
            if value is not None and value != "N/A":
                stage_metrics[key] = value

        # Update R2R timing (internal)
        if 'reg2reg' in path_groups:
            update_if_valid('internal_timing_r2r_wns',
                          path_groups['reg2reg'].get('wns'))
            update_if_valid('internal_timing_r2r_tns',
                          path_groups['reg2reg'].get('tns'))
            update_if_valid('internal_timing_r2r_nvp',
                          path_groups['reg2reg'].get('nvp'))

        # Update I2R timing (interface)
        if 'in2reg' in path_groups:
            update_if_valid('interface_timing_i2r_wns',
                          path_groups['in2reg'].get('wns'))
            # ... etc
```

**Step 5: Parse Log Files**
```python
log_metrics = utils.parse_log_errors_warnings(logs_dir)
stage_metrics['log_errors'] = log_metrics['errors']
stage_metrics['log_warnings'] = log_metrics['warnings']
```

**Step 6: Calculate Runtime**
```python
# Uses log file timestamps to calculate runtime
stage_metrics['runtime'] = utils.calculate_runtime(stage_dir)
# Returns format: "HH:MM:SS"
```

**Step 7: Determine Run Status**
```python
stage_metrics['run_status'] = utils.determine_run_status(stage_metrics)
# Returns: 'pass', 'fail', or 'continue_with_error'
# Based on:
# - Errors > 0 → 'fail'
# - Setup/Hold WNS < -0.5ns → 'fail'
# - DRC violations > 100 → 'fail'
# - Warnings > 50 or minor timing violations → 'continue_with_error'
# - Otherwise → 'pass'
```

**Step 8: Save to Files**
```python
# Add stage metrics to overall structure
self.all_metrics['stages'][self.stage] = stage_metrics

# Export to JSON (hierarchical)
utils.export_to_json(self.all_metrics, json_file)

# Export to CSV (flat table)
utils.export_to_csv(self.all_metrics, csv_file)
```

---

### 2. metrics_utils.py - Parser Library

#### Purpose
Contains all parsing functions and utility functions for extracting metrics from EDA tool reports.

#### Key Parsing Functions

**A. parse_timing_path_groups(reports_dir, analysis_type='setup')**

**Purpose:** Parse ALL timing path groups from a single timing report

**Input:**
- `reports_dir`: Path to reports directory
- `analysis_type`: 'setup' or 'hold'

**Process:**
```python
1. Determine which report files to check:
   - setup: timing_summary.rpt, setup.analysis_summary.rpt, report_qor.rpt
   - hold: hold.analysis_summary.rpt

2. For each report file:
   a. Read file content

   b. Try Genus format parsing:
      View:     ALL    7420.8      0.0     0
      Group:    clk    7420.8      0.0     0
      Group:    in2reg  N/A        N/A     0

   c. Try Innovus format parsing:
      View :    ALL    6.379      0.0     0
      Group :   clk    6.379      0.0     0

   d. Extract ALL path groups into dictionary:
      {
        'all': {'wns': 7420.8, 'tns': 0.0, 'nvp': 0},
        'clk': {'wns': 7420.8, 'tns': 0.0, 'nvp': 0},
        'in2reg': {'wns': "N/A", 'tns': "N/A", 'nvp': 0},
        'reg2out': {'wns': "N/A", 'tns': "N/A", 'nvp': 0},
        ...
      }

   e. parse_value() helper:
      - Converts string to float if numeric
      - Returns "N/A" for invalid/missing values
      - Assumes all values are in NANOSECONDS (ns)
```

**Output:**
```python
{
    'all': {'wns': 7420.8, 'tns': 0.0, 'nvp': 0},
    'clk': {'wns': 7420.8, 'tns': 0.0, 'nvp': 0},
    'cg_enable_group_clk': {'wns': 8704.8, 'tns': 0.0, 'nvp': 0},
    'in2reg': {'wns': "N/A", 'tns': "N/A", 'nvp': 0},
    'reg2out': {'wns': "N/A", 'tns': "N/A", 'nvp': 0},
}
```

**Important Notes:**
- **Single function captures ALL path groups** (not separate functions for R2R, I2R, etc.)
- **Returns "N/A" for missing values** (never None/NULL)
- **Assumes nanoseconds** - ensure tools report in ns, not ps

---

**B. parse_drv_violations(reports_dir)**

**Purpose:** Parse design rule violation metrics

**Process:**
```python
1. Check report files:
   - timing_summary.rpt (Genus)
   - setup.analysis_summary.rpt (Innovus)
   - report_constraint.all_violators.rpt

2. Parse DRV section using regex:
   Check : max_transition        N/A       N/A     0
   Check : max_capacitance    -15.000   -45.000     3
   Check : max_fanout            N/A       N/A     0

3. Extract all DRV types:
   - max_transition
   - max_capacitance
   - max_fanout
   - min_transition
   - min_capacitance
   - min_fanout
```

**Output:**
```python
{
    'max_transition': {'wns': "N/A", 'tns': "N/A", 'nvp': 0},
    'max_capacitance': {'wns': -15.0, 'tns': -45.0, 'nvp': 3},
    'max_fanout': {'wns': "N/A", 'tns': "N/A", 'nvp': 0},
}
```

---

**C. parse_area(reports_dir)**

**Purpose:** Parse area and utilization metrics

**Process:**
```python
1. Check report files:
   - report_area.rpt (Genus)
   - area.summary.rpt (Innovus)
   - report_qor.rpt (Genus QoR)

2. Parse area:
   Genus report_qor.rpt:
     Total Cell Area (Cell+Physical)    6303.150

   Innovus area.summary.rpt:
     aes_cipher_top    9839    6301.134
                       ^^^^    ^^^^^^^^
                       cells   area
```

**Output:**
```python
{
    'total_area': 6303.15,
    'utilization': None  # if not found
}
```

---

**D. parse_congestion_drc(reports_dir)**

**Purpose:** Parse DRC violations from routing

**Process:**
```python
1. Parse route.drc.rpt:
   Total Violations : 4 Viols.

2. Parse route.metal_density.rpt:
   Average Density : 65.4
   Maximum Density : 89.2
```

**Output:**
```python
{
    'drc_violations': 4,
    'metal_density_avg': 65.4,
    'metal_density_max': 89.2
}
```

---

**E. parse_log_errors_warnings(logs_dir)**

**Purpose:** Count errors and warnings in log files

**Process:**
```python
1. Get all *.log* files in logs_dir

2. For each log file:
   - Count pattern: \bERROR\b, \bFATAL\b, \bFAILED\b
   - Count pattern: \bWARN(ING)?\b
   - Count pattern: \bCRITICAL\b, \bSEVERE\b

3. Sum counts across all log files
```

**Output:**
```python
{
    'errors': 0,
    'warnings': 71,
    'critical': 0
}
```

---

**F. format_csv_row(metrics)**

**Purpose:** Convert metrics dictionary to CSV row format

**Process:**
```python
1. Format WNS/NVP combinations:
   wns=7.421, nvp=0  →  "7.421/0"
   wns="N/A", nvp=0  →  "N/A/0"
   wns="N/A", nvp="N/A"  →  "N/A"

2. Format single values:
   - Floats: format with specified decimals
   - "N/A": keep as "N/A"
   - None: convert to "N/A"

3. Create row dictionary with all 34 CSV columns:
   {
     'project': 'project1',
     'block_name': 'aes_cipher_top',
     'internal_timing_r2r': '7.421/0',
     'interface_timing_i2r': 'N/A',
     'max_tran': 'N/A/0',
     ...
     'ir_static': 'N/A',
     'em_power': 'N/A',
     'em_signal': 'N/A',
     'pv_drc_base': 'N/A',
     'pv_drc_metal': 'N/A',
     'pv_drc_antenna': 'N/A',
     'lvs': 'N/A',
     'lec': 'N/A',
   }
```

---

### 3. Data Flow Example

**Scenario:** Engineer runs synthesis and wants to collect metrics

```bash
# Step 1: Run synthesis
cd /proj/aes_cipher_top/run1/syn
genus -f genus_syn.tcl

# Reports generated:
# - reports/timing_summary.rpt
# - reports/report_qor.rpt
# - reports/report_area.rpt
# - logs/genus_syn.log

# Step 2: Collect metrics
cd /proj/aes_cipher_top/run1
python3 collect_metrics.py \
    --stage syn \
    --stage-dir ./syn \
    --run-dir . \
    --runtag run1 \
    --block-name aes_cipher_top \
    --project myproject

# Step 3: Scripts execute
# collect_metrics.py:
#   1. Initializes stage_metrics with "N/A" for all fields
#   2. Calls parse_timing_path_groups() → reads timing_summary.rpt
#   3. Calls parse_drv_violations() → reads timing_summary.rpt
#   4. Calls parse_area() → reads report_qor.rpt
#   5. Calls parse_instance_count() → reads report_qor.rpt
#   6. Calls parse_log_errors_warnings() → reads logs/*.log
#   7. Calculates runtime from log timestamps
#   8. Determines run_status based on metrics
#   9. Exports to JSON and CSV

# Step 4: Output files created
# - run1_metrics.json (hierarchical structure)
# - run1_metrics.csv (flat table for dashboard)
```

**JSON Structure:**
```json
{
  "project": "myproject",
  "block_name": "aes_cipher_top",
  "experiment": "run1",
  "rtl_tag": "v1",
  "run_directory": "/proj/aes_cipher_top/run1",
  "stages": {
    "syn": {
      "stage": "syn",
      "timestamp": "2025-12-23 10:00:00",
      "stage_directory": "/proj/aes_cipher_top/run1/syn",
      "internal_timing_r2r_wns": 7420.8,
      "internal_timing_r2r_tns": 0.0,
      "internal_timing_r2r_nvp": 0,
      "interface_timing_i2r_wns": "N/A",
      ... (all metrics)
      "setup_path_groups": { ... },  // Raw parsed data
      "drv_violations": { ... }       // Raw parsed data
    }
  }
}
```

---

## Testing Plan

### Phase 1: Unit Testing (Per Stage)

**Objective:** Test each stage individually to ensure correct parsing

#### Test 1.1: Synthesis Stage (syn)

**Setup:**
```bash
# Navigate to test synthesis directory
cd /proj1/pd/users/testcase/Bharath/proj/flow28nm/aes_cipher_top/bronze_v1/run1

# Create test output directory
mkdir -p test_results/syn_test
```

**Execute:**
```bash
python3 ../../tool_scripts/parse_scripts/collect_metrics.py \
    --stage syn \
    --stage-dir ./syn \
    --run-dir ./test_results/syn_test \
    --runtag syn_test \
    --block-name aes_cipher_top \
    --project flow28nm \
    --rtl-tag bronze_v1
```

**Verification Checklist:**
- [ ] Script completes without errors
- [ ] JSON file created: `test_results/syn_test/syn_test_metrics.json`
- [ ] CSV file created: `test_results/syn_test/syn_test_metrics.csv`
- [ ] Check JSON has NO null values: `grep -i null syn_test_metrics.json`
- [ ] Verify timing metrics captured:
  ```bash
  cat syn_test_metrics.json | grep "internal_timing_r2r_wns"
  # Expected: numeric value (e.g., 7420.8) or "N/A"
  ```
- [ ] Verify area captured:
  ```bash
  cat syn_test_metrics.json | grep "area"
  # Expected: numeric value (e.g., 6303.15) or "N/A"
  ```
- [ ] Verify all required fields present:
  ```bash
  cat syn_test_metrics.json | grep -E "ir_static|em_power|em_signal|pv_drc_base|lvs|lec"
  # Expected: All fields present with "N/A"
  ```
- [ ] Verify stage_directory captured:
  ```bash
  cat syn_test_metrics.json | grep "stage_directory"
  # Expected: "/proj1/pd/users/testcase/Bharath/proj/flow28nm/.../syn"
  ```

**Expected Output Example:**
```json
{
  "stages": {
    "syn": {
      "stage": "syn",
      "internal_timing_r2r_wns": 7420.8,
      "area": 6303.15,
      "inst_count": 9846,
      "log_warnings": 71,
      "run_status": "continue_with_error"
    }
  }
}
```

---

#### Test 1.2: Placement Stage (place)

**Execute:**
```bash
python3 ../../tool_scripts/parse_scripts/collect_metrics.py \
    --stage place \
    --stage-dir ./pnr/place \
    --run-dir ./test_results/place_test \
    --runtag place_test \
    --block-name aes_cipher_top
```

**Verification Checklist:**
- [ ] Placement-specific metrics captured (setup timing, DRV violations)
- [ ] stage_directory points to place directory
- [ ] No hold timing expected (check hold_wns = "N/A")

---

#### Test 1.3: Route Stage (route)

**Execute:**
```bash
python3 ../../tool_scripts/parse_scripts/collect_metrics.py \
    --stage route \
    --stage-dir ./pnr/route \
    --run-dir ./test_results/route_test \
    --runtag route_test \
    --block-name aes_cipher_top
```

**Verification Checklist:**
- [ ] Setup AND hold timing captured
- [ ] DRC violations parsed (drc_violations field)
- [ ] Congestion metrics if available
- [ ] stage_directory points to route directory

---

### Phase 2: Incremental Testing (Multi-Stage)

**Objective:** Test incremental metric collection across multiple stages

**Setup:**
```bash
mkdir -p test_results/incremental
```

**Execute (Sequential):**
```bash
# Step 1: Collect syn metrics
python3 ../../tool_scripts/parse_scripts/collect_metrics.py \
    --stage syn \
    --stage-dir ./syn \
    --run-dir ./test_results/incremental \
    --runtag incremental \
    --block-name aes_cipher_top

# Step 2: Collect place metrics (should ADD to existing JSON)
python3 ../../tool_scripts/parse_scripts/collect_metrics.py \
    --stage place \
    --stage-dir ./pnr/place \
    --run-dir ./test_results/incremental \
    --runtag incremental \
    --block-name aes_cipher_top

# Step 3: Collect route metrics
python3 ../../tool_scripts/parse_scripts/collect_metrics.py \
    --stage route \
    --stage-dir ./pnr/route \
    --run-dir ./test_results/incremental \
    --runtag incremental \
    --block-name aes_cipher_top
```

**Verification Checklist:**
- [ ] JSON file has 3 stages: syn, place, route
  ```bash
  cat incremental_metrics.json | grep -c '"stage":'
  # Expected: 3
  ```
- [ ] Each stage has unique stage_directory
- [ ] CSV file has 3 rows (one per stage)
  ```bash
  wc -l incremental_metrics.csv
  # Expected: 4 (header + 3 data rows)
  ```
- [ ] last_updated timestamp reflects latest collection

---

### Phase 3: Edge Case Testing

#### Test 3.1: Missing Reports Directory

**Setup:**
```bash
mkdir -p test_edge_cases/no_reports
# Don't create reports/ directory
```

**Execute:**
```bash
python3 collect_metrics.py \
    --stage syn \
    --stage-dir test_edge_cases/no_reports \
    --run-dir test_edge_cases \
    --runtag no_reports \
    --block-name test_block
```

**Expected Behavior:**
- [ ] Script completes with warnings (not errors)
- [ ] All metrics show "N/A"
- [ ] run_status = "N/A" or based on other criteria
- [ ] JSON and CSV still generated

---

#### Test 3.2: Empty Report Files

**Setup:**
```bash
mkdir -p test_edge_cases/empty_reports/reports
touch test_edge_cases/empty_reports/reports/timing_summary.rpt
touch test_edge_cases/empty_reports/reports/report_qor.rpt
```

**Execute:**
```bash
python3 collect_metrics.py \
    --stage syn \
    --stage-dir test_edge_cases/empty_reports \
    --run-dir test_edge_cases \
    --runtag empty_reports \
    --block-name test_block
```

**Expected Behavior:**
- [ ] Script completes with warnings
- [ ] All timing metrics show "N/A"
- [ ] No crashes or exceptions

---

#### Test 3.3: Reports with Violations

**Setup:** Use a directory with known timing/DRC violations

**Execute:**
```bash
python3 collect_metrics.py \
    --stage route \
    --stage-dir <path_to_failing_route> \
    --run-dir test_edge_cases \
    --runtag violations_test \
    --block-name test_block
```

**Verification Checklist:**
- [ ] Negative WNS captured correctly
- [ ] TNS captured correctly
- [ ] NVP (number of violating paths) captured
- [ ] DRV violations counted
- [ ] run_status = "fail" or "continue_with_error" (based on severity)

---

### Phase 4: CSV Dashboard Integration Testing

**Objective:** Ensure CSV format is compatible with dashboard software

**Test 4.1: Column Count**
```bash
head -1 <runtag>_metrics.csv | awk -F',' '{print NF}'
# Expected: 34 columns
```

**Test 4.2: Column Names**
```bash
head -1 <runtag>_metrics.csv
# Expected headers:
# project,block_name,experiment,RTL_tag,user_name,run_directory,stage_directory,
# run_end_time,stage,internal_timing_r2r,internal_timing_custom,
# interface_timing_i2r,interface_timing_r2o,interface_timing_i2o,
# max_tran,max_cap,noise,mpw_min_period_double_switching,congestion_drc_metrics,
# area,inst_count,utilization,logs_errors_warnings,run_status,runtime,
# ai_summary,ir_static,em_power,em_signal,pv_drc_base,pv_drc_metal,
# pv_drc_antenna,lvs,lec
```

**Test 4.3: Value Formatting**
```bash
# Check WNS/NVP format
cat <runtag>_metrics.csv | cut -d',' -f10
# Expected: "7.421/0" or "N/A" (not "7.421/None")

# Check for unquoted N/A
grep -c "N/A" <runtag>_metrics.csv
# Expected: Multiple occurrences

# Check for NULL
grep -i null <runtag>_metrics.csv
# Expected: No matches
```

**Test 4.4: Import to Dashboard**
- [ ] Import CSV into dashboard software
- [ ] Verify all rows displayed
- [ ] Verify numeric columns recognized as numbers
- [ ] Verify "N/A" handled gracefully (not treated as zero)

---

### Phase 5: Performance Testing

**Test 5.1: Execution Time**
```bash
time python3 collect_metrics.py \
    --stage route \
    --stage-dir <large_design_route_dir> \
    --run-dir ./test_results \
    --runtag perf_test \
    --block-name large_design

# Expected: < 5 seconds for typical design
```

**Test 5.2: Large Log Files**
```bash
# Test with logs > 100MB
ls -lh <stage_dir>/logs/*.log
# Run collection and verify no memory issues
```

---

## Common Issues and Troubleshooting

### Issue 1: "TypeError: '<' not supported between instances of 'str' and 'float'"

**Cause:** Trying to compare "N/A" string with numeric value

**Solution:** Already fixed in `determine_run_status()` with `get_numeric()` helper

**Verification:**
```bash
# Run test and check for this error
python3 collect_metrics.py ... 2>&1 | grep TypeError
# Expected: No output
```

---

### Issue 2: NULL values in JSON output

**Cause:** Parsers returning None instead of "N/A"

**Check:**
```bash
grep -i null <runtag>_metrics.json
# Expected: No matches
```

**Solution:** Already fixed - parsers return "N/A" and collect_metrics only updates if value is valid

---

### Issue 3: Missing stage_directory in output

**Cause:** Old version of scripts

**Check:**
```bash
grep "stage_directory" <runtag>_metrics.json
# Expected: One match per stage
```

**Solution:** Update to latest version of scripts

---

### Issue 4: Wrong timing units (ps vs ns)

**Symptom:** WNS shows very large values (e.g., 7420800.0 instead of 7420.8)

**Cause:** Reports generated in picoseconds but scripts expect nanoseconds

**Solution:**
1. **Configure tools to report in ns:**
   ```tcl
   # In Genus synthesis script
   set_db timing_report_time_unit ns

   # In Innovus P&R script
   set_global timing_report_time_unit ns
   ```

2. **Verify report units:**
   ```bash
   grep -i "time unit" reports/timing_summary.rpt
   # Expected: "Time Unit: ns" or similar
   ```

---

### Issue 5: Warnings about missing report files

**Symptom:**
```
[WARN] Reports directory not found: /path/to/reports
[WARN] Error parsing setup timing from timing_summary.rpt: [Errno 2] No such file or directory
```

**Cause:** Report files not generated or in different location

**Solution:**
1. Check if reports were generated:
   ```bash
   ls -l <stage_dir>/reports/
   ```

2. Verify report file names match expected patterns:
   - Genus: `timing_summary.rpt`, `report_qor.rpt`, `report_area.rpt`
   - Innovus: `setup.analysis_summary.rpt`, `area.summary.rpt`

3. If using different names, update `STAGE_CONFIG` in `collect_metrics.py`

---

### Issue 6: All metrics show "N/A"

**Cause:** Reports exist but parsing regex patterns don't match

**Debug:**
```bash
# Check report format
head -50 reports/timing_summary.rpt

# Look for timing section
grep -A 10 "View:" reports/timing_summary.rpt
grep -A 10 "Group:" reports/timing_summary.rpt
```

**Solution:**
- Compare actual report format with expected patterns in `parse_timing_path_groups()`
- If format differs, update regex patterns in `metrics_utils.py`

---

### Issue 7: CSV import fails in dashboard

**Symptom:** Dashboard shows error when importing CSV

**Debug:**
```bash
# Check for special characters
file <runtag>_metrics.csv
# Expected: ASCII text or UTF-8 Unicode text

# Check for malformed rows
awk -F',' '{print NF}' <runtag>_metrics.csv | sort -u
# Expected: Single number (e.g., 34) for all rows

# Check for unescaped commas in fields
grep -n ',,,' <runtag>_metrics.csv
```

**Solution:**
- Ensure no commas in AI summary or other text fields
- Already handled by CSV writer with proper quoting

---

## Test Result Template

Create a test report using this template:

```
=============================================================================
METRICS COLLECTION TESTING REPORT
=============================================================================

Test Date: _______________
Tester: _______________
Design: _______________
Technology: _______________

-----------------------------------------------------------------------------
PHASE 1: UNIT TESTING
-----------------------------------------------------------------------------

Test 1.1: Synthesis Stage
  Status: [ ] PASS [ ] FAIL
  Notes: _________________________________________________________________

Test 1.2: Placement Stage
  Status: [ ] PASS [ ] FAIL
  Notes: _________________________________________________________________

Test 1.3: Route Stage
  Status: [ ] PASS [ ] FAIL
  Notes: _________________________________________________________________

-----------------------------------------------------------------------------
PHASE 2: INCREMENTAL TESTING
-----------------------------------------------------------------------------

Multi-Stage Collection:
  Status: [ ] PASS [ ] FAIL
  Number of stages collected: _____
  Notes: _________________________________________________________________

-----------------------------------------------------------------------------
PHASE 3: EDGE CASE TESTING
-----------------------------------------------------------------------------

Test 3.1: Missing Reports
  Status: [ ] PASS [ ] FAIL

Test 3.2: Empty Reports
  Status: [ ] PASS [ ] FAIL

Test 3.3: Reports with Violations
  Status: [ ] PASS [ ] FAIL

-----------------------------------------------------------------------------
PHASE 4: CSV DASHBOARD INTEGRATION
-----------------------------------------------------------------------------

CSV Format Validation:
  Status: [ ] PASS [ ] FAIL

Dashboard Import:
  Status: [ ] PASS [ ] FAIL
  Dashboard Software: _______________

-----------------------------------------------------------------------------
PHASE 5: PERFORMANCE
-----------------------------------------------------------------------------

Execution Time: _____ seconds
Memory Usage: _____ MB

-----------------------------------------------------------------------------
ISSUES FOUND
-----------------------------------------------------------------------------

Issue #1:
  Description: __________________________________________________________
  Severity: [ ] Critical [ ] Major [ ] Minor
  Workaround: ___________________________________________________________

Issue #2:
  Description: __________________________________________________________
  Severity: [ ] Critical [ ] Major [ ] Minor
  Workaround: ___________________________________________________________

-----------------------------------------------------------------------------
OVERALL RESULT: [ ] PASS [ ] FAIL
-----------------------------------------------------------------------------

Recommendations:
_________________________________________________________________________
_________________________________________________________________________
```

---

## Quick Reference Commands

**Run metrics collection:**
```bash
python3 collect_metrics.py \
    --stage <stage_name> \
    --stage-dir <path_to_stage_dir> \
    --run-dir <path_to_run_dir> \
    --runtag <run_tag> \
    --block-name <block_name> \
    --project <project_name> \
    --rtl-tag <rtl_version>
```

**Verify output:**
```bash
# Check for NULL values
grep -i null <runtag>_metrics.json

# Count stages in JSON
cat <runtag>_metrics.json | grep -c '"stage":'

# Count rows in CSV (including header)
wc -l <runtag>_metrics.csv

# View specific metric
cat <runtag>_metrics.json | grep "internal_timing_r2r_wns"

# Check all sign-off metrics
cat <runtag>_metrics.json | grep -E "ir_static|em_power|lvs|lec"
```

**Debug parsing:**
```bash
# Run with Python stack trace on error
python3 -u collect_metrics.py ... 2>&1 | tee debug.log

# Check warnings
grep WARN debug.log

# Check errors
grep ERROR debug.log
```
