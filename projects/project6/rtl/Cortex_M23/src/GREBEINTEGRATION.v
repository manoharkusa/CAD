//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016,2021-2023 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//   Release Information   : AT621-MN-70005-r2p0-00rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------



`include "grebe_defs.v"

module GREBEINTEGRATION
  #( `GRB_TOP_PARAM_DECL)
  (
     input  wire        FCLK,
     input  wire        SCLK,
     input  wire        HCLK,
     input  wire        DCLK,

     input  wire        nPORESET,
     input  wire        nSYSPORESET,
     input  wire        nHRESET,
     input  wire        nDBGRESET,

     input  wire        HREADY,
     output wire [1:0]  HTRANS,
     output wire [2:0]  HSIZE,
     output wire        HWRITE,
     output wire [6:0]  HPROT,
     output wire        HNONSEC,
     output wire [2:0]  HBURST,
     output wire        HEXCL,
     output wire [31:0] HADDR,
     output wire [31:0] HWDATA,
     input  wire [31:0] HRDATA,
     input  wire        HRESP,
     input  wire        HEXOKAY,
     output wire        HMASTER,

     input  wire        HREADYCHK,
     input  wire [ 3:0] HRDATACHK,
     input  wire        HRESPCHK,
     output wire        HTRANSCHK,
     output wire [ 3:0] HADDRCHK,
     output wire [ 3:0] HWDATACHK,
     output wire        HCTRLCHK1,
     output wire        HCTRLCHK2,
     output wire        HPROTCHK,

     output wire        SPECHTRANS,
     output wire        CODENSEQ,
     output wire [3:0]  CODEHINT,
     output wire [1:0]  DATAHINT,

     input  wire         ATREADYE,
     output wire         ATVALIDE,
     output wire  [7:0]  ATDATAE,
     output wire  [6:0]  ATIDE,
     input  wire         AFVALIDE,
     output wire         AFREADYE,


     input  wire        ETMFIFOFULLEN,
     output wire        ETMPWRUP,
     output wire        ETMEN,
     output wire        ETMTRIGOUT,
     input  wire [47:0] TSVALUEB,
     input  wire        TSCLKCHANGE,

     input  wire         PSELT,
     input  wire         PENABLET,
     input  wire [11:2]  PADDRT,
     input  wire         PWRITET,
     input  wire [2:0]   PPROTT,
     input  wire [3:0]   PSTRBT,
     input  wire [31:0]  PWDATAT,
     output wire [31:0]  PRDATAT,
     output wire         PREADYT,
     output wire         PSLVERRT,

     input  wire         PSELC,
     input  wire         PENABLEC,
     input  wire [11:2]  PADDRC,
     input  wire         PWRITEC,
     input  wire [2:0]   PPROTC,
     input  wire [3:0]   PSTRBC,
     input  wire [31:0]  PWDATAC,
     output wire [31:0]  PRDATAC,
     output wire         PREADYC,
     output wire         PSLVERRC,

     input  wire [31:0] MTBSRAMBASE,
     input  wire        HREADYM,
     output wire        HREADYOUTM,
     input  wire [1:0]  HTRANSM,
     input  wire [31:0] HADDRM,
     input  wire [3:0]  HPROTM,
     input  wire [2:0]  HSIZEM,
     input  wire [2:0]  HBURSTM,
     input  wire        HWRITEM,
     input  wire [31:0] HWDATAM,
     input  wire        HSELRAMM,
     input  wire        HSELSFRM,
     output wire [31:0] HRDATAM,
     output wire        HRESPM,

     output wire        RAMHCLK,
     output wire        RAMCS,
     output wire [3:0]  RAMWE,
     output wire [MTBAWIDTH-3:0] RAMAD,
     output wire [31:0] RAMWD,
     input  wire [31:0] RAMRD,

     input  wire        TSTART,
     input  wire        TSTOP,

     output wire        IOTRANS,
     output wire        IOWRITE,
     output wire [31:0] IOCHECK,
     input wire         IOMATCH,
     output wire [31:0] IOADDR,
     output wire [1:0]  IOSIZE,
     output wire        IOMASTER,
     output wire        IOPRIV,
     output wire        IONONSEC,
     output wire [31:0] IOWDATA,
     input wire  [31:0] IORDATA,

     output wire  [3:0] IOCHECKCHK,
     input  wire        IOMATCHCHK,
     output wire  [3:0] IOADDRCHK ,
     output wire        IOTRANSCHK,
     output wire        IOCTRLCHK1,
     output wire  [3:0] IOWDATACHK,
     output wire        IOCTRLCHK2,
     input  wire  [3:0] IORDATACHK,

     output wire        HREADYD,
     input  wire [1:0]  HTRANSD,
     input  wire [1:0]  HSIZED,
     input  wire [6:0]  HPROTD,
     input  wire        HNONSECD,
     input  wire        HWRITED,
     input  wire [31:0] HADDRD,
     input  wire [31:0] HWDATAD,
     output wire [31:0] HRDATAD,
     output wire        HRESPD,

     input  wire [3:0]  CTICHIN,
     output wire [3:0]  CTICHOUT,
     output wire [1:0]  CTIIRQ,

     output wire        WAKEUP,
     input  wire        WICENREQ,
     output wire        WICENACK,
     output wire [241:0] WICSENSE,

     input  wire        SLEEPHOLDREQn,
     output wire        SLEEPHOLDACKn,
     output wire        SLEEPING,
     output wire        SLEEPDEEP,
     input  wire        DAPPWRUPREQ,
     output wire        DAPPWRUPACK,

     output wire        TXEV,
     input  wire        RXEV,
     input  wire [239:0] IRQ,
     input  wire        NMI,

     output wire        LOCKUP,
     output wire        HALTED,

     input  wire        DBGRESTART,
     output wire        DBGRESTARTED,
     input  wire        EDBGRQ,
     input  wire        NIDEN,
     input  wire        DBGEN,
     input  wire        SPIDEN,
     input  wire        SPNIDEN,

     input  wire        CFGSECEXT,
     input  wire [25:0] CFGSTCALIB,
     input  wire [25:0] CFGSTCALIBNS,

     input  wire [23:0] INITVTOR,
     input  wire [23:0] INITVTORNS,
     input  wire [31:0] ECOREVNUM,

     output wire [26:0] IDAUADDRA,
     input  wire        IDAUNSA,
     input  wire        IDAUNSCA,
     input  wire        IDAUIDVA,
     input  wire [7:0]  IDAUIDA,
     input  wire        IDAUNCHKA,

     output wire [26:0] IDAUADDRB,
     input  wire        IDAUNSB,
     input  wire        IDAUNSCB,
     input  wire        IDAUNCHKB,

     output wire [2:0]  DFE,

     output wire [1:0]  DBE,

     output wire        SYSRESETREQ,
     output wire        CURRNS,
     input  wire        STCLKEN,
     input  wire        STCLKENNS,
     input  wire        CPUWAIT,
     input  wire [7:0]  IRQLATENCY,
     output wire        GATEHCLK,
     input  wire        DFTSE,
     input  wire        DFTCGEN,
     input  wire        DFTRSTDISABLE,
     input  wire        FUSAEN,

     input  wire        SYSQREQN,
     output wire        SYSQACCEPTN,
     output wire        SYSQDENY,
     output wire        SYSQACTIVE,
     input  wire        DBGQREQN,
     output wire        DBGQACCEPTN,
     output wire        DBGQDENY,
     output wire        DBGQACTIVE

`ifdef ARM_GREBE_SRPG_ON
     ,
     input  wire        nISOLATESYS,
     input  wire        nPWRUPSYS,
     input  wire        nRETSYS,

     input  wire        nISOLATEDBG,
     input  wire        nPWRUPDBG
`endif
);


wire         core_dbgrestart;
wire         core_dbgrestarted;
wire         core_edbgrq;
wire         core_halted;
wire         mtb_tstart;
wire         mtb_tstop;

wire         nmi_pend;
wire [239:0] irq_pend;
wire         rxev_pend;

wire         wic_ds_req_n;
wire         wic_ds_ack_n;
wire [239:0] wic_mask_isr;
wire         wic_mask_nmi;
wire         wic_mask_rxev;
wire         wic_load;
wire         wic_clear;

wire         etm_psel;
wire         etm_penable;
wire         etm_nid_allowed;
wire         etm_pwrup;
wire         etm_valid;
wire [31:1]  etm_ia;
wire         etm_iccfail;
wire         etm_ibranch;
wire         etm_iindbr;
wire [2:0]   etm_intstat;
wire [8:0]   etm_intnum;
wire         etm_dvalid;
wire         etm_isb;
wire         etm_edbgrq;
wire         etm_trigout;
wire         etm_fifofull;
wire         etm_afready;
wire [3:0]   etm_cmpmatch;
wire [3:0]   etm_cmpmatch_inotd;

wire [3:0]   dwt_cmpmatch;

wire         mtb_iaexen;
wire [30:0]  mtb_iaex;
wire         mtb_iaexseq;
wire         mtb_atomic;

wire         mtb_edbgrq;

wire         cti_psel;
wire         cti_penable;
wire         cti_pready;
wire         cti_core_edbgrq;
wire         cti_core_dbgrestart;
wire [1:0]   cti_ext_irq;
wire         cti_mtb_tstart;
wire         cti_mtb_tstop;

wire [3:0]   cti_etm_extin;

wire [1:0]   etm_cti_trigout = {1'b0, etm_trigout};

wire         dbg_active;
wire         dbg_trcena;

wire [15:0]  unused = {PPROTC, PSTRBC, PPROTT, PSTRBT,
                      cti_etm_extin[3:2]};


assign core_edbgrq = EDBGRQ | etm_edbgrq | mtb_edbgrq | cti_core_edbgrq;
assign core_dbgrestart = DBGRESTART | cti_core_dbgrestart;

assign DBGRESTARTED = core_dbgrestarted;
assign HALTED = core_halted;

assign mtb_tstart = TSTART | cti_mtb_tstart;
assign mtb_tstop  = TSTOP  | cti_mtb_tstop;

wire core_idle_req_n;

`ifdef ARM_GREBEINTEGRATION_IS_CBAW
 `include "GREBEINTEGRATION_CBAW_inc.v"
`else
    localparam CBAW = 0;
`endif


`ifdef ARM_GREBE_DSM
GREBE_DSM #(`GRB_TOP_PARAM_INST) u_grebe
`else
GREBE #(`GRB_TOP_PARAM_INST) u_grebe
`endif

(
  .FCLK         (FCLK),
  .SCLK         (SCLK),
  .HCLK         (HCLK),
  .DCLK         (DCLK),
  .nSYSPORESET  (nSYSPORESET),
  .nDBGRESET    (nDBGRESET),
  .nHRESET      (nHRESET),

  .HREADY       (HREADY),
  .HTRANS       (HTRANS),
  .HSIZE        (HSIZE),
  .HWRITE       (HWRITE),
  .HPROT        (HPROT),
  .HNONSEC      (HNONSEC),
  .HBURST       (HBURST),
  .HEXCL        (HEXCL),
  .HADDR        (HADDR),
  .HWDATA       (HWDATA),
  .HRDATA       (HRDATA),
  .HRESP        (HRESP),
  .HEXOKAY      (HEXOKAY),
  .HMASTER      (HMASTER),

  .HREADYCHK    (HREADYCHK),
  .HRDATACHK    (HRDATACHK),
  .HRESPCHK     (HRESPCHK ),
  .HTRANSCHK    (HTRANSCHK),
  .HADDRCHK     (HADDRCHK ),
  .HWDATACHK    (HWDATACHK),
  .HCTRLCHK1    (HCTRLCHK1),
  .HCTRLCHK2    (HCTRLCHK2),
  .HPROTCHK     (HPROTCHK ),

  .SPECHTRANS   (SPECHTRANS),
  .CODENSEQ     (CODENSEQ),
  .CODEHINT     (CODEHINT),
  .DATAHINT     (DATAHINT),

  .HREADYD     (HREADYD),
  .HTRANSD     (HTRANSD),
  .HSIZED      (HSIZED),
  .HWRITED     (HWRITED),
  .HNONSECD    (HNONSECD),
  .HPROTD      (HPROTD),
  .HADDRD      (HADDRD),
  .HWDATAD     (HWDATAD),
  .HRDATAD     (HRDATAD),
  .HRESPD      (HRESPD),

  .ETMPWRUP     (etm_pwrup),
  .ETMIVALID    (etm_valid),
  .ETMIA        (etm_ia),
  .ETMICCFAIL   (etm_iccfail),
  .ETMIBRANCH   (etm_ibranch),
  .ETMIINDBR    (etm_iindbr),
  .ETMINTSTAT   (etm_intstat),
  .ETMINTNUM    (etm_intnum),
  .ETMDVALID    (etm_dvalid),
  .ETMISB       (etm_isb),
  .ETMCMPMATCH  (etm_cmpmatch),
  .ETMCMPINOTD  (etm_cmpmatch_inotd),

  .IOTRANS      (IOTRANS),
  .IOWRITE      (IOWRITE),
  .IOCHECK      (IOCHECK),
  .IOMATCH      (IOMATCH),
  .IOADDR       (IOADDR),
  .IOSIZE       (IOSIZE),
  .IOMASTER     (IOMASTER),
  .IOPRIV       (IOPRIV),
  .IONONSEC     (IONONSEC),
  .IOWDATA      (IOWDATA),
  .IORDATA      (IORDATA),

  .IOTRANSCHK   (IOTRANSCHK),
  .IOCHECKCHK   (IOCHECKCHK),
  .IOMATCHCHK   (IOMATCHCHK),
  .IOADDRCHK    (IOADDRCHK),
  .IOCTRLCHK1   (IOCTRLCHK1),
  .IOCTRLCHK2   (IOCTRLCHK2),
  .IOWDATACHK   (IOWDATACHK),
  .IORDATACHK   (IORDATACHK),

  .WICDSREQn    (wic_ds_req_n),
  .WICDSACKn    (wic_ds_ack_n),
  .WICMASKISR   (wic_mask_isr),
  .WICMASKNMI   (wic_mask_nmi),
  .WICMASKRXEV  (wic_mask_rxev),
  .WICLOAD      (wic_load),
  .WICCLEAR     (wic_clear),
  .DBGACTIVE    (dbg_active),
  .DBGTRCENA    (dbg_trcena),

  .SLEEPHOLDREQn(core_idle_req_n),
  .SLEEPHOLDACKn(SLEEPHOLDACKn),
  .SLEEPING     (SLEEPING),
  .SLEEPDEEP    (SLEEPDEEP),

  .TXEV         (TXEV),
  .RXEV         (rxev_pend),
  .IRQ          (irq_pend),
  .NMI          (nmi_pend),

  .LOCKUP       (LOCKUP),
  .HALTED       (core_halted),

  .DBGRESTART   (core_dbgrestart),
  .DBGRESTARTED (core_dbgrestarted),
  .EDBGRQ       (core_edbgrq),
  .NIDEN        (NIDEN),
  .DBGEN        (DBGEN),
  .SPIDEN       (SPIDEN),
  .SPNIDEN      (SPNIDEN),
  .CMPMATCH     (dwt_cmpmatch),

  .ETMNIDALLOWED  (etm_nid_allowed),

  .CFGSECEXT    (CFGSECEXT),
  .ECOREVNUM    (ECOREVNUM[19:0]),

  .INITVTOR     (INITVTOR),
  .INITVTORNS   (INITVTORNS),

  .IDAUADDRA    (IDAUADDRA),
  .IDAUNSA      (IDAUNSA),
  .IDAUNSCA     (IDAUNSCA),
  .IDAUIDVA     (IDAUIDVA),
  .IDAUIDA      (IDAUIDA),
  .IDAUNCHKA    (IDAUNCHKA),

  .IDAUADDRB    (IDAUADDRB),
  .IDAUNSB      (IDAUNSB),
  .IDAUNSCB     (IDAUNSCB),
  .IDAUNCHKB    (IDAUNCHKB),

  .IAEXEN       (mtb_iaexen),
  .IAEX         (mtb_iaex),
  .IAEXSEQ      (mtb_iaexseq),
  .ATOMIC       (mtb_atomic),

  .DFTCGEN      (DFTCGEN),
  .DFTRSTDISABLE(DFTRSTDISABLE),

  .SYSRESETREQ  (SYSRESETREQ),
  .CURRNS       (CURRNS),
  .CFGSTCALIB   (CFGSTCALIB),
  .STCLKEN      (STCLKEN),
  .CFGSTCALIBNS (CFGSTCALIBNS),
  .STCLKENNS    (STCLKENNS),
  .IRQLATENCY   (IRQLATENCY),
  .CPUWAIT      (CPUWAIT),
  .FUSAEN       (FUSAEN),

  .DBE          (DBE[1:0]),
  .DFE          (DFE[0])
);


generate
if ((DBG != 0 && CTI != 0) | (CBAW != 0))
begin: gen_grbcti

  GRBCTI
    #(`GRB_TOP_PARAM_INST)
  u_grb_cti
  (
    .clk                  (DCLK),
    .reset_n              (nDBGRESET),

    .cti_active_o         (),
    .ext_cti_revand_i     (ECOREVNUM[23:20]),

    .mtx_cti_psel_i       (cti_psel),
    .mtx_paddr_i          (PADDRC),
    .mtx_paddr31_i        (1'b0),
    .mtx_penable_i        (cti_penable),
    .mtx_pwrite_i         (PWRITEC),
    .mtx_pprot_i          (3'b000),
    .mtx_pwdata_i         (PWDATAC),
    .mtx_pstrb_i          (4'b0000),
    .cti_mtx_pready_o     (cti_pready),
    .cti_mtx_prdata_o     (PRDATAC),
    .cti_mtx_pslverr_o    (),

    .core_halted_i        (core_halted),
    .dwt_cmpmatch_i       (dwt_cmpmatch[3:0]),
    .etm_cti_extout_i     (etm_cti_trigout[1:0]),

    .cti_edbgrq_o         (cti_core_edbgrq),
    .cti_dbg_restart_o    (cti_core_dbgrestart),
    .nvic_dbg_restarted_i (core_dbgrestarted),
    .cti_ext_irq_o        (cti_ext_irq),
    .cti_etm_extin_o      (cti_etm_extin[3:0]),
    .cti_mtb_tstart_o     (cti_mtb_tstart),
    .cti_mtb_tstop_o      (cti_mtb_tstop),

    .ext_cti_chin_i       (CTICHIN[3:0]),
    .cti_ext_chout_o      (CTICHOUT[3:0]),

    .ext_dft_cgen_i        (DFTCGEN)
  );

end
else

begin: gen_no_grbcti

   assign PRDATAC             = {32{1'b0}};
   assign CTICHOUT[3:0]       = { 4{1'b0}};
   assign cti_pready          = 1'b1;
   assign cti_core_edbgrq     = 1'b0;
   assign cti_core_dbgrestart = 1'b0;
   assign cti_etm_extin       = { 4{1'b0}};
   assign cti_mtb_tstart      = 1'b0;
   assign cti_mtb_tstop       = 1'b0;
   assign cti_ext_irq         = { 2{1'b0}};

   wire unused = |{CTICHIN, etm_cti_trigout, cti_penable, ECOREVNUM[23:20],
                   PADDRC, PWRITEC, PWDATAC};

end
endgenerate

assign CTIIRQ[1:0] = {2{DBGEN}} & cti_ext_irq;



generate
if ((DBG != 0 && ETM != 0) | (CBAW != 0))
begin: gen_grbetm

  localparam TRACE_LVL = (ETM != 0) ? 2 : 0;

  wire etm_core_halted = core_halted & etm_pwrup;

  GRBETM #(.TRACE_LVL(TRACE_LVL),
           .CLKGATE_PRESENT(ACG),
           .RESET_ALL_REGS(RAR))
  u_grb_etm
  (
    .FCLK       (DCLK),
    .PORESETn   (nDBGRESET),
    .NIDEN      (etm_nid_allowed),
    .FIFOFULLEN (ETMFIFOFULLEN),
    .ETMIA      (etm_ia),
    .ETMIVALID  (etm_valid),
    .ETMISTALL  (1'b0),
    .ETMDVALID  (etm_dvalid),
    .ETMFOLD    (1'b0),
    .ETMCANCEL  (1'b0),
    .ETMICCFAIL (etm_iccfail),
    .ETMIBRANCH (etm_ibranch),
    .ETMIINDBR  (etm_iindbr),
    .ETMISB     (etm_isb),
    .ETMINTSTAT (etm_intstat),
    .ETMINTNUM  (etm_intnum),
    .COREHALT   (etm_core_halted),
    .EXTIN      (cti_etm_extin[1:0]),
    .MAXEXTIN   (2'b10),
    .DWTMATCH   (etm_cmpmatch),
    .DWTINOTD   (etm_cmpmatch_inotd),
    .ATREADYM   (ATREADYE),
    .PSEL       (etm_psel),
    .PENABLE    (etm_penable),
    .PADDR      (PADDRT[11:2]),
    .PWRITE     (PWRITET),
    .PWDATA     (PWDATAT),
    .ETMREVAND  (ECOREVNUM[27:24]),

    .TSVALUEB   (TSVALUEB),
    .TSCLKCHANGE(TSCLKCHANGE),
    .SE         (DFTSE),
    .CGBYPASS   (DFTCGEN),
    .ETMPWRUP   (etm_pwrup),
    .ETMEN      (ETMEN),
    .PRDATA     (PRDATAT),
    .ATDATAM    (ATDATAE[7:0]),
    .ATVALIDM   (ATVALIDE),
    .AFREADYM   (etm_afready),
    .ETMTRIGOUT (etm_trigout),
    .ATIDM      (ATIDE),
    .ETMDBGRQ   (etm_edbgrq),
    .FIFOFULL   (etm_fifofull)
  );

  wire unused = {etm_fifofull};


`ifdef GREBE_ECS
 `include "grb_ecs.v"
`endif

end
else
begin: gen_no_grbetm

  assign etm_pwrup  = 1'b0;
  assign etm_edbgrq = 1'b0;
  assign etm_trigout  = 1'b0;
  assign etm_fifofull = 1'b0;
  assign etm_afready = 1'b0;

  assign PRDATAT    = 32'b0;
  assign ATDATAE    = 8'b0;
  assign ATVALIDE   = 1'b0;
  assign ATIDE      = 7'b0;
  assign ETMEN      = 1'b0;

  wire unused = |{etm_nid_allowed, etm_valid, etm_ia, etm_iccfail,
                  etm_ibranch, etm_iindbr, etm_intstat, etm_intnum,
                  etm_dvalid, etm_isb, etm_fifofull,
                  etm_penable, etm_cmpmatch, etm_cmpmatch_inotd,
                  PWRITET, PADDRT, PWDATAT, ECOREVNUM[27:24], ATREADYE,
                  ETMFIFOFULLEN, TSVALUEB, TSCLKCHANGE
                  };

end
endgenerate

  assign ETMPWRUP = etm_pwrup;
  assign ETMTRIGOUT = etm_trigout;


generate
if ((CTI == 0) && (MTB == 0) && (CBAW == 0))
begin: gen_nocti_nomtb
  wire unused = |dwt_cmpmatch;
end
endgenerate



wire  dbg_apb_powered_up;

generate
if ((DBG != 0) | (CBAW != 0))
begin: gen_grb_dbg_misc

  grb_dbg_misc
    #(`GRB_TOP_PARAM_INST)
  u_grb_dbg_misc
  (

  .dclk       (DCLK),
  .ndbgreset  (nDBGRESET),

  .afvalid_tpiu_i   (AFVALIDE),
  .afready_tpiu_o   (AFREADYE),
  .afready_etm_i    (etm_afready),


  .pselc_i          (PSELC),
  .penablec_i       (PENABLEC),
  .preadyc_i        (cti_pready),

  .pselt_i          (PSELT),
  .penablet_i       (PENABLET),

  .dbg_apb_powered_up_i (dbg_apb_powered_up),

  .pselc_o          (cti_psel),
  .penablec_o       (cti_penable),
  .preadyc_o        (PREADYC),
  .pslverrc_o       (PSLVERRC),

  .pselt_o          (etm_psel),
  .penablet_o       (etm_penable),
  .preadyt_o        (PREADYT),
  .pslverrt_o       (PSLVERRT));

   end
else
   begin: gen_no_grb_dbg_misc
     assign AFREADYE   = 1'b1;
     assign cti_psel   = 1'b0;
     assign cti_penable = 1'b0;
     assign PREADYC    = 1'b1;
     assign PSLVERRC   = 1'b0;
     assign etm_psel   = 1'b0;
     assign etm_penable = 1'b0;
     assign PREADYT    = 1'b1;
     assign PSLVERRT   = 1'b0;

     wire unused = |{etm_afready, cti_pready,
                     AFVALIDE,
                     PSELC, PENABLEC, PSELT, PENABLET};
   end
endgenerate



generate
if ((DBG != 0 && MTB != 0) | (CBAW != 0))
begin: gen_grbmtb

  wire        hclk_mtb;
  wire        idle_mtb;


  if ((ACG != 0) | (CBAW != 0))
  begin: gen_mtb_acg

    wire mtb_clock_enable = ~idle_mtb;

    grb_acg u_mtb_acg
    (  .CLKIN  (FCLK),
       .ENABLE (mtb_clock_enable),
       .DFTCGEN (DFTCGEN),
       .CLKOUT (hclk_mtb)
    );
  end
  else
  begin: gen_no_mtb_acg
    assign hclk_mtb = FCLK;
  end

  assign RAMHCLK = hclk_mtb;


  wire mtb_niden = etm_nid_allowed;
  wire mtb_dbgen = DBGEN;


  GRBMTB
    #(.MTBAWIDTH (MTBAWIDTH),
      .WPT       (WPT),
      .RESET_ALL_REGS(RAR)
  )
  u_grbmtb
  (
    .HCLK         (hclk_mtb),
    .RESETn       (nHRESET),
    .IDLE         (idle_mtb),

    .HADDR        (HADDRM[31:0]),
    .HBURST       (HBURSTM),
    .HMASTLOCK    (1'b0),
    .HPROT        (HPROTM),
    .HSIZE        (HSIZEM[2:0]),
    .HTRANS       (HTRANSM[1:0]),
    .HWDATA       (HWDATAM[31:0]),
    .HWRITE       (HWRITEM),
    .HSELRAM      (HSELRAMM),
    .HSELSFR      (HSELSFRM),
    .HREADY       (HREADYM),
    .HRDATA       (HRDATAM),
    .HREADYOUT    (HREADYOUTM),
    .HRESP        (HRESPM),

    .RAMRD        (RAMRD),
    .RAMAD        (RAMAD[MTBAWIDTH-3:0]),
    .RAMWD        (RAMWD[31:0]),
    .RAMCS        (RAMCS),
    .RAMWE        (RAMWE[3:0]),

    .IAEXSEQ      (mtb_iaexseq),
    .IAEXEN       (mtb_iaexen),
    .IAEX         (mtb_iaex),
    .ATOMIC       (mtb_atomic),
    .EDBGRQ       (mtb_edbgrq),

    .DWTMATCH     (dwt_cmpmatch),
    .TSTART       (mtb_tstart),
    .TSTOP        (mtb_tstop),
    .DBGEN        (mtb_dbgen),
    .NIDEN        (mtb_niden),
    .SRAMBASEADDR (MTBSRAMBASE),
    .ECOREVNUM    (ECOREVNUM[31:28])
  );

end
else
begin: gen_no_grbmtb

  assign mtb_edbgrq = 1'b0;

  assign HRDATAM       = 32'b0;
  assign HREADYOUTM    = 1'b1;
  assign HRESPM        = 1'b0;
  assign RAMHCLK       = 1'b0;
  assign RAMAD         = {(MTBAWIDTH-2){1'b0}};
  assign RAMWD         = 32'b0;
  assign RAMCS         = 1'b0;
  assign RAMWE         = {4{1'b0}};

  wire unused = |{ MTBSRAMBASE, HREADYM, HTRANSM,
                   HADDRM, HPROTM, HSIZEM, HBURSTM,
                   HWRITEM, HWDATAM, mtb_tstop, mtb_tstart,
                   mtb_iaexen, mtb_iaex, mtb_iaexseq, mtb_atomic,
                   RAMRD, ECOREVNUM[31:28], HSELSFRM, HSELRAMM};
end
endgenerate


generate
if ((WIC != 0) | (CBAW != 0))
begin: gen_wic

  grb_wic
  #( .IRQDIS_0 (IRQDIS_0),
     .IRQDIS_1 (IRQDIS_1),
     .IRQDIS_2 (IRQDIS_2),
     .IRQDIS_3 (IRQDIS_3),
     .IRQDIS_4 (IRQDIS_4),
     .IRQDIS_5 (IRQDIS_5),
     .IRQDIS_6 (IRQDIS_6),
     .IRQDIS_7 (IRQDIS_7),
     .WICLINES (WICLINES),
     .FLOPPARITY (FLOPPARITY)
  )
  u_wic
  (
    .WAKEUP      (WAKEUP),
    .WICSENSE    (WICSENSE),
    .WICPENDISR  (irq_pend[239:0]),
    .WICPENDNMI  (nmi_pend),
    .WICPENDRXEV (rxev_pend),
    .WICDSREQn   (wic_ds_req_n),
    .WICENACK    (WICENACK),
    .FCLK        (FCLK),
    .RESETn      (nHRESET),
    .WICLOAD     (wic_load),
    .WICCLEAR    (wic_clear),
    .IRQ         (IRQ),
    .NMI         (NMI),
    .RXEV        (RXEV),
    .WICMASKISR  (wic_mask_isr[239:0]),
    .WICMASKNMI  (wic_mask_nmi),
    .WICMASKRXEV (wic_mask_rxev),
    .WICENREQ    (WICENREQ),
    .WICDSACKn   (wic_ds_ack_n),
    .WICDFE      (DFE[1])
  );

end
else
begin: gen_nowic

  assign irq_pend     = IRQ;
  assign nmi_pend     = NMI;
  assign rxev_pend    = RXEV;
  assign wic_ds_req_n = 1'b1;

  assign WICSENSE = 242'b0;
  assign WAKEUP   = 1'b0;
  assign WICENACK = 1'b0;

  assign DFE[1] = 1'b0;

  wire unused = |{wic_ds_ack_n, wic_mask_isr, wic_mask_nmi, wic_mask_rxev, wic_load, wic_clear, WICENREQ};

end
endgenerate


 grb_qchannel
    #(.CBAW  (CBAW),
      `GRB_TOP_PARAM_INST)
   u_qchannel
(
  .clk                  (FCLK),
  .nPORESET             (nPORESET),
  .wakeup_i             (WAKEUP),
  .sleep_i              (SLEEPING),
  .nsleepholdack_i      (SLEEPHOLDACKn),
  .sysqreqn_i           (SYSQREQN),
  .sysqacceptn_o        (SYSQACCEPTN),
  .sysqdeny_o           (SYSQDENY),
  .sysqactive_o         (SYSQACTIVE),
  .dbg_active_i         (dbg_active),
  .dbg_trcena_i         (dbg_trcena),
  .dbg_etm_pwrup_i      (etm_pwrup),
  .dbg_etm_psel_i       (etm_psel),
  .dbg_etm_penable_i    (etm_penable),
  .dbg_cti_psel_i       (cti_psel),
  .dbg_cti_pready_i     (cti_pready),
  .dbg_apb_powered_up_o (dbg_apb_powered_up),
  .dap_pwrup_req_i      (DAPPWRUPREQ),
  .dap_pwrup_ack_o      (DAPPWRUPACK),
  .dbgqreqn_i           (DBGQREQN),
  .dbgqacceptn_o        (DBGQACCEPTN),
  .dbgqdeny_o           (DBGQDENY),
  .dbgqactive_o         (DBGQACTIVE),
  .sleepholdreqn_i      (SLEEPHOLDREQn),
  .core_idle_req_n_o    (core_idle_req_n),
  .fusaen_i             (FUSAEN),
  .dftse_i              (DFTSE),
  .flop_parity_fault_o  (DFE[2])
  );

assign GATEHCLK = (SLEEPING | ~SLEEPHOLDACKn) & ~DAPPWRUPACK;



endmodule
