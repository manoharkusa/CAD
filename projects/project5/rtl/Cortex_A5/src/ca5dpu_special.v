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
//      Checked In          : $Date: 2010-07-22 14:19:20 +0100 (Thu, 22 Jul 2010) $
//
//      Revision            : $Revision: 143923 $
//
//      Release Information : CORTEX-A5-FPU-r0p1-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract: Control for inserting integer/FPU special instructions
//-----------------------------------------------------------------------------

`include "ca5dpu_params.v"

module ca5dpu_special `DPU_PARAM_DECL (
  // -----------------------------
  // Inputs
  // -----------------------------

  input  wire                           clk,
  input  wire                           reset_n,

  input  wire                           div_finished_iss_i,

  input  wire [1:0]                     valid_instrs_iss_i,
  input  wire [1:0]                     valid_instrs_ex1_i,
  input  wire [1:0]                     valid_instrs_ex2_i,
  input  wire [1:0]                     valid_instrs_wr_i,
  input  wire [1:0]                     pre_valid_instrs_wr_i,
  input  wire                           cc_pass_instr0_wr_i,

  input  wire                           no_insert_iss_i,

  input  wire                           flush_ret_i,
  input  wire                           flush_wr_i,
  input  wire                           quash_wr_special_i,
  input  wire                           stall_wr_i,
  input  wire                           stall_iss_i,

  input  wire                           fdivs_valid_iss_i,
  input  wire                           fdivs_valid_f1_i,
  input  wire                           fdivs_valid_f2_i,
  input  wire                           fdivs_valid_f3_i,

  input  wire                           fmuld_valid_iss_i,
  input  wire                           fmuld_valid_f1_i,
  input  wire                           fmuld_valid_f2_i,
  input  wire                           fmuld_valid_f3_i,

  input  wire [(`CA5_FP_RF_ADDR_W-1):0] rf_rd_addr_fr0_iss_i,
  input  wire [(`CA5_FP_RF_ADDR_W-1):0] rf_rd_addr_fr1_iss_i,
  input  wire [(`CA5_FP_RF_ADDR_W-1):0] rf_rd_addr_fr2_iss_i,
  input  wire [1:0]                     rf_rd_en_fr0_iss_i,
  input  wire [1:0]                     rf_rd_en_fr1_iss_i,
  input  wire [1:0]                     raw_rf_rd_en_fr2_iss_i,
  input  wire [(`CA5_FP_RF_ADDR_W-1):0] raw_rf_wr_addr_fw0_iss_i,
  input  wire [1:0]                     swap_rf_wr_en_fw0_iss_i,

  input  wire [1:0]                     rf_ilock_ctl_fr0_iss_i,
  input  wire [1:0]                     rf_ilock_ctl_fr1_iss_i,
  input  wire [1:0]                     rf_ilock_ctl_fr2_iss_i,
  input  wire [1:0]                     rf_ilock_ctl_fw0_iss_i,

  input  wire [(`CA5_FP_EX_PIPE_W-1):0] fp_ex_pipe_iss_i,
  input  wire [(`CA5_FP_PIPECTL_W-1):0] fp_pipectl_iss_i,

  input  wire                           fp_serialize_iss_i,   // FPU FPSCR/FPEXC write enable

  input  wire [(`CA5_SEL_FAD_A_W-1):0]  sel_fad_a_iss_i,

  // -----------------------------
  // Outputs
  // -----------------------------

  output wire                           unflushable_sfmac_iss_o,
  output wire                           unflushable_sfmuld_iss_o,
  output wire                           unflushable_sfdiv_iss_o,
  output wire                           special_stall_iss_o,
  output wire                           special_insert_iss_o,
  output wire                           special_interlock_iss_o,
  output reg  [(`CA5_SEL_FAD_A_W-1):0]  special_sel_fad_a_iss_o,
  output reg  [(`CA5_SEL_FAD_B_W-1):0]  special_sel_fad_b_iss_o,
  output reg  [1:0]                     special_rf_rd_en_fr2_iss_o,
  output reg  [(`CA5_FP_RF_ADDR_W-1):0] special_rf_rd_addr_fr2_iss_o,
  output reg  [1:0]                     special_rf_wr_en_fw0_iss_o,
  output reg  [(`CA5_FP_RF_ADDR_W-1):0] special_rf_wr_addr_fw0_iss_o,
  output reg  [(`CA5_RF_FWR_SRC_W-1):0] special_rf_wr_src_fw0_iss_o,
  output reg  [(`CA5_FP_ADD_CTL_W-1):0] special_fp_add_ctl_iss_o,
  output wire                           fmacs_valid_f3_o,
  output wire                           quash_sfmuld_f1_o,
  output wire                           fmuld_xflag_force_f3_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                            fdivs_committed;
  reg [1:0]                      fdivs_rf_wr_en_fw0_f1;
  reg [(`CA5_FP_RF_ADDR_W-1):0]  fdivs_rf_wr_addr_fw0_f1;
  reg                            fdivs_finished;
  reg                            fmuld_committed;
  reg [(`CA5_FP_RF_ADDR_W-1):0]  fmuld_rf_wr_addr_fw0_f1;
  reg                            fmuld_accumulate_f1;
  reg                            fmuld_fused_mac_f1;
  reg                            fmuld_sign_f1;
  reg                            fmac_valid_f1;
  reg                            fmac_valid_f2;
  reg                            fmac_valid_f4;
  reg [(`CA5_FP_RF_ADDR_W-1):0]  fmac_wr_addr_f1;
  reg [(`CA5_FP_RF_ADDR_W-1):0]  fmac_wr_addr_f2;
  reg [(`CA5_FP_RF_ADDR_W-1):0]  fmac_wr_addr_f3;
  reg [(`CA5_FP_RF_ADDR_W-1):0]  fmac_wr_addr_f4;
  reg [1:0]                      fmac_wr_en_f1;
  reg [1:0]                      fmac_wr_en_f2;
  reg [1:0]                      fmac_wr_en_f3;
  reg [1:0]                      fmac_wr_en_f4;
  reg                            fmac_pre_valid_f3;
  reg                            fmac_sign_f1;
  reg                            fmac_sign_f2;
  reg                            fmac_sign_f3;
  reg                            fmac_sign_f4;
  reg                            fmac_dp_f1;
  reg                            fmac_dp_f2;
  reg                            fmac_dp_f3;
  reg                            fmac_dp_f4;
  reg                            quash_sfmuld_f1;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [(`CA5_FP_MUL_CTL_W-1):0] fp_mul_ctl_iss;
  wire                           en_fdivs_committed;
  wire                           nxt_fdivs_committed;
  wire                           fdivs_stall_iss;
  wire                           fdivs_valid_masked_iss;
  wire                           fdivs_struct_hazard;
  wire                           fdivs_write_hazard;
  wire                           fdivs_read_hazard;
  wire                           fdivs_interlock_iss;
  wire                           fmuld_stall_iss;
  wire                           nxt_fdivs_finished;
  wire                           en_fdivs_finished;
  wire                           fmac_insert_iss;
  wire                           fmac_interlock_iss;
  wire                           fmac_valid_iss;
  wire                           fmac_fr0_read_hazard;
  wire                           fmac_fr1_read_hazard;
  wire                           fmac_fr2_read_hazard;
  wire                           fmac_read_hazard;
  wire                           fmac_fw0_write_hazard;
  wire                           fmac_write_hazard;
  wire                           fmac_struct_hazard;
  wire                           fmac_valid_en;
  wire                           nxt_fmac_valid_f1;
  wire                           nxt_fmac_valid_f2;
  wire                           nxt_fmac_valid_f3;
  wire                           fmac_valid_f3;
  wire                           en_quash_sfmuld_f1;
  wire                           fmac_in_flight;
  wire                           fdivs_in_flight;
  wire                           fmuld_in_flight;
  wire                           fp_special_in_flight;
  wire                           fpscr_interlock_iss;
  wire                           this_fmuld_commits;
  wire                           nxt_fmuld_committed;
  wire                           en_fmuld_committed;
  wire                           fmuld_done;
  wire                           fmuld_valid_masked_iss;
  wire                           fmuld_struct_hazard;
  wire                           fmuld_read_hazard;
  wire                           fmuld_write_hazard;
  wire                           fmuld_interlock_iss;
  wire                           fmac_valid_iss_sp;
  wire                           fmac_valid_iss_dp;
  wire                           nxt_fmac_valid_f4;
  wire                           neon_mul_int_op_iss;
  wire [(`CA5_SEL_FAD_A_W-1):0]  sfmac_sel_fad_a;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  function automatic check_interlock;
    input [(`CA5_FP_RF_ADDR_W-1):0] rf_addr_a;
    input [(`CA5_FP_RF_ADDR_W-1):0] rf_addr_b;
    input [1:0]                     rf_en_a;
    input [1:0]                     rf_en_b;
    input [1:0]                     ilock_ctl;

    check_interlock = (rf_addr_a[(`CA5_FP_RF_ADDR_W-1):1] == rf_addr_b[(`CA5_FP_RF_ADDR_W-1):1])
                        & (ilock_ctl[1] | (rf_addr_a[0] == rf_addr_b[0]))
                        & ((|ilock_ctl) | (|(rf_en_a & rf_en_b)));
  endfunction

  // ===========================================================================
  // == Divide/Square Root Control                                            ==
  // ===========================================================================

  // ------------------------------------------------------
  // FPU Divider commited flag
  // ------------------------------------------------------
  //
  // The commited flag is asserted once the divide phantom reaches Ret.
  //
  // We assert the nxt_div_committed signal when the phantom is in Wr, has
  // passed its condition codes and the stall signal is not asserted so we
  // can move into the Ret stage.
  //
  // The committed flag is cleared when the special is inserted but not until
  // any flush has cleared.

  assign en_fdivs_committed = ((fdivs_stall_iss |
                                (fdivs_valid_f3_i &
                                 pre_valid_instrs_wr_i[0] &
                                 cc_pass_instr0_wr_i)) &
                               ~(stall_wr_i & ~flush_ret_i));

  assign nxt_fdivs_committed = (fdivs_valid_f3_i &
                                ~quash_wr_special_i &
                                ~fdivs_stall_iss);

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      fdivs_committed <= 1'b0;
    else if (en_fdivs_committed)
      fdivs_committed <= nxt_fdivs_committed;

  // ------------------------------------------------------
  // FPU Divider finished flag
  // ------------------------------------------------------
  //
  // The finished flag is asserted once the datapath signals that the
  // divide is ready for an sMOV to be issued to pick up the result.  The
  // extra complexity here is that the datapath can signal that it is
  // ready before the phantom has reached and successfully cleared Wr and
  // become 'committed'.
  //
  // Therefore we enable the finished register once the datapath signals
  // it is ready and then hold the enable until the special is issued or
  // cleared so that we do not miss anything that might clear the finished
  // flag.
  //
  // We set the finished register when the datapath signals it is ready
  // and hold the set flag as long as:
  // - The finished flag is asserted and the divide is committed... OR
  // - The finished flag is asserted, the divide phantom is still valid
  // in the F3 stages and it has not been quashed/ccfailed. The divide
  // cannot finish before F3 because the operation is started in F2
  // only if there is no stall in F2. A stall can occur when the phantom
  // is in F3 and therefore it can finish in F3 before it is committed.
  // Hence, it can't finish before F3.
  //
  // When the special is inserted by the fdivs_stall_iss signal we clear the
  // finished flag.
  //

  assign en_fdivs_finished  = div_finished_iss_i | fdivs_finished;

  assign nxt_fdivs_finished = (fdivs_committed |
                              (fdivs_valid_f3_i & cc_pass_instr0_wr_i & ~quash_wr_special_i)) &
                               ~(fdivs_stall_iss & ~(stall_wr_i & ~flush_ret_i));

  always @(posedge clk or negedge reset_n)
    if(~reset_n)
      fdivs_finished <= 1'b0;
    else if (en_fdivs_finished)
      fdivs_finished <= nxt_fdivs_finished;

  // ------------------------------------------------------
  // FPU Divider special stall
  // ------------------------------------------------------
  //
  // To insert the FPU divider sMOV we need to stall the issue stage
  // with the fdivs_stall_iss signal.  However we can not stall if a
  // higher priority FMACs special is inserted.

  assign fdivs_stall_iss = (div_finished_iss_i | fdivs_finished) &
                            fdivs_committed &
                            ~fmac_insert_iss & ~fmuld_stall_iss & ~fmuld_in_flight & ~(no_insert_iss_i & ~fdivs_interlock_iss);

  // ------------------------------------------------------
  // DIV/SQRT Hazard Checking
  // ------------------------------------------------------
  // There are three types of hazard that we need to check against
  // 1. A structural hazard where a DIV/SQRT is in Iss when one is already
  //    underway.
  // 2. A read hazard where the result of an outstanding DIV/SQRT is needed.
  // 3. A write hazard where the outstanding DIV/SQRT needs to be written
  //    before the instruction in Iss can proceed.

  // -- Register the DIV/SQRT Write Address --
  // The write address needs to be registered when we have a valid div/sqrt
  // instruction in Iss.  However, we must be careful to not overwrite a
  // previously registered address for an outstanding div/sqrt.

  assign fdivs_valid_masked_iss = (fdivs_valid_iss_i &
                                   ~fdivs_valid_f1_i &
                                   ~fdivs_valid_f2_i &
                                   ~fdivs_valid_f3_i &
                                   ~fdivs_committed &
                                   ~stall_iss_i);
  always @(posedge clk)
    if(fdivs_valid_masked_iss)
      begin
        fdivs_rf_wr_en_fw0_f1   <= swap_rf_wr_en_fw0_iss_i;
        fdivs_rf_wr_addr_fw0_f1 <= raw_rf_wr_addr_fw0_iss_i;
      end


  // -- Structural Hazard --

  assign fdivs_struct_hazard =  fdivs_valid_iss_i &
                               (fdivs_valid_f1_i |
                                fdivs_valid_f2_i |
                                fdivs_valid_f3_i |
                                fdivs_committed);

  // -- Read Hazard --
  // Check incoming read addresses against stored write address;
  // but only when busy & not when inserting sFDIV.
  assign fdivs_read_hazard = (check_interlock(rf_rd_addr_fr0_iss_i, fdivs_rf_wr_addr_fw0_f1,     rf_rd_en_fr0_iss_i, fdivs_rf_wr_en_fw0_f1, rf_ilock_ctl_fr0_iss_i) |
                              check_interlock(rf_rd_addr_fr1_iss_i, fdivs_rf_wr_addr_fw0_f1,     rf_rd_en_fr1_iss_i, fdivs_rf_wr_en_fw0_f1, rf_ilock_ctl_fr1_iss_i) |
                              check_interlock(rf_rd_addr_fr2_iss_i, fdivs_rf_wr_addr_fw0_f1, raw_rf_rd_en_fr2_iss_i, fdivs_rf_wr_en_fw0_f1, rf_ilock_ctl_fr2_iss_i))
                             & (fdivs_valid_f1_i |
                                fdivs_valid_f2_i |
                                fdivs_valid_f3_i |
                                fdivs_committed) & valid_instrs_iss_i[0];
  // -- Write Hazard --
  // Check incoming write addresses against stored write address;
  // but only when busy & not when inserting sFDIV.
  assign fdivs_write_hazard = check_interlock(raw_rf_wr_addr_fw0_iss_i, fdivs_rf_wr_addr_fw0_f1, swap_rf_wr_en_fw0_iss_i, fdivs_rf_wr_en_fw0_f1, rf_ilock_ctl_fw0_iss_i)
                              & (fdivs_valid_f1_i |
                                 fdivs_valid_f2_i |
                                 fdivs_valid_f3_i |
                                 fdivs_committed) & valid_instrs_iss_i[0];

  // ------------------------------------------------------
  // FDIV/SQRT Interlock Generation
  // ------------------------------------------------------

  assign fdivs_interlock_iss = (fdivs_struct_hazard |
                                fdivs_read_hazard   |
                                fdivs_write_hazard);

  // ===========================================================================
  // == FMULD Control                                                         ==
  // ===========================================================================
  //
  // The following logic generates control and interlock signals for double
  // precision FMUL instructions.

  // ------------------------------------------------------
  // FMULD committed flag
  // ------------------------------------------------------
  //
  // The committed flag is asserted once the multiply phantom reaches Ret.
  //
  // We assert the nxt_div_committed signal when the phantom is in Wr, has
  // passed its condition codes and the stall signal is not asserted so we
  // can move into the Ret stage.
  //
  // The committed flag is cleared when the special is inserted but not until
  // any flush has cleared.

  assign this_fmuld_commits = (fmuld_valid_f3_i &
                               pre_valid_instrs_wr_i[0] &
                               cc_pass_instr0_wr_i);

  assign nxt_fmuld_committed = this_fmuld_commits & ~quash_wr_special_i & (~fmuld_accumulate_f1 & ~fmuld_stall_iss | stall_wr_i & ~flush_ret_i);

  assign en_fmuld_committed = ((fmuld_accumulate_f1 ? fmac_insert_iss : fmuld_stall_iss) & ~(stall_wr_i & ~flush_ret_i)) |
                                nxt_fmuld_committed;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      fmuld_committed <= 1'b0;
    else if (en_fmuld_committed)
      fmuld_committed <= nxt_fmuld_committed;

  // An FMULD is done (ready to have special issued) in the cycle it commits
  // A VFMA is done in the next cycle
  assign fmuld_done = this_fmuld_commits & ~fmuld_fused_mac_f1 | fmuld_committed;

  // ------------------------------------------------------
  // FMULD special stall
  // ------------------------------------------------------
  //
  // To insert the sFMULD we need to stall the issue stage
  // with the fmuld_stall_iss signal.  However we can not stall if a
  // higher priority FMACs special is inserted.

  assign fmuld_stall_iss = fmuld_done & ~fmuld_accumulate_f1 & ~fmac_insert_iss &
                           ~(no_insert_iss_i & ~fmuld_interlock_iss & ~fdivs_interlock_iss);

  // Due to timing, the quash_wr_special_i term cannot be used to qualify the special
  // fmuld_stall_iss signal.  If the FMULD is quashed in Wr, we insert the
  // associated sFMULD and quash it in F1.
  //
  // We use quash_wr_special (which factors in the exception quash signal) rather than
  // flush_wr since we can dual issue an fmac from decoder1 and we must be able
  // to kill the FMAC if an LDR from decoder0 has a data abort.

  assign en_quash_sfmuld_f1 = ((fmuld_stall_iss & ~stall_wr_i) | flush_ret_i);

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      quash_sfmuld_f1 <= 1'b0;
    else if (en_quash_sfmuld_f1)
      quash_sfmuld_f1 <= quash_wr_special_i & ~fmuld_committed;

  // ------------------------------------------------------
  // FMULD Hazard Checking
  // ------------------------------------------------------
  // There are three types of hazard that we need to check against
  // 1. A structural hazard where an instruction needing the MUL pipe is in
  //    Iss when an FMULD is underway.
  // 2. A read hazard where the result of an outstanding FMULD is needed.
  // 3. A write hazard where the outstanding FMULD needs to be written
  //    before the instruction in Iss can proceed.

  // -- Register the FMULD Write Address --
  // The write address needs to be registered when we have a valid FMULD
  // instruction in Iss.  However, we must be careful to not overwrite a
  // previously registered address for an outstanding FMULD.

  assign fmuld_valid_masked_iss = (fmuld_valid_iss_i &
                                   ~fmuld_valid_f1_i &
                                   ~fmuld_valid_f2_i &
                                   ~fmuld_valid_f3_i &
                                   ~fmuld_committed &
                                   ~stall_iss_i);
  always @(posedge clk)
    if(fmuld_valid_masked_iss)
      begin
        fmuld_rf_wr_addr_fw0_f1 <= raw_rf_wr_addr_fw0_iss_i;
        fmuld_accumulate_f1     <= fp_mul_ctl_iss[`CA5_FP_MUL_ACCUMULATE_BITS] & ~fp_mul_ctl_iss[`CA5_FP_MUL_FUSED_MAC_BITS];
        fmuld_fused_mac_f1      <= fp_mul_ctl_iss[`CA5_FP_MUL_FUSED_MAC_BITS];
        fmuld_sign_f1           <= fp_pipectl_iss_i[`CA5_FP_PIPECTL_ACCSGN_BITS];
      end


  // -- Structural Hazard --

  assign fmuld_struct_hazard = fp_ex_pipe_iss_i[`CA5_FP_EX_PIPE_MUL] &
                                (fmuld_valid_f1_i |
                                 fmuld_valid_f2_i |
                                 fmuld_valid_f3_i |
                                 fmuld_committed);

  // -- Read Hazard --
  // Check incoming read addresses against stored write address;
  // but only when busy & not when inserting sFDIV.
  assign fmuld_read_hazard = (check_interlock(rf_rd_addr_fr0_iss_i, fmuld_rf_wr_addr_fw0_f1,     rf_rd_en_fr0_iss_i, 2'b11, rf_ilock_ctl_fr0_iss_i) |
                              check_interlock(rf_rd_addr_fr1_iss_i, fmuld_rf_wr_addr_fw0_f1,     rf_rd_en_fr1_iss_i, 2'b11, rf_ilock_ctl_fr1_iss_i) |
                              check_interlock(rf_rd_addr_fr2_iss_i, fmuld_rf_wr_addr_fw0_f1, raw_rf_rd_en_fr2_iss_i, 2'b11, rf_ilock_ctl_fr2_iss_i))
                             & (fmuld_valid_f1_i |
                                fmuld_valid_f2_i |
                                fmuld_valid_f3_i |
                                fmuld_committed) & valid_instrs_iss_i[0];
  // -- Write Hazard --
  // Check incoming write addresses against stored write address;
  // but only when busy & not when inserting sFDIV.
  assign fmuld_write_hazard = check_interlock(raw_rf_wr_addr_fw0_iss_i, fmuld_rf_wr_addr_fw0_f1, swap_rf_wr_en_fw0_iss_i, 2'b11, rf_ilock_ctl_fw0_iss_i)
                              & (fmuld_valid_f1_i |
                                 fmuld_valid_f2_i |
                                 fmuld_valid_f3_i |
                                 fmuld_committed);

  // ------------------------------------------------------
  // FMULD Interlock Generation
  // ------------------------------------------------------

  assign fmuld_interlock_iss = (fmuld_struct_hazard |
                                fmuld_read_hazard   |
                                fmuld_write_hazard);

  // ===========================================================================
  // == FMACS Control                                                         ==
  // ===========================================================================
  //
  // The following logic generates control and interlock signals for single
  // precision FMAC instructions.

  assign fp_mul_ctl_iss = fp_pipectl_iss_i[`CA5_FP_PIPECTL_MUL_CTL_BITS];

`genif (NEON_0)
  assign neon_mul_int_op_iss = fp_mul_ctl_iss[`CA5_FP_MUL_NEON_INT_OP_BITS];
`genelse
  assign neon_mul_int_op_iss = 1'b0;
`genendif

  assign fmac_valid_iss_sp = (fp_ex_pipe_iss_i[`CA5_FP_EX_PIPE_MUL] & ~fp_mul_ctl_iss[`CA5_FP_MUL_PRECISION_BITS]
                                & fp_mul_ctl_iss[`CA5_FP_MUL_ACCUMULATE_BITS] & ~neon_mul_int_op_iss & valid_instrs_iss_i[0]);
  assign fmac_valid_iss_dp = fmuld_done & fmuld_accumulate_f1 & ~quash_wr_special_i;

  assign fmac_valid_iss = fmac_valid_iss_sp | fmac_valid_iss_dp;

  assign fmac_valid_en = ((fmac_valid_iss    |
                           fmac_valid_f1     |
                           fmac_valid_f2     |
                           fmac_pre_valid_f3 |
                           fmac_valid_f4) & ~(stall_wr_i & ~flush_ret_i));

  assign nxt_fmac_valid_f1 = fmac_valid_iss & (valid_instrs_iss_i[0] & ~flush_wr_i & ~stall_iss_i | fmac_valid_iss_dp);
  assign nxt_fmac_valid_f2 = fmac_valid_f1  & (valid_instrs_ex1_i[0] & ~flush_wr_i                | fmac_dp_f1);
  assign nxt_fmac_valid_f3 = fmac_valid_f2  & (valid_instrs_ex2_i[0] & ~flush_wr_i                | fmac_dp_f2);
  assign nxt_fmac_valid_f4 = fmac_valid_f3  & (valid_instrs_wr_i[0]  & ~quash_wr_special_i        | fmac_dp_f3 );

  always @(posedge clk or negedge reset_n)
    begin
      if(~reset_n) begin
        fmac_valid_f1      <= 1'b0;
        fmac_valid_f2      <= 1'b0;
        fmac_pre_valid_f3  <= 1'b0;
        fmac_valid_f4      <= 1'b0;
        fmac_sign_f1       <= 1'b0;
        fmac_sign_f2       <= 1'b0;
        fmac_sign_f3       <= 1'b0;
        fmac_sign_f4       <= 1'b0;
        fmac_wr_addr_f4    <= {5{1'b0}};
        fmac_wr_en_f4      <= {2{1'b0}};
      end else if (fmac_valid_en) begin
        fmac_valid_f1      <= nxt_fmac_valid_f1;
        fmac_valid_f2      <= nxt_fmac_valid_f2;
        fmac_pre_valid_f3  <= nxt_fmac_valid_f3;
        fmac_valid_f4      <= nxt_fmac_valid_f4;
        fmac_sign_f1       <= fmac_valid_iss_dp ? fmuld_sign_f1 : fp_pipectl_iss_i[`CA5_FP_PIPECTL_ACCSGN_BITS];
        fmac_sign_f2       <= fmac_sign_f1;
        fmac_sign_f3       <= fmac_sign_f2;
        fmac_sign_f4       <= fmac_sign_f3;
        fmac_wr_addr_f4    <= fmac_wr_addr_f3;
        fmac_wr_en_f4      <= fmac_wr_en_f3;
      end
    end

  always @(posedge clk)
    if (fmac_valid_en) begin
      fmac_dp_f1           <= fmac_valid_iss_dp;
      fmac_dp_f2           <= fmac_dp_f1;
      fmac_dp_f3           <= fmac_dp_f2;
      fmac_dp_f4           <= fmac_dp_f3;
      fmac_wr_addr_f1      <= fmac_valid_iss_dp ? fmuld_rf_wr_addr_fw0_f1 : raw_rf_wr_addr_fw0_iss_i;
      fmac_wr_addr_f2      <= fmac_wr_addr_f1;
      fmac_wr_addr_f3      <= fmac_wr_addr_f2;
      fmac_wr_en_f1        <= {2{fmac_valid_iss_dp}} | swap_rf_wr_en_fw0_iss_i;
      fmac_wr_en_f2        <= fmac_wr_en_f1;
      fmac_wr_en_f3        <= fmac_wr_en_f2;
    end

`genif (NEON_0) : NEON1
  reg [(`CA5_SEL_FAD_A_W-1):0] fmac_sel_fad_a_f1;
  reg [(`CA5_SEL_FAD_A_W-1):0] fmac_sel_fad_a_f2;
  reg [(`CA5_SEL_FAD_A_W-1):0] fmac_sel_fad_a_f3;
  reg [(`CA5_SEL_FAD_A_W-1):0] fmac_sel_fad_a_f4;

  always @(posedge clk)
    if (fmac_valid_en) begin
      fmac_sel_fad_a_f1    <= fmac_valid_iss_dp ? `CA5_SEL_FAD_A_FR2 : sel_fad_a_iss_i;
      fmac_sel_fad_a_f2    <= fmac_sel_fad_a_f1;
      fmac_sel_fad_a_f3    <= fmac_sel_fad_a_f2;
      fmac_sel_fad_a_f4    <= fmac_sel_fad_a_f3;
    end

  assign sfmac_sel_fad_a = fmac_sel_fad_a_f4;
`genelse
  assign sfmac_sel_fad_a = `CA5_SEL_FAD_A_FR2;
`genendif

  // Qualify the fmac valid signal in Wr with the condition code flags
  assign fmac_valid_f3 = fmac_pre_valid_f3 & (fmac_dp_f3 | cc_pass_instr0_wr_i);

  // Insert the special when the instruction leaves wr, and hasn't ccfailed.
  assign fmac_insert_iss = /*pre_valid_instrs_wr_i[0] & */ fmac_valid_f4;

  // ------------------------------------------------------
  // FMACS Hazard Checking
  // ------------------------------------------------------
  // We must check for any RAW hazards between the instruction in Iss and the
  // write address in F1/F2/F3/F4. The write address will become the read/write
  // address for the accumulator so we must interlock until the special is
  // inserted.
  //
  // We also need to check for WAW hazards to prevent a special being inserted
  // after a later instruction that writes the same destination.  If the fmacs
  // ccfails then the special will not be inserted, therefore no need to
  // interlock in this case.

  // FMACS read hazard checking
  assign fmac_fr0_read_hazard = (((rf_rd_addr_fr0_iss_i == fmac_wr_addr_f1) & |(rf_rd_en_fr0_iss_i & fmac_wr_en_f1) & fmac_valid_f1) |
                                 ((rf_rd_addr_fr0_iss_i == fmac_wr_addr_f2) & |(rf_rd_en_fr0_iss_i & fmac_wr_en_f2) & fmac_valid_f2) |
                                 ((rf_rd_addr_fr0_iss_i == fmac_wr_addr_f3) & |(rf_rd_en_fr0_iss_i & fmac_wr_en_f3) & fmac_valid_f3) |
                                 ((rf_rd_addr_fr0_iss_i == fmac_wr_addr_f4) & |(rf_rd_en_fr0_iss_i & fmac_wr_en_f4) & fmac_valid_f4));

  assign fmac_fr1_read_hazard = (((rf_rd_addr_fr1_iss_i == fmac_wr_addr_f1) & |(rf_rd_en_fr1_iss_i & fmac_wr_en_f1) & fmac_valid_f1) |
                                 ((rf_rd_addr_fr1_iss_i == fmac_wr_addr_f2) & |(rf_rd_en_fr1_iss_i & fmac_wr_en_f2) & fmac_valid_f2) |
                                 ((rf_rd_addr_fr1_iss_i == fmac_wr_addr_f3) & |(rf_rd_en_fr1_iss_i & fmac_wr_en_f3) & fmac_valid_f3) |
                                 ((rf_rd_addr_fr1_iss_i == fmac_wr_addr_f4) & |(rf_rd_en_fr1_iss_i & fmac_wr_en_f4) & fmac_valid_f4));

  assign fmac_fr2_read_hazard = (((rf_rd_addr_fr2_iss_i == fmac_wr_addr_f1) & |(raw_rf_rd_en_fr2_iss_i & fmac_wr_en_f1) & fmac_valid_f1) |
                                 ((rf_rd_addr_fr2_iss_i == fmac_wr_addr_f2) & |(raw_rf_rd_en_fr2_iss_i & fmac_wr_en_f2) & fmac_valid_f2) |
                                 ((rf_rd_addr_fr2_iss_i == fmac_wr_addr_f3) & |(raw_rf_rd_en_fr2_iss_i & fmac_wr_en_f3) & fmac_valid_f3) |
                                 ((rf_rd_addr_fr2_iss_i == fmac_wr_addr_f4) & |(raw_rf_rd_en_fr2_iss_i & fmac_wr_en_f4) & fmac_valid_f4));

  assign fmac_read_hazard = (valid_instrs_iss_i[0] &
                             (fmac_fr0_read_hazard | fmac_fr1_read_hazard | fmac_fr2_read_hazard));

  // FMACS write hazard checking
  assign fmac_fw0_write_hazard = (((raw_rf_wr_addr_fw0_iss_i == fmac_wr_addr_f1) & |(swap_rf_wr_en_fw0_iss_i & fmac_wr_en_f1) & fmac_valid_f1) |
                                  ((raw_rf_wr_addr_fw0_iss_i == fmac_wr_addr_f2) & |(swap_rf_wr_en_fw0_iss_i & fmac_wr_en_f2) & fmac_valid_f2) |
                                  ((raw_rf_wr_addr_fw0_iss_i == fmac_wr_addr_f3) & |(swap_rf_wr_en_fw0_iss_i & fmac_wr_en_f3) & fmac_valid_f3) |
                                  ((raw_rf_wr_addr_fw0_iss_i == fmac_wr_addr_f4) & |(swap_rf_wr_en_fw0_iss_i & fmac_wr_en_f4) & fmac_valid_f4));

  assign fmac_write_hazard = fmac_fw0_write_hazard;

  // FMACS structural hazard checking
  assign fmac_struct_hazard = fmac_insert_iss & (fp_ex_pipe_iss_i[`CA5_FP_EX_PIPE_ADD] |
                                                (|swap_rf_wr_en_fw0_iss_i & valid_instrs_iss_i[0] & ~fmac_valid_iss_sp) |
                                                (|raw_rf_rd_en_fr2_iss_i & valid_instrs_iss_i[0]));

  // ------------------------------------------------------
  // FMACS Interlock Generation
  // ------------------------------------------------------

  // If forcing in order, then stall the NOP until we are ready to insert the sFMAC
  assign fmac_interlock_iss = fmac_read_hazard |
                              fmac_write_hazard |
                              fmac_struct_hazard |
                              (no_insert_iss_i & ((fmuld_accumulate_f1 & fmuld_in_flight) | fmac_valid_f1 | fmac_valid_f2 | fmac_valid_f3));

  // ===========================================================================
  // == Interlock Generation for serializing (FMXR/FMRX/FMSTAT) Instructions  ==
  // ===========================================================================
  //
  // We must generate an interlock for instructions that write the FPSCR/FPEXC
  // (certain types of FMXR) to prevent the control signals changing while FPU
  // phantom instructions are in the pipeline (or the instruction is 'commited')
  // and the subsequent special has not been issued.
  //
  // We must also generate an interlock for instructions that read the FPSCR/
  // FPEXC registers (FMRX/FMSTAT) while FPU phantom instructions are in the
  // pipeline (or the instruction is 'commited') since the subsequent special
  // may modify the FPSCR/FPEXC.
  //
  // Finally we also serialize any accesses to the FPSID/MVFR0/MVFR1 system
  // registers even though these can not be modified.
  //
  // In all cases we must wait until the special has been issued before we
  // can allow the FMRX/FMXR instruction to proceed.

  assign fmac_in_flight = (fmac_valid_f1 |
                           fmac_valid_f2 |
                           fmac_valid_f3 |
                           fmac_valid_f4 |
                           fmac_insert_iss);

  assign fdivs_in_flight = (fdivs_valid_f1_i |
                            fdivs_valid_f2_i |
                            fdivs_valid_f3_i |
                            fdivs_committed);

  assign fmuld_in_flight = (fmuld_valid_f1_i |
                            fmuld_valid_f2_i |
                            fmuld_valid_f3_i |
                            fmuld_committed);

  assign fp_special_in_flight = fmac_in_flight | fdivs_in_flight | fmuld_in_flight;

  // Create the interlock - the fp_serialize_iss signal catches all cases except for
  // when we copy the FPSCR to the integer register file with an FMRX instruction.
  assign fpscr_interlock_iss = fp_special_in_flight & fp_serialize_iss_i;

  // ------------------------------------------------------
  // Combined Interlock and Type Signal
  // ------------------------------------------------------

  // Priority of special intructions is as follows:
  // 1: sFMAC  for FMAC
  // 2: sFMULD for FMULD
  // 3: sFDIV  for FDIV/FSQRT

  assign special_interlock_iss_o = (fdivs_interlock_iss | fmac_interlock_iss |
                                    fmuld_interlock_iss |
                                    fpscr_interlock_iss);

  assign special_stall_iss_o     = fdivs_stall_iss | fmuld_stall_iss;
  assign special_insert_iss_o    = fdivs_stall_iss | fmuld_stall_iss | fmac_insert_iss;

  always @*
    begin
      special_sel_fad_a_iss_o       = `CA5_SEL_FAD_A_ZERO;
      special_sel_fad_b_iss_o       = `CA5_SEL_FAD_B_ZERO;
      special_rf_rd_en_fr2_iss_o    = 2'b00;
      special_rf_rd_addr_fr2_iss_o  = {5{1'b0}};
      special_fp_add_ctl_iss_o      = {`CA5_FP_ADD_CTL_W{1'b0}};

      case({fdivs_stall_iss, fmuld_stall_iss, fmac_insert_iss})
        3'b001: begin
          special_sel_fad_a_iss_o       = sfmac_sel_fad_a;
          special_sel_fad_b_iss_o       = `CA5_SEL_FAD_B_FML_Q;
          special_rf_rd_en_fr2_iss_o    = fmac_wr_en_f4;
          special_rf_rd_addr_fr2_iss_o  = fmac_wr_addr_f4;
          special_rf_wr_en_fw0_iss_o    = fmac_wr_en_f4;
          special_rf_wr_addr_fw0_iss_o  = fmac_wr_addr_f4;
          special_rf_wr_src_fw0_iss_o   = `CA5_RF_FWR_SRC_FAD_Q;

          special_fp_add_ctl_iss_o[`CA5_FP_ADD_NEGATE_BITS]     = fmac_sign_f4 ? 2'b01              : 2'b00;
          special_fp_add_ctl_iss_o[`CA5_FP_ADD_OUT_FORMAT_BITS] = fmac_dp_f4   ? `CA5_FP_FORMAT_F64 : `CA5_FP_FORMAT_F32;
          special_fp_add_ctl_iss_o[`CA5_FP_ADD_IN_FORMAT_BITS]  = fmac_dp_f4   ? `CA5_FP_FORMAT_F64 : `CA5_FP_FORMAT_F32;
        end
        3'b010: begin
          special_rf_wr_en_fw0_iss_o    = 2'b11;
          special_rf_wr_addr_fw0_iss_o  = fmuld_rf_wr_addr_fw0_f1;
          special_rf_wr_src_fw0_iss_o   = `CA5_RF_FWR_SRC_FML_Q;
        end
        3'b100: begin
          special_rf_wr_en_fw0_iss_o    = fdivs_rf_wr_en_fw0_f1;
          special_rf_wr_addr_fw0_iss_o  = fdivs_rf_wr_addr_fw0_f1;
          special_rf_wr_src_fw0_iss_o   = `CA5_RF_FWR_SRC_FML_Q;
        end
        default: begin
          special_sel_fad_a_iss_o       = {`CA5_SEL_FAD_A_W{1'bx}};
          special_sel_fad_b_iss_o       = {`CA5_SEL_FAD_B_W{1'bx}};
          special_rf_rd_en_fr2_iss_o    = 2'bxx;
          special_rf_rd_addr_fr2_iss_o  = {5{1'bx}};
          special_rf_wr_en_fw0_iss_o    = 2'bxx;
          special_rf_wr_addr_fw0_iss_o  = {`CA5_FP_RF_ADDR_W{1'bx}};
          special_rf_wr_src_fw0_iss_o   = {`CA5_RF_FWR_SRC_W{1'bx}};
          special_fp_add_ctl_iss_o      = {`CA5_FP_ADD_CTL_W{1'bx}};
        end
      endcase
    end

  // ------------------------------------------------------
  // Assign to module outputs
  // ------------------------------------------------------

  assign unflushable_sfmac_iss_o    = fmac_insert_iss;
  assign unflushable_sfmuld_iss_o   = fmuld_stall_iss;
  assign unflushable_sfdiv_iss_o    = fdivs_stall_iss;
  assign fmacs_valid_f3_o           = fmac_valid_f3 & ~fmac_dp_f3;
  assign quash_sfmuld_f1_o          = quash_sfmuld_f1;
  assign fmuld_xflag_force_f3_o     = fmac_valid_f3 & fmac_dp_f3;

  //----------------------------------------------------------------------------
  //                     OVL definitions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_ERROR,`OVL_ASSERT,"special_insert_iss is correct")
    ovl_special_insert (.clk             (clk),
                        .reset_n         (reset_n),
                        .antecedent_expr (special_stall_iss_o),
                        .consequent_expr (special_insert_iss_o));

  assert_zero_one_hot #(`OVL_ERROR,3,`OVL_ASSERT,"Insert special signals not one hot")
    ovl_special_onehot (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr ({fdivs_stall_iss, fmuld_stall_iss, fmac_insert_iss}));

`endif

endmodule // ca5dpu_special
