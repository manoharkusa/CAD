.EXPORT_ALL_VARIABLES:
.PHONY: all lec lec_clean run_r2g run_g2g
BLOCK_NAME ?= $(BLOCK_NAME) 

RUN_DIR := $(EXP_DIR)
LEC_BASE_DIR := $(RUN_DIR)/lec
ENABLE_AI ?= 0
# SLURM
PARTITION ?= reg
CPUS_PER_TASK ?= 2
MEM ?= 4G
SRUN ?= srun
TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")

ifeq ($(ENABLE_AI),1)
      AI_FLAG := --enable-ai
else
      AI_FLAG :=
endif

all: lec
lec: lec_clean run_r2g run_g2g

lec: lec_clean run_r2g

lec_clean:
	@echo "Cleaning LEC contents in $(LEC_BASE_DIR) (keeping dirs)"
	@if [ -d "$(LEC_BASE_DIR)" ]; then \
		rm -rf $(LEC_BASE_DIR)/r2g/inputs $(LEC_BASE_DIR)/r2g/log $(LEC_BASE_DIR)/r2g/logs $(LEC_BASE_DIR)/r2g/reports $(LEC_BASE_DIR)/r2g/outputs 2>/dev/null || true; \
		rm -rf $(LEC_BASE_DIR)/g2g/inputs $(LEC_BASE_DIR)/g2g/log $(LEC_BASE_DIR)/g2g/logs $(LEC_BASE_DIR)/g2g/reports $(LEC_BASE_DIR)/g2g/outputs 2>/dev/null || true; \
		echo "LEC clean done."; \
	else \
		echo "ERROR: $(LEC_BASE_DIR) not found"; exit 1; \
	fi

run_r2g:
	@echo "R2G LEC command not provided yet."
	@echo "Add conformal invocation here (can be wrapped with srun)."
	@echo "Example: cd $(LEC_BASE_DIR)/r2g && $(SRUN) ... conformal -dofile <dofile> | tee ./logs/lec_r2g_$(TIMESTAMP).log"
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage run_r2g --stage-dir $(LEC_BASE_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG);

