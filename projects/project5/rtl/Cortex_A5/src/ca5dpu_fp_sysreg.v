//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2010  ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2010-08-04 08:59:19 +0100 (Wed, 04 Aug 2010) $
//
//      Revision            : $Revision: 145003 $
//
//      Release Information : CORTEX-A5-FPU-r0p1-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Pipeline and Register Bank for the VFP System Registers
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This block contains the system registers for the floating point unit.
// (FPSID, FPSCR, FPEXC)
//
// There is one write point and one read point.
//
// This module also contains all the pipelining logic and data selection
// logic for controlling writes into and reads out of these registers.
//
//-----------------------------------------------------------------------------

`include "ca5dpu_params.v"

module ca5dpu_fp_sysreg `DPU_PARAM_DECL (
  // Inputs
  input  wire                               clk,
  input  wire                               reset_n,
  input  wire [(`CA5_FP_CFLAG_SRC_W-1):0]   fp_cflag_src_iss_i,
  input  wire [(`CA5_FP_XFLAG_SRC_W-1):0]   fp_xflag_src_iss_i,
  input  wire [(`CA5_FP_SYSREG_ADDR_W-1):0] fp_sysreg_addr_iss_i,
  input  wire                               fp_sysreg_wen_iss_i,
  input  wire                               instr_fmstat_de_i,
  input  wire                               stall_iss_i,
  input  wire                               issue_to_iss_i,
  input  wire                               issue_to_ex1_i,
  input  wire                               issue_to_ex2_i,
  input  wire                               quash_iss_i,
  input  wire                               quash_wr_i,
  input  wire                               stall_wr_i,
  input  wire                               flush_ret_i,
  input  wire                               valid_instrs_iss_i,
  input  wire                               valid_instrs_wr_i,
  input  wire                               cc_pass_instr0_wr_i,
  input  wire                               unflushable_wr_i,
  input  wire                               unflushable_sfmac_wr_i,
  input  wire [31:0]                        st_data_wr_i,
  input  wire [3:0]                         fp_cflags_add_f3_i,
  input  wire [(`CA5_XFLAGS_W-1):0]         fp_xflags_add_f5_i,
  input  wire [(`CA5_XFLAGS_W-1):0]         fp_xflags_mul_f5_i,
  input  wire                               fmuld_xflag_force_f3_i,
  input  wire                               fpexc_dex_write_wr_i,
  input  wire                               fpexc_dex_val_wr_i,
  input  wire [3:0]                         perph_revision_i,
  // Outputs
  output wire [3:0]                         fp_cflags_ex2_o,
  output wire                               instr_fmstat_ex2_o,
  output reg  [31:0]                        fp_sysreg_rd_data_wr_o,
  output wire [1:0]                         fp_sysreg_rmode_f5_o,
  output wire                               fp_sysreg_fz_f5_o,
  output wire                               fp_sysreg_dn_f5_o,
  output wire                               fp_sysreg_ahp_f5_o,
  output wire                               fp_sysreg_vector_f5_o,
  output wire                               fp_sysreg_en_f5_o,
  output wire                               fp_serialize_iss_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [3:0]                          fp_perph_revision;
  reg [(`CA5_FPSCR_W-1):0]           fpscr_reg_f5;
  reg [(`CA5_FPEXC_W-1):0]           fpexc_reg_f5;
  reg                                instr_fmstat_iss;
  reg [(`CA5_FP_CFLAG_SRC_W-1):0]    fp_cflag_src_f1;
  reg [(`CA5_FP_XFLAG_SRC_W-1):0]    fp_xflag_src_f1;
  reg [(`CA5_FP_SYSREG_ADDR_W-1):0]  fp_sysreg_addr_f1;
  reg                                fp_sysreg_wen_f1;
  reg                                instr_fmstat_ex1;
  reg [(`CA5_FP_CFLAG_SRC_W-1):0]    fp_cflag_src_f2;
  reg [(`CA5_FP_XFLAG_SRC_W-1):0]    fp_xflag_src_f2;
  reg [(`CA5_FP_SYSREG_ADDR_W-1):0]  fp_sysreg_addr_f2;
  reg                                fp_sysreg_wen_f2;
  reg                                instr_fmstat_ex2;
  reg [(`CA5_FP_CFLAG_SRC_W-1):0]    fp_cflag_src_f3;
  reg [(`CA5_FP_XFLAG_SRC_W-1):0]    fp_xflag_src_f3;
  reg [(`CA5_FP_SYSREG_ADDR_W-1):0]  fp_sysreg_addr_f3;
  reg                                fp_sysreg_wen_f3;
  reg [(`CA5_FP_CFLAG_SRC_W-1):0]    fp_cflag_src_f4;
  reg [(`CA5_FP_XFLAG_SRC_W-1):0]    fp_xflag_src_f4;
  reg [(`CA5_FP_SYSREG_ADDR_W-1):0]  fp_sysreg_addr_f4;
  reg                                fp_sysreg_wen_f4;
  reg [(`CA5_FP_CFLAG_SRC_W-1):0]    raw_fp_cflag_src_f5;
  reg [(`CA5_FP_XFLAG_SRC_W-1):0]    raw_fp_xflag_src_f5;
  reg [(`CA5_FP_SYSREG_ADDR_W-1):0]  fp_sysreg_addr_f5;
  reg                                fp_sysreg_wen_f5;
  reg [3:0]                          fp_cflags_add_f4;
  reg [3:0]                          fp_cflags_add_f5;
  reg [(`CA5_FPSCR_W-1):0]           st_data_f4;
  reg [(`CA5_FPSCR_W-1):0]           st_data_f5;
  reg [(`CA5_XFLAGS_W-1):0]          nxt_xflags_f5;
  reg [3:0]                          nxt_cflags_f5;
  reg                                fpexc_dex_write_f4;
  reg                                fpexc_dex_val_f4;
  reg                                fpexc_dex_write_f5;
  reg                                fpexc_dex_val_f5;
  reg                                enable_f1;
  reg                                enable_f2;
  reg                                enable_f3;
  reg                                enable_f4;
  reg                                enable_f5;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [(`CA5_FP_CFLAG_SRC_W-1):0]   nxt_fp_cflag_src_f4;
  wire [(`CA5_FP_XFLAG_SRC_W-1):0]   nxt_fp_xflag_src_f4;
  wire                               nxt_fp_sysreg_wen_f4;
  wire [(`CA5_FP_CFLAG_SRC_W-1):0]   fp_cflag_src_f5;
  wire [(`CA5_FP_XFLAG_SRC_W-1):0]   fp_xflag_src_f5;
  wire [31:0]                        fpscr_f5;
  wire [31:0]                        fpexc_f5;
  wire [31:0]                        nxt_fpscr_f5;
  wire [31:0]                        nxt_fpexc_f5;
  wire [(`CA5_FPEXC_W-1):0]          nxt_fpexc_reg_f5;
  wire [(`CA5_FPSCR_W-1):0]          nxt_fpscr_reg_f5;
  wire                               vmsr_fpscr_f5;
  wire                               vmsr_fpexc_f5;
  wire                               en_fpscr_reg_f5;
  wire                               en_fpexc_reg_f5;
  wire                               valid_enable_f3;
  wire [(`CA5_FPSCR_W-1):0]          nxt_st_data_f4;
  wire [6:0]                         nxt_config_f5;
  wire [2:0]                         nxt_len_f5;
  wire                               nxt_en_f5;
  wire                               nxt_dex_f5;
  wire [(`CA5_XFLAGS_W-1):0]         xflags_f5;
  wire [(`CA5_XFLAGS_W-1):0]         xflags_st_f5;
  wire                               nxt_qc_bit_f5;
  wire                               qc_bit_f5;
  wire                               enable_iss;
  wire                               nxt_enable_f4;
  wire                               nxt_enable_f5;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ---------------------------------------------------------
  // Revision field register
  // ---------------------------------------------------------

`define CA5_FP_PERPH_REVISION   `CA5_PERPH_REVISION

  always @(posedge clk)
    fp_perph_revision  <= `CA5_FP_PERPH_REVISION;

  // ------------------------------------------------------
  // Iss stage
  // ------------------------------------------------------

  always @(posedge clk)
    if (issue_to_iss_i)
      instr_fmstat_iss    <= instr_fmstat_de_i;

  // If the instruction in Iss reads or writes the FPU system registers
  // then force serialization
  assign fp_serialize_iss_o = (fp_sysreg_wen_iss_i | // Asserted for FPSCR/FPEXC writes
                               instr_fmstat_iss    | // Asserted for fmstat instructions
                               (|fp_sysreg_addr_iss_i));

  assign enable_iss = ((|fp_sysreg_addr_iss_i)                         |
                       (fp_xflag_src_iss_i != `CA5_FP_XFLAG_SRC_FPSCR) |
                       (fp_cflag_src_iss_i != `CA5_FP_CFLAG_SRC_FPSCR))
                      & valid_instrs_iss_i & ~stall_iss_i & ~quash_iss_i;

  // ------------------------------------------------------
  // F1 stage
  // ------------------------------------------------------

  always @(posedge clk)
    if (~stall_wr_i | flush_ret_i)
      enable_f1 <= enable_iss;

  always @(posedge clk)
    if (issue_to_ex1_i)
      instr_fmstat_ex1 <= instr_fmstat_iss;

  always @(posedge clk)
    if (enable_iss) begin
      fp_cflag_src_f1   <= fp_cflag_src_iss_i;
      fp_xflag_src_f1   <= fp_xflag_src_iss_i;
      fp_sysreg_addr_f1 <= fp_sysreg_addr_iss_i;
      fp_sysreg_wen_f1  <= fp_sysreg_wen_iss_i;
    end

  // ------------------------------------------------------
  // F2 stage
  // ------------------------------------------------------

  always @(posedge clk)
    if (~stall_wr_i | flush_ret_i)
      enable_f2 <= enable_f1;

  always @(posedge clk)
    if (issue_to_ex2_i)
      instr_fmstat_ex2 <= instr_fmstat_ex1;

  always @(posedge clk)
    if (enable_f1 & (~stall_wr_i | flush_ret_i)) begin
      fp_cflag_src_f2   <= fp_cflag_src_f1;
      fp_xflag_src_f2   <= fp_xflag_src_f1;
      fp_sysreg_addr_f2 <= fp_sysreg_addr_f1;
      fp_sysreg_wen_f2  <= fp_sysreg_wen_f1;
    end

  // Forward cflags to the F2 stage for FMSTAT instructions
  // Only need to forward from VCMP instructions - VMSR to the FPSCR inserts bubbles in the pipe
  assign fp_cflags_ex2_o = (valid_enable_f3 & fp_cflag_src_f3 == `CA5_FP_CFLAG_SRC_ALU) ? fp_cflags_add_f3_i :
                           (enable_f4       & fp_cflag_src_f4 == `CA5_FP_CFLAG_SRC_ALU) ? fp_cflags_add_f4   :
                                                                                          nxt_fpscr_f5[`CA5_FPSCR_ARCH_NZCV_BITS];


  // ------------------------------------------------------
  // F3 stage
  // ------------------------------------------------------

  always @(posedge clk)
    if (~stall_wr_i | flush_ret_i)
      enable_f3 <= enable_f2;

  always @(posedge clk)
    if (enable_f2 & (~stall_wr_i | flush_ret_i)) begin
      fp_cflag_src_f3   <= fp_cflag_src_f2;
      fp_xflag_src_f3   <= fp_xflag_src_f2;
      fp_sysreg_wen_f3  <= fp_sysreg_wen_f2;
      fp_sysreg_addr_f3 <= fp_sysreg_addr_f2;
    end

  // Read the appropriate register in the F3 stage (the correct value will be the
  // value from the F5 stage, ie. the value generated by the instruction two ahead
  // A bubble is inserted beforehand so that there is no write in F4
  always @*
    case (fp_sysreg_addr_f3)
      `CA5_FP_SYSREG_ADDR_FPSCR : fp_sysreg_rd_data_wr_o = nxt_fpscr_f5;
      `CA5_FP_SYSREG_ADDR_FPEXC : fp_sysreg_rd_data_wr_o = nxt_fpexc_f5;
      `CA5_FP_SYSREG_ADDR_FPSID : fp_sysreg_rd_data_wr_o = `CA5_FPSID_READ_VALUE(fp_perph_revision);
      `CA5_FP_SYSREG_ADDR_MVFR0 : fp_sysreg_rd_data_wr_o = `CA5_MVFR0_READ_VALUE;
      `CA5_FP_SYSREG_ADDR_MVFR1 : fp_sysreg_rd_data_wr_o = `CA5_MVFR1_READ_VALUE;
      default                   : fp_sysreg_rd_data_wr_o = 32'hxxxx_xxxx;
    endcase

  // Gate signals off if the instruction failed its condition codes
  assign valid_enable_f3 = enable_f3 & valid_instrs_wr_i & cc_pass_instr0_wr_i & ~quash_wr_i;

  assign nxt_enable_f4 = valid_enable_f3 | unflushable_wr_i | unflushable_sfmac_wr_i | fmuld_xflag_force_f3_i;

  assign nxt_fp_xflag_src_f4  = ({`CA5_FP_XFLAG_SRC_W{valid_enable_f3}}         & fp_xflag_src_f3)        |
                                ({`CA5_FP_XFLAG_SRC_W{unflushable_sfmac_wr_i}}  & `CA5_FP_XFLAG_SRC_ALU)  |
                                ({`CA5_FP_XFLAG_SRC_W{fmuld_xflag_force_f3_i |
                                                      unflushable_wr_i}}        & `CA5_FP_XFLAG_SRC_MUL);

  assign nxt_fp_cflag_src_f4  = {`CA5_FP_CFLAG_SRC_W{valid_enable_f3}} & fp_cflag_src_f3;

  assign nxt_fp_sysreg_wen_f4 = valid_enable_f3 & fp_sysreg_wen_f3;

  // For FPEXC writes, the useful bits are within the NZCV bits in the below data
  assign nxt_st_data_f4[`CA5_FPSCR_FP_BITS] = {st_data_wr_i[`CA5_FPSCR_ARCH_NZCV_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_AHP_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_DN_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_FZ_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_RMODE_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_STRIDE_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_LEN_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_IDC_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_IXC_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_UFC_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_OFC_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_DZC_BITS],
                                               st_data_wr_i[`CA5_FPSCR_ARCH_IOC_BITS]};

`genif (NEON_0)
  assign nxt_st_data_f4[`CA5_FPSCR_QC_BITS] = st_data_wr_i[`CA5_FPSCR_ARCH_QC_BITS];
`genendif

  // ------------------------------------------------------
  // F4 stage
  // ------------------------------------------------------

  always @(posedge clk)
    if (~stall_wr_i | flush_ret_i) begin
      enable_f4          <= nxt_enable_f4;
      fpexc_dex_write_f4 <= fpexc_dex_write_wr_i;
      fpexc_dex_val_f4   <= fpexc_dex_val_wr_i;
    end

  always @(posedge clk)
    if (nxt_enable_f4 & (~stall_wr_i | flush_ret_i)) begin
      fp_cflag_src_f4   <= nxt_fp_cflag_src_f4;
      fp_xflag_src_f4   <= nxt_fp_xflag_src_f4;
      fp_sysreg_wen_f4  <= nxt_fp_sysreg_wen_f4;
      fp_sysreg_addr_f4 <= fp_sysreg_addr_f3;
      fp_cflags_add_f4  <= fp_cflags_add_f3_i;
    end

  // Register the store data into the F4 stage
  always @(posedge clk)
    if (nxt_fp_sysreg_wen_f4)
      st_data_f4 <= nxt_st_data_f4;

  assign nxt_enable_f5 = enable_f4 & (~stall_wr_i | flush_ret_i);

  // ------------------------------------------------------
  // F5 stage
  // ------------------------------------------------------

  always @(posedge clk)
    begin
      enable_f5           <= nxt_enable_f5;
      fpexc_dex_write_f5  <= fpexc_dex_write_f4;
      fpexc_dex_val_f5    <= fpexc_dex_val_f4;
    end

  always @(posedge clk)
    if (nxt_enable_f5) begin
      raw_fp_cflag_src_f5 <= fp_cflag_src_f4;
      raw_fp_xflag_src_f5 <= fp_xflag_src_f4;
      fp_sysreg_wen_f5    <= fp_sysreg_wen_f4;
      fp_sysreg_addr_f5   <= fp_sysreg_addr_f4;
      fp_cflags_add_f5    <= fp_cflags_add_f4;
    end

  always @(posedge clk)
    if (nxt_enable_f5 & fp_sysreg_wen_f4)
      st_data_f5 <= st_data_f4;

  // ------------------------------------------------------
  // Combine the sticky exception flags from various sources
  // ------------------------------------------------------

  assign xflags_f5   [`CA5_XFLAGS_FP_BITS] = fpscr_reg_f5[`CA5_FPSCR_FP_XFLAGS_BITS];
  assign xflags_st_f5[`CA5_XFLAGS_FP_BITS] = st_data_f5  [`CA5_FPSCR_FP_XFLAGS_BITS];

`genif (NEON_0)
  assign xflags_f5   [`CA5_XFLAGS_QC_BITS] = fpscr_reg_f5[`CA5_FPSCR_QC_BITS];
  assign xflags_st_f5[`CA5_XFLAGS_QC_BITS] = st_data_f5  [`CA5_FPSCR_QC_BITS];
`genendif

  assign fp_xflag_src_f5 = {`CA5_FP_XFLAG_SRC_W{enable_f5}} & raw_fp_xflag_src_f5;

  always @*
    case (fp_xflag_src_f5[2])
      1'b0    : nxt_xflags_f5 = xflags_f5
                                | {`CA5_XFLAGS_W{fp_xflag_src_f5[0]}} & fp_xflags_mul_f5_i
                                | {`CA5_XFLAGS_W{fp_xflag_src_f5[1]}} & fp_xflags_add_f5_i;
      1'b1    : nxt_xflags_f5 = xflags_st_f5;
      default : nxt_xflags_f5 = {`CA5_XFLAGS_W{1'bx}};
    endcase

`genif (NEON_0)
  assign nxt_qc_bit_f5  = nxt_xflags_f5[`CA5_XFLAGS_QC_BITS];
`genelse
  assign nxt_qc_bit_f5  = 1'b0;
`genendif

  // ------------------------------------------------------
  // Select the NZCV bits from the appropriate source
  // ------------------------------------------------------

  assign fp_cflag_src_f5 = {`CA5_FP_CFLAG_SRC_W{enable_f5}} & raw_fp_cflag_src_f5;

  always @*
    case (fp_cflag_src_f5)
      `CA5_FP_CFLAG_SRC_FPSCR : nxt_cflags_f5 = fpscr_reg_f5[`CA5_FPSCR_NZCV_BITS];
      `CA5_FP_CFLAG_SRC_STR   : nxt_cflags_f5 = st_data_f5[`CA5_FPSCR_NZCV_BITS];
      `CA5_FP_CFLAG_SRC_ALU   : nxt_cflags_f5 = fp_cflags_add_f5;
      default                 : nxt_cflags_f5 = 4'bxxxx;
    endcase

  // ------------------------------------------------------
  // Select the remaining FPSCR bits
  // ------------------------------------------------------

  // These bits can only be written by a VMSR to the FPSCR
  assign vmsr_fpscr_f5 = enable_f5 & fp_sysreg_wen_f5 & (fp_sysreg_addr_f5 == `CA5_FP_SYSREG_ADDR_FPSCR);

  assign nxt_len_f5     = vmsr_fpscr_f5 ? st_data_f5[`CA5_FPSCR_LEN_BITS]
                                        : fpscr_reg_f5[`CA5_FPSCR_LEN_BITS];
  assign nxt_config_f5  = vmsr_fpscr_f5 ? st_data_f5[`CA5_FPSCR_CONFIG_BITS]
                                        : fpscr_reg_f5[`CA5_FPSCR_CONFIG_BITS];

  // ------------------------------------------------------
  // Generate the new FPEXC bits
  // ------------------------------------------------------

  assign vmsr_fpexc_f5 = enable_f5 & fp_sysreg_wen_f5 & (fp_sysreg_addr_f5 == `CA5_FP_SYSREG_ADDR_FPEXC);

  assign nxt_en_f5      = vmsr_fpexc_f5 ? st_data_f5[`CA5_FPEXC_ST_EN_BITS]
                                        : fpexc_reg_f5[`CA5_FPEXC_EN_BITS];

  assign nxt_dex_f5     = fpexc_dex_write_f5 ? fpexc_dex_val_f5               :
                          vmsr_fpexc_f5      ? st_data_f5[`CA5_FPEXC_ST_DEX_BITS] :
                                               fpexc_reg_f5[`CA5_FPEXC_DEX_BITS];

  // ------------------------------------------------------
  // FP Registers
  // ------------------------------------------------------

  assign nxt_fpscr_f5 = {nxt_cflags_f5,
                         nxt_qc_bit_f5,
                         nxt_config_f5,
                         1'b0,
                         nxt_len_f5,
                         8'h00,
                         nxt_xflags_f5[`CA5_XFLAGS_IDC_BITS],
                         2'b00,
                         {nxt_xflags_f5[`CA5_XFLAGS_IXC_BITS],
                          nxt_xflags_f5[`CA5_XFLAGS_UFC_BITS],
                          nxt_xflags_f5[`CA5_XFLAGS_OFC_BITS],
                          nxt_xflags_f5[`CA5_XFLAGS_DZC_BITS],
                          nxt_xflags_f5[`CA5_XFLAGS_IOC_BITS]}
                        };

  assign nxt_fpexc_f5 = {1'b0,
                         nxt_en_f5,
                         nxt_dex_f5,
                         {29{1'b0}} };

  // The next values of the registers are simply the ret-stage values with
  // all the redundant bits removed
  assign nxt_fpscr_reg_f5[`CA5_FPSCR_FP_BITS] = {nxt_fpscr_f5[`CA5_FPSCR_ARCH_NZCV_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_AHP_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_DN_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_FZ_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_RMODE_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_STRIDE_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_LEN_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_IDC_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_IXC_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_UFC_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_OFC_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_DZC_BITS],
                                                 nxt_fpscr_f5[`CA5_FPSCR_ARCH_IOC_BITS]};

`genif (NEON_0)
  assign nxt_fpscr_reg_f5[`CA5_FPSCR_QC_BITS] = nxt_fpscr_f5[`CA5_FPSCR_ARCH_QC_BITS];
`genendif

  assign nxt_fpexc_reg_f5 = {nxt_fpexc_f5[`CA5_FPEXC_ARCH_EN_BITS],
                             nxt_fpexc_f5[`CA5_FPEXC_ARCH_DEX_BITS]};

  assign en_fpscr_reg_f5 = (fp_xflag_src_f5 != `CA5_FP_XFLAG_SRC_FPSCR);

  assign en_fpexc_reg_f5 = vmsr_fpexc_f5 | fpexc_dex_write_f5;

  // Storage registers for FPSCR and FPEXC
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      fpscr_reg_f5 <= {`CA5_FPSCR_W{1'b0}};
    else if (en_fpscr_reg_f5)
      fpscr_reg_f5 <= nxt_fpscr_reg_f5;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      fpexc_reg_f5 <= {`CA5_FPEXC_W{1'b0}};
    else if (en_fpexc_reg_f5)
      fpexc_reg_f5 <= nxt_fpexc_reg_f5;

  // Expand storage registers to full architectural width
`genif (NEON_0)
  assign qc_bit_f5 = fpscr_reg_f5[`CA5_FPSCR_QC_BITS];
`genelse
  assign qc_bit_f5 = 1'b0;
`genendif

  assign fpscr_f5 = {fpscr_reg_f5[`CA5_FPSCR_NZCV_BITS],    // 31..28
                     qc_bit_f5,                             // 27
                     fpscr_reg_f5[`CA5_FPSCR_AHP_BITS],     // 26
                     fpscr_reg_f5[`CA5_FPSCR_DN_BITS],      // 25
                     fpscr_reg_f5[`CA5_FPSCR_FZ_BITS],      // 24
                     fpscr_reg_f5[`CA5_FPSCR_RMODE_BITS],   // 23..22
                     fpscr_reg_f5[`CA5_FPSCR_STRIDE_BITS],  // 21..20
                     1'b0,                                  // 19
                     fpscr_reg_f5[`CA5_FPSCR_LEN_BITS],     // 18..16
                     8'h00,                                 // 15..8
                     fpscr_reg_f5[`CA5_FPSCR_IDC_BITS],     // 7
                     2'b00,                                 // 6..5
                     fpscr_reg_f5[`CA5_FPSCR_IXC_BITS],     // 4
                     fpscr_reg_f5[`CA5_FPSCR_UFC_BITS],     // 3
                     fpscr_reg_f5[`CA5_FPSCR_OFC_BITS],     // 2
                     fpscr_reg_f5[`CA5_FPSCR_DZC_BITS],     // 1
                     fpscr_reg_f5[`CA5_FPSCR_IOC_BITS]};    // 0

  assign fpexc_f5 = {1'b0,                                  // 31
                     fpexc_reg_f5[`CA5_FPEXC_EN_BITS],      // 30
                     fpexc_reg_f5[`CA5_FPEXC_DEX_BITS],     // 29
                     1'b0,                                  // 28
                     28'h000_0000};                         // 27..0

  // ------------------------------------------------------
  // Output aliasing
  // ------------------------------------------------------

  // Extract various control bits from the system registers
  assign fp_sysreg_rmode_f5_o   =  fpscr_f5[`CA5_FPSCR_ARCH_RMODE_BITS];
  assign fp_sysreg_fz_f5_o      =  fpscr_f5[`CA5_FPSCR_ARCH_FZ_BITS];
  assign fp_sysreg_dn_f5_o      =  fpscr_f5[`CA5_FPSCR_ARCH_DN_BITS];
  assign fp_sysreg_ahp_f5_o     =  fpscr_f5[`CA5_FPSCR_ARCH_AHP_BITS];
  assign fp_sysreg_vector_f5_o  = |fpscr_f5[`CA5_FPSCR_ARCH_LEN_BITS];
  assign fp_sysreg_en_f5_o      =  fpexc_f5[`CA5_FPEXC_ARCH_EN_BITS];
  assign instr_fmstat_ex2_o     =  instr_fmstat_ex2;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_xflag_src_iss
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"fp_xflag_src_iss has an illegal value")
    ovl_fpu_xflag_src_iss (.clk              (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (enable_iss),
                           .consequent_expr ((fp_xflag_src_iss_i == `CA5_FP_XFLAG_SRC_FPSCR) ||
                                             (fp_xflag_src_iss_i == `CA5_FP_XFLAG_SRC_STR)   ||
                                             (fp_xflag_src_iss_i == `CA5_FP_XFLAG_SRC_ALU)   ||
                                             (fp_xflag_src_iss_i == `CA5_FP_XFLAG_SRC_MUL)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_cflag_src_iss
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"fp_cflag_src_iss has an illegal value")
    ovl_fpu_cflag_src_iss (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (enable_iss),
                           .consequent_expr ((fp_cflag_src_iss_i == `CA5_FP_CFLAG_SRC_FPSCR) ||
                                             (fp_cflag_src_iss_i == `CA5_FP_CFLAG_SRC_STR)   ||
                                             (fp_cflag_src_iss_i == `CA5_FP_CFLAG_SRC_ALU)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_sysreg_addr_iss
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"fp_sysreg_addr_iss has an illegal value")
    ovl_fpu_sysreg_addr_iss (.clk             (clk),
                            .reset_n          (reset_n),
                            .antecedent_expr  (enable_iss),
                            .consequent_expr  ((fp_sysreg_addr_iss_i == `CA5_FP_SYSREG_ADDR_NONE)  ||
                                               (fp_sysreg_addr_iss_i == `CA5_FP_SYSREG_ADDR_FPEXC) ||
                                               (fp_sysreg_addr_iss_i == `CA5_FP_SYSREG_ADDR_FPSCR) ||
                                               (fp_sysreg_addr_iss_i == `CA5_FP_SYSREG_ADDR_FPSID) ||
                                               (fp_sysreg_addr_iss_i == `CA5_FP_SYSREG_ADDR_MVFR0) ||
                                               (fp_sysreg_addr_iss_i == `CA5_FP_SYSREG_ADDR_MVFR1)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_xflag_src_f5
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL,`CA5_FP_XFLAG_SRC_W,`OVL_ASSERT,"fp_xflag_src_f5 is X or Z")
    ovl_fpu_xflag_src_f5 (.clk        (clk),
                          .reset_n    (reset_n),
                          .qualifier  (enable_f5),
                          .test_expr  (fp_xflag_src_f5));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_cflag_src_f5
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL,`CA5_FP_CFLAG_SRC_W,`OVL_ASSERT,"fp_cflag_src_f5 is X or Z")
    ovl_fpu_cflag_src_f5 (.clk        (clk),
                          .reset_n    (reset_n),
                          .qualifier  (enable_f5),
                          .test_expr  (fp_cflag_src_f5));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_sysreg_addr_f5
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL,`CA5_FP_SYSREG_ADDR_W,`OVL_ASSERT,"fp_sysreg_addr_f5 is X or Z")
    ovl_fpu_sysreg_addr_f5 (.clk        (clk),
                            .reset_n    (reset_n),
                            .qualifier  (enable_f5),
                            .test_expr  (fp_sysreg_addr_f5));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpscr_write
  // Should not be writing Xs to the FPSCR
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL,`CA5_FPSCR_W,`OVL_ASSERT,"Writing Xs into the FPSCR")
    ovl_fpscr_write (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (en_fpscr_reg_f5),
                     .test_expr (nxt_fpscr_reg_f5));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpexc_write
  // Should not be writing Xs to the FPEXC
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_ERROR,`CA5_FPEXC_W,`OVL_ASSERT,"Writing Xs into the FPEXC")
    ovl_fpexc_write (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (en_fpexc_reg_f5),
                     .test_expr (nxt_fpexc_reg_f5));
  // OVL_ASSERT_END

`endif

endmodule // ca5dpu_fp_sysreg
