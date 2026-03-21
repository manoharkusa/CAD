.EXPORT_ALL_VARIABLES:
.PHONY: all pv pv_fill pv_signoff status pv_clean feol_fill beol_fill merge_fill run_calibre_drc run_calibre_lvs run_antenna v2lvs

BLOCK_NAME ?= $(BLOCK_NAME) 

RUN_DIR := $(EXP_DIR)
PV_BASE_DIR := $(RUN_DIR)/pv
CHIP_FINISH_DIR := $(RUN_DIR)/pnr/chip_finish
ENABLE_AI ?= 0
# SLURM
PARTITION ?= reg
CPUS_PER_TASK ?= 2
MEM ?= 4G
SRUN ?= srun
TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")

FEOL_FILL_DIR  := $(PV_BASE_DIR)/feol_fill
BEOL_FILL_DIR  :=  $(PV_BASE_DIR)/beol_fill
MERGE_FILL_DIR := $(PV_BASE_DIR)/merge_fill
CALIBRE_DRC_DIR:=  $(PV_BASE_DIR)/run_calibre_drc
ANTENNA_DIR    := $(PV_BASE_DIR)/run_antenna
V2LVS_DIR      := $(PV_BASE_DIR)/v2lvs
CALIBRE_LVS_DIR:= $(PV_BASE_DIR)/run_calibre_lvs
# PV scripts (from project tools)
PV_FEOL_TCL := $(ENV_SCRIPTS)/pv/feol_runset.rule
PV_BEOL_TCL := $(ENV_SCRIPTS)/pv/beol_runset.rule
PV_MERGE_TCL:= $(ENV_SCRIPTS)/pv/merge_gds.tcl
PV_DRC_TCL  := $(ENV_SCRIPTS)/pv/DRC_runset.rule
PV_ANT_TCL  := $(ENV_SCRIPTS)/pv/Antenna_calibre_runset.rule
PV_LVS_TCL  := $(ENV_SCRIPTS)/pv/lvs_calibre_runset.rule


ifeq ($(ENABLE_AI),1)
      AI_FLAG := --enable-ai
else
      AI_FLAG :=
endif

# Default: full PV (as you defined)
all: pv

# Full PV chain
pv: pv_clean pv_fill pv_signoff

# Fill-only chain (often used before signoff)
pv_fill: feol_fill beol_fill merge_fill

# Signoff chain (depends on merge output + netlist conversion)
pv_signoff: run_calibre_drc run_antenna v2lvs run_calibre_lvs

status:
	@echo "PV status under: $(PV_BASE_DIR)"
	@for d in feol_fill beol_fill merge_fill drc antenna cdl lvs ; do \
		if [ -d "$(PV_BASE_DIR)/$$d" ]; then echo "DIR  : $(PV_BASE_DIR)/$$d"; else echo "MISS : $(PV_BASE_DIR)/$$d"; fi; \
	done
	@echo "Tip: run 'make pv_fill' then 'make pv_signoff'"

pv_clean:
	@echo "Cleaning PV contents under $(PV_BASE_DIR) (keeping dirs)"
	@if [ -d "$(PV_BASE_DIR)" ]; then \
		rm -rf $(PV_BASE_DIR)/*/inputs  $(PV_BASE_DIR)/*/logs $(PV_BASE_DIR)/*/reports $(PV_BASE_DIR)/*/outputs 2>/dev/null || true; \
		echo "PV clean done."; \
	else \
		echo "ERROR: $(PV_BASE_DIR) not found"; exit 1; \
	fi

feol_fill:
	cd $(PV_BASE_DIR)/feol_fill; rm -rf inputs logs reports outputs; \
	mkdir inputs logs reports outputs; \
	ln -s $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).merged.gds.gz ./inputs/.; \
	export GDS_PATH="$(PV_BASE_DIR)/feol_fill/inputs/$(BLOCK_NAME).merged.gds.gz"; \
	echo "LAYOUT PATH \"$$GDS_PATH\"" > feol_runset; \
	cat $(PV_FEOL_TCL) >> feol_runset; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" feol_runset; \
	$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
	calibre -turbo 2 -hier -drc feol_runset | tee ./logs/feol_fill_$(TIMESTAMP).logs; \
	mv ${BLOCK_NAME}_FEOL.gds ./outputs/; \
	mv ${BLOCK_NAME}.summary ./reports/;
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage feol_fill --stage-dir $(FEOL_FILL_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG);

beol_fill:
	cd $(PV_BASE_DIR)/beol_fill; rm -rf inputs logs reports outputs; \
	mkdir inputs logs reports outputs; \
	ln -s $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).merged.gds.gz ./inputs/.; \
	export GDS_PATH="$(PV_BASE_DIR)/beol_fill/inputs/$(BLOCK_NAME).merged.gds.gz"; \
	echo "LAYOUT PATH \"$$GDS_PATH\"" > beol_runset; \
	cat $(PV_BEOL_TCL) >> beol_runset; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" beol_runset; \
	$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
	calibre -turbo 2 -hier -drc beol_runset | tee ./logs/beol_fill_$(TIMESTAMP).logs; \
	mv ${BLOCK_NAME}_BEOL.gds ./outputs/; \
	mv ${BLOCK_NAME}.summary ./reports/;
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage beol_fill --stage-dir $(BEOL_FILL_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG);

merge_fill:
	cd $(PV_BASE_DIR)/merge_fill; rm -rf inputs log reports outputs; \
	mkdir inputs log reports outputs; \
	ln -s $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).merged.gds.gz ./inputs/.; \
	export GDS_PATH="$(PV_BASE_DIR)/merge_fill/inputs/$(BLOCK_NAME).merged.gds.gz"; \
	echo "set design_gds \"$$GDS_PATH\"" > merge_gds_block.tcl; \
	cat $(PV_MERGE_TCL) >> merge_gds_block.tcl; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" merge_gds_block.tcl; \
	$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
	calibredrv -s ./merge_gds_block.tcl -threads 2 | tee ./log/merge_gds_$(TIMESTAMP).log;
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage merge_fill --stage-dir $(MERGE_FILL_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG);

run_calibre_drc: merge_fill
	cd $(PV_BASE_DIR)/drc; rm -rf inputs logs reports outputs; \
	mkdir inputs logs reports outputs; \
	export GDS_PATH="$(PV_BASE_DIR)/merge_fill/outputs/$(BLOCK_NAME).merged_fill.gds.gz"; \
	echo "LAYOUT PATH \"$$GDS_PATH\"" > drc_runset; \
	cat $(PV_DRC_TCL) >> drc_runset; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" drc_runset; \
	$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
	calibre -turbo 2 -hier -drc drc_runset | tee ./logs/calibre_drc_$(TIMESTAMP).log;
	mv $(PV_BASE_DIR)/drc/${BLOCK_NAME}.db $(PV_BASE_DIR)/drc/outputs/; \
	mv $(PV_BASE_DIR)/drc/${BLOCK_NAME}.summary $(PV_BASE_DIR)/drc/reports/;
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage run_calibre_drc --stage-dir $(CALIBRE_DRC_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG);

run_antenna: merge_fill
	cd $(PV_BASE_DIR)/antenna; rm -rf inputs log reports outputs; \
	mkdir inputs logs reports outputs; \
	export GDS_PATH="$(PV_BASE_DIR)/merge_fill/outputs/$(BLOCK_NAME).merged_fill.gds.gz"; \
	echo "LAYOUT PATH \"$$GDS_PATH\"" > antenna_runset; \
	cat $(PV_ANT_TCL) >> antenna_runset; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" antenna_runset; \
	$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
	calibre -turbo 2 -hier -drc antenna_runset | tee ./logs/calibre_antenna_$(TIMESTAMP).log;
	mv $(PV_BASE_DIR)/antenna/${BLOCK_NAME}.db $(PV_BASE_DIR)/antenna/outputs/; \
	mv $(PV_BASE_DIR)/antenna/${BLOCK_NAME}.summary $(PV_BASE_DIR)/antenna/reports/;
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage run_antenna --stage-dir $(ANTENNA_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG);

v2lvs:
	cd $(PV_BASE_DIR)/cdl; rm -rf inputs logs reports outputs; \
	mkdir inputs logs reports outputs; \
	ln -s $(CHIP_FINISH_DIR)/outputs/$(BLOCK_NAME).fill.pg.vg ./inputs/.; \
	v2lvs -v ./inputs/$(BLOCK_NAME).fill.pg.vg -o ./outputs/$(BLOCK_NAME).cdl \
		-s /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140lvt_180b/AN61001_20180509/TSMCHOME/digital/Back_End/spice/tcbn28hpcplusbwp40p140lvt_110a/tcbn28hpcplusbwp40p140lvt_110a.spi \
		-s /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140_180b/AN61001_20180509/TSMCHOME/digital/Back_End/spice/tcbn28hpcplusbwp40p140_110a/tcbn28hpcplusbwp40p140_110a.spi \
		-s /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140hvt_180a/AN61001_20180829/TSMCHOME/digital/Back_End/spice/tcbn28hpcplusbwp40p140hvt_110a/tcbn28hpcplusbwp40p140hvt_110a.spi | tee ./logs/v2cdl_$(TIMESTAMP).logs;
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage v2lvs --stage-dir $(V2LVS_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG);

run_calibre_lvs: v2lvs
	cd $(PV_BASE_DIR)/lvs; rm -rf inputs logs reports outputs; \
	mkdir inputs logs reports outputs; \
	ln -s $(CHIP_FINISH_DIR)/outputs/hcell.list ./inputs/.; \
	cat $(PV_LVS_TCL) > lvscalibre_runset; \
	sed -i "s/TEST_BLOCK/${BLOCK_NAME}/" lvscalibre_runset; \
	$(SRUN) -p $(PARTITION) --cpus-per-task=$(CPUS_PER_TASK) --mem=$(MEM) \
	calibre -turbo 2 -hier -hcell ./inputs/hcell.list -lvs lvscalibre_runset | tee ./logs/calibre_lvs_$(TIMESTAMP).log;
	mv $(PV_BASE_DIR)/lvs/${BLOCK_NAME}_erc.db $(PV_BASE_DIR)/lvs/outputs/; \
	mv $(PV_BASE_DIR)/lvs/${BLOCK_NAME}_erc.summary $(PV_BASE_DIR)/lvs/reports/;
	@python3 $(ENV_SCRIPTS)/parse_scripts/collect_metrics.py --stage run_calibre_lvs --stage-dir $(CALIBRE_LVS_DIR) --run-dir $(RUN_DIR)/dashboard $(AI_FLAG);

