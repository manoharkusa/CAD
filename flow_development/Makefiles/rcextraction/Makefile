.EXPORT_ALL_VARIABLES:
.PHONY: qrc_clean run_qrc qrc

BLOCK_NAME ?= $(BLOCK_NAME)
ENABLE_AI ?= 0

RUN_DIR := $(EXP_DIR)
PV_BASE_DIR := $(RUN_DIR)/pv
QRC_BASE_DIR := $(RUN_DIR)/rcextraction
CHIP_FINISH_DIR := $(RUN_DIR)/pnr/chip_finish

# SLURM — set by orchestrator from flow_config.yaml slurm: block per stage.
# Fallback defaults are used only when running make manually without the orchestrator.
USE_SLURM      ?= 1
PARTITION      ?= g12v1
CPUS_PER_TASK  ?= 2
MEM            ?= 4G
SRUN           ?= srun

ifeq ($(USE_SLURM),1)
SRUN_PREFIX = $(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM)
else
SRUN_PREFIX =
endif

ifeq ($(ENABLE_AI),1)
      AI_FLAG := --enable-ai
else
      AI_FLAG :=
endif

# QRC scripts (from project tools)
QRC_CMD      := $(ENV_SCRIPTS)/quantus/qrc.cmd
QRC_TECHLIB  := $(ENV_SCRIPTS)/quantus/techlib.defs
QRC_TECHDIR  := $(ENV_SCRIPTS)/quantus/tech

qrc: qrc_clean run_qrc

qrc_clean:
	@echo "Cleaning QRC contents in $(QRC_BASE_DIR) (keeping dirs)"
	@if [ -d "$(QRC_BASE_DIR)" ]; then \
		rm -rf $(QRC_BASE_DIR)/inputs/* $(QRC_BASE_DIR)/logs/* $(QRC_BASE_DIR)/outputs/* $(QRC_BASE_DIR)/reports/* 2>/dev/null || true; \
		rm -f $(RUN_DIR)/.makefile.lock $(RUN_DIR)/.orchestrator.lock 2>/dev/null || true; \
		echo "QRC clean done."; \
	else \
		echo "ERROR: $(QRC_BASE_DIR) not found"; exit 1; \
	fi

run_qrc:
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@touch $(RUN_DIR)/.makefile.lock
	cd $(QRC_BASE_DIR) && \
	ln -sf $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).IR.def ./inputs/. && \
	cp -rf $(QRC_TECHLIB) . && \
	cp -rf $(QRC_TECHDIR) . && \
	$(SRUN_PREFIX) \
	quantus -cmd $(QRC_CMD) | tee ./logs/qrc.log; \
	touch $(QRC_BASE_DIR)/work/qrc_complete
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage qrc --stage-dir $(QRC_BASE_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG)
	@rm -f $(RUN_DIR)/.makefile.lock
