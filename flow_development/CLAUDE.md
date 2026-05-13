# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

An **ASIC Design Flow Automation Framework** targeting TSMC 28nm. It orchestrates a full chip design pipeline — RTL synthesis through physical verification — using industry EDA tools (Genus, Innovus, Quantus, Tempus, Calibre, Conformal). The framework manages stage execution, dependency tracking, quality checks, and metrics collection with optional SLURM cluster support.

## Running Flow Stages

All stages are invoked via Makefiles. Run from the block's working directory (`/run_dir` or equivalent):

```bash
# Synthesis
make -f Makefiles/genus/Makefile syn
make -f Makefiles/genus/Makefile clean

# Place & Route (individual stages or full chain)
make -f Makefiles/innovus/Makefile init_design
make -f Makefiles/innovus/Makefile floorplan
make -f Makefiles/innovus/Makefile place
make -f Makefiles/innovus/Makefile cts
make -f Makefiles/innovus/Makefile route
make -f Makefiles/innovus/Makefile pnr       # full chain
make -f Makefiles/innovus/Makefile pnr_clean

# RC Extraction
make -f Makefiles/rcextraction/Makefile qrc

# Static Timing Analysis
make -f Makefiles/sta/Makefile sta

# Physical Verification
make -f Makefiles/pv/Makefile pv_fill
make -f Makefiles/pv/Makefile pv_signoff
make -f Makefiles/pv/Makefile pv_clean
```

**SLURM execution** — set env vars before make:
```bash
export USE_SLURM=1 PARTITION=g12v1 CPUS_PER_TASK=4 MEM=16G
make -f Makefiles/innovus/Makefile place
```

**AI-assisted optimization**: pass `--enable-ai` flag when launching tool scripts directly.

## Metrics and QMS

After each stage completes, metrics are collected and quality checks run:

```bash
# Collect metrics for a specific stage
python3 tools_scripts_v1/parse_scripts/collect_metrics.py --stage <stage_name>

# Run QMS checks
python3 tools_scripts_v1/parse_scripts/collect_qms.py --stage <stage_name>

# Unified post-processing (metrics + QMS)
python3 tools_scripts_v1/parse_scripts/post_stage.py --stage <stage_name>
```

Results are written as JSON to the stage's `outputs/` directory and optionally uploaded to a local dashboard API (port 3000 via curl).

## Architecture

### Configuration Layer (YAML)

- **`tools_scripts_v1/flow_config.yaml`** — Master flow: 18+ stages with `depends_on`, timeouts, SLURM resource specs, and tool assignments
- **`tools_scripts_v1/common/project_tech.yaml`** — Technology/PDK: corner definitions, metal stack, standard cells, macro lists, IO/power nets, CTS buffers
- **`tools_scripts_v1/templates/block.yaml`** — Block-level overrides: routing layer constraints, corner selection, timing criticality flags

### EDA Tool Scripts (`tools_scripts_v1/<tool>/`)

Each tool directory has a master TCL script that:
1. Sources shared utilities from `tools_scripts_v1/common/` (`ui_common_procs.tcl`, `yaml_utils.tcl`, `pdk_loader.tcl`)
2. Loads PDK config from YAML
3. Performs tool-specific operations
4. Writes reports to `reports/`, databases to `outputs/`
5. Emits `UI_MSG`-formatted messages consumed by the dashboard

Key tool directories: `genus/`, `innovus/`, `quantus/`, `tempus/`, `calibre/`, `pv/`, `conformal/`

### Stage Execution Model

Each stage operates in a directory with `inputs/`, `outputs/`, `reports/`, `logs/`, `work/` subdirectories. Completion is tracked by marker files (e.g., `init_design_complete`). Lock files (`.orchestrator.lock`, `.makefile.lock`) prevent concurrent execution. Stages will skip if already marked complete.

### Multi-Corner Flow

PnR runs on 4 corners: `ss0p81vm40_cw`, `ss0p81v125c_rcw`, `ff0p99v125c_rcb`, `ff0p99vm40_cb`. MMMC configuration lives in `tools_scripts_v1/innovus/mmmc_config.tcl`. STA signoff adds a typical corner (5 total).

### Parsing & QMS (`tools_scripts_v1/parse_scripts/`)

- **`metrics_utils.py`** — Core parsing library (~850 lines) for Genus/Innovus reports: timing, area, utilization, DRC
- **`qms_utils.py`** — Quality Management System checks (~175KB): validates metric thresholds per stage
- **`collect_metrics.py`** — Orchestrates metric collection across all stages
- **`syn_qms.py`, `place_qms.py`, etc.** — Stage-specific QMS entry points calling into `qms_utils.py`

### Netlist / Database Flow

RTL → Verilog netlist (synthesis/Genus) → DEF/OA database (PnR/Innovus) → SPEF parasitics (Quantus) → STA results (Tempus) → GDS layout (Calibre)

## Key Files

| File | Purpose |
|------|---------|
| `tools_scripts_v1/flow_config.yaml` | Flow orchestration: stages, deps, timeouts, SLURM |
| `tools_scripts_v1/common/project_tech.yaml` | PDK/technology definition |
| `tools_scripts_v1/templates/block.yaml` | Block-specific config template |
| `tools_scripts_v1/innovus/mmmc_config.tcl` | Multi-corner timing setup |
| `tools_scripts_v1/parse_scripts/metrics_utils.py` | Report parsing library |
| `tools_scripts_v1/parse_scripts/qms_utils.py` | QMS validation library |
| `Makefiles/innovus/Makefile` | PnR stage entry points |
