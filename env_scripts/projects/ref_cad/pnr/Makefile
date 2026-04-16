.EXPORT_ALL_VARIABLES:
.PHONY: all pnr status  pnr_clean init_design floorplan place cts post_cts route postroute chip_finish

# Default: run full PnR chain
ENABLE_AI ?= 0
SDC ?= /proj1/pd/users/testcase/Bharath/test_designs/aes_180nm/aes_cipher_top/inputs/aes_cipher_top.sdc

# Directories (already created by setup)
RUN_DIR := $(EXP_DIR)
SYNTH_DIR := $(RUN_DIR)/syn
PNR_BASE_DIR := $(RUN_DIR)/pnr
INIT_DIR := $(PNR_BASE_DIR)/init
FLOORPLAN_DIR := $(PNR_BASE_DIR)/floorplan
PLACE_DIR := $(PNR_BASE_DIR)/place
CTS_DIR := $(PNR_BASE_DIR)/cts
POSTCTS_DIR := $(PNR_BASE_DIR)/postcts
ROUTE_DIR := $(PNR_BASE_DIR)/route
POSTROUTE_DIR := $(PNR_BASE_DIR)/postroute
CHIP_FINISH_DIR := $(PNR_BASE_DIR)/chip_finish

# Innovus scripts (from project tools)
INIT_TCL    := $(ENV_SCRIPTS)/innovus/design_init.tcl
FP_TCL      := $(ENV_SCRIPTS)/innovus/floorplan.tcl
PLACE_TCL   := $(ENV_SCRIPTS)/innovus/place.tcl
CTS_TCL     := $(ENV_SCRIPTS)/innovus/cts.tcl
POSTCTS_TCL := $(ENV_SCRIPTS)/innovus/post_cts.tcl
ROUTE_TCL   := $(ENV_SCRIPTS)/innovus/route.tcl
POSTROUTE_TCL := $(ENV_SCRIPTS)/innovus/post_route.tcl
CHIPFINISH_TCL := $(ENV_SCRIPTS)/innovus/chip_finish.tcl



# SLURM Parameters
USE_SLURM     ?= 1
PARTITION     ?= g12v1
CPUS_PER_TASK ?= 2
MEM           ?= 16G
SRUN          ?= srun
ifeq ($(USE_SLURM),1)
SRUN_PREFIX = $(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) --pty
else
SRUN_PREFIX =
endif

TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")

all: pnr

ifeq ($(ENABLE_AI),1)
      AI_FLAG := --enable-ai
else
      AI_FLAG :=
endif
# Convenience
pnr: pnr_clean init_design floorplan place cts post_cts route postroute chip_finish

pnr_clean:
	@echo "Cleaning PnR contents under $(PNR_BASE_DIR) (keeping dirs)"
	@if [ -d "$(PNR_BASE_DIR)" ]; then \
		rm -rf $(PNR_BASE_DIR)/*/logs/* $(PNR_BASE_DIR)/*/reports/* $(PNR_BASE_DIR)/*/outputs/* $(PNR_BASE_DIR)/*/work/* 2>/dev/null || true; \
		find $(PNR_BASE_DIR) -path "*/work/*_complete" -type f -delete 2>/dev/null || true; \
		rm -f $(RUN_DIR)/.makefile.lock $(RUN_DIR)/.orchestrator.lock 2>/dev/null || true; \
		echo "PnR clean done."; \
	else \
		echo "ERROR: $(PNR_BASE_DIR) not found"; exit 1; \
	fi

init_design:
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@if [ -f "$(INIT_DIR)/work/init_design_complete" ]; then \
		echo "[SKIP] Init design already completed (remove $(INIT_DIR)/work/init_design_complete to rerun)"; \
	else \
		touch $(RUN_DIR)/.makefile.lock; \
		echo "Running init_design in $(INIT_DIR)"; \
		cd $(INIT_DIR)/work && \
		$(SRUN_PREFIX) innovus -stylus -files $(INIT_TCL) | tee ../logs/init_design.log; \
		if [ -f "$(INIT_DIR)/work/init_design_flow_complete" ]; then \
			python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage init --stage-dir $(INIT_DIR) --run-dir $(RUN_DIR)/dashboard -runtag $(EXP_NAME) --block-name $(BLOCK_NAME) --project $(PROJ_NAME) --rtl-tag $(RTL_TAG) $(AI_FLAG); \
			touch $(INIT_DIR)/work/init_design_complete; \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "init_design completed"; \
		else \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "ERROR: init_design flow did not complete. Skipping parse scripts."; \
			exit 1; \
		fi; \
	fi

floorplan: init_design
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@if [ -f "$(FLOORPLAN_DIR)/work/floorplan_complete" ]; then \
		echo "[SKIP] Floorplan already completed (remove $(FLOORPLAN_DIR)/work/floorplan_complete to rerun)"; \
	else \
		touch $(RUN_DIR)/.makefile.lock; \
		echo "Running floorplan in $(FLOORPLAN_DIR)"; \
		cd $(FLOORPLAN_DIR)/work && \
		$(SRUN_PREFIX) innovus -stylus -files $(FP_TCL) | tee ../logs/floorplan.log; \
		if [ -f "$(FLOORPLAN_DIR)/work/floorplan_flow_complete" ]; then \
			python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage floorplan --stage-dir $(FLOORPLAN_DIR) --run-dir $(RUN_DIR)/dashboard -runtag $(EXP_NAME) --block-name $(BLOCK_NAME) --project $(PROJ_NAME) --rtl-tag $(RTL_TAG) $(AI_FLAG); \
			touch $(FLOORPLAN_DIR)/work/floorplan_complete; \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "floorplan completed"; \
		else \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "ERROR: floorplan flow did not complete. Skipping parse scripts."; \
			exit 1; \
		fi; \
	fi

place: floorplan
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@if [ -f "$(PLACE_DIR)/work/place_complete" ]; then \
		echo "[SKIP] Place already completed (remove $(PLACE_DIR)/work/place_complete to rerun)"; \
	else \
		touch $(RUN_DIR)/.makefile.lock; \
		echo "Running place in $(PLACE_DIR)"; \
		cd $(PLACE_DIR)/work && \
		$(SRUN_PREFIX) innovus -stylus -files $(PLACE_TCL) | tee ../logs/place.log; \
		if [ -f "$(PLACE_DIR)/work/place_flow_complete" ]; then \
			python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage place --stage-dir $(PLACE_DIR) --run-dir $(RUN_DIR)/dashboard  -runtag $(EXP_NAME) --block-name $(BLOCK_NAME) --project $(PROJ_NAME) --rtl-tag $(RTL_TAG) $(AI_FLAG); \
			touch $(PLACE_DIR)/work/place_complete; \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "place completed"; \
		else \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "ERROR: place flow did not complete. Skipping parse scripts."; \
			exit 1; \
		fi; \
	fi

cts: place
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@if [ -f "$(CTS_DIR)/work/cts_complete" ]; then \
		echo "[SKIP] CTS already completed (remove $(CTS_DIR)/work/cts_complete to rerun)"; \
	else \
		touch $(RUN_DIR)/.makefile.lock; \
		echo "Running CTS in $(CTS_DIR)"; \
		cd $(CTS_DIR)/work && \
		$(SRUN_PREFIX) innovus -stylus -files $(CTS_TCL) | tee ../logs/cts.log; \
		if [ -f "$(CTS_DIR)/work/cts_flow_complete" ]; then \
			python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage cts --stage-dir $(CTS_DIR) --run-dir $(RUN_DIR)/dashboard -runtag $(EXP_NAME) --block-name $(BLOCK_NAME) --project $(PROJ_NAME) --rtl-tag $(RTL_TAG) $(AI_FLAG); \
			touch $(CTS_DIR)/work/cts_complete; \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "CTS completed"; \
		else \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "ERROR: cts flow did not complete. Skipping parse scripts."; \
			exit 1; \
		fi; \
	fi

post_cts: cts
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@if [ -f "$(POSTCTS_DIR)/work/postcts_complete" ]; then \
		echo "[SKIP] Post CTS already completed (remove $(POSTCTS_DIR)/work/postcts_complete to rerun)"; \
	else \
		touch $(RUN_DIR)/.makefile.lock; \
		echo "Running post_cts in $(POSTCTS_DIR)"; \
		cd $(POSTCTS_DIR)/work && \
		$(SRUN_PREFIX) innovus -stylus -files $(POSTCTS_TCL) | tee ../logs/post_cts.log; \
		if [ -f "$(POSTCTS_DIR)/work/postcts_flow_complete" ]; then \
			python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage postcts --stage-dir $(POSTCTS_DIR) --run-dir $(RUN_DIR)/dashboard  -runtag $(EXP_NAME) --block-name $(BLOCK_NAME) --project $(PROJ_NAME) --rtl-tag $(RTL_TAG) $(AI_FLAG); \
			touch $(POSTCTS_DIR)/work/postcts_complete; \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "Post CTS completed"; \
		else \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "ERROR: post_cts flow did not complete. Skipping parse scripts."; \
			exit 1; \
		fi; \
	fi

route: post_cts
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@if [ -f "$(ROUTE_DIR)/work/route_complete" ]; then \
		echo "[SKIP] Route already completed (remove $(ROUTE_DIR)/work/route_complete to rerun)"; \
	else \
		touch $(RUN_DIR)/.makefile.lock; \
		echo "Running route in $(ROUTE_DIR)"; \
		cd $(ROUTE_DIR)/work && \
		$(SRUN_PREFIX) innovus -stylus -files $(ROUTE_TCL) | tee ../logs/route.log; \
		if [ -f "$(ROUTE_DIR)/work/route_flow_complete" ]; then \
			python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage route --stage-dir $(ROUTE_DIR) --run-dir $(RUN_DIR)/dashboard -runtag $(EXP_NAME) --block-name $(BLOCK_NAME) --project $(PROJ_NAME) --rtl-tag $(RTL_TAG) $(AI_FLAG); \
			touch $(ROUTE_DIR)/work/route_complete; \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "Route completed"; \
		else \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "ERROR: route flow did not complete. Skipping parse scripts."; \
			exit 1; \
		fi; \
	fi

postroute: route
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@if [ -f "$(POSTROUTE_DIR)/work/post_route_complete" ]; then \
		echo "[SKIP] Post route already completed (remove $(POSTROUTE_DIR)/work/post_route_complete to rerun)"; \
	else \
		touch $(RUN_DIR)/.makefile.lock; \
		echo "Running postroute in $(POSTROUTE_DIR)"; \
		cd $(POSTROUTE_DIR)/work && \
		$(SRUN_PREFIX) innovus -stylus -files $(POSTROUTE_TCL) | tee ../logs/postroute.log; \
		if [ -f "$(POSTROUTE_DIR)/work/postroute_flow_complete" ]; then \
			python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage postroute --stage-dir $(POSTROUTE_DIR) --run-dir $(RUN_DIR)/dashboard -runtag $(EXP_NAME) --block-name $(BLOCK_NAME) --project $(PROJ_NAME) --rtl-tag $(RTL_TAG) $(AI_FLAG); \
			touch $(POSTROUTE_DIR)/work/post_route_complete; \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "Post Route completed"; \
		else \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "ERROR: postroute flow did not complete. Skipping parse scripts."; \
			exit 1; \
		fi; \
	fi

chip_finish: postroute
	@if [ -f "$(RUN_DIR)/.orchestrator.lock" ]; then \
		echo "ERROR: Orchestrator run is active. Cannot run make directly."; \
		cat "$(RUN_DIR)/.orchestrator.lock" 2>/dev/null; exit 1; \
	fi
	@if [ -f "$(CHIP_FINISH_DIR)/work/chip_finish_complete" ]; then \
		echo "[SKIP] Chip finish already completed (remove $(CHIP_FINISH_DIR)/work/chip_finish_complete to rerun)"; \
	else \
		touch $(RUN_DIR)/.makefile.lock; \
		echo "Running chip_finish in $(CHIP_FINISH_DIR)"; \
		cd $(CHIP_FINISH_DIR)/work && \
		$(SRUN_PREFIX) innovus -stylus -files $(CHIPFINISH_TCL) | tee ../logs/chip_finish.log; \
		if [ -f "$(CHIP_FINISH_DIR)/work/chip_finish_flow_complete" ]; then \
			python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage chip_finish --stage-dir $(CHIP_FINISH_DIR) --run-dir $(RUN_DIR)/dashboard -runtag $(EXP_NAME) --block-name $(BLOCK_NAME) --project $(PROJ_NAME) --rtl-tag $(RTL_TAG) $(AI_FLAG); \
			touch $(CHIP_FINISH_DIR)/work/chip_finish_complete; \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "Chip Finish completed"; \
		else \
			rm -f $(RUN_DIR)/.makefile.lock; \
			echo "ERROR: chip_finish flow did not complete. Skipping parse scripts."; \
			exit 1; \
		fi; \
	fi

