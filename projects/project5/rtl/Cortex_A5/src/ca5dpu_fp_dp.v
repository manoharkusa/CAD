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
//      Checked In          : $Date: 2009-11-13 13:52:31 +0000 (Fri, 13 Nov 2009) $
//
//      Revision            : $Revision: 123484 $
//
//      Release Information : CORTEX-A5-FPU-r0p1-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Floating point datapath wrapper module (containing data muxes)
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This module instantiates the FPU datapath modules and
// contains the muxes used to select data to and from those pipelines.

`include "ca5dpu_params.v"

module ca5dpu_fp_dp `DPU_PARAM_DECL (
  // ---------------------------------------------------------
  // Interface signals
  // ---------------------------------------------------------

  // -----------------------------
  // Inputs
  // -----------------------------

  input  wire                             clk,
  input  wire                             reset_n,

  // Data in and out from the various blocks
  input  wire                             flush_ret_i,
  input  wire                             stall_wr_i,

  // FPU
  input  wire [1:0]                       rf_rd_en_fr0_f1_i,
  input  wire [1:0]                       rf_rd_en_fr1_f1_i,
  input  wire [1:0]                       rf_rd_en_fr2_f1_i,
  input  wire [63:0]                      rf_rd_data_fr0_f1_i,   // FPU register file read port 0
  input  wire [63:0]                      rf_rd_data_fr1_f1_i,   // FPU register file read port 1
  input  wire [63:0]                      rf_rd_data_fr2_f1_i,   // FPU register file read port 2
  input  wire [2:0]                       fr0_lo_fwd_f1_i,       // FPU forwarding mux select
  input  wire [2:0]                       fr1_lo_fwd_f1_i,       // FPU forwarding mux select
  input  wire [2:0]                       fr2_lo_fwd_f1_i,       // FPU forwarding mux select
  input  wire [2:0]                       fr0_hi_fwd_f1_i,       // FPU forwarding mux select
  input  wire [2:0]                       fr1_hi_fwd_f1_i,       // FPU forwarding mux select
  input  wire [2:0]                       fr2_hi_fwd_f1_i,       // FPU forwarding mux select
  input  wire [(`CA5_SEL_FAD_A_W-1):0]    sel_fad_a_f1_i,        // Mux select signal(s) for FAD_A
  input  wire [(`CA5_SEL_FAD_B_W-1):0]    sel_fad_b_f1_i,        // Mux select signal(s) for FAD_B
  input  wire [(`CA5_SEL_FAD_C_W-1):0]    sel_fad_c_f1_i,        // Mux select signal(s) for FAD_C
  input  wire                             sel_fml_a_f1_i,        // Mux select signal(s) for FML_A
  input  wire [(`CA5_SEL_FML_B_W-1):0]    sel_fml_b_f1_i,        // Mux select signal(s) for FML_B
  input  wire                             sel_fml_c_f1_i,        // Mux select signal(s) for FML_C
  input  wire [(`CA5_RF_FWR_SRC_W-1):0]   rf_wr_src_fw0_f2_i,    // Mux select signal(s) for RF write port 0
  input  wire [(`CA5_RF_FWR_SRC_W-1):0]   rf_wr_src_fw0_f3_i,    // Mux select signal(s) for RF write port 0
  input  wire [(`CA5_RF_FWR_SRC_W-1):0]   rf_wr_src_fw0_f5_i,    // Mux select signal(s) for RF write port 0
  input  wire [12:0]                      imm_data_f1_i,         // FPU immediate data
  input  wire [(`CA5_FP_EX_PIPE_W-1):0]   fp_ex_pipe_f1_i,
  input  wire [(`CA5_FP_PIPECTL_W-1):0]   fp_pipectl_f1_i,
  input  wire                             fp_div_enb_f1_i,
  input  wire [1:0]                       fp_sysreg_rmode_f5_i,
  input  wire                             fp_sysreg_fz_f5_i,
  input  wire                             fp_sysreg_dn_f5_i,
  input  wire                             fp_sysreg_ahp_f5_i,
  input  wire [1:0]                       valid_instrs_wr_i,
  input  wire                             issue_to_ex2_fpu_i,
  input  wire                             issue_to_wr_fpu_i,
  input  wire                             issue_to_f4_i,
  input  wire                             first_x32_wr_i,
  input  wire [31:0]                      fwd_ldr_wr_i,         // Load data from LSU (not sign extended)
  input  wire [31:0]                      fwd_alu_wr_i,         // Data from ALU
  input  wire [31:0]                      st_data_wr_i,         // Data from store pipe
  input  wire [1:0]                       ls_elem_size_wr_i,    // Size of element data

  // -----------------------------
  // Outputs
  // -----------------------------

  // FPU Divider
  output wire                             div_finished_iss_o,

  // FPU Data
  output wire [63:0]                      rf_wr_data_fw0_f5_o,  // FPU register file data port 0

  output wire [31:0]                      ls_data_fw0_wr_o,

  output wire [31:0]                      fwd_data_fr0_f1_o,
  output wire [31:0]                      fwd_data_fr1_f1_o,

  // FPU flags
  output wire [3:0]                       fp_cflags_add_f3_o,
  output wire [(`CA5_XFLAGS_W-1):0]       fp_xflags_mul_f5_o,
  output wire [(`CA5_XFLAGS_W-1):0]       fp_xflags_add_f5_o
);

  // -----------------------------
  // Wire and Reg declarations
  // -----------------------------

  // FPU Signals
  wire [63:0]                     fad_a_data_f1;    // FAD A input data bus
  wire [63:0]                     fad_b_data_f1;    // FAD B input data bus
  wire [63:0]                     fad_c_data_f1;    // FAD C input data bus
  wire [63:0]                     fml_a_data_f1;    // FML A input data bus
  wire [63:0]                     fml_b_data_f1;    // FML B input data bus
  wire [63:0]                     fml_c_data_f1;    // FML C input data bus

  wire                            hold_fml_b_data_f1;

  wire [31:0]                     ld_data_f3;
  wire [31:0]                     dup_ld_data_f3;
  wire [31:0]                     ls_rt_data_fw0_f3;
  reg [63:0]                      fwd_data_raw_fr0_f1;
  reg [63:0]                      fwd_data_raw_fr1_f1;
  reg [63:0]                      fwd_data_raw_fr2_f1;
  reg [63:0]                      neon_modimm_data_f1;
  reg [7:0]                       imm_data_f2;
  reg [7:0]                       imm_data_f3;
  wire [63:0]                     fwd_data_fr0_f1;
  wire [63:0]                     fwd_data_fr1_f1;
  wire [63:0]                     fwd_data_fr2_f1;
  wire [63:0]                     rf_wr_data_fw0_f5;

  wire                            add_enable_f1;
  wire                            mul_enable_f1;
  wire [(`CA5_FP_ADD_CTL_W-1):0]  add_ctl_f1;
  wire [(`CA5_FP_MUL_CTL_W-1):0]  mul_ctl_f1;
  wire                            fp_sfmac_f1;
  wire                            neon_vrsqrts_f1;
  wire                            sel_imm_data_fw0_f2;
  wire                            sel_dp_imm_data_fw0_f2;
  wire                            sel_ld_data_fw0_f3;
  wire                            sel_st_data_fw0_f3;
  wire                            sel_imm_data_fw0_f3;
  wire                            sel_dp_imm_data_fw0_f3;
  wire                            sel_neon_ld_fw0_f3;
  wire                            sel_ld_prev_fw0_f3;
  wire                            sel_alu_data_fw0_f3;
  wire                            en_ls_rt_data_fw0_f4;
  reg                             en_ls_rt_data_fw0_f5;
  reg [31:0]                      ls_rt_data_fw0_f4;
  reg [31:0]                      ls_rt_data_fw0_f5;

  wire                            fp_force_rn_f1;
  wire                            fp_force_rz_f1;
  wire                            fp_force_dn_fz_f1;

  wire [63:0]                     fad_data_f5;
  wire [63:0]                     fml_data_f5;
  reg [1:0]                       fp_sysreg_rmode;

  wire [1:0]                      mac_round_mode_f5;
  wire                            mac_force_dn_fz_f5;
  wire                            mac_fused_mac_f5;
  wire [1:0]                      fp_rm_add_f1;
  wire                            add_force_dn_fz_f1;
  wire                            add_fused_mac_f1;

  // ------------------------------------------------------
  // Ex1 Stage Forwarding muxes
  // ------------------------------------------------------

  always @*
    case (fr0_lo_fwd_f1_i)
      `CA5_FWD_FW0_F5 : fwd_data_raw_fr0_f1[31:0]  = rf_wr_data_fw0_f5[31:0];
      `CA5_FWD_FW0_F4 : fwd_data_raw_fr0_f1[31:0]  = ls_rt_data_fw0_f4[31:0];
      `CA5_FWD_FW0_F3 : fwd_data_raw_fr0_f1[31:0]  = ls_rt_data_fw0_f3[31:0];
      `CA5_FWD_FNULL  : fwd_data_raw_fr0_f1[31:0]  = rf_rd_data_fr0_f1_i[31:0];
      default         : fwd_data_raw_fr0_f1[31:0]  = {32{1'bx}};
    endcase

  always @*
    case (fr0_hi_fwd_f1_i)
      `CA5_FWD_FW0_F5 : fwd_data_raw_fr0_f1[63:32] = rf_wr_data_fw0_f5[63:32];
      `CA5_FWD_FW0_F4 : fwd_data_raw_fr0_f1[63:32] = ls_rt_data_fw0_f4[31:0];
      `CA5_FWD_FW0_F3 : fwd_data_raw_fr0_f1[63:32] = ls_rt_data_fw0_f3[31:0];
      `CA5_FWD_FNULL  : fwd_data_raw_fr0_f1[63:32] = rf_rd_data_fr0_f1_i[63:32];
      default         : fwd_data_raw_fr0_f1[63:32] = {32{1'bx}};
    endcase

  always @*
    case (fr1_lo_fwd_f1_i)
      `CA5_FWD_FW0_F5 : fwd_data_raw_fr1_f1[31:0]  = rf_wr_data_fw0_f5[31:0];
      `CA5_FWD_FW0_F4 : fwd_data_raw_fr1_f1[31:0]  = ls_rt_data_fw0_f4[31:0];
      `CA5_FWD_FW0_F3 : fwd_data_raw_fr1_f1[31:0]  = ls_rt_data_fw0_f3[31:0];
      `CA5_FWD_FNULL  : fwd_data_raw_fr1_f1[31:0]  = rf_rd_data_fr1_f1_i[31:0];
      default         : fwd_data_raw_fr1_f1[31:0]  = {32{1'bx}};
    endcase

  always @*
    case (fr1_hi_fwd_f1_i)
      `CA5_FWD_FW0_F5 : fwd_data_raw_fr1_f1[63:32] = rf_wr_data_fw0_f5[63:32];
      `CA5_FWD_FW0_F4 : fwd_data_raw_fr1_f1[63:32] = ls_rt_data_fw0_f4[31:0];
      `CA5_FWD_FW0_F3 : fwd_data_raw_fr1_f1[63:32] = ls_rt_data_fw0_f3[31:0];
      `CA5_FWD_FNULL  : fwd_data_raw_fr1_f1[63:32] = rf_rd_data_fr1_f1_i[63:32];
      default         : fwd_data_raw_fr1_f1[63:32] = {32{1'bx}};
    endcase

  always @*
    case (fr2_lo_fwd_f1_i)
      `CA5_FWD_FW0_F5 : fwd_data_raw_fr2_f1[31:0]  = rf_wr_data_fw0_f5[31:0];
      `CA5_FWD_FW0_F4 : fwd_data_raw_fr2_f1[31:0]  = ls_rt_data_fw0_f4[31:0];
      `CA5_FWD_FW0_F3 : fwd_data_raw_fr2_f1[31:0]  = ls_rt_data_fw0_f3[31:0];
      `CA5_FWD_FNULL  : fwd_data_raw_fr2_f1[31:0]  = rf_rd_data_fr2_f1_i[31:0];
      default         : fwd_data_raw_fr2_f1[31:0]  = {32{1'bx}};
    endcase

  always @*
    case (fr2_hi_fwd_f1_i)
      `CA5_FWD_FW0_F5 : fwd_data_raw_fr2_f1[63:32] = rf_wr_data_fw0_f5[63:32];
      `CA5_FWD_FW0_F4 : fwd_data_raw_fr2_f1[63:32] = ls_rt_data_fw0_f4[31:0];
      `CA5_FWD_FW0_F3 : fwd_data_raw_fr2_f1[63:32] = ls_rt_data_fw0_f3[31:0];
      `CA5_FWD_FNULL  : fwd_data_raw_fr2_f1[63:32] = rf_rd_data_fr2_f1_i[63:32];
      default         : fwd_data_raw_fr2_f1[63:32] = {32{1'bx}};
    endcase

  assign fwd_data_fr0_f1[63:32] = fwd_data_raw_fr0_f1[63:32];
  assign fwd_data_fr0_f1[31:0]  = rf_rd_en_fr0_f1_i == 2'b10 ? fwd_data_raw_fr0_f1[63:32]
                                                             : fwd_data_raw_fr0_f1[31:0];

  assign fwd_data_fr1_f1[63:32] = fwd_data_raw_fr1_f1[63:32];
  assign fwd_data_fr1_f1[31:0]  = rf_rd_en_fr1_f1_i == 2'b10 ? fwd_data_raw_fr1_f1[63:32]
                                                             : fwd_data_raw_fr1_f1[31:0];

  assign fwd_data_fr2_f1[63:32] = fwd_data_raw_fr2_f1[63:32];
  assign fwd_data_fr2_f1[31:0]  = rf_rd_en_fr2_f1_i == 2'b10 ? fwd_data_raw_fr2_f1[63:32]
                                                             : fwd_data_raw_fr2_f1[31:0];

  // ------------------------------------------------------
  // Calculate the modified immediate constant
  // ------------------------------------------------------

`genif (NEON_0)
  always @*
    case (imm_data_f1_i[12:8])
      // {op, cmode}
      `def_x000x : neon_modimm_data_f1 = {2{ {24{1'b0}}, imm_data_f1_i[7:0]}};
      `def_x001x : neon_modimm_data_f1 = {2{ {16{1'b0}}, imm_data_f1_i[7:0], { 8{1'b0}} }};
      `def_x010x : neon_modimm_data_f1 = {2{ { 8{1'b0}}, imm_data_f1_i[7:0], {16{1'b0}} }};
      `def_x011x : neon_modimm_data_f1 = {2{             imm_data_f1_i[7:0], {24{1'b0}} }};
      `def_x100x : neon_modimm_data_f1 = {4{ {8{1'b0}}, imm_data_f1_i[7:0]}};
      `def_x101x : neon_modimm_data_f1 = {4{imm_data_f1_i[7:0], {8{1'b0}} }};
      `def_x1100 : neon_modimm_data_f1 = {2{ {16{1'b0}}, imm_data_f1_i[7:0], { 8{1'b1}} }};
      `def_x1101 : neon_modimm_data_f1 = {2{ { 8{1'b0}}, imm_data_f1_i[7:0], {16{1'b1}} }};
      5'b01110   : neon_modimm_data_f1 = {8{imm_data_f1_i[7:0]}};
      5'b11110   : neon_modimm_data_f1 = {{8{imm_data_f1_i[7]}}, {8{imm_data_f1_i[6]}}, {8{imm_data_f1_i[5]}}, {8{imm_data_f1_i[4]}},
                                          {8{imm_data_f1_i[3]}}, {8{imm_data_f1_i[2]}}, {8{imm_data_f1_i[1]}}, {8{imm_data_f1_i[0]}}};
      default    : neon_modimm_data_f1 = {64{1'bx}};
    endcase
`genendif

  // ------------------------------------------------------
  // Read data muxes
  // ------------------------------------------------------

  // Add data selection muxing
`genif (NEON_0)
  assign fad_a_data_f1[63:0] = ({64{sel_fad_a_f1_i == `CA5_SEL_FAD_A_FR2}}   & fwd_data_fr2_f1[63:0]) |
                               ({64{sel_fad_a_f1_i == `CA5_SEL_FAD_A_TWO}}   & 64'h00000000_40000000) |
                               ({64{sel_fad_a_f1_i == `CA5_SEL_FAD_A_THREE}} & 64'h00000000_40400000);
  assign fad_b_data_f1[63:0] = ({64{sel_fad_b_f1_i == `CA5_SEL_FAD_B_FR1}}   & fwd_data_fr1_f1[63:0]) |
                               ({64{sel_fad_b_f1_i == `CA5_SEL_FAD_B_FML_Q}} & fml_data_f5[63:0])     |
                               ({64{sel_fad_b_f1_i == `CA5_SEL_FAD_B_IMM}}   & neon_modimm_data_f1);

  assign fad_c_data_f1[63:0] = ({64{sel_fad_c_f1_i == `CA5_SEL_FAD_C_FR0}}   & fwd_data_fr0_f1[63:0]) |
                               ({64{sel_fad_c_f1_i == `CA5_SEL_FAD_C_IMM}}   & {8{imm_data_f1_i[7:0]}});
`genelse
  assign fad_a_data_f1[63:0] =  {64{sel_fad_a_f1_i == `CA5_SEL_FAD_A_FR2}}   & fwd_data_fr2_f1[63:0];
  assign fad_b_data_f1[63:0] = ({64{sel_fad_b_f1_i == `CA5_SEL_FAD_B_FR1}}   & fwd_data_fr1_f1[63:0]) |
                               ({64{sel_fad_b_f1_i == `CA5_SEL_FAD_B_FML_Q}} & fml_data_f5[63:0]);
  assign fad_c_data_f1[63:0] =  {64{1'bx}};
`genendif

  // Multiply data selection muxing
  assign fml_a_data_f1[63:0] = {64{sel_fml_a_f1_i == `CA5_SEL_FML_A_FR0}} & fwd_data_fr0_f1[63:0];
  assign fml_b_data_f1[63:0] = {64{sel_fml_b_f1_i == `CA5_SEL_FML_B_FR1}} & fwd_data_fr1_f1[63:0];
  assign fml_c_data_f1[63:0] = {64{sel_fml_c_f1_i == `CA5_SEL_FML_C_FR2}} & fwd_data_fr2_f1[63:0];

  // Should the previous data on the B input be reused?
  assign hold_fml_b_data_f1 = sel_fml_b_f1_i == `CA5_SEL_FML_B_PREV;

  // -----------------------------------------------------
  // F2 Stage
  // -----------------------------------------------------

  always @(posedge clk)
    if (~stall_wr_i & issue_to_ex2_fpu_i)
        imm_data_f2  <= imm_data_f1_i[7:0];

  // ------------------------------------------------------
  // Locally generated FPU datapath control signals
  // ------------------------------------------------------

  assign fp_force_rn_f1     = fp_pipectl_f1_i[`CA5_FP_PIPECTL_FORCE_RN_BITS];
  assign fp_force_rz_f1     = fp_pipectl_f1_i[`CA5_FP_PIPECTL_FORCE_RZ_BITS];
`genif (NEON_0)
  assign fp_force_dn_fz_f1  = fp_pipectl_f1_i[`CA5_FP_PIPECTL_FORCE_DN_FZ_BITS];
`genelse
  assign fp_force_dn_fz_f1  = 1'b0;
`genendif

  // Force rounding mode zero when FTOUIZS/FTOSIZS is in F1.
  always @*
    begin
      case ({fp_force_rz_f1, fp_force_rn_f1})
        2'b11, // Shouldn't happen
        2'b10   : fp_sysreg_rmode = 2'b11;
        2'b01   : fp_sysreg_rmode = 2'b00;
        2'b00   : fp_sysreg_rmode = fp_sysreg_rmode_f5_i[1:0];
        default : fp_sysreg_rmode = 2'bxx;
      endcase
    end

  // Signal the single precision datapath that an sFMAC has been inserted
  // so it can use the rounding mode that the multiplier used
  assign fp_sfmac_f1 = (sel_fad_b_f1_i == `CA5_SEL_FAD_B_FML_Q);

  // A VRSQRTS instruction must decrement the exponent of the final result
  // Signal this instruction to the ALU pipe
  assign neon_vrsqrts_f1 = (sel_fad_a_f1_i == `CA5_SEL_FAD_A_THREE);

  // ------------------------------------------------------
  // FPU Datapath
  // ------------------------------------------------------

  assign fp_rm_add_f1       = fp_sfmac_f1 ? mac_round_mode_f5  : fp_sysreg_rmode;
  assign add_force_dn_fz_f1 = fp_sfmac_f1 ? mac_force_dn_fz_f5 : fp_force_dn_fz_f1;
  assign add_fused_mac_f1   = fp_sfmac_f1 & mac_fused_mac_f5;

  // FP add pipe control signals
  assign add_enable_f1 = fp_ex_pipe_f1_i[`CA5_FP_EX_PIPE_ADD];
  assign add_ctl_f1    = fp_pipectl_f1_i[`CA5_FP_PIPECTL_ADD_CTL_BITS];

  ca5dpu_fp_alu `DPU_PARAM_INST u_ca5dpu_fp_alu(
    .clk                  (clk),
    .stall_wr_i           (stall_wr_i),
    .flush_ret_i          (flush_ret_i),
    .rm_f1_i              (fp_rm_add_f1[1:0]),
    .force_dn_fz_f1_i     (add_force_dn_fz_f1),
    .fpscr_fz_i           (fp_sysreg_fz_f5_i),
    .fpscr_dn_i           (fp_sysreg_dn_f5_i),
    .ahp_f1_i             (fp_sysreg_ahp_f5_i),
    .enable_f1_i          (add_enable_f1),
    .add_ctl_f1_i         (add_ctl_f1),
    .dec_exp_f1_i         (neon_vrsqrts_f1),
    .fused_mac_f1_i       (add_fused_mac_f1),
    .imm_data_f1_i        (imm_data_f1_i[5:0]),
    .imm_data_f2_i        (imm_data_f2[7:0]),
    .fad_a_data_f1_i      (fad_a_data_f1),
    .fad_b_data_f1_i      (fad_b_data_f1),
    .fad_c_data_f1_i      (fad_c_data_f1),
    .fad_data_f5_o        (fad_data_f5),
    .add_xflags_f5_o      (fp_xflags_add_f5_o),
    .fp_cmpflags_f3_o     (fp_cflags_add_f3_o)
  );

  // FP multiply pipe control signals
  assign mul_enable_f1 = fp_ex_pipe_f1_i[`CA5_FP_EX_PIPE_MUL];
  assign mul_ctl_f1    = fp_pipectl_f1_i[`CA5_FP_PIPECTL_MUL_CTL_BITS];

  ca5dpu_fp_mul `DPU_PARAM_INST u_ca5dpu_fp_mul(
    .clk                  (clk),
    .stall_wr_i           (stall_wr_i),
    .flush_ret_i          (flush_ret_i),
    .round_mode_f1_i      (fp_sysreg_rmode),
    .force_dn_fz_f1_i     (fp_force_dn_fz_f1),
    .fpscr_dn_i           (fp_sysreg_dn_f5_i),
    .fpscr_fz_i           (fp_sysreg_fz_f5_i),
    .mul_enable_f1_i      (mul_enable_f1),
    .mul_ctl_f1_i         (mul_ctl_f1),
    .collect_div_f1_i     (fp_div_enb_f1_i),
    .fml_a_data_f1_i      (fml_a_data_f1),
    .fml_b_data_f1_i      (fml_b_data_f1),
    .fml_c_data_f1_i      (fml_c_data_f1),
    .hold_b_f1_i          (hold_fml_b_data_f1),
    .fml_data_f5_o        (fml_data_f5),
    .mul_xflags_o         (fp_xflags_mul_f5_o),
    .mac_round_mode_f5_o  (mac_round_mode_f5),
    .mac_force_dn_fz_f5_o (mac_force_dn_fz_f5),
    .div_finished_iss_o   (div_finished_iss_o),
    .fused_mac_f5_o       (mac_fused_mac_f5)
  );

  // Clock immediate data only in the case of floating point move immediate
  assign sel_imm_data_fw0_f2    = rf_wr_src_fw0_f2_i == `CA5_RF_FWR_SRC_SP_MOV;
  assign sel_dp_imm_data_fw0_f2 = rf_wr_src_fw0_f2_i == `CA5_RF_FWR_SRC_DP_MOV;

  always @(posedge clk)
    if (~stall_wr_i & (sel_imm_data_fw0_f2 | sel_dp_imm_data_fw0_f2))
      imm_data_f3 <= imm_data_f2;

  // ------------------------------------------------------
  // F3 datapath (load-store and register transfer)
  // ------------------------------------------------------

  // As the floating point pipeline is skewed any data signals from the integer
  // pipeline that are destined for the FPU register file must be muxed in the F3
  // stage, registered through F4 and then muxed with the FPU datapath signals in
  // the F5 stage before being written to the register file.
  //
  // Note that because floating point loads are always word aligned the non sign
  // extended data signals are used to help timing.
  assign sel_ld_data_fw0_f3     = rf_wr_src_fw0_f3_i == `CA5_RF_FWR_SRC_LSU;
  assign sel_st_data_fw0_f3     = rf_wr_src_fw0_f3_i == `CA5_RF_FWR_SRC_STR;
  assign sel_imm_data_fw0_f3    = rf_wr_src_fw0_f3_i == `CA5_RF_FWR_SRC_SP_MOV;
  assign sel_dp_imm_data_fw0_f3 = rf_wr_src_fw0_f3_i == `CA5_RF_FWR_SRC_DP_MOV;

`genif (NEON_0) : NEON1
  wire [(`CA5_NEON_VLD_CTL_W-1):0]  neon_vld_ctl_f1;
  reg  [(`CA5_NEON_VLD_CTL_W-1):0]  neon_vld_ctl_f2;
  reg  [(`CA5_NEON_VLD_CTL_W-1):0]  neon_vld_ctl_f3;

  assign neon_vld_ctl_f1 = fp_pipectl_f1_i[`CA5_FP_PIPECTL_NEON_VLD_BITS];

  always @(posedge clk)
    if (issue_to_ex2_fpu_i & ~stall_wr_i)
      begin
        neon_vld_ctl_f2 <= neon_vld_ctl_f1;
      end

  always @(posedge clk)
    if (issue_to_wr_fpu_i & ~stall_wr_i)
      begin
        neon_vld_ctl_f3 <= neon_vld_ctl_f2;
      end

  assign sel_neon_ld_fw0_f3   = rf_wr_src_fw0_f3_i == `CA5_RF_FWR_SRC_NEON_LD;
  assign sel_ld_prev_fw0_f3   = rf_wr_src_fw0_f3_i == `CA5_RF_FWR_SRC_LD_PREV;
  assign sel_alu_data_fw0_f3  = rf_wr_src_fw0_f3_i == `CA5_RF_FWR_SRC_ALU;

  ca5dpu_neon_ld u_dpu_neon_ld(
    .clk                (clk),
    .stall_wr_i         (stall_wr_i),
    .valid_instrs_wr_i  (valid_instrs_wr_i),
    .first_x32_wr_i     (first_x32_wr_i),
    .neon_vld_ctl_f3_i  (neon_vld_ctl_f3),
    .ls_elem_size_wr_i  (ls_elem_size_wr_i),
    .fwd_ldr_wr_i       (fwd_ldr_wr_i),
    .st_data_wr_i       (st_data_wr_i),
    .ld_data_f3_o       (ld_data_f3),
    .dup_ld_data_f3_o   (dup_ld_data_f3)
  );
`genelse
  assign sel_neon_ld_fw0_f3   = 1'b0;
  assign sel_ld_prev_fw0_f3   = 1'b0;
  assign sel_alu_data_fw0_f3  = 1'b0;
  assign ld_data_f3[31:0]     = fwd_ldr_wr_i;
  assign dup_ld_data_f3[31:0] = {32{1'b0}};
`genendif

  assign ls_rt_data_fw0_f3 = ({32{sel_ld_data_fw0_f3}}     & ld_data_f3[31:0])      |
                             ({32{sel_neon_ld_fw0_f3}}     & dup_ld_data_f3[31:0])  |
                             ({32{sel_st_data_fw0_f3}}     & st_data_wr_i[31:0])    |
                             ({32{sel_imm_data_fw0_f3}}    & {imm_data_f3[7], ~imm_data_f3[6], {5{imm_data_f3[6]}},imm_data_f3[5:0], {19{1'b0}} }) |
                             ({32{sel_dp_imm_data_fw0_f3}} & {imm_data_f3[7], ~imm_data_f3[6], {8{imm_data_f3[6]}},imm_data_f3[5:0], {16{1'b0}} }) |
                             ({32{sel_ld_prev_fw0_f3}}     & ls_rt_data_fw0_f4)     |
                             ({32{sel_alu_data_fw0_f3}}    & fwd_alu_wr_i[31:0]);

  assign en_ls_rt_data_fw0_f4 = (sel_ld_data_fw0_f3 | sel_neon_ld_fw0_f3 | sel_st_data_fw0_f3 | sel_imm_data_fw0_f3 |
                                 sel_dp_imm_data_fw0_f3 | sel_alu_data_fw0_f3) & issue_to_f4_i;

  // Datapath registers
  always @(posedge clk)
    if (en_ls_rt_data_fw0_f4)
      ls_rt_data_fw0_f4[31:0] <= ls_rt_data_fw0_f3;

  // Enable signal for next cycle
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      en_ls_rt_data_fw0_f5 <= 1'b0;
    else if (~stall_wr_i | flush_ret_i)
      en_ls_rt_data_fw0_f5 <= en_ls_rt_data_fw0_f4;

  // Expand the immediate data to 32-bits for SP and DP


  // ------------------------------------------------------
  // F4 datapath (load-store and register transfer)
  // ------------------------------------------------------

  always @(posedge clk)
     if (en_ls_rt_data_fw0_f5 & (~stall_wr_i | flush_ret_i))
       ls_rt_data_fw0_f5 <= ls_rt_data_fw0_f4[31:0];

  // ------------------------------------------------------
  // F5 datapath
  // ------------------------------------------------------

  assign rf_wr_data_fw0_f5 = (({64{(rf_wr_src_fw0_f5_i  == `CA5_RF_FWR_SRC_FML_Q)}}     & fml_data_f5[63:0]) |
                              ({64{(rf_wr_src_fw0_f5_i  == `CA5_RF_FWR_SRC_FAD_Q)}}     & fad_data_f5[63:0]) |
                              ({64{((rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_STR)     |
                                    (rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_ALU)     |
                                    (rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_LSU)     |
                                    (rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_NEON_LD) |
                                    (rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_SP_MOV)  |
                                    (rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_LD_PREV))}}  & {ls_rt_data_fw0_f5, ls_rt_data_fw0_f5}) |
                              ({64{(rf_wr_src_fw0_f5_i  == `CA5_RF_FWR_SRC_DP_MOV)}}    & {ls_rt_data_fw0_f5, {32{1'b0}} }));


  assign rf_wr_data_fw0_f5_o[63:0] = rf_wr_data_fw0_f5[63:0];
  assign ls_data_fw0_wr_o[31:0]    = ls_rt_data_fw0_f3[31:0];
  assign fwd_data_fr0_f1_o[31:0]  = fwd_data_fr0_f1[31:0];
  assign fwd_data_fr1_f1_o[31:0]  = fwd_data_fr1_f1[31:0];

  //----------------------------------------------------------------------------
  //                     OVL definitions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_ill_early_fp_rf_sel_0
  // Checks for illegal early select signal combinations into the FPU RF write
  // port 0
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_ERROR,`OVL_ASSERT,"Illegal early select for data into the fpu RF port 0")
    ovl_ill_early_fp_rf_sel_0 (.clk       (clk),
                               .reset_n   (reset_n),
                               .test_expr (rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_NONE    ||
                                           rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_DP_MOV  ||
                                           rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_NEON_LD ||
                                           rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_FAD_Q   ||
                                           rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_FML_Q   ||
                                           rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_LSU     ||
                                           rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_STR     ||
                                           rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_SP_MOV  ||
                                           rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_LD_PREV ||
                                           rf_wr_src_fw0_f5_i == `CA5_RF_FWR_SRC_ALU));
  // OVL_ASSERT_END

`endif

endmodule // ca5dpu_fp_dp
