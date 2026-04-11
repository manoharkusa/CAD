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

module GREBEINTEGRATION_MCU
#(
  `include "grb_sbistc_params.v"
  ,`GRB_TOP_PARAM_DECL
)
(
  input  wire        FCLK,
  input  wire        SCLK,
  input  wire        HCLK,
  input  wire        DCLK,
  input  wire        TRACECLKIN,
  input  wire        SWCLKTCK,

  input  wire        nPORESET,
  input  wire        nSYSPORESET,
  input  wire        nHRESET,
  input  wire        nDBGRESET,
  input  wire        nTRST,
  input  wire        nTRESET,

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

  output wire        TRACECLK,
  output wire [3:0]  TRACEDATA,
  output wire        TRACESWO,
  output wire        SWOACTIVE,
  output wire        TPIUACTV,
  output wire        TPIUBAUD,
  output wire [1:0]  TRACEPORTSIZE,

  input  wire        ETMFIFOFULLEN,
  output wire        ETMPWRUP,
  output wire        ETMEN,
  input  wire [47:0] TSVALUEB,
  input  wire        TSCLKCHANGE,

  input  wire         PSEL,
  input  wire         PENABLE,
  input  wire [19:2]  PADDR,
  input  wire         PWRITE,
  input  wire [2:0]   PPROT,
  input  wire [3:0]   PSTRB,
  input  wire [31:0]  PWDATA,
  output wire [31:0]  PRDATA,
  output wire         PREADY,
  output wire         PSLVERR,

  input  wire         PSELCHK,
  input  wire         PENABLECHK,
  input  wire [2:0]   PADDRCHK,
  input  wire         PCTRLCHK,
  input  wire         PSTRBCHK,
  input  wire [3:0]   PWDATACHK,
  output wire [3:0]   PRDATACHK,
  output wire         PREADYCHK,
  output wire         PSLVERRCHK,

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

  input  wire        DEVICEEN,
  input  wire        TDI,
  output wire        TDO,
  output wire        nTDOEN,
  input  wire        SWDITMS,
  output wire        SWDO,
  output wire        SWDOEN,
  output wire        SWDETECT,

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

  output wire        CDBGPWRUPREQ,
  input  wire        CDBGPWRUPACK,

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
  input  wire [47:0] ECOREVNUM,
  input  wire [3:0]  INSTANCEID,

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

  output wire [2:0]  DBE,

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

  output wire [3:0]  SBIST_TESTSTATUS,
  output wire [GREBE_SBISTC_TESTID_W-1:0]   SBIST_TESTID,
  output wire [3:0]  SBIST_TESTFMODE,
  output wire        SBIST_DEADLOCK,

`ifdef ARM_NODAP
  output wire        SLVREADY,
  input  wire [1:0]  SLVTRANS,
  input  wire [1:0]  SLVSIZE,
  input  wire [6:0]  SLVPROT,
  input  wire        SLVNONSEC,
  input  wire        SLVWRITE,
  input  wire [31:0] SLVADDR,
  input  wire [31:0] SLVWDATA,
  output wire [31:0] SLVRDATA,
  output wire        SLVRESP,

`endif

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
  output wire        nPWRUPSYSACK,
  input  wire        nRETSYS,

  input  wire        nISOLATEDBG,
  input  wire        nPWRUPDBG,
  output wire        nPWRUPDBGACK
`endif
);


localparam [31:0] TPIUBASE     = 32'hE0040000;
localparam [31:0] ETMBASE      = 32'hE0041000;
localparam [31:0] CTIBASE      = 32'hE0042000;
localparam [31:0] SBISTBASE    = 32'hE0048000;
localparam [31:0] MCUROMBASE   = 32'hE00FE000;

wire         etm_psel;
wire [2:0]   etm_pprot = 3'b000;
wire [3:0]   etm_pstrb = 4'b0000;
wire [31:0]  etm_prdata;
wire         etm_pready;
wire         etm_pslverr;

wire         cti_pready;
wire         cti_psel;
wire [2:0]   cti_pprot = 3'b000;
wire [3:0]   cti_pstrb = 4'b0000;
wire [31:0]  cti_prdata;
wire         cti_pslverr;

wire         tpiu_pready;
wire         tpiu_psel;
wire [31:0]  tpiu_prdata;

wire         mcurom_pready;
wire         mcurom_psel;
wire [31:0]  mcurom_prdata;

wire         slv_ready;
wire [1:0]   slv_trans;
wire [1:0]   slv_size;
wire [6:0]   slv_prot;
wire         slv_nonsec;
wire         slv_write;
wire [31:0]  slv_addr;
wire [31:0]  slv_wdata;
wire [31:0]  slv_rdata;
wire         slv_resp;

wire        is_halted;

wire        atready_grb;
wire        atvalid_grb;
wire [7:0]  atdata_grb;
wire [6:0]  atid_grb;
wire        afready_grb;
wire        afvalid_grb;
wire        is_etmpwrup;
wire        etmtrigout;

wire        qch_dap_pwrup_req;
wire        qch_dap_pwrup_ack;

wire        gate_hclk;
wire        gate_hclk_mcu;

wire            SBISTPREADY;
wire   [31:0]   SBISTPRDATA;
wire            SBISTPSLVERR;
wire            SBISTPSEL;
wire            SBISTPREADYCHK;
wire    [3:0]   SBISTPRDATACHK;
wire            SBISTPSLVERRCHK;
wire            SBIST_PSACTIVE0;

wire  [239:0]   SBIST_IRQ;
wire            SBIST_NMI;
wire            SBIST_WICENREQ;
wire  [239:0]   IRQ_MUX;
wire            NMI_MUX;
wire            WICENREQ_MUX;

wire        [1:0] HTRANS_MCU;
wire        [2:0] HSIZE_MCU;
wire              HWRITE_MCU;
wire        [6:0] HPROT_MCU;
wire              HNONSEC_MCU;
wire        [2:0] HBURST_MCU;
wire              HEXCL_MCU;
wire       [31:0] HADDR_MCU;
wire       [31:0] HWDATA_MCU;
wire       [31:0] HRDATA_MCU;
wire              HRESP_MCU;
wire              HEXOKAY_MCU;
wire              HREADY_MCU;
wire              HTRANSCHK_MCU;
wire       [ 3:0] HADDRCHK_MCU;
wire       [ 3:0] HWDATACHK_MCU;
wire              HCTRLCHK1_MCU;
wire              HCTRLCHK2_MCU;
wire              HPROTCHK_MCU;
wire              HREADYCHK_MCU;
wire        [3:0] HRDATACHK_MCU;
wire              HRESPCHK_MCU;

wire unused = |{PPROT, PSTRB, PSTRBCHK};

`ifdef ARM_GREBEINTEGRATION_MCU_IS_CBAW
 `include "GREBEINTEGRATION_MCU_CBAW_inc.v"
`else
    localparam CBAW = 0;
`endif

`ifdef ARM_GRBIK_NETLIST
GREBEINTEGRATION_input_delay
#(
  .ARM_INPUT_DELAY(1),
  .MTBAWIDTH(MTBAWIDTH)
)
`else
GREBEINTEGRATION #(`GRB_TOP_PARAM_INST)
`endif
u_grebeintegration
(
  .FCLK          (FCLK),
  .SCLK          (SCLK),
  .HCLK          (HCLK),
  .DCLK          (DCLK),
  .nPORESET      (nPORESET),
  .nSYSPORESET   (nSYSPORESET),
  .nHRESET       (nHRESET),
  .nDBGRESET     (nDBGRESET),

  .HREADY        (HREADY_MCU),
  .HTRANS        (HTRANS_MCU),
  .HSIZE         (HSIZE_MCU),
  .HWRITE        (HWRITE_MCU),
  .HPROT         (HPROT_MCU),
  .HNONSEC       (HNONSEC_MCU),
  .HBURST        (HBURST_MCU),
  .HEXCL         (HEXCL_MCU),
  .HADDR         (HADDR_MCU),
  .HWDATA        (HWDATA_MCU),
  .HRDATA        (HRDATA_MCU),
  .HRESP         (HRESP_MCU),
  .HEXOKAY       (HEXOKAY_MCU),
  .HMASTER       (HMASTER),

  .HREADYCHK     (HREADYCHK_MCU),
  .HRDATACHK     (HRDATACHK_MCU),
  .HRESPCHK      (HRESPCHK_MCU),
  .HTRANSCHK     (HTRANSCHK_MCU),
  .HADDRCHK      (HADDRCHK_MCU),
  .HWDATACHK     (HWDATACHK_MCU),
  .HCTRLCHK1     (HCTRLCHK1_MCU),
  .HCTRLCHK2     (HCTRLCHK2_MCU),
  .HPROTCHK      (HPROTCHK_MCU),

  .SPECHTRANS    (SPECHTRANS),
  .CODENSEQ      (CODENSEQ),
  .CODEHINT      (CODEHINT),
  .DATAHINT      (DATAHINT),

  .ATREADYE      (atready_grb),
  .ATVALIDE      (atvalid_grb),
  .ATDATAE       (atdata_grb),
  .ATIDE         (atid_grb),
  .AFVALIDE      (afvalid_grb),
  .AFREADYE      (afready_grb),

  .ETMFIFOFULLEN (ETMFIFOFULLEN),
  .ETMPWRUP      (is_etmpwrup),
  .ETMEN         (ETMEN),

  .PSELT         (etm_psel),
  .PENABLET      (PENABLE),
  .PADDRT        (PADDR[11:2]),
  .PWRITET       (PWRITE),
  .PPROTT        (etm_pprot),
  .PSTRBT        (etm_pstrb),
  .PWDATAT       (PWDATA),
  .PRDATAT       (etm_prdata),
  .PREADYT       (etm_pready),
  .PSLVERRT      (etm_pslverr),

  .PREADYC       (cti_pready),
  .PSELC         (cti_psel),
  .PENABLEC      (PENABLE),
  .PADDRC        (PADDR[11:2]),
  .PWRITEC       (PWRITE),
  .PPROTC        (cti_pprot),
  .PSTRBC        (cti_pstrb),
  .PWDATAC       (PWDATA),
  .PRDATAC       (cti_prdata),
  .PSLVERRC      (cti_pslverr),

  .MTBSRAMBASE   (MTBSRAMBASE),
  .HREADYM       (HREADYM),
  .HREADYOUTM    (HREADYOUTM),
  .HTRANSM       (HTRANSM),
  .HADDRM        (HADDRM),
  .HPROTM        (HPROTM),
  .HSIZEM        (HSIZEM),
  .HBURSTM       (HBURSTM),
  .HWRITEM       (HWRITEM),
  .HWDATAM       (HWDATAM),
  .HRDATAM       (HRDATAM),
  .HRESPM        (HRESPM),
  .HSELRAMM      (HSELRAMM),
  .HSELSFRM      (HSELSFRM),
  .RAMHCLK       (RAMHCLK),
  .RAMCS         (RAMCS),
  .RAMWE         (RAMWE),
  .RAMAD         (RAMAD),
  .RAMWD         (RAMWD),
  .RAMRD         (RAMRD),

  .TSTART        (TSTART),
  .TSTOP         (TSTOP),

  .IOTRANS       (IOTRANS),
  .IOWRITE       (IOWRITE),
  .IOCHECK       (IOCHECK),
  .IOMATCH       (IOMATCH),
  .IOADDR        (IOADDR),
  .IOSIZE        (IOSIZE),
  .IOMASTER      (IOMASTER),
  .IOPRIV        (IOPRIV),
  .IONONSEC      (IONONSEC),
  .IOWDATA       (IOWDATA),
  .IORDATA       (IORDATA),

  .IOTRANSCHK    (IOTRANSCHK),
  .IOCHECKCHK    (IOCHECKCHK),
  .IOMATCHCHK    (IOMATCHCHK),
  .IOADDRCHK     (IOADDRCHK),
  .IOCTRLCHK1    (IOCTRLCHK1),
  .IOCTRLCHK2    (IOCTRLCHK2),
  .IOWDATACHK    (IOWDATACHK),
  .IORDATACHK    (IORDATACHK),

  .HREADYD      (slv_ready),
  .HTRANSD      (slv_trans),
  .HSIZED       (slv_size),
  .HPROTD       (slv_prot),
  .HNONSECD     (slv_nonsec),
  .HWRITED      (slv_write),
  .HADDRD       (slv_addr),
  .HWDATAD      (slv_wdata),
  .HRDATAD      (slv_rdata),
  .HRESPD       (slv_resp),

  .CTICHIN       (CTICHIN),
  .CTICHOUT      (CTICHOUT),
  .CTIIRQ        (CTIIRQ),

  .WAKEUP        (WAKEUP),
  .WICENREQ      (WICENREQ_MUX),
  .WICENACK      (WICENACK),
  .WICSENSE      (WICSENSE),

  .SLEEPHOLDREQn (SLEEPHOLDREQn),
  .SLEEPHOLDACKn (SLEEPHOLDACKn),
  .SLEEPING      (SLEEPING),
  .SLEEPDEEP     (SLEEPDEEP),
  .DAPPWRUPREQ   (qch_dap_pwrup_req),
  .DAPPWRUPACK   (qch_dap_pwrup_ack),

  .TXEV          (TXEV),
  .RXEV          (RXEV),
  .IRQ           (IRQ_MUX),
  .NMI           (NMI_MUX),

  .LOCKUP        (LOCKUP),
  .HALTED        (is_halted),

  .DBGRESTART    (DBGRESTART),
  .DBGRESTARTED  (DBGRESTARTED),
  .EDBGRQ        (EDBGRQ),
  .NIDEN         (NIDEN),
  .DBGEN         (DBGEN),
  .SPIDEN        (SPIDEN),
  .SPNIDEN       (SPNIDEN),

  .CFGSECEXT     (CFGSECEXT),
  .CFGSTCALIB    (CFGSTCALIB),
  .CFGSTCALIBNS  (CFGSTCALIBNS),
  .ECOREVNUM     (ECOREVNUM[31:0]),
  .INITVTOR      (INITVTOR),
  .INITVTORNS    (INITVTORNS),

  .IDAUADDRA     (IDAUADDRA),
  .IDAUNSA       (IDAUNSA),
  .IDAUNSCA      (IDAUNSCA),
  .IDAUIDVA      (IDAUIDVA),
  .IDAUIDA       (IDAUIDA),
  .IDAUNCHKA     (IDAUNCHKA),

  .IDAUADDRB     (IDAUADDRB),
  .IDAUNSB       (IDAUNSB),
  .IDAUNSCB      (IDAUNSCB),
  .IDAUNCHKB     (IDAUNCHKB),

  .DFE           (DFE),
  .DBE           (DBE[1:0]),

  .SYSRESETREQ   (SYSRESETREQ),
  .CURRNS        (CURRNS),
  .STCLKEN       (STCLKEN),
  .STCLKENNS     (STCLKENNS),
  .CPUWAIT       (CPUWAIT),
  .IRQLATENCY    (IRQLATENCY),
  .GATEHCLK      (gate_hclk),
  .DFTSE         (DFTSE),
  .DFTCGEN       (DFTCGEN),
  .DFTRSTDISABLE (DFTRSTDISABLE),
  .FUSAEN        (FUSAEN),

  .SYSQREQN      (SYSQREQN),
  .SYSQACCEPTN   (SYSQACCEPTN),
  .SYSQDENY      (SYSQDENY),
  .SYSQACTIVE    (SYSQACTIVE),

  .DBGQREQN      (DBGQREQN),
  .DBGQACCEPTN   (DBGQACCEPTN),
  .DBGQDENY      (DBGQDENY),
  .DBGQACTIVE    (DBGQACTIVE),

`ifdef ARM_GREBE_SRPG_ON
  .nISOLATESYS   (nISOLATESYS),
  .nPWRUPSYS     (nPWRUPSYS),
  .nRETSYS       (nRETSYS),

  .nISOLATEDBG   (nISOLATEDBG),
  .nPWRUPDBG    (nPWRUPDBG),
`endif
  .TSVALUEB      (TSVALUEB),
  .TSCLKCHANGE   (TSCLKCHANGE),
  .ETMTRIGOUT    (etmtrigout)
);

assign HALTED   = is_halted;
assign ETMPWRUP = is_etmpwrup;

reg  cdbg_pwrup_ack_q;
always @(posedge FCLK or negedge nPORESET)
  if (~nPORESET)
    cdbg_pwrup_ack_q <= 1'b0;
  else
    cdbg_pwrup_ack_q <= CDBGPWRUPACK;

assign gate_hclk_mcu = gate_hclk & ~cdbg_pwrup_ack_q;
assign GATEHCLK = gate_hclk_mcu;


grb_apb_interconnect
     #(
      .MCUROMBASE(MCUROMBASE),
      .TPIUBASE(TPIUBASE),
      .ETMBASE(ETMBASE),
      .CTIBASE(CTIBASE),
      .SBISTBASE(SBISTBASE)
     )
  u_grb_apb_interconnect(
  .paddr_i      (PADDR[19:12]),
  .psel_i       (PSEL),

  .pready0_i    (mcurom_pready),
  .prdata0_i    (mcurom_prdata),

  .pready1_i    (tpiu_pready),
  .prdata1_i    (tpiu_prdata),

  .pready2_i    (etm_pready),
  .prdata2_i    (etm_prdata),
  .pslverr2_i   (etm_pslverr),

  .pready3_i    (cti_pready),
  .prdata3_i    (cti_prdata),
  .pslverr3_i   (cti_pslverr),

  .pready4_i    (SBISTPREADY),
  .prdata4_i    (SBISTPRDATA),
  .pslverr4_i   (SBISTPSLVERR),
  .pready4chk_i (SBISTPREADYCHK),
  .prdata4chk_i (SBISTPRDATACHK),
  .pslverr4chk_i(SBISTPSLVERRCHK),

  .psel0_o      (mcurom_psel),
  .psel1_o      (tpiu_psel),
  .psel2_o      (etm_psel),
  .psel3_o      (cti_psel),
  .psel4_o      (SBISTPSEL),
  .pready_o     (PREADY),
  .prdata_o     (PRDATA),
  .pslverr_o    (PSLVERR),
  .preadychk_o  (PREADYCHK),
  .prdatachk_o  (PRDATACHK),
  .pslverrchk_o (PSLVERRCHK)
);


generate
  if((DBG != 0 && ETM != 0) | (CBAW == 1)) begin: gen_mcu_rom

  grb_apb_cs_rom_table
  #(
    .BASE            (MCUROMBASE),
    .JEPID           (7'h3B),
    .JEPCONTINUATION (4'h4),
    .PARTNUMBER      (12'h4CC),
    .REVISION        (4'h0),
    .ENTRY0BASEADDR  (32'hE00FF000),
    .ENTRY0PRESENT   (1'b1),
    .ENTRY1BASEADDR  (TPIUBASE),
    .ENTRY1PRESENT   (1'b1),
    .ENTRY2BASEADDR  (32'h00000000),
    .ENTRY2PRESENT   (1'b0),
    .ENTRY3BASEADDR  (32'h00000000),
    .ENTRY3PRESENT   (1'b0)
  )
  u_rom_table
  (
    .pclk(FCLK),
    .psel_i(mcurom_psel),
    .paddr(PADDR[11:2]),
    .ecorevnum(ECOREVNUM[47:44]),
    .prdata_o(mcurom_prdata),
    .pready_o(mcurom_pready)
   );

  end
 else
 begin: gen_no_mcu_rom

   wire unused = |{mcurom_psel, ECOREVNUM[47:44]};
   assign mcurom_prdata = {32{1'b0}};
   assign mcurom_pready = 1'b1;

 end
endgenerate


`ifdef ARM_NODAP

assign      slv_trans = SLVTRANS;
assign      slv_size = SLVSIZE ;
assign      slv_prot = SLVPROT;
assign      slv_nonsec = SLVNONSEC;
assign      slv_write = SLVWRITE;
assign      slv_addr = SLVADDR;
assign      slv_wdata = SLVWDATA ;

assign      SLVREADY = slv_ready;
assign      SLVRDATA = slv_rdata;
assign      SLVRESP = slv_resp;

`else

 generate
 `ifdef ARM_GREBEINTEGRATION_MCU_IS_CBAW
    if(CBAW != 0)
 `else
    if(DBG != 0)
 `endif
    begin: gen_dap1

  wire [31:0] target_id = TARGETID;
  wire dp_reset_n;

 wire global_dap_pwrupack = cdbg_pwrup_ack_q | qch_dap_pwrup_ack;

  grb_dbg_reset_sync
    u_grb_dbg_reset_sync
       (.RSTIN         (nPORESET),
        .CLK           (SWCLKTCK),
        .DFTSE         (DFTSE),
        .DFTRSTDISABLE (DFTRSTDISABLE),
        .RSTOUT        (dp_reset_n));

  GRBDAP  #(`GRB_DAP_PARAM_INST) u_dap
  (
   .SWDO         (SWDO),
   .SWDOEN       (SWDOEN),
   .SWDETECT     (SWDETECT),
   .TDO          (TDO),
   .nTDOEN       (nTDOEN),
   .CDBGPWRUPREQ (qch_dap_pwrup_req),
   .SLVADDR      (slv_addr),
   .SLVWDATA     (slv_wdata),
   .SLVTRANS     (slv_trans),
   .SLVWRITE     (slv_write),
   .SLVPROT      (slv_prot),
   .SLVNONSEC    (slv_nonsec),
   .SLVSIZE      (slv_size),

   .SWCLKTCK     (SWCLKTCK),
   .nTRST        (nTRST),
   .DPRESETn     (dp_reset_n),
   .APRESETn     (nDBGRESET),
   .SWDITMS      (SWDITMS),
   .TDI          (TDI),
   .HALTED       (is_halted),
   .CDBGPWRUPACK (global_dap_pwrupack),
   .CFGSECEXT    (CFGSECEXT),
   .DEVICEEN     (DEVICEEN),
   .DCLK         (DCLK),
   .SLVRDATA     (slv_rdata),
   .SLVREADY     (slv_ready),
   .SLVRESP      (slv_resp),
   .BASEADDR     (BASEADDR),
   .TARGETID     (target_id),
   .INSTANCEID   (INSTANCEID),
   .ECOREVNUM    (ECOREVNUM[39:32]),
   .DFTSE        (DFTSE)
  );

  end else begin: gen_dap0
    assign slv_size = {2{1'b0}};
    assign slv_prot = {7{1'b0}};
    assign slv_write = 1'b0;
    assign slv_trans = {2{1'b0}};
    assign slv_wdata = {32{1'b0}};
    assign slv_nonsec = 1'b0;
    assign slv_addr = {32{1'b0}};
    assign TDO = 1'b0;
    assign nTDOEN = 1'b0;
    assign SWDO = 1'b0;
    assign SWDOEN = 1'b0;
    assign SWDETECT = 1'b0;
    assign qch_dap_pwrup_req = 1'b0;

    wire unused = |{slv_ready, slv_rdata, slv_resp, qch_dap_pwrup_ack,
                    SWCLKTCK, DEVICEEN, TDI, SWDITMS, INSTANCEID,
                    nTRST, ECOREVNUM[39:32]};

   end
endgenerate
`endif

assign CDBGPWRUPREQ = qch_dap_pwrup_req;

generate
  if((DBG != 0 && ETM != 0) | (CBAW == 1)) begin: gen_tpiu

  localparam ATB1 = 1;
  localparam ATB2 = 0;


  wire syncreq1s;

    GRBTPIU
     #(
      .RAR(RAR),
      .ATB1(ATB1),
      .ATB2(ATB2)
     )
    u_grb_tpiu(
      .ATCLK       (FCLK),
      .ATCLKEN     (1'b1),
      .TRACECLKIN  (TRACECLKIN),
      .RESETn      (nDBGRESET),
      .TRESETn     (nTRESET),
      .ECOREVNUM   (ECOREVNUM[43:40]),

      .PWRITE      (PWRITE),
      .PENABLE     (PENABLE),
      .PSEL        (tpiu_psel),
      .PADDR       (PADDR[11:2]),
      .PWDATA      (PWDATA[12:0]),
      .PRDATA      (tpiu_prdata),
      .PREADY      (tpiu_pready),

      .ATREADY1S   (atready_grb),
      .ATID1S      (atid_grb),
      .ATDATA1S    (atdata_grb),
      .ATVALID1S   (atvalid_grb),
      .AFVALID1S   (afvalid_grb),
      .AFREADY1S   (afready_grb),
      .SYNCREQ1S   (syncreq1s),

      .ATVALID2S   (1'b0),
      .ATID2S      (7'h00),
      .ATDATA2S    (8'b0),
      .AFREADY2S   (1'b0),
      .ATREADY2S   (),
      .AFVALID2S   (),
      .SYNCREQ2S   (),

      .MAXPORTSIZE (2'b11),
      .ETMTRIGOUT  (etmtrigout),
      .DSYNC       (1'b0),
      .TRACECLK    (TRACECLK),
      .TRACEDATA   (TRACEDATA),
      .TRACESWO    (TRACESWO),
      .SWOACTIVE   (SWOACTIVE),
      .TPIUACTV    (TPIUACTV),
      .TPIUBAUD    (TPIUBAUD),

      .TRACEPORTSIZE (TRACEPORTSIZE)
    );


    wire unused = |{afvalid_grb, syncreq1s};

 end
 else
 begin: gen_no_tpiu

    assign atready_grb = 1'b0;
    assign afvalid_grb = 1'b0;
    assign tpiu_prdata = 32'h00000000;
    assign tpiu_pready = 1'b1;
    assign TRACECLK  = 1'b0 ;
    assign TRACEDATA = 4'b0 ;
    assign TRACESWO  = 1'b0 ;
    assign SWOACTIVE = 1'b0 ;
    assign TPIUBAUD  = 1'b0 ;
    assign TPIUACTV  = 1'b0 ;
    assign TRACEPORTSIZE  = {2{1'b0}};

    wire unused = |{etmtrigout, tpiu_psel, afready_grb,
                    atid_grb, atdata_grb, atvalid_grb,
                    TRACECLKIN, nTRESET, ECOREVNUM[43:40]};
  end
endgenerate

generate
  if (SBISTC) begin: gen_sbistc

  localparam       GREBE_SBIST_FCTLR_STATUS_IDLE        = 4'b0000;
  localparam       GREBE_SBIST_FCTLR_STATUS_INIT        = 4'b0001;
  localparam       GREBE_SBIST_FCTLR_STATUS_PING        = 4'b0010;
  localparam       GREBE_SBIST_FCTLR_STATUS_DONE        = 4'b0011;
  localparam       GREBE_SBIST_FCTLR_STATUS_FAIL        = 4'b0100;
  localparam       GREBE_SBIST_FCTLR_STATUS_PDONE       = 4'b0101;
  localparam       GREBE_SBIST_FCTLR_STATUS_SCHED_DONE  = 4'b0111;
  localparam       GREBE_SBIST_FAULT_TRAP_TIMEOUT       = 7000;
  localparam       GREBE_SBIST_SIMULATION_TIMEOUT       = 32'h0870;

  wire               SBIST_AHB_SUBORDINATE_BUSY;
  wire               SBIST_AHB_SUBORDINATE_ERR;

  wire               SBIST_PSVAL0;
  wire [31:1]        SBIST_PSPAYL0;
  wire               SBIST_PSVAL1;
  wire               SBIST_PSACTIVE1;
  wire [31:1]        SBIST_PSPAYL1;

  wire [31:0]        SBIST_FPSPR2;
  wire [31:0]        SBIST_FPSPR3;
  wire [31:0]        SBIST_FPSPR4;

  wire [31:0]        SBIST_WICSENSE_MUX;
  wire [31:0]        SBIST_EVENTBUS_MUX;

  wire               SBIST_PS_COMPLETER_ERR;

`ifdef SCHED_EN
  assign  SBISTPSLVERR = SBIST_PS_COMPLETER_ERR & ~(PWDATA == 32'h00000007 && PADDR == 18'h11000);
`else
  assign  SBISTPSLVERR = SBIST_PS_COMPLETER_ERR;
`endif

  grb_sbistc #(
    .PSI               (SBIST_PSI),
    .DL_RESET          (SBIST_DL_RESET),
    .DL_CYCLES         (SBIST_DL_CYCLES),
    .SBISTBASE         (SBISTBASE),
    .BUSPROT           (BUSPROT)
  ) u_sbistc
    (
     .clk                (HCLK),
     .reset_n            (nHRESET),
     .PSEL               (SBISTPSEL),
     .PENABLE            (PENABLE),
     .PADDR              (PADDR),
     .PWRITE             (PWRITE),
     .PWDATA             (PWDATA),
     .PREADY             (SBISTPREADY),
     .PSLVERR            (SBIST_PS_COMPLETER_ERR),
     .PRDATA             (SBISTPRDATA),
     .PSELCHK            (PSELCHK),
     .PENABLECHK         (PENABLECHK),
     .PADDRCHK           (PADDRCHK  ),
     .PCTRLCHK           (PCTRLCHK  ),
     .PWDATACHK          (PWDATACHK ),
     .PRDATACHK          (SBISTPRDATACHK),
     .PREADYCHK          (SBISTPREADYCHK),
     .PSLVERRCHK         (SBISTPSLVERRCHK),
     .DBE                (DBE[2]),
     .PSVAL0             (SBIST_PSVAL0),
     .PSACTIVE0          (SBIST_PSACTIVE0),
     .PSPAYL0            (SBIST_PSPAYL0),
     .PSVAL1             (SBIST_PSVAL1),
     .PSACTIVE1          (SBIST_PSACTIVE1),
     .PSPAYL1            (SBIST_PSPAYL1),
     .FPSPR2             (SBIST_FPSPR2),
     .FPSPR3             (SBIST_FPSPR3),
     .FPSPR4             (SBIST_FPSPR4),

     .IWICSENSE_MUX      (SBIST_WICSENSE_MUX),
     .EVENTBUS_MUX       (SBIST_EVENTBUS_MUX),

     .AHB_SUBORDINATE_BUSY (SBIST_AHB_SUBORDINATE_BUSY),
     .AHB_SUBORDINATE_ERR  (SBIST_AHB_SUBORDINATE_ERR),

     .TESTSTATUS         (SBIST_TESTSTATUS),
     .TESTID             (SBIST_TESTID),
     .TESTFMODE          (SBIST_TESTFMODE),
     .DEADLOCK           (SBIST_DEADLOCK)
  );

  grb_sbist_trickbox u_sbist_trickbox
    (
     .clk             (HCLK),
     .reset_n         (nHRESET),
     .ps_val0         (SBIST_PSVAL0),
     .ps_val1         (SBIST_PSVAL1),
     .ps_active0      (SBIST_PSACTIVE0),
     .ps_active1      (SBIST_PSACTIVE1),
     .ps_payl0        (SBIST_PSPAYL0),
     .ps_payl1        (SBIST_PSPAYL1),
     .WICENACK        (WICENACK),
     .WICSENSE        (WICSENSE),
     .EVENTBUS        ({DBE[2:0], DFE[2:0]}),
     .FPSPR2          (SBIST_FPSPR2),
     .IRQ             (SBIST_IRQ),
     .NMI             (SBIST_NMI),
     .WICENREQ        (SBIST_WICENREQ),
     .WICENACK_FROM_TRICKBOX (),
     .wic_sense_mux   (SBIST_WICSENSE_MUX),
     .eventbus_mux    (SBIST_EVENTBUS_MUX)
     );

  wire       [31:0] HRDATA_STL;
  wire              HRESP_STL;
  wire              HEXOKAY_STL;
  wire              HREADY_STL;
  wire        [1:0] HTRANS_STL;
  wire        [2:0] HSIZE_STL;
  wire              HWRITE_STL;
  wire        [6:0] HPROT_STL;
  wire              HNONSEC_STL;
  wire              HEXCL_STL;
  wire       [31:0] HADDR_STL;
  wire       [31:0] HWDATA_STL;
  wire              HREADYCHK_STL;
  wire       [3:0]  HRDATACHK_STL;
  wire              HRESPCHK_STL;
  wire              HTRANSCHK_STL;
  wire        [3:0] HADDRCHK_STL;
  wire        [3:0] HWDATACHK_STL;
  wire              HCTRLCHK1_STL;
  wire              HCTRLCHK2_STL;
  wire              HPROTCHK_STL;

  grb_sbist_ahb_subordinate u_sbist_ahb_subordinate
    (
    .clk              (HCLK),
    .reset_n          (nHRESET),
    .HRDATA            (HRDATA_STL ),
    .HRESP             (HRESP_STL  ),
    .HEXOKAY           (HEXOKAY_STL),
    .HREADY            (HREADY_STL ),
    .HTRANS            (HTRANS_STL ),
    .HSIZE             (HSIZE_STL  ),
    .HWRITE            (HWRITE_STL ),
    .HPROT             (HPROT_STL  ),
    .HNONSEC           (HNONSEC_STL),
    .HEXCL             (HEXCL_STL  ),
    .HADDR             (HADDR_STL  ),
    .HWDATA            (HWDATA_STL ),
    .HREADYCHK         (HREADYCHK_STL),
    .HRDATACHK         (HRDATACHK_STL),
    .HRESPCHK          (HRESPCHK_STL ),
    .HTRANSCHK         (HTRANSCHK_STL),
    .HADDRCHK          (HADDRCHK_STL ),
    .HWDATACHK         (HWDATACHK_STL),
    .HCTRLCHK1         (HCTRLCHK1_STL),
    .HCTRLCHK2         (HCTRLCHK2_STL),
    .HPROTCHK          (HPROTCHK_STL ),
    .FPSPR3            (SBIST_FPSPR3),
    .FPSPR4            (SBIST_FPSPR4),
    .AHB_SUBORDINATE_ERR (SBIST_AHB_SUBORDINATE_ERR ),
    .AHB_SUBORDINATE_BUSY(SBIST_AHB_SUBORDINATE_BUSY)
    );

  grb_sbist_ahb_interconnect u_sbist_ahb_interconnect
    (
     .clk             (HCLK),
     .reset_n         (nHRESET),
     .HRDATA_EXT     (HRDATA       ),
     .HRESP_EXT      (HRESP        ),
     .HEXOKAY_EXT    (HEXOKAY      ),
     .HREADY_EXT     (HREADY       ),
     .HTRANS_EXT     (HTRANS       ),
     .HSIZE_EXT      (HSIZE        ),
     .HWRITE_EXT     (HWRITE       ),
     .HPROT_EXT      (HPROT        ),
     .HNONSEC_EXT    (HNONSEC      ),
     .HBURST_EXT     (HBURST       ),
     .HEXCL_EXT      (HEXCL        ),
     .HADDR_EXT      (HADDR        ),
     .HWDATA_EXT     (HWDATA       ),
     .HREADYCHK_EXT  (HREADYCHK    ),
     .HRDATACHK_EXT  (HRDATACHK    ),
     .HRESPCHK_EXT   (HRESPCHK     ),
     .HTRANSCHK_EXT  (HTRANSCHK    ),
     .HADDRCHK_EXT   (HADDRCHK     ),
     .HWDATACHK_EXT  (HWDATACHK    ),
     .HCTRLCHK1_EXT  (HCTRLCHK1    ),
     .HCTRLCHK2_EXT  (HCTRLCHK2    ),
     .HPROTCHK_EXT   (HPROTCHK     ),
     .HRDATA_STL     (HRDATA_STL   ),
     .HRESP_STL      (HRESP_STL    ),
     .HEXOKAY_STL    (HEXOKAY_STL  ),
     .HREADY_STL     (HREADY_STL   ),
     .HTRANS_STL     (HTRANS_STL   ),
     .HSIZE_STL      (HSIZE_STL    ),
     .HWRITE_STL     (HWRITE_STL   ),
     .HPROT_STL      (HPROT_STL    ),
     .HNONSEC_STL    (HNONSEC_STL  ),
     .HEXCL_STL      (HEXCL_STL    ),
     .HADDR_STL      (HADDR_STL    ),
     .HWDATA_STL     (HWDATA_STL   ),
     .HREADYCHK_STL  (HREADYCHK_STL),
     .HRDATACHK_STL  (HRDATACHK_STL),
     .HRESPCHK_STL   (HRESPCHK_STL ),
     .HTRANSCHK_STL  (HTRANSCHK_STL),
     .HADDRCHK_STL   (HADDRCHK_STL ),
     .HWDATACHK_STL  (HWDATACHK_STL),
     .HCTRLCHK1_STL  (HCTRLCHK1_STL),
     .HCTRLCHK2_STL  (HCTRLCHK2_STL),
     .HPROTCHK_STL   (HPROTCHK_STL ),
     .HTRANS_MCU     (HTRANS_MCU   ) ,
     .HSIZE_MCU      (HSIZE_MCU    ) ,
     .HWRITE_MCU     (HWRITE_MCU   ) ,
     .HPROT_MCU      (HPROT_MCU    ) ,
     .HNONSEC_MCU    (HNONSEC_MCU  ) ,
     .HBURST_MCU     (HBURST_MCU   ) ,
     .HEXCL_MCU      (HEXCL_MCU    ) ,
     .HADDR_MCU      (HADDR_MCU    ) ,
     .HWDATA_MCU     (HWDATA_MCU   ) ,
     .HRDATA_MCU     (HRDATA_MCU   ) ,
     .HRESP_MCU      (HRESP_MCU    ) ,
     .HEXOKAY_MCU    (HEXOKAY_MCU  ) ,
     .HREADY_MCU     (HREADY_MCU   ) ,
     .HTRANSCHK_MCU  (HTRANSCHK_MCU),
     .HADDRCHK_MCU   (HADDRCHK_MCU ),
     .HWDATACHK_MCU  (HWDATACHK_MCU),
     .HCTRLCHK1_MCU  (HCTRLCHK1_MCU),
     .HCTRLCHK2_MCU  (HCTRLCHK2_MCU),
     .HPROTCHK_MCU   (HPROTCHK_MCU ),
     .HREADYCHK_MCU  (HREADYCHK_MCU),
     .HRDATACHK_MCU  (HRDATACHK_MCU),
     .HRESPCHK_MCU   (HRESPCHK_MCU ),

     .STL_SUBORDINATE_EN(SBIST_FPSPR4[0]));

   end else begin: gen_nosbistc
    assign SBIST_PSACTIVE0 = 1'b0;
    assign SBIST_IRQ      = {240{1'b0}};
    assign SBIST_NMI      = 1'b0;
    assign SBIST_WICENREQ = 1'b0;
    assign HTRANS     = HTRANS_MCU   ;
    assign HWRITE     = HWRITE_MCU   ;
    assign HADDR      = HADDR_MCU    ;
    assign HSIZE      = HSIZE_MCU    ;
    assign HBURST     = HBURST_MCU   ;
    assign HPROT      = HPROT_MCU    ;
    assign HNONSEC    = HNONSEC_MCU  ;
    assign HWDATA     = HWDATA_MCU   ;
    assign HTRANSCHK  = HTRANSCHK_MCU;
    assign HADDRCHK   = HADDRCHK_MCU ;
    assign HWDATACHK  = HWDATACHK_MCU;
    assign HPROTCHK   = HPROTCHK_MCU ;
    assign HCTRLCHK1  = HCTRLCHK1_MCU;
    assign HCTRLCHK2  = HCTRLCHK2_MCU;

    assign HREADY_MCU    = HREADY   ;
    assign HRESP_MCU     = HRESP    ;
    assign HRDATA_MCU    = HRDATA   ;
    assign HEXOKAY_MCU   = HEXOKAY  ;
    assign HEXCL         = HEXCL_MCU;
    assign HREADYCHK_MCU = HREADYCHK;
    assign HRDATACHK_MCU = HRDATACHK;
    assign HRESPCHK_MCU  = HRESPCHK ;

    assign SBISTPREADY      = 1'b1;
    assign SBISTPSLVERR     = 1'b1;
    assign SBISTPRDATA      = 32'd0;
    assign SBISTPREADYCHK   = 1'b0;
    assign SBISTPRDATACHK   = 4'hF;
    assign SBISTPSLVERRCHK  = 1'b0;
    assign DBE[2]           = 1'b0;

    assign SBIST_TESTSTATUS = 4'h0;
    assign SBIST_TESTID     = {GREBE_SBISTC_TESTID_W{1'b0}};
    assign SBIST_TESTFMODE  = 4'h0;
    assign SBIST_DEADLOCK   = 1'b0;

    wire unused = |{SBISTPSEL, PSELCHK, PENABLECHK, PWDATACHK, PADDRCHK, PCTRLCHK};
  end
endgenerate

assign IRQ_MUX  = SBIST_PSACTIVE0 ? SBIST_IRQ : IRQ;
assign NMI_MUX  = SBIST_PSACTIVE0 ? SBIST_NMI : NMI;
assign WICENREQ_MUX  = SBIST_PSACTIVE0 ? SBIST_WICENREQ : WICENREQ;



endmodule
