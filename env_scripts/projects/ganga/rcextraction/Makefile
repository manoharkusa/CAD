.EXPORT_ALL_VARIABLES:
.PHONY: qrc_clean run_qrc qrc

BLOCK_NAME ?= $(BLOCK_NAME) 

RUN_DIR := $(EXP_DIR)
PV_BASE_DIR := $(RUN_DIR)/pv
QRC_BASE_DIR := $(RUN_DIR)/rcextraction
CHIP_FINISH_DIR := $(RUN_DIR)/pnr/chip_finish

#SLURM
PARTITION ?= reg
CPUS_PER_TASK ?= 2
MEM ?= 4G
SRUN ?= srun
TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")

# QRC scripts (from project tools)
QRC_CMD := $(ENV_SCRIPTS)/quantus/qrc.cmd
QRC_TECHLIB := $(ENV_SCRIPTS)/quantus/techlib.defs
QRC_TECHDIR := $(ENV_SCRIPTS)/quantus/tech

qrc: qrc_clean run_qrc

qrc_clean:
	@echo "Cleaning QRC contents in $(QRC_BASE_DIR) (keeping dirs)"
	@if [ -d "$(QRC_BASE_DIR)" ]; then \
		rm -rf $(QRC_BASE_DIR)/inputs/* $(QRC_BASE_DIR)/logs/* $(QRC_BASE_DIR)/outputs/* $(QRC_BASE_DIR)/reports/* 2>/dev/null || true; \
		echo "QRC clean done."; \
	else \
		echo "ERROR: $(QRC_BASE_DIR) not found"; exit 1; \
	fi

run_qrc:
	@echo "Running Quantus in $(QRC_BASE_DIR)"
	@cd $(QRC_BASE_DIR) && \
	ln -sf $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).IR.def ./inputs/. && \
	cp -rf $(QRC_TECHLIB) . && \
	cp -rf $(QRC_TECHDIR) . && \
	$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
	quantus -cmd $(QRC_CMD) | tee ./logs/quantus_$(TIMESTAMP).log
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage run_qrc --stage-dir $(QRC_BASE_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG);

