.EXPORT_ALL_VARIABLES:
.PHONY: clean syn

# User Parameters
SDC ?= /proj1/pd/users/testcase/Bharath/test_designs/aes_180nm/aes_cipher_top/inputs/aes_cipher_top.sdc
RTL_FILELIST ?= /proj1/pd/users/testcase/TESTCASES/test_designs_central/aes_core/file_list_fixed.tcl
BLOCK_NAME ?= $(BLOCK_NAME)
ENABLE_AI ?= 0
# Directory Paths (created by setup)
RUN_DIR   := $(EXP_DIR)
SYNTH_DIR := $(RUN_DIR)/syn

# Synthesis script (from project tools)
GENUS_TCL := $(ENV_SCRIPTS)/genus/genus_syn.tcl

# SLURM Parameters
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

# -------------------------------------------------
# Clean synthesis outputs (keep directory structure)
# -------------------------------------------------
clean:
	@echo "Cleaning synthesis contents in $(SYNTH_DIR)"
	@if [ -d "$(SYNTH_DIR)" ]; then \
		rm -rf $(SYNTH_DIR)/logs/* \
		       $(SYNTH_DIR)/reports/* \
		       $(SYNTH_DIR)/outputs/* \
		       $(SYNTH_DIR)/work/* 2>/dev/null || true; \
		rm -f $(SYNTH_DIR)/synth_complete 2>/dev/null || true; \
		echo "Clean completed"; \
	else \
		echo "ERROR: $(SYNTH_DIR) does not exist"; \
		exit 1; \
	fi


# -------------------------------------------------
# Run Genus Synthesis
# -------------------------------------------------

syn:
	@if [ -f "$(SYNTH_DIR)/synth_complete" ]; then \
		echo "[SKIP] Synthesis already completed (remove $(SYNTH_DIR)/synth_complete to rerun)"; \
	else \
		echo "Starting synthesis for block: $(BLOCK_NAME)"; \
		echo "Working directory : $(SYNTH_DIR)"; \
		echo "Genus script      : $(GENUS_TCL)"; \
		echo "SLURM             : partition=$(PARTITION), CPUs=$(CPUS_PER_TASK), MEM=$(MEM)"; \
		cd $(SYNTH_DIR) && \
			$(SRUN) -p $(PARTITION) \
			        --cpus-per-task=$(CPUS_PER_TASK) \
			        --mem=$(MEM) \
			        genus -files $(GENUS_TCL) | tee ./logs/genus_syn_$(TIMESTAMP).log; \
		python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage syn --stage-dir $(SYNTH_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG); \
		python3 $(ENV_SCRIPTS)/parse_scripts/collect_qms.py --stage syn --stage-dir $(SYNTH_DIR) --run-dir $(RUN_DIR)/dashboard --runtag $(RUNTAG) --block-name $(BLOCK_NAME) --project $(PROJ_DIR) --rtl-tag $(RTL_VERSION); \
		touch $(SYNTH_DIR)/synth_complete; \
		echo "Synthesis completed successfully"; \
	fi

