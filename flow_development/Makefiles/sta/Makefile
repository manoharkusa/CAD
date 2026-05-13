.EXPORT_ALL_VARIABLES:
.PHONY: all sta sta_clean run_sta

ENABLE_AI ?= 0

BLOCK_NAME ?= $(BLOCK_NAME)

SDC ?= /proj1/pd/users/testcase/Bharath/test_designs/aes_180nm/aes_cipher_top/inputs/aes_cipher_top.sdc

RUN_DIR := $(EXP_DIR)
STA_BASE_DIR := $(RUN_DIR)/sta
CHIP_FINISH_DIR := $(RUN_DIR)/pnr/chip_finish
QRC_BASE_DIR := $(RUN_DIR)/rcextraction

# SLURM Parameters
USE_SLURM     ?= 1
PARTITION     ?= g12v1
CPUS_PER_TASK ?= 2
MEM           ?= 4G
SRUN          ?= srun
ifeq ($(USE_SLURM),1)
SRUN_PREFIX = $(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM)
else
SRUN_PREFIX =
endif

NUM_CORES ?= 8

# Tempus script (from project tools)
TEMPUS_TCL := $(ENV_SCRIPTS)/tempus/tempus.tcl

ifeq ($(ENABLE_AI),1)
      AI_FLAG := --enable-ai
else
      AI_FLAG :=
endif

all: sta
sta: sta_clean run_sta

sta_clean:
	@echo "Cleaning STA contents in $(STA_BASE_DIR) (keeping dirs)"
	@if [ -d "$(STA_BASE_DIR)" ]; then \
		rm -rf $(STA_BASE_DIR)/inputs/* $(STA_BASE_DIR)/logs/* $(STA_BASE_DIR)/outputs/* $(STA_BASE_DIR)/reports/* $(STA_BASE_DIR)/work/* 2>/dev/null || true; \
		find $(STA_BASE_DIR) -path "*/work/*_complete" -type f -delete 2>/dev/null || true; \
		rm -f $(RUN_DIR)/.makefile.lock $(RUN_DIR)/.orchestrator.lock 2>/dev/null || true; \
		echo "STA clean done."; \
	else \
		echo "ERROR: $(STA_BASE_DIR) not found"; exit 1; \
	fi

run_sta:
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@if [ -f "$(STA_BASE_DIR)/work/run_sta_complete" ]; then \
		echo "[SKIP] STA already completed (remove $(STA_BASE_DIR)/work/run_sta_complete to rerun)"; \
	else \
		touch $(RUN_DIR)/.makefile.lock; \
		echo "Running Tempus in $(STA_BASE_DIR)"; \
		ln -sf $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).vg $(STA_BASE_DIR)/inputs/.; \
		ln -sf $(QRC_BASE_DIR)/outputs/*.spef.gz $(STA_BASE_DIR)/inputs/.; \
		cd $(STA_BASE_DIR)/work && \
		$(SRUN_PREFIX) tempus -stylus -files $(TEMPUS_TCL) | tee ../logs/sta.log; \
		if [ -f "$(STA_BASE_DIR)/work/tempus_flow_complete" ]; then \
			python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage sta --stage-dir $(STA_BASE_DIR) --run-dir $(RUN_DIR)/dashboard -runtag $(EXP_NAME) --block-name $(BLOCK_NAME) --project $(PROJ_NAME) --rtl-tag $(RTL_TAG) $(AI_FLAG); \
			touch $(STA_BASE_DIR)/work/run_sta_complete; \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "STA completed"; \
		else \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "ERROR: tempus flow did not complete. Skipping parse scripts."; \
			exit 1; \
		fi; \
	fi
