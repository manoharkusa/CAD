.EXPORT_ALL_VARIABLES:
.PHONY: all pv pv_fill pv_signoff status pv_clean feol_fill beol_fill merge_fill run_calibre_drc run_calibre_lvs run_antenna v2lvs

BLOCK_NAME ?= $(BLOCK_NAME)

RUN_DIR := $(EXP_DIR)
PV_BASE_DIR := $(RUN_DIR)/pv
CHIP_FINISH_DIR := $(RUN_DIR)/pnr/chip_finish
ENABLE_AI ?= 0

# SLURM — set by orchestrator from flow_config.yaml slurm: block per stage.
# Fallback defaults are used only when running make manually without the orchestrator.
USE_SLURM      ?= 1
PARTITION      ?= g11v2
CPUS_PER_TASK  ?= 2
MEM            ?= 4G
SRUN_TIMEOUT   ?= 60
SRUN           ?= srun

# SRUN_PREFIX: empty when USE_SLURM=0, full srun command when USE_SLURM=1
ifeq ($(USE_SLURM),1)
SRUN_PREFIX = $(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) --time=$(SRUN_TIMEOUT)
else
SRUN_PREFIX =
endif

TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")

FEOL_FILL_DIR   := $(PV_BASE_DIR)/feol_fill
BEOL_FILL_DIR   := $(PV_BASE_DIR)/beol_fill
MERGE_FILL_DIR  := $(PV_BASE_DIR)/merge_fill
CALIBRE_DRC_DIR := $(PV_BASE_DIR)/drc
ANTENNA_DIR     := $(PV_BASE_DIR)/antenna
V2LVS_DIR       := $(PV_BASE_DIR)/cdl
CALIBRE_LVS_DIR := $(PV_BASE_DIR)/lvs

# PV scripts (from project tools)
PV_FEOL_TCL := $(ENV_SCRIPTS)/pv/feol_runset.rule
PV_BEOL_TCL := $(ENV_SCRIPTS)/pv/beol_runset.rule
PV_MERGE_TCL := $(ENV_SCRIPTS)/pv/merge_gds.tcl
PV_DRC_TCL  := $(ENV_SCRIPTS)/pv/DRC_runset.rule
PV_ANT_TCL  := $(ENV_SCRIPTS)/pv/Antenna_calibre_runset.rule
PV_LVS_TCL  := $(ENV_SCRIPTS)/pv/lvs_calibre_runset.rule

ifeq ($(ENABLE_AI),1)
      AI_FLAG := --enable-ai
else
      AI_FLAG :=
endif

# Default: full PV
all: pv

# Full PV chain
pv: pv_clean pv_fill pv_signoff

# Fill-only chain
pv_fill: feol_fill beol_fill merge_fill

# Signoff chain
pv_signoff: run_calibre_drc run_antenna v2lvs run_calibre_lvs

status:
	@echo "PV status under: $(PV_BASE_DIR)"
	@for d in feol_fill beol_fill merge_fill run_calibre_drc run_antenna v2lvs run_calibre_lvs; do \
		if [ -d "$(PV_BASE_DIR)/$$d" ]; then echo "DIR  : $(PV_BASE_DIR)/$$d"; else echo "MISS : $(PV_BASE_DIR)/$$d"; fi; \
	done
	@echo "Tip: run 'make pv_fill' then 'make pv_signoff'"

pv_clean:
	@echo "Cleaning PV contents under $(PV_BASE_DIR) (keeping dirs)"
	@if [ -d "$(PV_BASE_DIR)" ]; then \
		rm -rf $(PV_BASE_DIR)/*/inputs/* $(PV_BASE_DIR)/*/logs/* $(PV_BASE_DIR)/*/reports/* $(PV_BASE_DIR)/*/outputs/* $(PV_BASE_DIR)/*/work/* 2>/dev/null || true; \
		find $(PV_BASE_DIR) -path '*/work/*_complete' -delete 2>/dev/null || true; \
		rm -f $(RUN_DIR)/.makefile.lock $(RUN_DIR)/.orchestrator.lock 2>/dev/null || true; \
		echo "PV clean done."; \
	else \
		echo "ERROR: $(PV_BASE_DIR) not found"; exit 1; \
	fi

feol_fill:
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@touch $(RUN_DIR)/.makefile.lock
	cd $(FEOL_FILL_DIR)/work; \
	ln -sf $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).merged.gds.gz ../inputs/.; \
	export GDS_PATH="$(FEOL_FILL_DIR)/inputs/$(BLOCK_NAME).merged.gds.gz"; \
	echo "LAYOUT PATH \"$$GDS_PATH\"" > feol_runset; \
	cat $(PV_FEOL_TCL) >> feol_runset; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" feol_runset; \
	$(SRUN_PREFIX) \
	calibre -turbo $(CPUS_PER_TASK) -hier -drc feol_runset | tee ../logs/feol_fill.log; \
	mv ${BLOCK_NAME}_FEOL.gds ../outputs/; \
	mv ${BLOCK_NAME}.summary ../reports/; \
	touch $(FEOL_FILL_DIR)/work/feol_fill_complete
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage feol_fill --stage-dir $(FEOL_FILL_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG)
	@rm -f $(RUN_DIR)/.makefile.lock

beol_fill:
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@touch $(RUN_DIR)/.makefile.lock
	cd $(BEOL_FILL_DIR)/work; \
	ln -sf $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).merged.gds.gz ../inputs/.; \
	export GDS_PATH="$(BEOL_FILL_DIR)/inputs/$(BLOCK_NAME).merged.gds.gz"; \
	echo "LAYOUT PATH \"$$GDS_PATH\"" > beol_runset; \
	cat $(PV_BEOL_TCL) >> beol_runset; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" beol_runset; \
	$(SRUN_PREFIX) \
	calibre -turbo $(CPUS_PER_TASK) -hier -drc beol_runset | tee ../logs/beol_fill.log; \
	mv ${BLOCK_NAME}_BEOL.gds ../outputs/; \
	mv ${BLOCK_NAME}.summary ../reports/; \
	touch $(BEOL_FILL_DIR)/work/beol_fill_complete
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage beol_fill --stage-dir $(BEOL_FILL_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG)
	@rm -f $(RUN_DIR)/.makefile.lock

merge_fill:
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@touch $(RUN_DIR)/.makefile.lock
	cd $(MERGE_FILL_DIR)/work; \
	ln -sf $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).merged.gds.gz ../inputs/.; \
	export GDS_PATH="$(MERGE_FILL_DIR)/inputs/$(BLOCK_NAME).merged.gds.gz"; \
	echo "set design_gds \"$$GDS_PATH\"" > merge_gds_block.tcl; \
	cat $(PV_MERGE_TCL) >> merge_gds_block.tcl; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" merge_gds_block.tcl; \
	$(SRUN_PREFIX) \
	calibredrv -s ./merge_gds_block.tcl -threads $(CPUS_PER_TASK) | tee ../logs/merge_fill.log; \
	touch $(MERGE_FILL_DIR)/work/merge_fill_complete
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage merge_fill --stage-dir $(MERGE_FILL_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG)
	@rm -f $(RUN_DIR)/.makefile.lock

run_calibre_drc:
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@touch $(RUN_DIR)/.makefile.lock
	cd $(CALIBRE_DRC_DIR)/work; \
	export GDS_PATH="$(MERGE_FILL_DIR)/outputs/$(BLOCK_NAME).merged_fill.gds.gz"; \
	echo "LAYOUT PATH \"$$GDS_PATH\"" > drc_runset; \
	cat $(PV_DRC_TCL) >> drc_runset; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" drc_runset; \
	$(SRUN_PREFIX) \
	calibre -turbo $(CPUS_PER_TASK) -hier -drc drc_runset | tee ../logs/run_calibre_drc.log; \
	mv ${BLOCK_NAME}.db ../outputs/; \
	mv ${BLOCK_NAME}.summary ../reports/; \
	touch $(CALIBRE_DRC_DIR)/work/run_calibre_drc_complete
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage run_calibre_drc --stage-dir $(CALIBRE_DRC_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG)
	@rm -f $(RUN_DIR)/.makefile.lock

run_antenna:
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@touch $(RUN_DIR)/.makefile.lock
	cd $(ANTENNA_DIR)/work; \
	export GDS_PATH="$(MERGE_FILL_DIR)/outputs/$(BLOCK_NAME).merged_fill.gds.gz"; \
	echo "LAYOUT PATH \"$$GDS_PATH\"" > antenna_runset; \
	cat $(PV_ANT_TCL) >> antenna_runset; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" antenna_runset; \
	$(SRUN_PREFIX) \
	calibre -turbo $(CPUS_PER_TASK) -hier -drc antenna_runset | tee ../logs/run_antenna.log; \
	mv ${BLOCK_NAME}.db ../outputs/; \
	mv ${BLOCK_NAME}.summary ../reports/; \
	touch $(ANTENNA_DIR)/work/run_antenna_complete
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage run_antenna --stage-dir $(ANTENNA_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG)
	@rm -f $(RUN_DIR)/.makefile.lock

v2lvs:
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@touch $(RUN_DIR)/.makefile.lock
	cd $(V2LVS_DIR)/work; \
	ln -sf $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).fill.pg.vg ../inputs/.; \
	ln -sf $(CHIP_FINISH_DIR)/outputs/cdl_files.list ../inputs/.; \
	CDL_ARGS=$$(awk '{print "-s " $$1}' ../inputs/cdl_files.list | tr '\n' ' '); \
	v2lvs -v ../inputs/$(BLOCK_NAME).fill.pg.vg -o ../outputs/$(BLOCK_NAME).cdl $$CDL_ARGS \
		| tee ../logs/v2lvs.log; \
	touch $(V2LVS_DIR)/work/v2lvs_complete
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage v2lvs --stage-dir $(V2LVS_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG)
	@rm -f $(RUN_DIR)/.makefile.lock

run_calibre_lvs:
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@touch $(RUN_DIR)/.makefile.lock
	cd $(CALIBRE_LVS_DIR)/work; \
	ln -sf $(CHIP_FINISH_DIR)/outputs/hcell.list ../inputs/.; \
	ln -sf $(V2LVS_DIR)/outputs/$(BLOCK_NAME).cdl ../inputs/.; \
	cat $(PV_LVS_TCL) > lvscalibre_runset; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" lvscalibre_runset; \
	$(SRUN_PREFIX) \
	calibre -turbo $(CPUS_PER_TASK) -hier -hcell ../inputs/hcell.list -lvs lvscalibre_runset | tee ../logs/run_calibre_lvs.log; \
	mv ${BLOCK_NAME}_erc.db ../outputs/; \
	mv ${BLOCK_NAME}_erc.summary ../reports/; \
	touch $(CALIBRE_LVS_DIR)/work/run_calibre_lvs_complete
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage run_calibre_lvs --stage-dir $(CALIBRE_LVS_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG)
	@rm -f $(RUN_DIR)/.makefile.lock
