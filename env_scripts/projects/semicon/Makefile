.EXPORT_ALL_VARIABLES:
.PHONY: all syn pnr pv rcextraction sta clean

SRUN ?= srun
SBATCH ?= sbatch
PARTITION ?= reg
CPUS ?= 16 
MEM ?= 16G

LOGDIR := $(EXP_DIR)/dashboard/logs
mkdir_logdir = mkdir -p $(LOGDIR)
# ----------------------------
# Default target
# ----------------------------
all: syn

# ----------------------------
# SYNTHESIS
# ----------------------------
syn:
	@$(mkdir_logdir)
	@echo "[SUBMIT] SYNTHESIS"
	@jid=`$(SBATCH) -p $(PARTITION) -c $(CPUS) --mem=$(MEM) \
		--job-name=syn \
		--output=$(LOGDIR)/syn.out \
		--wrap="cd syn && make syn"`; \
	echo $$jid | awk '{print $$4}' > $(LOGDIR)/syn.jid

# ----------------------------
# PNR (entire flow)
# ----------------------------
pnr: syn
	@jid_syn=`cat $(LOGDIR)/syn.jid`; \
	echo "[SUBMIT] PNR (after SYN $$jid_syn)"; \
	jid=`$(SBATCH) -p $(PARTITION) -c $(CPUS) --mem=$(MEM) \
		--dependency=afterok:$$jid_syn \
		--job-name=pnr \
		--output=$(LOGDIR)/pnr.out \
		--wrap="cd pnr && make all"`; \
	echo $$jid | awk '{print $$4}' > $(LOGDIR)/pnr.jid

# ----------------------------
# PV FLOW (parallel FEOL/BEOL)
# ----------------------------
pv: pnr
	@jid_pnr=`cat $(LOGDIR)/pnr.jid`; \
	echo "[SUBMIT] FEOL + BEOL (after PNR $$jid_pnr)"

	@jid_feol=`$(SBATCH) -p $(PARTITION) -c $(CPUS) --mem=$(MEM) \
		--dependency=afterok:$$jid_pnr \
		--job-name=feol_fill \
		--output=$(LOGDIR)/feol.out \
		--wrap="cd pv && make feol_fill"`; \
	echo $$jid_feol | awk '{print $$4}' > $(LOGDIR)/feol.jid

	@jid_beol=`$(SBATCH) -p $(PARTITION) -c $(CPUS) --mem=$(MEM) \
		--dependency=afterok:$$jid_pnr \
		--job-name=beol_fill \
		--output=$(LOGDIR)/beol.out \
		--wrap="cd pv && make beol_fill"`; \
	echo $$jid_beol | awk '{print $$4}' > $(LOGDIR)/beol.jid

	@jid_merge=`$(SBATCH) -p $(PARTITION) -c $(CPUS) --mem=$(MEM) \
		--dependency=afterok:`cat $(LOGDIR)/feol.jid`,`cat $(LOGDIR)/beol.jid` \
		--job-name=merge_fill \
		--output=$(LOGDIR)/merge.out \
		--wrap="cd pv && make merge_fill"`; \
	echo $$jid_merge | awk '{print $$4}' > $(LOGDIR)/merge.jid

	@echo "[SUBMIT] DRC + ANTENNA + V2LVS (after MERGE)"

	@$(SBATCH) -p $(PARTITION) -c $(CPUS) --mem=$(MEM) \
		--dependency=afterok:`cat $(LOGDIR)/merge.jid` \
		--job-name=drc \
		--output=$(LOGDIR)/drc.out \
		--wrap="cd pv && make run_calibre_drc" &

	@$(SBATCH) -p $(PARTITION) -c $(CPUS) --mem=$(MEM) \
		--dependency=afterok:`cat $(LOGDIR)/merge.jid` \
		--job-name=antenna \
		--output=$(LOGDIR)/antenna.out \
		--wrap="cd pv && make run_antenna" &

	@jid_v2lvs=`$(SBATCH) -p $(PARTITION) -c $(CPUS) --mem=$(MEM) \
		--dependency=afterok:`cat $(LOGDIR)/merge.jid` \
		--job-name=v2lvs \
		--output=$(LOGDIR)/v2lvs.out \
		--wrap="cd pv && make v2lvs"`; \
	echo $$jid_v2lvs | awk '{print $$4}' > $(LOGDIR)/v2lvs.jid

	@jid_lvs=`$(SBATCH) -p $(PARTITION) -c $(CPUS) --mem=$(MEM) \
		--dependency=afterok:`cat $(LOGDIR)/merge.jid`,`cat $(LOGDIR)/v2lvs.jid` \
		--job-name=lvs \
		--output=$(LOGDIR)/lvs.out \
		--wrap="cd pv && make run_calibre_lvs"`; \
	echo $$jid_lvs | awk '{print $$4}' > $(LOGDIR)/lvs.jid

# ----------------------------
# RC EXTRACTION (after BEOL)
# ----------------------------
rcextraction: pv
	@jid_beol=`cat $(LOGDIR)/beol.jid`; \
	echo "[SUBMIT] RCEXTRACTION (after BEOL $$jid_beol)"; \
	jid=`$(SBATCH) -p $(PARTITION) -c $(CPUS) --mem=$(MEM) \
		--dependency=afterok:$$jid_beol \
		--job-name=rcextraction \
		--output=$(LOGDIR)/rcx.out \
		--wrap="cd rcextraction && make all"`; \
	echo $$jid | awk '{print $$4}' > $(LOGDIR)/rcx.jid

# ----------------------------
# STA (after RC extraction)
# ----------------------------
sta: rcextraction
	@jid_rcx=`cat $(LOGDIR)/rcx.jid`; \
	echo "[SUBMIT] STA (after RCX $$jid_rcx)"; \
	$(SBATCH) -p $(PARTITION) -c $(CPUS) --mem=$(MEM) \
		--dependency=afterok:$$jid_rcx \
		--job-name=sta \
		--output=$(LOGDIR)/sta.out \
		--wrap="cd sta && make all"

# ----------------------------
# Clean
# ----------------------------
clean:
	rm -rf $(LOGDIR)

