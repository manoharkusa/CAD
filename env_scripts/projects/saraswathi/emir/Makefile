.EXPORT_ALL_VARIABLES :
.PHONY :
# User Parameters

RUNTAG ?= run1
SDC ?= /proj1/pd/users/testcase/Bharath/test_designs/aes_180nm/aes_cipher_top/inputs/aes_cipher_top.sdc
RTL_FILELIST ?= /proj1/pd/users/testcase/TESTCASES/test_designs_central/aes_core/file_list_fixed.tcl
BLOCK_NAME ?= $(BLOCK_NAME) 
# Directory Paths
#PROJ_DIR := /proj1/pd/users/testcase/Bharath/proj/flow28nm
#RUN_DIR := $(PROJ_DIR)/$(BLOCK_NAME)/$(RUNTAG)
RUN_DIR := $(EXP_DIR)
SYNTH_DIR := $(RUN_DIR)/syn
#PNR_BASE_DIR := $(RUN_DIR)/pnr
#INIT_DIR := $(PNR_BASE_DIR)/init
#FLOORPLAN_DIR := $(PNR_BASE_DIR)/floorplan
#PLACE_DIR := $(PNR_BASE_DIR)/place
#CTS_DIR := $(PNR_BASE_DIR)/cts
#POSTCTS_DIR := $(PNR_BASE_DIR)/postcts
#ROUTE_DIR := $(PNR_BASE_DIR)/route
#POSTROUTE_DIR := $(PNR_BASE_DIR)/postroute
#CHIP_FINISH_DIR := $(PNR_BASE_DIR)/chip_finish
#TOOL_SCRIPTS := $(PROJ_DIR)/$(BLOCK_NAME)/tool_scripts

#PV_BASE_DIR := $(RUN_DIR)/pv
# SLURM Parameters (can be overridden on command line)
PARTITION ?= g11v2      # default partition
CPUS_PER_TASK ?= 2            # default cores
MEM ?= 4G                     # default memory
SRUN ?= srun                  # srun command
NUM_CORES ?= 8

TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")

# Main Targets
all: clean setup syn pnr_clean pnr_setup init_design floorplan place cts post_cts route postroute chip_finish
pnr: pnr_clean pnr_setup init_design floorplan place cts post_cts route postroute chip_finish 

# Target 1: Clean existing run
clean:
	@echo "Cleaning existing run:$(SYNTH_DIR)" 
	@if [ -d "$(SYNTH_DIR)" ]; then \
        	rm -rf $(SYNTH_DIR)/*; \
        	echo "Cleaned the  $(SYNTH_DIR)/"; \
    	else \
        	echo "No existing run found"; \
    	fi
	@echo "Clean completed"

# Target 2: Setup directory structure
setup: clean
	@echo "Setting up directory structure for $(BLOCK_NAME)/$(RUNTAG)"
	@# Synthesis directories
	@mkdir -p $(SYNTH_DIR)/{inputs,logs,reports,outputs}
	@echo "Created directory structure:"
	@tree $(RUN_DIR) -L 3
	@touch $(SYNTH_DIR)/.setup_done

# Target 3: Run Synthesis
syn: $(SYNTH_DIR)/.setup_done
	@echo "Starting synthesis in $(SYNTH_DIR)"
	@echo "Using synthesis script $(ENV_SCRIPTS)/genus/genus_syn.tcl"
	@echo "Submitting via srun: partition=$(PARTITION), cpus-per-task=$(CPUS_PER_TASK), mem=$(MEM)"
	@cd $(SYNTH_DIR) && \
		$(SRUN) -p $(PARTITION) \
		        --cpus-per-task=$(CPUS_PER_TASK) \
		        --mem=$(MEM) \
		        genus -files $(ENV_SCRIPTS)/genus/genus_syn.tcl | tee ./logs/genus_syn_$(TIMESTAMP).log
	@touch $(SYNTH_DIR)/synth_complete
	@echo "Synthesis completed"


# Target 4: pnr clean
pnr_clean: $(SYNTH_DIR)/synth_complete
	@echo "Cleaning existing PnR run: $(PNR_BASE_DIR)"
	@if [ -d "$(PNR_BASE_DIR)" ]; then \
        	rm -rf $(PNR_BASE_DIR); \
        	echo "Removed $(PNR_BASE_DIR)"; \
    	else \
        	echo "No existing PnR run found"; \
    	fi
	@echo "$(PNR_BASE_DIR) Clean completed"

# Target 5: pnr setup
pnr_setup: pnr_clean 
	@echo "Setting up directory structure for PnR stages under $(PNR_BASE_DIR)"
	@# Create directories for each PnR stage with inputs, logs, reports, outputs
	@mkdir -p $(INIT_DIR)/{inputs,logs,reports,outputs}
	@mkdir -p $(FLOORPLAN_DIR)/{inputs,logs,reports,outputs}
	@mkdir -p $(PLACE_DIR)/{inputs,logs,reports,outputs}
	@mkdir -p $(CTS_DIR)/{inputs,logs,reports,outputs}
	@mkdir -p $(POSTCTS_DIR)/{inputs,logs,reports,outputs}
	@mkdir -p $(ROUTE_DIR)/{inputs,logs,reports,outputs}
	@mkdir -p $(POSTROUTE_DIR)/{inputs,logs,reports,outputs}
	@mkdir -p $(CHIP_FINISH_DIR)/{inputs,logs,reports,outputs}
	@echo "Created PnR stage directory structure:"
	@tree $(PNR_BASE_DIR) -L 3
	@touch $(INIT_DIR)/.setup_done


# Target : Init design
init_design: $(INIT_DIR)/.setup_done $(SYNTH_DIR)/synth_complete
	@echo "Starting init_design in $(INIT_DIR)"
	@echo "Using init_design script $(TOOL_SCRIPTS)/design_init.tcl"
	@cd $(INIT_DIR) && innovus -stylus -files $(TOOL_SCRIPTS)/design_init.tcl | tee ./logs/innovus_init_design_$(TIMESTAMP).log  
	@touch $(INIT_DIR)/init_design_complete
	@echo "init_design completed"

# Target : Floorplan
floorplan: $(INIT_DIR)/init_design_complete 
	@echo "Starting floorplan in $(FLOORPLAN_DIR)"
	@echo "Using floorplan script $(TOOL_SCRIPTS)/floorplan.tcl"
	@cd $(FLOORPLAN_DIR) && innovus -stylus -files $(TOOL_SCRIPTS)/floorplan.tcl | tee ./logs/innovus_floorplan_$(TIMESTAMP).log  
	@touch $(FLOORPLAN_DIR)/floorplan_complete
	@echo "floorplan completed"

# Target : Place opt 
place: $(FLOORPLAN_DIR)/floorplan_complete 
	@echo "Starting place in $(PLACE_DIR)"
	@echo "Using place script $(TOOL_SCRIPTS)/place.tcl"
	@cd $(PLACE_DIR) && innovus -stylus -files $(TOOL_SCRIPTS)/place.tcl | tee ./logs/innovus_place_$(TIMESTAMP).log  
	@touch $(PLACE_DIR)/place_complete
	@echo "place completed"
# Target : CTS
cts: $(PLACE_DIR)/place_complete 
	@echo "Starting CTS in $(CTS_DIR)"
	@echo "Using CTS script $(TOOL_SCRIPTS)/cts.tcl"
	@cd $(CTS_DIR) && innovus -stylus -files $(TOOL_SCRIPTS)/cts.tcl | tee ./logs/innovus_cts_$(TIMESTAMP).log  
	@touch $(CTS_DIR)/cts_complete
	@echo "CTS completed"

# Target : Post CTS
post_cts: $(CTS_DIR)/cts_complete 
	@echo "Starting Post CTS in $(POSTCTS_DIR)"
	@echo "Using Post CTS script $(TOOL_SCRIPTS)/post_cts.tcl"
	@cd $(POSTCTS_DIR) && innovus -stylus -files $(TOOL_SCRIPTS)/post_cts.tcl | tee ./logs/innovus_post_cts_$(TIMESTAMP).log  
	@touch $(POSTCTS_DIR)/postcts_complete
	@echo "Post CTS completed"

# Target : Route
route: $(POSTCTS_DIR)/postcts_complete 
	@echo "Starting route in $(ROUTE_DIR)"
	@echo "Using route script $(TOOL_SCRIPTS)/route.tcl"
	@cd $(ROUTE_DIR) && innovus -stylus -files $(TOOL_SCRIPTS)/route.tcl | tee ./logs/innovus_route_$(TIMESTAMP).log  
	@touch $(ROUTE_DIR)/route_complete
	@echo "Route completed"

# Target : Post Route
postroute: $(ROUTE_DIR)/route_complete 
	@echo "Starting post route in $(POSTROUTE_DIR)"
	@echo "Using post route script $(TOOL_SCRIPTS)/post_route.tcl"
	@cd $(POSTROUTE_DIR) && innovus -stylus -files $(TOOL_SCRIPTS)/post_route.tcl | tee ./logs/innovus_post_route_$(TIMESTAMP).log  
	@touch $(POSTROUTE_DIR)/post_route_complete
	@echo "Post Route completed"

# Target : Chip Finish
chip_finish: $(POSTROUTE_DIR)/post_route_complete 
	@echo "Starting chip finish in $(CHIP_FINISH_DIR)"
	@echo "Using chip finish script $(TOOL_SCRIPTS)/chip_finish.tcl"
	@cd $(CHIP_FINISH_DIR) && innovus -stylus -files $(TOOL_SCRIPTS)/chip_finish.tcl | tee ./logs/innovus_chip_finish_$(TIMESTAMP).log  
	@touch $(CHIP_FINISH_DIR)/chip_finish_complete
	@echo "Chip Finish completed"

# Target : pv clean
pv_clean: $(CHIP_FINISH_DIR)/chip_finish_complete
	@echo "Cleaning existing PV run: $(PV_BASE_DIR)"
	@if [ -d "$(PV_BASE_DIR)" ]; then \
        	rm -rf $(PV_BASE_DIR); \
        	echo "Removed $(PV_BASE_DIR)"; \
    	else \
        	echo "No existing PV run found"; \
    	fi
	@echo "$(PV_BASE_DIR) Clean completed"

# Target : pv setup
pv_setup: pv_clean
	@echo "Setting up directory structure for PV stages under $(PV_BASE_DIR)"
	@# Create directories for each PV stage
	@mkdir -p $(PV_BASE_DIR)/{drc,lvs,feol_fill,beol_fill,merge_fill,antenna,cdl}

feol_fill:
	cd $(PV_BASE_DIR)/feol_fill; rm -rf inputs log reports outputs; \
        mkdir inputs log reports outputs; \
	ln -s $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).merged.gds.gz ./inputs/.; \
	export GDS_PATH="$(PV_BASE_DIR)/feol_fill/inputs/$(BLOCK_NAME).merged.gds.gz"; \
	echo "LAYOUT PATH \"$$GDS_PATH\"" > feol_runset; \
        cat $(TOOL_SCRIPTS)/pv/feol_runset.tcl >> feol_runset; \
        sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" feol_runset; \
        calibre -turbo 2 -hier -drc feol_runset | tee ./log/feol_fill.log; \
	mv ${BLOCK_NAME}_FEOL.gds ./outputs/; \
	mv ${BLOCK_NAME}.summary ./reports/;

beol_fill:
	cd $(PV_BASE_DIR)/beol_fill; rm -rf inputs log reports outputs; \
        mkdir inputs log reports outputs; \
	ln -s $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).merged.gds.gz ./inputs/.; \
	export GDS_PATH="$(PV_BASE_DIR)/beol_fill/inputs/$(BLOCK_NAME).merged.gds.gz"; \
	echo "LAYOUT PATH \"$$GDS_PATH\"" > beol_runset; \
        cat $(TOOL_SCRIPTS)/pv/beol_runset.tcl >> beol_runset; \
        sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" beol_runset; \
        calibre -turbo 2 -hier -drc beol_runset | tee ./log/beol_fill.log; \
	mv ${BLOCK_NAME}_BEOL.gds ./outputs/; \
	mv ${BLOCK_NAME}.summary ./reports/;

merge_fill:
	cd $(PV_BASE_DIR)/merge_fill; rm -rf inputs log reports outputs; \
	mkdir inputs log reports outputs; \
	ln -s $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).merged.gds.gz ./inputs/.; \
	export GDS_PATH="$(PV_BASE_DIR)/merge_fill/inputs/$(BLOCK_NAME).merged.gds.gz"; \
        echo "set design_gds \"$$GDS_PATH\"" > merge_gds_block.tcl; \
        cat $(TOOL_SCRIPTS)/pv/merge_gds.tcl >> merge_gds_block.tcl; \
        sed -i "s/TEST_BLOCK/${BLOCK_NAME}/"  merge_gds_block.tcl; \
        calibredrv -s ./merge_gds_block.tcl -threads 2 | tee ./log/merge_gds.log;

run_calibre_drc:
	cd $(PV_BASE_DIR)/drc; rm -rf inputs log reports outputs; \
	mkdir inputs log reports outputs; \
	export GDS_PATH="$(PV_BASE_DIR)/merge_fill/outputs/$(BLOCK_NAME).merged_fill.gds.gz"; \
	echo "LAYOUT PATH \"$$GDS_PATH\"" > drc_runset; \
        cat $(TOOL_SCRIPTS)/pv/DRC_runset.tcl >> drc_runset; \
        sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" drc_runset; \
        calibre -turbo 2 -hier -drc drc_runset | tee ./log/calibre_drc.log;


innovus_interactive: 
	@echo "Starting interactive in $(POSTROUTE_DIR)"
	@cd $(POSTROUTE_DIR) && innovus -stylus | tee ./logs/innovus_interactive_$(TIMESTAMP).log  


.PHONY: all clean setup syn pnr_clean pnr_setup init_design floorplan place cts post_cts route postroute chip_finish 
