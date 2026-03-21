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



# SLURM
PARTITION ?= reg
CPUS_PER_TASK ?= 2
MEM ?= 16G
SRUN ?= srun
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
		find $(PNR_BASE_DIR) -name "*_complete" -type f -delete 2>/dev/null || true; \
		echo "PnR clean done."; \
	else \
		echo "ERROR: $(PNR_BASE_DIR) not found"; exit 1; \
	fi

init_design:
	@if [ -f "$(INIT_DIR)/init_design_complete" ]; then \
		echo "[SKIP] Init design already completed (remove $(INIT_DIR)/init_design_complete to rerun)"; \
	else \
		echo "Running init_design in $(INIT_DIR)"; \
		cd $(INIT_DIR) && \
		$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
		innovus -stylus -files $(INIT_TCL) | tee ./logs/innovus_init_design_$(TIMESTAMP).log; \
		python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage init --stage-dir $(INIT_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG); \
		touch $(INIT_DIR)/init_design_complete; \
		echo "init_design completed"; \
	fi

floorplan: init_design
	@if [ -f "$(FLOORPLAN_DIR)/floorplan_complete" ]; then \
		echo "[SKIP] Floorplan already completed (remove $(FLOORPLAN_DIR)/floorplan_complete to rerun)"; \
	else \
		echo "Running floorplan in $(FLOORPLAN_DIR)"; \
		cd $(FLOORPLAN_DIR) && \
		$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
		innovus -stylus -files $(FP_TCL) | tee ./logs/innovus_floorplan_$(TIMESTAMP).log; \
		python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage floorplan --stage-dir $(FLOORPLAN_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG); \
		touch $(FLOORPLAN_DIR)/floorplan_complete; \
		echo "floorplan completed"; \
	fi

place: floorplan
	@if [ -f "$(PLACE_DIR)/place_complete" ]; then \
		echo "[SKIP] Place already completed (remove $(PLACE_DIR)/place_complete to rerun)"; \
	else \
		echo "Running place in $(PLACE_DIR)"; \
		cd $(PLACE_DIR) && \
		$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
		innovus -stylus -files $(PLACE_TCL) | tee ./logs/innovus_place_$(TIMESTAMP).log; \
		python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage place --stage-dir $(PLACE_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG); \
		touch $(PLACE_DIR)/place_complete; \
		echo "place completed"; \
	fi

cts: place
	@if [ -f "$(CTS_DIR)/cts_complete" ]; then \
		echo "[SKIP] CTS already completed (remove $(CTS_DIR)/cts_complete to rerun)"; \
	else \
		echo "Running CTS in $(CTS_DIR)"; \
		cd $(CTS_DIR) && \
		$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
		innovus -stylus -files $(CTS_TCL) | tee ./logs/innovus_cts_$(TIMESTAMP).log; \
		python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage cts --stage-dir $(CTS_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG); \
		touch $(CTS_DIR)/cts_complete; \
		echo "CTS completed"; \
	fi

post_cts: cts
	@if [ -f "$(POSTCTS_DIR)/postcts_complete" ]; then \
		echo "[SKIP] Post CTS already completed (remove $(POSTCTS_DIR)/postcts_complete to rerun)"; \
	else \
		echo "Running post_cts in $(POSTCTS_DIR)"; \
		cd $(POSTCTS_DIR) && \
		$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
		innovus -stylus -files $(POSTCTS_TCL) | tee ./logs/innovus_post_cts_$(TIMESTAMP).log; \
		python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage postcts --stage-dir $(POSTCTS_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG); \
		touch $(POSTCTS_DIR)/postcts_complete; \
		echo "Post CTS completed"; \
	fi

route: post_cts
	@if [ -f "$(ROUTE_DIR)/route_complete" ]; then \
		echo "[SKIP] Route already completed (remove $(ROUTE_DIR)/route_complete to rerun)"; \
	else \
		echo "Running route in $(ROUTE_DIR)"; \
		cd $(ROUTE_DIR) && \
		$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
		innovus -stylus -files $(ROUTE_TCL) | tee ./logs/innovus_route_$(TIMESTAMP).log; \
		python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage route --stage-dir $(ROUTE_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG); \
		touch $(ROUTE_DIR)/route_complete; \
		echo "Route completed"; \
	fi

postroute: route
	@if [ -f "$(POSTROUTE_DIR)/post_route_complete" ]; then \
		echo "[SKIP] Post route already completed (remove $(POSTROUTE_DIR)/post_route_complete to rerun)"; \
	else \
		echo "Running postroute in $(POSTROUTE_DIR)"; \
		cd $(POSTROUTE_DIR) && \
		$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
		innovus -stylus -files $(POSTROUTE_TCL) | tee ./logs/innovus_post_route_$(TIMESTAMP).log; \
		python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage postroute --stage-dir $(POSTROUTE_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG); \
		touch $(POSTROUTE_DIR)/post_route_complete; \
		echo "Post Route completed"; \
	fi

chip_finish: postroute
	@if [ -f "$(CHIP_FINISH_DIR)/chip_finish_complete" ]; then \
		echo "[SKIP] Chip finish already completed (remove $(CHIP_FINISH_DIR)/chip_finish_complete to rerun)"; \
	else \
		echo "Running chip_finish in $(CHIP_FINISH_DIR)"; \
		cd $(CHIP_FINISH_DIR) && \
		$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
		innovus -stylus -files $(CHIPFINISH_TCL) | tee ./logs/innovus_chip_finish_$(TIMESTAMP).log; \
		python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage chip_finish --stage-dir $(CHIP_FINISH_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG); \
		touch $(CHIP_FINISH_DIR)/chip_finish_complete; \
		echo "Chip Finish completed"; \
	fi

