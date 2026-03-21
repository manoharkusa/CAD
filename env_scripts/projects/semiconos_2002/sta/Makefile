.EXPORT_ALL_VARIABLES:
.PHONY: all sta sta_clean run_sta

ENABLE_AI ?= 0

BLOCK_NAME ?= $(BLOCK_NAME)

SDC ?= /proj1/pd/users/testcase/Bharath/test_designs/aes_180nm/aes_cipher_top/inputs/aes_cipher_top.sdc

RUN_DIR := $(EXP_DIR)
STA_BASE_DIR := $(RUN_DIR)/sta
CHIP_FINISH_DIR := $(RUN_DIR)/pnr/chip_finish
QRC_BASE_DIR := $(RUN_DIR)/rcextraction

# SLURM
PARTITION ?= g12v1 
CPUS_PER_TASK ?= 2
MEM ?= 4G
SRUN ?= srun
TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")
NUM_CORES ?=8

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
		rm -rf $(STA_BASE_DIR)/inputs/* $(STA_BASE_DIR)/logs/* $(STA_BASE_DIR)/outputs/* $(STA_BASE_DIR)/reports/* 2>/dev/null || true; \
		echo "STA clean done."; \
	else \
		echo "ERROR: $(STA_BASE_DIR) not found"; exit 1; \
	fi


run_sta:
	@echo "Running Tempus in $(STA_BASE_DIR)"
	@cd $(STA_BASE_DIR) && \
	ln -sf $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).vg ./inputs/. && \
	ln -sf $(QRC_BASE_DIR)/outputs/*.spef.gz ./inputs/. && \
	$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
	tempus -stylus -files $(TEMPUS_TCL) | tee ./logs/tempus_$(TIMESTAMP).log
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage sta --stage-dir $(STA_BASE_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG);

