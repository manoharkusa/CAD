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
//      Checked In          : $Date: 2009-12-23 19:19:36 +0000 (Wed, 23 Dec 2009) $
//
//      Revision            : $Revision: 128517 $
//
//      Release Information : CORTEX-A5-FPU-r0p1-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Floating point multiplier
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs IEEE multiplication with all rounding modes
//

`include "ca5dpu_params.v"

module ca5dpu_fp_mul `DPU_PARAM_DECL (
  input  wire                           clk,
  input  wire                           stall_wr_i,
  input  wire                           flush_ret_i,
  input  wire                           mul_enable_f1_i,
  input  wire [(`CA5_FP_MUL_CTL_W-1):0] mul_ctl_f1_i,
  input  wire                           collect_div_f1_i,
  input  wire                    [ 1:0] round_mode_f1_i,
  input  wire                           force_dn_fz_f1_i,
  input  wire                           fpscr_dn_i,        // default NaN mode
  input  wire                           fpscr_fz_i,        // flush to zero mode
  input  wire                    [63:0] fml_a_data_f1_i,
  input  wire                    [63:0] fml_b_data_f1_i,
  input  wire                    [63:0] fml_c_data_f1_i,
  input  wire                           hold_b_f1_i,       // Reuse the previous B operand

  output wire                    [63:0] fml_data_f5_o,
  output wire     [(`CA5_XFLAGS_W-1):0] mul_xflags_o,
  output wire                    [ 1:0] mac_round_mode_f5_o,
  output wire                           mac_force_dn_fz_f5_o,
  output wire                           div_finished_iss_o,
  output wire                           fused_mac_f5_o
);

  localparam  LOW_MUL_W     = 16;
  localparam  HIGH_MUL_W    = (NEON_0 ? 16 : 11);
  localparam  MUL_WIDTH     = LOW_MUL_W + HIGH_MUL_W;
  localparam  MUL_OP_W      = (NEON_0 ? MUL_WIDTH * 2 : MUL_WIDTH);
  localparam  ACC_WIDTH     = (NEON_0 ? 64 : 56);
  localparam  SUM_WIDTH     = (NEON_0 ? 64 : 55);
  localparam  RAW_SUM_WIDTH = (NEON_0 ? 67 : 55);

  reg  [10:0]               a_exp_f2;
  reg                       a_exp_max_f2;
  reg  [26:0]               a_mant_other_f2;
  reg                       a_sign_f2;
  reg  [12:0]               acc_exp_f3;
  reg  [12:0]               acc_exp_f4;
  reg                       acc_sub_f3;
  reg                       acc_sub_f4;
  reg                       acc_sub_inc_f5;
  reg  [ACC_WIDTH-1:0]      acc_val_f3;
  reg                       acc_val_huge_f3;
  reg                       accum_cycle_f2;
  reg                       accum_cycle_f3;
  reg                       accum_cycle_f4;
  reg                       accum_high_f3;
  reg  [10:0]               b_exp_f2;
  reg                       b_exp_max_f2;
  reg  [26:0]               b_mant_other_f2;
  reg                       b_sign_f2;
  reg                       collect_div_f2;
  reg                       collect_div_f3;
  reg                       collect_div_f4;
  reg                       div_roundbit_f4;
  reg                       div_stickybit_f4;
  reg                       divbyzero_f4;
  reg                       divbyzero_f5;
  reg                       double_prec_f2;
  reg                       double_prec_f3;
  reg                       double_prec_f4;
  reg                       double_prec_f5;
  reg  [ 1:0]               dp_fsm;
  reg                       enable_f2;
  reg                       enable_f3;
  reg                       enable_f4;
  reg  [ 2:0]               feedback_sel_f3;
  reg                       first_cycle_f2;
  reg                       first_cycle_f3;
  reg                       first_cycle_f4;
  reg                       frac_round_over_f5;
  reg                       fused_mac_f2;
  reg                       fused_mac_f3;
  reg                       fused_mac_f4;
  reg                       fused_mac_f5;
  reg                       guardbit_f5;
  reg                       in_flushzero_f3;
  reg                       in_flushzero_f4;
  reg                       in_flushzero_f5;
  reg                       inc_exp_f5;
  reg                       invalid_f3;
  reg                       invalid_f4;
  reg                       invalid_f5;
  reg                       last_cycle_f2;
  reg                       last_cycle_f3;
  reg                       last_cycle_f4;
  reg  [ 5:0]               mant_lz_f3;
  reg  [MUL_OP_W-1:0]       mul_op_a_f2;
  reg  [MUL_OP_W-1:0]       mul_op_b_f2;
  reg  [54:0]               mul_sum_f4;
  reg                       mul_zero_f3;
  reg                       neg_result_f3;
  reg                       neg_result_f4;
  reg                       negate_f2;
  reg  [1:0]                neon_acc_sat_f4;
  reg  [3:0]                neon_acc_sel_f2;
  reg  [3:0]                neon_acc_sel_f3;
  reg  [1:0]                neon_acc_sign_f3;
  reg  [1:0]                neon_acc_sign_f4;
  reg  [1:0]                neon_can_sat_f3;
  reg                       neon_fixup_f2;
  reg                       neon_mul_qc_f3;
  reg  [1:0]                neon_mul_sat_f3;
  reg  [2:0]                neon_out_fmt_f2;
  reg  [2:0]                neon_out_fmt_f3;
  reg  [2:0]                neon_part_sel_f2;
  reg  [2:0]                neon_part_sel_f3;
  reg                       neon_qc_bit_f4;
  reg                       neon_qc_bit_f5;
  reg                       neon_round_f2;
  reg                       neon_sat_dbl_f2;
  reg  [1:0]                neon_sat_width_f4;
  reg                       neon_underflow_f4;
  reg                       neon_vrsqrte_f3;
  reg  [10:0]               norm_exp_f5;
  reg                       norm_exp_zero_f5;
  reg  [51:0]               norm_frac_f5;
  reg                       norm_frac_zero_f5;
  reg  [12:0]               nxt_acc_exp_f4;
  reg                       nxt_acc_sub_f4;
  reg                       nxt_div_roundbit_f4;
  reg                       nxt_div_stickybit_f4;
  reg                       nxt_divbyzero_f4;
  reg                       nxt_double_prec_f4;
  reg                       nxt_fused_mac_f4;
  reg                       nxt_in_flushzero_f4;
  reg                       nxt_invalid_f4;
  reg  [54:0]               nxt_mul_sum_f4;
  reg                       nxt_neg_result_f4;
  reg                       nxt_out_sign_f4;
  reg                       nxt_res_infinite_f4;
  reg                       nxt_res_nan_f4;
  reg                       nxt_res_sign_f4;
  reg                       nxt_res_zero_f4;
  reg  [ 1:0]               nxt_round_mode_f4;
  reg  [ 6:0]               nxt_shift_f4;
  reg  [63:0]               op_c_f2;
  reg                       out_overflow_f5;
  reg                       out_sign_f3;
  reg                       out_sign_f4;
  reg                       out_sign_f5;
  reg  [HIGH_MUL_W*2-1:0]   prod_hi_hi_f3;
  reg  [MUL_WIDTH-1:0]      prod_hi_lo_f3;
  reg  [MUL_WIDTH-1:0]      prod_lo_hi_f3;
  reg  [LOW_MUL_W*2-1:0]    prod_lo_lo_f3;
  reg  [ 2:0]               raw_feedback_sel_f2;
  reg                       raw_neon_divbyzero_f3;
  reg                       raw_neon_force_dn_fz_f2;
  reg                       raw_neon_force_dn_fz_f3;
  reg                       raw_neon_force_dn_fz_f4;
  reg                       raw_neon_force_dn_fz_f5;
  reg                       raw_neon_int_op_f2;
  reg                       raw_neon_int_op_f3;
  reg                       raw_neon_int_op_f4;
  reg                       raw_neon_int_op_f5;
  reg                       raw_neon_inv_zero_f2;
  reg                       raw_neon_underflow_f5;
  reg                       raw_res_zero_f4;
  reg                       res_infinite_f3;
  reg                       res_infinite_f4;
  reg                       res_infinite_f5;
  reg                       res_nan_f3;
  reg                       res_nan_f4;
  reg                       res_nan_f5;
  reg                       res_sign_f3;
  reg                       res_sign_f4;
  reg                       res_zero_f3;
  reg                       res_zero_f5;
  reg  [ 1:0]               round_mode_f2;
  reg  [ 1:0]               round_mode_f3;
  reg  [ 1:0]               round_mode_f4;
  reg  [ 1:0]               round_mode_f5;
  reg                       round_updown_f5;
  reg  [ 1:0]               round_val_f5;
  reg                       roundbit_f5;
  reg  [ 6:0]               shift_f4;
  reg                       shift_low_f4;
  reg                       sqrt_f2;
  reg                       start_div_f2;
  reg                       stickyandbit_f5;
  reg                       stickybit_f5;

  wire [10:0]               a_exp_f1;
  wire                      a_exp_max_f1;
  wire [10:0]               a_exp_raw;
  wire                      a_exp_zero_f1;
  wire                      a_exp_zero_f2;
  wire                      a_flushzero;
  wire                      a_frac_zero_f2;
  wire                      a_infinite_f2;
  wire [52:0]               a_mant_f2;
  wire [ 5:0]               a_mant_lz_f2;
  wire [26:0]               a_mant_other_f1;
  wire                      a_nan_f2;
  wire                      a_sign_f1;
  wire                      a_snan_f2;
  wire                      a_zero_f2;
  wire [12:0]               acc_exp_f2;
  wire [12:0]               acc_renorm_exp_f4;
  wire [ 6:0]               acc_shift;
  wire                      acc_sub_f2;
  wire                      acc_sub_inc_f4;
  wire [ACC_WIDTH-1:0]      acc_val_f2;
  wire                      acc_val_huge_f2;
  wire                      acc_val_larger_f2;
  wire                      accum_cycle_f1;
  wire                      accum_high_f2;
  wire [ 6:0]               align_shift;
  wire                      andbit_in_f4;
  wire [10:0]               b_exp_f1;
  wire                      b_exp_max_f1;
  wire [10:0]               b_exp_raw;
  wire                      b_exp_zero_f1;
  wire                      b_exp_zero_f2;
  wire                      b_flushzero;
  wire                      b_frac_zero_f2;
  wire                      b_infinite_f2;
  wire [52:0]               b_mant_f2;
  wire [ 5:0]               b_mant_lz_f2;
  wire [26:0]               b_mant_other_f1;
  wire                      b_nan_f2;
  wire                      b_sign_f1;
  wire                      b_snan_f2;
  wire                      b_zero_f2;
  wire [10:0]               bias;
  wire [10:0]               c_exp_f2;
  wire                      c_exp_max_f2;
  wire                      c_exp_zero_f2;
  wire                      c_flushzero;
  wire                      c_frac_zero_f2;
  wire                      c_infinite_f2;
  wire [52:0]               c_mant_f2;
  wire [ 5:0]               c_mant_lz_f2;
  wire                      c_nan_f2;
  wire [12:0]               c_shift_f2;
  wire                      c_shift_huge;
  wire                      c_shift_normal;
  wire                      c_shift_tiny;
  wire                      c_sign_f2;
  wire                      c_snan_f2;
  wire                      c_zero_f2;
  wire                      div_divbyzero_f3;
  wire                      div_double_prec_f3;
  wire                      div_in_flushzero_f3;
  wire                      div_invalid_f3;
  wire [12:0]               div_out_exp_f3;
  wire [53:0]               div_out_frac_f3;
  wire                      div_out_sign_f3;
  wire                      div_res_infinite_f3;
  wire                      div_res_nan_f3;
  wire                      div_res_zero_f3;
  wire [ 1:0]               div_round_mode_f3;
  wire                      div_roundbit_f3;
  wire [ 6:0]               div_shift_f3;
  wire                      div_stickybit_f3;
  wire                      divbyzero_f2;
  wire                      double_prec_f1;
  wire                      enable_f1;
  wire [ 6:0]               exp_offset_f4;
  wire                      extra_shift;
  wire                      feedback_carry_high;
  wire                      feedback_carry_low;
  wire [ 2:0]               feedback_sel_f1;
  wire [ 2:0]               feedback_sel_f2;
  wire [54:0]               feedback_val;
  wire                      final_cycle_f2;
  wire                      final_cycle_f3;
  wire                      final_cycle_f4;
  wire                      first_cycle_f1;
  wire                      first_mul_zero_f2;
  wire                      flush_res_zero_f4;
  wire                      flush_res_zero_f5;
  wire [55:0]               fmac_acc_val_f2;
  wire [53:0]               fmac_clz_operand_high;
  wire [53:0]               fmac_clz_operand_low;
  wire [53:0]               fmac_clz_operand_mid;
  wire [ 5:0]               fmac_clz_res;
  wire [ 5:0]               fmac_clz_res_high;
  wire [ 5:0]               fmac_clz_res_low;
  wire [ 5:0]               fmac_clz_res_mid;
  wire                      fmac_negacc_f1;
  wire                      force_dn_fz_f2;
  wire                      force_dn_fz_f4;
  wire                      force_dn_fz_f5;
  wire                      frac_round_over_f4;
  wire                      fused_mac_f1;
  wire                      guardbit_f4;
  wire                      in_flushzero_f2;
  wire                      inc_exp_f4;
  wire                      inexact_f5;
  wire                      invalid_f2;
  wire                      invalid_op;
  wire                      last_cycle_f1;
  wire [ 5:0]               mant_lz_f2;
  wire [12:0]               mod_acc_exp_f3;
  wire                      mul_infinite_f2;
  wire                      mul_inv;
  wire                      mul_inx;
  wire [MUL_OP_W-1:0]       mul_op_a_f1;
  wire [MUL_OP_W-1:0]       mul_op_b_f1;
  wire [MUL_WIDTH-1:0]      mul_op_c_f2;
  wire [MUL_WIDTH-1:0]      mul_op_d_f2;
  wire                      mul_ovf;
  wire [ 5:0]               mul_renorm_shift;
  wire                      mul_sel_a_hi;
  wire                      mul_sel_a_prev;
  wire                      mul_sel_b_hi;
  wire                      mul_sel_lo;
  wire                      mul_sel_sp;
  wire [ 6:0]               mul_shift;
  wire [SUM_WIDTH-1:0]      mul_sum_f3;
  wire                      mul_sum_carry_f3;
  wire [RAW_SUM_WIDTH-1:0]  mul_sum_raw_f3;
  wire                      mul_sum_was_zero;
  wire                      mul_udf;
  wire                      mul_zero_f2;
  wire                      nan_sel_a_f2;
  wire                      nan_sel_b_f2;
  wire                      nan_sel_c_f2;
  wire                      nan_sign_f2;
  wire [52:0]               nan_val_f2;
  wire                      neg_result_f2;
  wire                      negate_f1;
  wire [1:0]                neon_acc_sat_f3;
  wire [1:0]                neon_acc_sign_f2;
  wire [1:0]                neon_can_sat_f2;
  wire                      neon_divbyzero_f3;
  wire                      neon_fixup_32bit_f2;
  wire                      neon_fixup_f1;
  wire                      neon_int_op_f1;
  wire                      neon_int_op_f2;
  wire                      neon_int_op_f3;
  wire                      neon_int_op_f4;
  wire                      neon_int_op_f5;
  wire                      neon_inv_zero_f1;
  wire                      neon_inv_zero_f2;
  wire                      neon_mul_qc_f2;
  wire [1:0]                neon_mul_sat_f2;
  wire [2:0]                neon_out_fmt_f1;
  wire                      neon_qc_bit_f3;
  wire                      neon_round_f1;
  wire                      neon_sat_dbl_f1;
  wire [1:0]                neon_sat_width_f3;
  wire                      neon_udf_f5;
  wire                      neon_underflow_f3;
  wire [7:0]                neon_vrec_est_exp_f3;
  wire [63:0]               neon_vrec_est_res_f3;
  wire                      neon_vrec_udf_f3;
  wire [10:0]               norm_exp_f4;
  wire                      norm_exp_zero_f4;
  wire [52:0]               norm_frac_f4;
  wire [ 1:0]               norm_frac_max_f4;
  wire                      norm_frac_top;
  wire                      norm_frac_zero_f4;
  wire [ 1:0]               nxt_dp_fsm;
  wire [10:0]               nxt_norm_exp_f5;
  wire [51:0]               nxt_norm_frac_f5;
  wire [63:0]               nxt_op_c_f2;
  wire                      nxt_out_sign_f5;
  wire [10:0]               out_exp;
  wire                      out_flushzero_f5;
  wire [51:0]               out_frac;
  wire                      out_frac_max;
  wire                      out_frac_zero;
  wire                      out_overflow_f4;
  wire                      out_sign_f2;
  wire                      overflow_to_inf;
  wire                      penultimate_cycle_f3;
  wire [12:0]               prod_exp_f2;
  wire [HIGH_MUL_W*2-1:0]   prod_hi_hi_f2;
  wire [HIGH_MUL_W*2-1:0]   prod_hi_hi_f2_raw;
  wire [MUL_WIDTH-1:0]      prod_hi_lo_f2;
  wire [MUL_WIDTH-1:0]      prod_hi_lo_f2_raw;
  wire [MUL_WIDTH-1:0]      prod_lo_hi_f2;
  wire [MUL_WIDTH-1:0]      prod_lo_hi_f2_raw;
  wire [LOW_MUL_W*2-1:0]    prod_lo_lo_f2;
  wire [LOW_MUL_W*2-1:0]    prod_lo_lo_f2_raw;
  wire                      res_denormal;
  wire [10:0]               res_exp_f4;
  wire [10:0]               res_exp_p1;
  wire                      res_infinite_f2;
  wire                      res_nan_f2;
  wire                      res_sign_f2;
  wire                      res_zero_f2;
  wire                      res_zero_f4;
  wire [10:0]               round_exp;
  wire                      round_nearest_f4;
  wire                      round_updown_f4;
  wire [ 1:0]               round_val_f4;
  wire                      roundbit_f4;
  wire [51:0]               rounded_frac;
  wire [ 6:0]               shift_f3;
  wire                      shift_low_f3;
  wire [110:0]              shift_operand;
  wire                      shifted_andbit;
  wire [55:0]               shifted_c_f2;
  wire [56:0]               shifted_frac;
  wire [56:0]               shifted_frac_raw;
  wire                      shifted_msb;
  wire                      sqrt_f1;
  wire                      start_div_f1;
  wire                      stickyandbit_f4;
  wire                      stickybit_f4;
  wire                      vrec_est_f2;
  wire [52:0]               vrec_est_op_f2;
  wire                      vrsqrte_f2;

  // Instantiate the divider module
  // This takes its input data in F2, and returns a result (many cycles later)
  // in F4

  ca5dpu_fp_div u_fp_div (
    .clk                  (clk),
    .stall_wr_i           (stall_wr_i),
    .flush_ret_i          (flush_ret_i),
    .start_div_f2_i       (start_div_f2),
    .sqrt_f2_i            (sqrt_f2),
    .double_prec_f2_i     (double_prec_f2),
    .round_mode_f2_i      (round_mode_f2),
    .res_zero_f2_i        (res_zero_f2),
    .res_infinite_f2_i    (res_infinite_f2),
    .res_nan_f2_i         (res_nan_f2),
    .invalid_f2_i         (invalid_f2),
    .divbyzero_f2_i       (divbyzero_f2),
    .in_flushzero_f2_i    (in_flushzero_f2),
    .out_sign_f2_i        (out_sign_f2),
    .a_exp_f2_i           (a_exp_f2),
    .b_exp_f2_i           (b_exp_f2),
    .a_mant_f2_i          (a_mant_f2),
    .b_mant_f2_i          (b_mant_f2),
    .a_mant_lz_f2_i       (a_mant_lz_f2),
    .b_mant_lz_f2_i       (b_mant_lz_f2),
    .nan_sel_a_f2_i       (nan_sel_a_f2),
    .nan_sel_b_f2_i       (nan_sel_b_f2),

    .out_sign_f3_o        (div_out_sign_f3),
    .out_exp_f3_o         (div_out_exp_f3),
    .out_frac_f3_o        (div_out_frac_f3),
    .roundbit_f3_o        (div_roundbit_f3),
    .stickybit_f3_o       (div_stickybit_f3),
    .shift_f3_o           (div_shift_f3),
    .double_prec_f3_o     (div_double_prec_f3),
    .round_mode_f3_o      (div_round_mode_f3),
    .res_infinite_f3_o    (div_res_infinite_f3),
    .res_zero_f3_o        (div_res_zero_f3),
    .res_nan_f3_o         (div_res_nan_f3),
    .invalid_f3_o         (div_invalid_f3),
    .divbyzero_f3_o       (div_divbyzero_f3),
    .in_flushzero_f3_o    (div_in_flushzero_f3),
    .div_finished_iss_o   (div_finished_iss_o)
  );


  // --- F1 stage ---

  // Extract control signals from cmd input
  assign first_cycle_f1 = mul_enable_f1_i;
  assign double_prec_f1 = mul_ctl_f1_i[`CA5_FP_MUL_PRECISION_BITS];
  assign negate_f1      = mul_ctl_f1_i[`CA5_FP_MUL_NEG_SQRT_BITS] & ~start_div_f1;
  assign fused_mac_f1   = mul_ctl_f1_i[`CA5_FP_MUL_FUSED_MAC_BITS];
  assign fmac_negacc_f1 = mul_ctl_f1_i[`CA5_FP_MUL_ACCUMULATE_BITS] & fused_mac_f1;

  // Extract divider control signals
  assign start_div_f1   = mul_ctl_f1_i[`CA5_FP_MUL_DIVIDE_BITS] & mul_enable_f1_i;
  assign sqrt_f1        = mul_ctl_f1_i[`CA5_FP_MUL_NEG_SQRT_BITS];

  // Generate other control signals
  assign enable_f1     = first_cycle_f1 | dp_fsm != 0 | accum_cycle_f1;
  assign last_cycle_f1 = first_cycle_f1 & ~double_prec_f1 | (~first_cycle_f1 & (dp_fsm == 2'b01));

  assign accum_cycle_f1 = ~first_cycle_f1 & ~collect_div_f1_i & last_cycle_f2 & fused_mac_f2 & double_prec_f2;

`genif (NEON_0)
  assign neon_int_op_f1   = mul_ctl_f1_i[`CA5_FP_MUL_NEON_INT_OP_BITS] & mul_enable_f1_i;
  assign neon_inv_zero_f1 = mul_ctl_f1_i[`CA5_FP_MUL_NEON_INV_IS_ZERO_BITS];
  assign neon_fixup_f1    = mul_ctl_f1_i[`CA5_FP_MUL_NEON_FIXUP_BITS];
  assign neon_sat_dbl_f1  = mul_ctl_f1_i[`CA5_FP_MUL_NEON_SAT_DBL_BITS];
  assign neon_round_f1    = mul_ctl_f1_i[`CA5_FP_MUL_NEON_ROUND_BITS];    // Also indicates VRSQRTE instead of VRECPE
  assign neon_out_fmt_f1  = mul_ctl_f1_i[`CA5_FP_MUL_NEON_OUT_FMT_BITS];
`genelse
  assign neon_int_op_f1 = 1'b0;
`genendif

  assign feedback_sel_f1[0] = ~first_cycle_f1 & ~nxt_dp_fsm[0];
  assign feedback_sel_f1[1] = (nxt_dp_fsm == 2'b01);
  assign feedback_sel_f1[2] = first_cycle_f1 & fused_mac_f1 & double_prec_f1;

  assign nxt_dp_fsm = (first_cycle_f1 &  double_prec_f1) ? 2'b11 :
                      (first_cycle_f1 & ~double_prec_f1) ? 2'b00 :
                                                           dp_fsm - 1'b1;

  always @(posedge clk)
  begin
    if (enable_f1 & ~accum_cycle_f1 & (~stall_wr_i | flush_ret_i))
      dp_fsm <= nxt_dp_fsm;
  end


  assign a_sign_f1 = (double_prec_f1 ? fml_a_data_f1_i[63]
                                     : fml_a_data_f1_i[31]) ^ (negate_f1 & fused_mac_f1);
  assign b_sign_f1 =  double_prec_f1 ? fml_b_data_f1_i[63]
                                     : fml_b_data_f1_i[31];

  // Extract exponents from input operands
  assign a_exp_raw = double_prec_f1 ? fml_a_data_f1_i[62:52]
                                    : {3'b000, fml_a_data_f1_i[30:23]};
  assign b_exp_raw = double_prec_f1 ? fml_b_data_f1_i[62:52]
                                    : {3'b000, fml_b_data_f1_i[30:23]};

  assign a_exp_zero_f1 = a_exp_raw == 0;
  assign b_exp_zero_f1 = b_exp_raw == 0;

  assign a_exp_max_f1 = double_prec_f1 ? &fml_a_data_f1_i[62:52]
                                       : &fml_a_data_f1_i[30:23];
  assign b_exp_max_f1 = double_prec_f1 ? &fml_b_data_f1_i[62:52]
                                       : &fml_b_data_f1_i[30:23];

  assign a_exp_f1 = a_exp_raw | { {10{1'b0}}, a_exp_zero_f1};
  assign b_exp_f1 = b_exp_raw | { {10{1'b0}}, b_exp_zero_f1};

  // Select the appropriate bits of the operands for the multipliers
  assign mul_sel_sp     = ~neon_int_op_f1 & ~accum_cycle_f1 &  first_cycle_f1 & ~double_prec_f1;
  assign mul_sel_lo     = ~neon_int_op_f1 & ~accum_cycle_f1 &  first_cycle_f1 &  double_prec_f1;
  assign mul_sel_a_hi   =                   ~accum_cycle_f1 & ~first_cycle_f1 & ~nxt_dp_fsm[1];
  assign mul_sel_a_prev =                   ~accum_cycle_f1 & ~first_cycle_f1 &  nxt_dp_fsm[1];
  assign mul_sel_b_hi   =                   ~accum_cycle_f1 & ~first_cycle_f1;

`genif (NEON_0)
  wire mul_sel_u8;
  wire mul_sel_s8;
  wire mul_sel_a_16;
  wire mul_sel_b_16;
  wire mul_sel_b_16_lo;
  wire mul_sel_b_16_hi;
  wire mul_sel_i32;

  assign mul_sel_u8       = neon_int_op_f1 & (mul_ctl_f1_i[`CA5_FP_MUL_NEON_TYPE_BITS] == `CA5_NEON_MUL_TYPE_U8);
  assign mul_sel_s8       = neon_int_op_f1 & (mul_ctl_f1_i[`CA5_FP_MUL_NEON_TYPE_BITS] == `CA5_NEON_MUL_TYPE_S8);
  assign mul_sel_a_16     = neon_int_op_f1 & (  mul_ctl_f1_i[`CA5_FP_MUL_NEON_TYPE_BITS] == `CA5_NEON_MUL_TYPE_16
                                              | mul_ctl_f1_i[`CA5_FP_MUL_NEON_TYPE_BITS] == `CA5_NEON_MUL_TYPE_16_LO
                                              | mul_ctl_f1_i[`CA5_FP_MUL_NEON_TYPE_BITS] == `CA5_NEON_MUL_TYPE_16_HI);
  assign mul_sel_b_16     = neon_int_op_f1 & (mul_ctl_f1_i[`CA5_FP_MUL_NEON_TYPE_BITS] == `CA5_NEON_MUL_TYPE_16);
  assign mul_sel_b_16_lo  = neon_int_op_f1 & (mul_ctl_f1_i[`CA5_FP_MUL_NEON_TYPE_BITS] == `CA5_NEON_MUL_TYPE_16_LO);
  assign mul_sel_b_16_hi  = neon_int_op_f1 & (mul_ctl_f1_i[`CA5_FP_MUL_NEON_TYPE_BITS] == `CA5_NEON_MUL_TYPE_16_HI);

  assign mul_sel_i32      = neon_int_op_f1 & (mul_ctl_f1_i[`CA5_FP_MUL_NEON_TYPE_BITS] == `CA5_NEON_MUL_TYPE_I32);

  assign mul_op_a_f1 = ({64{mul_sel_sp}}      & {5'b00000, ~a_exp_zero_f1, fml_a_data_f1_i[22:0],
                                                 8'h00,    ~a_exp_zero_f1, fml_a_data_f1_i[22:0], 3'b000})                  |
                       ({64{mul_sel_lo}}      & {6'b000000, fml_a_data_f1_i[25:0], 6'b000000, fml_a_data_f1_i[25:0]})       |
                       ({64{mul_sel_a_hi}}    & {5'b00000, a_mant_other_f2, 5'b00000, a_mant_other_f2})                     |
                       ({64{mul_sel_a_prev}}  & mul_op_a_f2)                                                                |
                       ({64{mul_sel_u8}}      & {8'h00, fml_a_data_f1_i[31:24], 8'h00, fml_a_data_f1_i[23:16],
                                                 8'h00, fml_a_data_f1_i[15: 8], 8'h00, fml_a_data_f1_i[ 7: 0]})             |
                       ({64{mul_sel_s8}}      & {{8{fml_a_data_f1_i[31]}}, fml_a_data_f1_i[31:24],
                                                 {8{fml_a_data_f1_i[23]}}, fml_a_data_f1_i[23:16],
                                                 {8{fml_a_data_f1_i[15]}}, fml_a_data_f1_i[15: 8],
                                                 {8{fml_a_data_f1_i[ 7]}}, fml_a_data_f1_i[ 7: 0]})                         |
                       ({64{mul_sel_a_16}}    & fml_a_data_f1_i)                                                            |
                       ({64{mul_sel_i32}}     & {fml_a_data_f1_i[31:0], fml_a_data_f1_i[31:0]});

  assign mul_op_b_f1 = ({64{mul_sel_sp}}      & {8'h00, ~b_exp_zero_f1, fml_b_data_f1_i[22:0],
                                                 8'h00, ~b_exp_zero_f1, fml_b_data_f1_i[22:0]})                             |
                       ({64{mul_sel_lo}}      & {6'b000000, fml_b_data_f1_i[25:0], 6'b000000, fml_b_data_f1_i[25:0]})       |
                       ({64{mul_sel_b_hi}}    & {5'b00000, b_mant_other_f2, 5'b00000, b_mant_other_f2})                     |
                       ({64{mul_sel_u8}}      & {8'h00, fml_b_data_f1_i[23:16], 8'h00, fml_b_data_f1_i[31:24],
                                                 8'h00, fml_b_data_f1_i[15: 8], 8'h00, fml_b_data_f1_i[ 7: 0]})             |
                       ({64{mul_sel_s8}}      & {{8{fml_b_data_f1_i[23]}}, fml_b_data_f1_i[23:16],
                                                 {8{fml_b_data_f1_i[31]}}, fml_b_data_f1_i[31:24],
                                                 {8{fml_b_data_f1_i[15]}}, fml_b_data_f1_i[15: 8],
                                                 {8{fml_b_data_f1_i[ 7]}}, fml_b_data_f1_i[ 7: 0]})                         |
                       ({64{mul_sel_b_16}}    & {fml_b_data_f1_i[47:32], fml_b_data_f1_i[63:48], fml_b_data_f1_i[31: 0]})   |
                       ({64{mul_sel_b_16_lo}} & {fml_b_data_f1_i[15: 0], fml_b_data_f1_i[15: 0],
                                                 fml_b_data_f1_i[15: 0], fml_b_data_f1_i[15: 0]})                           |
                       ({64{mul_sel_b_16_hi}} & {fml_b_data_f1_i[31:16], fml_b_data_f1_i[31:16],
                                                fml_b_data_f1_i[31:16], fml_b_data_f1_i[31:16]})                            |
                       ({64{mul_sel_i32}}     & {fml_b_data_f1_i[31:0], fml_b_data_f1_i[31:0]});
`genelse
  assign mul_op_a_f1 = ({27{mul_sel_sp}}      & {~a_exp_zero_f1, fml_a_data_f1_i[22:0], 3'b000})  |
                       ({27{mul_sel_lo}}      & {1'b0, fml_a_data_f1_i[25:0]})                    |
                       ({27{mul_sel_a_hi}}    & a_mant_other_f2)                                  |
                       ({27{mul_sel_a_prev}}  & mul_op_a_f2);

  assign mul_op_b_f1 = ({27{mul_sel_sp}}      & {3'b000, ~b_exp_zero_f1, fml_b_data_f1_i[22:0]})  |
                       ({27{mul_sel_lo}}      & {1'b0, fml_b_data_f1_i[25:0]})                    |
                       ({27{mul_sel_b_hi}}    & b_mant_other_f2);
`genendif

  // Store the parts of the operand that aren't being multiplied
  assign a_mant_other_f1 = {~a_exp_zero_f1, fml_a_data_f1_i[51:26]};
  assign b_mant_other_f1 = first_cycle_f1 ? {~b_exp_zero_f1, fml_b_data_f1_i[51:26]} :
                                            mul_op_b_f2[26:0];

  assign nxt_op_c_f2 = {fml_c_data_f1_i[63] ^ fmac_negacc_f1, fml_c_data_f1_i[62:0]};

  always @(posedge clk)
  begin
    if (~stall_wr_i | flush_ret_i) begin
      first_cycle_f2  <= first_cycle_f1;
      last_cycle_f2   <= last_cycle_f1;
      accum_cycle_f2  <= accum_cycle_f1;
      enable_f2       <= enable_f1;
      start_div_f2    <= start_div_f1;
      collect_div_f2  <= collect_div_f1_i;

      if (first_cycle_f1) begin
        double_prec_f2    <= double_prec_f1;
        negate_f2         <= negate_f1;
        fused_mac_f2      <= fused_mac_f1;
        a_exp_f2          <= a_exp_f1;
        a_exp_max_f2      <= a_exp_max_f1;
        round_mode_f2     <= round_mode_f1_i;
        a_sign_f2         <= a_sign_f1;
        sqrt_f2           <= sqrt_f1;
        op_c_f2           <= nxt_op_c_f2;
      end
      if (first_cycle_f1 & ~hold_b_f1_i) begin
        b_exp_f2          <= b_exp_f1;
        b_exp_max_f2      <= b_exp_max_f1;
        b_sign_f2         <= b_sign_f1;
      end
      if (first_cycle_f1 & double_prec_f1)
        a_mant_other_f2   <= a_mant_other_f1;
      if (enable_f1) begin
        raw_feedback_sel_f2   <= feedback_sel_f1;
        mul_op_a_f2       <= mul_op_a_f1;
      end
      if (enable_f1 & ~hold_b_f1_i)
        mul_op_b_f2       <= mul_op_b_f1;
      if (enable_f1 & (~first_cycle_f1 | double_prec_f1))
        b_mant_other_f2   <= b_mant_other_f1;
    end
  end

`genif (NEON_0)
  always @(posedge clk)
  begin
    if ((~stall_wr_i | flush_ret_i) & (first_cycle_f1 | collect_div_f1_i)) begin
      raw_neon_int_op_f2      <= neon_int_op_f1;
      raw_neon_inv_zero_f2    <= neon_inv_zero_f1;
      neon_fixup_f2           <= neon_fixup_f1;
      neon_sat_dbl_f2         <= neon_sat_dbl_f1;
      neon_round_f2           <= neon_round_f1;
      neon_out_fmt_f2         <= neon_out_fmt_f1;
      raw_neon_force_dn_fz_f2 <= force_dn_fz_f1_i;
    end
  end
`genendif

  // --- F2 stage ---

`genif (NEON_0)
  assign neon_int_op_f2   = raw_neon_int_op_f2;
  assign neon_inv_zero_f2 = raw_neon_inv_zero_f2;
  assign vrec_est_f2      = (neon_out_fmt_f2 == `CA5_NEON_MUL_OUT_FMT_VREC);
  assign vrsqrte_f2       = neon_round_f2;
  assign force_dn_fz_f2   = raw_neon_force_dn_fz_f2;
`genelse
  assign neon_int_op_f2   = 1'b0;
  assign neon_inv_zero_f2 = 1'b0;
  assign vrec_est_f2      = 1'b0;
  assign vrsqrte_f2       = 1'b0;
  assign force_dn_fz_f2   = 1'b0;
`genendif

  assign final_cycle_f2 = (fused_mac_f2 & double_prec_f2) ? accum_cycle_f2
                                                          : last_cycle_f2;

  assign a_frac_zero_f2 = double_prec_f2 ? (a_mant_other_f2[25:0] == 0 && mul_op_a_f2[25:0] == 0)
                                         : (mul_op_a_f2[25:3] == 0);
  assign b_frac_zero_f2 = double_prec_f2 ? (b_mant_other_f2[25:0] == 0 && mul_op_b_f2[25:0] == 0)
                                         : (mul_op_b_f2[22:0] == 0);

  assign a_exp_zero_f2 = ~(double_prec_f2 ? a_mant_other_f2[26]
                                          : mul_op_a_f2[26]);
  assign b_exp_zero_f2 = ~(double_prec_f2 ? b_mant_other_f2[26]
                                          : mul_op_b_f2[23]);

  // Operand C is only used for double-precision Fused MAC
  assign c_sign_f2 = op_c_f2[63];
  assign c_exp_f2 = op_c_f2[62:52] | { {10{1'b0}}, c_exp_zero_f2};
  assign c_mant_f2 = {|op_c_f2[62:52], op_c_f2[51:0]};

  assign c_frac_zero_f2 = ~|op_c_f2[51:0];
  assign c_exp_zero_f2  = ~|op_c_f2[62:52];
  assign c_exp_max_f2   =  &op_c_f2[62:52];

  assign a_zero_f2 = a_frac_zero_f2 & a_exp_zero_f2 | a_flushzero;
  assign b_zero_f2 = b_frac_zero_f2 & b_exp_zero_f2 | b_flushzero;
  assign c_zero_f2 = c_frac_zero_f2 & c_exp_zero_f2 | c_flushzero;

  assign a_infinite_f2 = a_exp_max_f2 & a_frac_zero_f2;
  assign b_infinite_f2 = b_exp_max_f2 & b_frac_zero_f2;
  assign c_infinite_f2 = c_exp_max_f2 & c_frac_zero_f2;

  assign a_nan_f2 = a_exp_max_f2 & ~a_frac_zero_f2 & ~neon_int_op_f2;
  assign b_nan_f2 = b_exp_max_f2 & ~b_frac_zero_f2 & ~neon_int_op_f2;
  assign c_nan_f2 = c_exp_max_f2 & ~c_frac_zero_f2 & ~neon_int_op_f2;

  assign a_snan_f2 = a_nan_f2 & ~(double_prec_f2 ? a_mant_other_f2[25]
                                                 : mul_op_a_f2[25]);
  assign b_snan_f2 = b_nan_f2 & ~(double_prec_f2 ? b_mant_other_f2[25]
                                                 : mul_op_b_f2[22]);
  assign c_snan_f2 = c_nan_f2 & ~op_c_f2[51];

  // Calculate if any of the inputs are denormal and will be flushed to zero
  assign a_flushzero      = ~a_frac_zero_f2 & a_exp_zero_f2 & (force_dn_fz_f2 | fpscr_fz_i);
  assign b_flushzero      = ~b_frac_zero_f2 & b_exp_zero_f2 & (force_dn_fz_f2 | fpscr_fz_i);
  assign c_flushzero      = ~c_frac_zero_f2 & c_exp_zero_f2 & (force_dn_fz_f2 | fpscr_fz_i);
  assign in_flushzero_f2  = a_flushzero | b_flushzero | c_flushzero;

  // Calculate if product will be trivially zero or infinity.
  assign first_mul_zero_f2 = (start_div_f2 & sqrt_f2) ? a_zero_f2                   :
                              start_div_f2            ? (a_zero_f2 | b_infinite_f2) :
                              vrec_est_f2             ? a_infinite_f2               :
                                                        (a_zero_f2 | b_zero_f2);

  assign mul_infinite_f2 = (start_div_f2 & sqrt_f2) ? a_infinite_f2               :
                            start_div_f2            ? (a_infinite_f2 | b_zero_f2) :
                            vrec_est_f2             ? a_zero_f2                   :
                                                      ((a_infinite_f2 | b_infinite_f2)
                                                       & ~(neon_inv_zero_f2 & first_mul_zero_f2));

  assign res_zero_f2     = (fused_mac_f2 & double_prec_f2) ? first_mul_zero_f2 & c_zero_f2
                                                           : first_mul_zero_f2;
  assign res_infinite_f2 = (fused_mac_f2 & double_prec_f2) ? mul_infinite_f2 | c_infinite_f2
                                                           : mul_infinite_f2;

  assign invalid_op = (start_div_f2 & sqrt_f2) |
                       (vrec_est_f2 & vrsqrte_f2)     ? (a_sign_f2 & ~a_zero_f2 & ~a_nan_f2)                                    :
                       start_div_f2                   ? (a_infinite_f2 & b_infinite_f2 | a_zero_f2 & b_zero_f2)                 :
                      (fused_mac_f2 & double_prec_f2) ? (mul_zero_f2 & mul_infinite_f2 & ~c_snan_f2 |
                                                         mul_infinite_f2 & ~a_nan_f2 & ~b_nan_f2 & c_infinite_f2 & acc_sub_f2)  :
                                                        (mul_zero_f2 & mul_infinite_f2);

  assign divbyzero_f2 = start_div_f2 & ~sqrt_f2 & ~res_nan_f2 & ~a_infinite_f2 & b_zero_f2
                          | vrec_est_f2 & a_zero_f2;

  // Output is NaN if either operand is NaN or if zero is multiplied by infinity
  assign res_nan_f2 = ~neon_int_op_f2 & (a_nan_f2 | b_nan_f2 | c_nan_f2 | invalid_op);

  assign invalid_f2 = a_snan_f2 | b_snan_f2 | c_snan_f2 | invalid_op;

  assign nan_sel_c_f2 = (  c_snan_f2                           | ( c_nan_f2 & ~a_snan_f2 & ~b_snan_f2 & ~invalid_op)) & ~(force_dn_fz_f2 | fpscr_dn_i);
  assign nan_sel_a_f2 = ((~c_snan_f2 &  a_snan_f2)             | (~c_nan_f2 &  a_nan_f2  & ~b_snan_f2))               & ~(force_dn_fz_f2 | fpscr_dn_i);
  assign nan_sel_b_f2 = ((~c_snan_f2 & ~a_snan_f2 & b_snan_f2) | (~c_nan_f2 & ~a_nan_f2  &  b_nan_f2))                & ~(force_dn_fz_f2 | fpscr_dn_i);


  assign nan_sign_f2 = nan_sel_a_f2 & a_sign_f2 |
                       nan_sel_b_f2 & b_sign_f2 |
                       nan_sel_c_f2 & c_sign_f2;

  assign res_sign_f2 = res_nan_f2 ? nan_sign_f2 : (a_sign_f2 ^ b_sign_f2);
  assign out_sign_f2 = res_sign_f2 ^ (negate_f2 & ~fused_mac_f2);


  assign a_mant_f2 = double_prec_f2 ? {a_mant_other_f2[26:0], mul_op_a_f2[25:0]}
                                    : {mul_op_a_f2[26:0], {26{1'b0}} };

  assign b_mant_f2 = double_prec_f2 ? {b_mant_other_f2[26:0], mul_op_b_f2[25:0]}
                                    : {mul_op_b_f2[23:0], {29{1'b0}} };

  ca5dpu_fp_clz54 u_a_mant_clz(.opa({a_mant_f2, 1'b0}), .res(a_mant_lz_f2));
  ca5dpu_fp_clz54 u_b_mant_clz(.opa({b_mant_f2, 1'b0}), .res(b_mant_lz_f2));
  ca5dpu_fp_clz54 u_c_mant_clz(.opa({c_mant_f2, 1'b0}), .res(c_mant_lz_f2));

  // If both LZ values are nonzero, then the output result will be so tiny that
  // the actual values don't matter, so or them together instead of adding them.
  assign mant_lz_f2 = a_mant_lz_f2 | ({6{~vrec_est_f2}} & b_mant_lz_f2);

`genif (NEON_0)
  assign vrec_est_op_f2 = mul_op_a_f2[52:0];
`genelse
  assign vrec_est_op_f2 = {53{1'b0}};
`genendif

  assign nan_val_f2 = {53{nan_sel_a_f2 &  double_prec_f2}} & {2'b11, a_mant_f2[50:0]}                                 |
                      {53{nan_sel_b_f2 &  double_prec_f2}} & {2'b11, b_mant_f2[50:0]}                                 |
                      {53{nan_sel_a_f2 & ~double_prec_f2}} & {3'b001, ~fused_mac_f2 | a_mant_f2[51], a_mant_f2[50:2]} |
                      {53{nan_sel_b_f2 & ~double_prec_f2}} & {3'b001, ~fused_mac_f2 | b_mant_f2[51], b_mant_f2[50:2]} |
                      {53{nan_sel_c_f2}}                   & {2'b11, c_mant_f2[50:0]}                                 |
                      {53{vrec_est_f2 & (~a_nan_f2 | neon_int_op_f2)}} & vrec_est_op_f2                               |
                      {53{res_nan_f2 & ~nan_sel_a_f2 &
                           ~nan_sel_b_f2 & ~nan_sel_c_f2}} & { {2{double_prec_f2}}, ~double_prec_f2, ~double_prec_f2 & ~(fused_mac_f2 & invalid_f2),
                                                               {48{1'b0}}, ~double_prec_f2 & fused_mac_f2 & invalid_f2 };
                               // If this operation is a single-precision Fused MAC with input operands of infinity and zero,
                               // pass a signalling NaN to the ALU pipe so that QNaN+0*Inf returns the default NaN

  // Calculate the exponent of the result before normalization
  assign bias = double_prec_f2  ? 11'h3FF :
                                  11'h07F;

  assign prod_exp_f2 = {2'b00, a_exp_f2} + b_exp_f2 - bias;

  // Perform the partial multiplies
  // For the FP multiplies the products a_lo*b_lo, a_lo*b_hi, a_hi*b_lo and a_hi*b_hi are generated
  // For Neon, some instructions require independent data into each multiplier
  // 'c' and 'd' values are created - for the FPU-only configuration they are aliased onto 'a' and 'b'.
  // while for Neon they are sourced from the upper bits of the (extended) a and b registers
`genif (NEON_0)
  assign mul_op_c_f2 = mul_op_a_f2[MUL_OP_W-1:MUL_WIDTH];
  assign mul_op_d_f2 = mul_op_b_f2[MUL_OP_W-1:MUL_WIDTH];
`genelse
  assign mul_op_c_f2 = mul_op_a_f2;
  assign mul_op_d_f2 = mul_op_b_f2;
`genendif

  assign prod_lo_lo_f2_raw = mul_op_a_f2[LOW_MUL_W-1:0]         * mul_op_b_f2[LOW_MUL_W-1:0];
  assign prod_lo_hi_f2_raw = mul_op_c_f2[LOW_MUL_W-1:0]         * mul_op_d_f2[MUL_WIDTH-1:LOW_MUL_W];
  assign prod_hi_lo_f2_raw = mul_op_c_f2[MUL_WIDTH-1:LOW_MUL_W] * mul_op_d_f2[LOW_MUL_W-1:0];
  assign prod_hi_hi_f2_raw = mul_op_a_f2[MUL_WIDTH-1:LOW_MUL_W] * mul_op_b_f2[MUL_WIDTH-1:LOW_MUL_W];

  // Mux in fraction bits from a NaN operand
`genif (NEON_0)
  assign prod_lo_lo_f2 = neon_mul_sat_f2[0] ? { {2{neon_fixup_32bit_f2}}, 30'h3FFFFFFF}
                                            : prod_lo_lo_f2_raw;
  assign prod_hi_hi_f2 = neon_mul_sat_f2[1] ? {32'h3FFFFFFF}
                                            : prod_hi_hi_f2_raw;

  assign prod_lo_hi_f2 = (res_nan_f2 | vrec_est_f2) ? nan_val_f2[31:0]
                                                    : prod_lo_hi_f2_raw;

  assign prod_hi_lo_f2 = (res_nan_f2 | vrec_est_f2) ? {11'h000, nan_val_f2[52:32]}
                                                    : prod_hi_lo_f2_raw;
`genelse

  assign prod_lo_lo_f2 = prod_lo_lo_f2_raw;
  assign prod_hi_hi_f2 = prod_hi_hi_f2_raw;

  assign prod_lo_hi_f2 = res_nan_f2 ? nan_val_f2[26:0]
                                    : prod_lo_hi_f2_raw;

  assign prod_hi_lo_f2 = res_nan_f2 ? {1'b0, nan_val_f2[52:27]}
                                    : prod_hi_lo_f2_raw;
`genendif

  assign mul_zero_f2 = first_cycle_f2 ? first_mul_zero_f2
                                      : mul_zero_f3;

  assign c_shift_f2 = {2'b00, a_exp_f2} + b_exp_f2 - c_exp_f2
                        - (accum_cycle_f2         ? (11'h3FF - 7'd108) :
                           last_cycle_f2          ? (11'h3FF - 7'd54)  :
                           raw_feedback_sel_f2[0] ? (11'h3FF - 7'd28)  :
                                                    (11'h3FF - 7'd2));

  ca5dpu_fp_shift7 #(.in_width(109), .out_width(56)) u_fmac_shift
  (
    .data_i     ({c_mant_f2, {56{1'b0}} }),
    .andbit_i   (1'b0),
    .fillbit_i  (1'b0),
    .shift_i    (c_shift_f2[6:0]),
    .result_o   (shifted_c_f2),
    .andbit_o   ()
  );

  assign c_shift_normal = fused_mac_f2 & ~c_zero_f2 & ~mul_zero_f2 & ~c_shift_f2[12] & ~|c_shift_f2[11:7] & ~c_shift_tiny;
  assign c_shift_huge   = fused_mac_f2 & ~c_zero_f2 & ~mul_zero_f2 & ~c_shift_f2[12] &  |c_shift_f2[11:7];
  assign c_shift_tiny   = accum_cycle_f2 & ~c_zero_f2 & (mul_zero_f2 | c_shift_f2[12] | c_shift_f2[11:0] < 6'd54);

  assign acc_sub_f2 = fused_mac_f2 & double_prec_f2 & ~a_nan_f2 & ~b_nan_f2 & ~c_nan_f2 & (a_sign_f2 ^ b_sign_f2 ^ c_sign_f2);

  assign fmac_acc_val_f2[55:0] = ({56{c_shift_normal}}  & (shifted_c_f2)            |
                                  {56{c_shift_huge}}    & { {55{1'b0}}, ~c_zero_f2} |
                                  {56{c_shift_tiny}}    & {1'b0, c_mant_f2, 2'b00})
                                  ^ {56{acc_sub_f2}};

  assign acc_val_larger_f2 = fused_mac_f2 & double_prec_f2 & ~c_zero_f2
                              & (mul_zero_f2 | c_infinite_f2 | prod_exp_f2[12] | (c_exp_f2 > prod_exp_f2[11:0] + 1'b1))
                              & (~c_exp_zero_f2 | mul_zero_f2 | prod_exp_f2[12] & c_mant_lz_f2 <= ~prod_exp_f2[11:0]);

  // Only valid when last_cycle is also valid, so use the registered f3 version in accum_cycle
  assign acc_val_huge_f2 = fused_mac_f2 & double_prec_f2 & ~c_zero_f2 & (c_shift_f2[12] | mul_zero_f2);

  assign accum_high_f2 = accum_cycle_f2 & acc_val_larger_f2 & (acc_val_huge_f3 | prod_exp_f2[12] | prod_exp_f2[11:0] == 12'd0 | ~(acc_sub_f2 & ((c_shift_f2[6:0] + c_mant_lz_f2 + mul_sum_carry_f3) > 7'd106) & ~res_infinite_f2 & ~prod_exp_f2[12]));

  assign acc_exp_f2 = vrec_est_f2                      ? {2'b00, a_exp_f2}   :
                      accum_cycle_f2 & acc_val_huge_f3 ? {2'b00, c_exp_f2}   :
                      accum_high_f2                    ? prod_exp_f2 + 6'd54 :
                                                         prod_exp_f2;

  assign neg_result_f2 = accum_cycle_f2 & ~res_nan_f2 & acc_sub_f2 & ~mul_infinite_f2 & (acc_val_larger_f2 | ~mul_sum_f3[54]);

`genif (NEON_0)
  // Generate fixup values and add them into the accumulator register
  // See ca5dpu_mac.v for a description of the fixup values
  wire [63:0] neg_acc_val;
  wire [63:0] neon_acc_val_f2;
  wire [31:0] dbl_opa;
  wire [31:0] dbl_opb;
  wire [15:0] fixup_val_low;
  wire [15:0] fixup_val_high;
  wire [1:0]  fixup_low_carry_out;
  wire        fixup_sign_a_low;
  wire        fixup_sign_b_low;
  wire        fixup_sign_a_high;
  wire        fixup_sign_b_high;
  wire        low_zeroes;
  wire        high_zeroes;

  // Invert the accumulate operand unless this is a VMLS
  // It's not immediately obvious why this is done, explanation follows:
  // In F3 the partial products are added together, and then the multiplication result
  // is either added to or subtracted from the accumulator. To simplify the adder
  // in F3, the accumulator is always added to the products, and the formula
  // -a = ~a + 1 is utilized - we want to calculate either a + (p - f1 - f2) or
  // a - (p - f1 -f2), where a is the accumulator input, p is the sum of the partial
  // products, and f1 and f2 are the components of the fixup values
  // For VMUL and VMLA, we produce p + ~(~a + f1 + f2), while for VMLS we produce
  // ~(p + ~(a + f1 + f2)). The main advantage is that the optional negations can
  // be performed in F2 and F4, removing a critical path in F3, and there's no need
  // to fiddle about with carry-ins for subtraction

  assign neg_acc_val = ((neon_out_fmt_f2 == `CA5_NEON_MUL_OUT_FMT_4_8)
                              ? {8'h00, op_c_f2[31:24], 8'h00, op_c_f2[23:16],
                                 8'h00, op_c_f2[15: 8], 8'h00, op_c_f2[ 7: 0]}
                              : op_c_f2) ^ {64{~negate_f2}};

  assign neon_fixup_32bit_f2 = (neon_out_fmt_f2 == `CA5_NEON_MUL_OUT_FMT_64 |
                                neon_out_fmt_f2 == `CA5_NEON_MUL_OUT_FMT_32_H);

  assign fixup_sign_a_high = neon_fixup_f2 & mul_op_a_f2[31];
  assign fixup_sign_b_high = neon_fixup_f2 & mul_op_b_f2[31];

  assign fixup_sign_a_low  = neon_fixup_f2 & (neon_fixup_32bit_f2 ? mul_op_a_f2[31]
                                                                  : mul_op_a_f2[15]);
  assign fixup_sign_b_low  = neon_fixup_f2 & (neon_fixup_32bit_f2 ? mul_op_b_f2[31]
                                                                  : mul_op_b_f2[15]);

  assign dbl_opa = neon_sat_dbl_f2 ? {mul_op_a_f2[30:16], mul_op_a_f2[15] & neon_fixup_32bit_f2, mul_op_a_f2[14:0], 1'b0}
                                   : mul_op_a_f2[31:0];
  assign dbl_opb = neon_sat_dbl_f2 ? {mul_op_b_f2[30:16], mul_op_b_f2[15] & neon_fixup_32bit_f2, mul_op_b_f2[14:0], 1'b0}
                                   : mul_op_b_f2[31:0];

  assign {fixup_low_carry_out,
          fixup_val_low}        = {2'b00, neon_fixup_32bit_f2 ? neg_acc_val[47:32] : neg_acc_val[31:16]}
                                      + ({16{fixup_sign_a_low}} & dbl_opb[15:0])
                                      + ({16{fixup_sign_b_low}} & dbl_opa[15:0]);
  assign fixup_val_high         = neg_acc_val[63:48]
                                      + ({16{fixup_sign_a_high}} & dbl_opb[31:16])
                                      + ({16{fixup_sign_b_high}} & dbl_opa[31:16])
                                      + ({2{neon_fixup_32bit_f2}} & fixup_low_carry_out);

  // The rounding value for the VQRDMULH instruction is introduced here
  // Since this isn't an accumulating instruction, op_c_f2 will always be zero,
  // thus neg_acc_val (inverted) will alway be ones. Masking off the appropriate
  // bits from acc_val_f2 effectively adds the rounding value into the accumulator
  assign neon_acc_val_f2 = neon_fixup_32bit_f2 ? {fixup_val_high, fixup_val_low, neg_acc_val[31] & ~neon_round_f2, neg_acc_val[30:0]}
                                               : {fixup_val_high, neg_acc_val[47] & ~neon_round_f2, neg_acc_val[46:32],
                                                  fixup_val_low,  neg_acc_val[15] & ~neon_round_f2, neg_acc_val[14: 0]};


  // Detect saturation on the doubling multiply - only occurs if both
  // multiplication operands are max negative (ie. 0x80...0)

  assign low_zeroes  = mul_op_a_f2[14: 0] == 0 && mul_op_b_f2[14: 0] == 0;
  assign high_zeroes = mul_op_a_f2[30:16] == 0 && mul_op_b_f2[30:16] == 0;

  assign neon_mul_sat_f2[1] = neon_sat_dbl_f2 & mul_op_a_f2[31] & mul_op_b_f2[31] & high_zeroes
                              & (neon_fixup_32bit_f2 ? (~mul_op_a_f2[15] & ~mul_op_b_f2[15] & low_zeroes)
                                                     : 1'b1);
  assign neon_mul_sat_f2[0] = neon_fixup_32bit_f2 ? neon_mul_sat_f2[1]
                                                  : neon_sat_dbl_f2 & mul_op_a_f2[15] & mul_op_b_f2[15] & low_zeroes;

  assign neon_mul_qc_f2 = |neon_mul_sat_f2;

  // Detect whether saturation on accumulate is possible, and which direction it will go in
  // The stored sign value is inverted for a subtract, since the F3 result will also be inverted
  assign neon_acc_sign_f2[0] = op_c_f2[31] ^ negate_f2;
  assign neon_acc_sign_f2[1] = op_c_f2[63] ^ negate_f2;

  assign neon_can_sat_f2[0]  = neon_sat_dbl_f2 & ((mul_op_a_f2[15] ^ mul_op_b_f2[15]) == neon_acc_sign_f2[0]);
  assign neon_can_sat_f2[1]  = neon_sat_dbl_f2 & ((mul_op_a_f2[31] ^ mul_op_b_f2[31]) == neon_acc_sign_f2[1]);

  assign acc_val_f2 = { {8{1'b0}}, fmac_acc_val_f2} | {64{neon_int_op_f2}} & neon_acc_val_f2;

`genelse
  assign acc_val_f2 = fmac_acc_val_f2;
`genendif

  // Generate select signals for the adder input muxes
  assign feedback_sel_f2 = (accum_cycle_f2 ? accum_high_f2 ? 3'b100
                                                           : 3'b010
                                           : raw_feedback_sel_f2)
                               & {3{~res_nan_f2 & ~neon_int_op_f2}};

`genif (NEON_0)
  always @*
    case (neon_out_fmt_f2)
      `CA5_NEON_MUL_OUT_FMT_32_L,
      `CA5_NEON_MUL_OUT_FMT_32_H,
      `CA5_NEON_MUL_OUT_FMT_64: begin
        neon_part_sel_f2 = 3'b001 & {3{neon_int_op_f2 | ~res_nan_f2 & ~mul_zero_f2}};
        if (neon_sat_dbl_f2)
          neon_acc_sel_f2  = 4'b0100;
        else
          neon_acc_sel_f2  = {3'b000, neon_int_op_f2};
      end
      `CA5_NEON_MUL_OUT_FMT_2_16_H,
      `CA5_NEON_MUL_OUT_FMT_2_32: begin
        neon_part_sel_f2 = 3'b010;
        if (neon_sat_dbl_f2)
          neon_acc_sel_f2  = 4'b1000;
        else
          neon_acc_sel_f2  = 4'b0010;
      end
      `CA5_NEON_MUL_OUT_FMT_4_8,
      `CA5_NEON_MUL_OUT_FMT_4_16: begin
        neon_part_sel_f2 = 3'b100;
        neon_acc_sel_f2  = 4'b0000;
      end
      `CA5_NEON_MUL_OUT_FMT_VREC: begin
        neon_part_sel_f2 = 3'b000;
        neon_acc_sel_f2  = 4'b0000;
      end
      default: begin
        neon_part_sel_f2 = 3'bxxx;
        neon_acc_sel_f2  = 4'bxxxx;
      end
    endcase
`genendif

  always @(posedge clk)
    if (~stall_wr_i | flush_ret_i) begin
      first_cycle_f3  <= first_cycle_f2;
      last_cycle_f3   <= last_cycle_f2;
      accum_cycle_f3  <= accum_cycle_f2;
      enable_f3       <= enable_f2;
      collect_div_f3  <= collect_div_f2;

      if (first_cycle_f2) begin
        double_prec_f3      <= double_prec_f2;
        fused_mac_f3        <= fused_mac_f2;
        round_mode_f3       <= round_mode_f2;
        mul_zero_f3         <= first_mul_zero_f2;
        res_infinite_f3     <= res_infinite_f2;
        res_zero_f3         <= res_zero_f2;
        res_nan_f3          <= res_nan_f2;
        invalid_f3          <= invalid_f2;
        out_sign_f3         <= out_sign_f2;
        res_sign_f3         <= res_sign_f2;
        acc_sub_f3          <= acc_sub_f2;
        in_flushzero_f3     <= in_flushzero_f2;
        mant_lz_f3          <= mant_lz_f2;
      end
      if (enable_f2 & (first_cycle_f2 | ~res_nan_f2)) begin
        feedback_sel_f3     <= feedback_sel_f2;
        prod_lo_lo_f3       <= prod_lo_lo_f2;
        prod_lo_hi_f3       <= prod_lo_hi_f2;
        prod_hi_lo_f3       <= prod_hi_lo_f2;
        prod_hi_hi_f3       <= prod_hi_hi_f2;
        acc_val_f3          <= acc_val_f2;
        acc_val_huge_f3     <= acc_val_huge_f2;
        neg_result_f3       <= neg_result_f2;
      end
      if (final_cycle_f2 | first_cycle_f2 & res_nan_f2) begin
        acc_exp_f3          <= acc_exp_f2;
        accum_high_f3       <= accum_high_f2;
      end
    end

`genif (NEON_0)
  always @(posedge clk)
    begin
      if ((~stall_wr_i | flush_ret_i) & (first_cycle_f2  | collect_div_f2)) begin
        raw_neon_int_op_f3      <= neon_int_op_f2;
        neon_out_fmt_f3         <= neon_out_fmt_f2;
        neon_part_sel_f3        <= neon_part_sel_f2;
        neon_acc_sel_f3         <= neon_acc_sel_f2;
        neon_mul_qc_f3          <= neon_mul_qc_f2;
        neon_acc_sign_f3        <= neon_acc_sign_f2;
        neon_can_sat_f3         <= neon_can_sat_f2;
        neon_vrsqrte_f3         <= vrsqrte_f2;
        raw_neon_divbyzero_f3   <= divbyzero_f2;
        raw_neon_force_dn_fz_f3 <= force_dn_fz_f2;
        neon_mul_sat_f3         <= neon_mul_sat_f2;
      end
    end
`genendif

  // --- F3 stage ---

`genif (NEON_0)
  assign neon_int_op_f3     = raw_neon_int_op_f3;
  assign neon_divbyzero_f3  = raw_neon_divbyzero_f3;
`genelse
  assign neon_int_op_f3     = 1'b0;
  assign neon_divbyzero_f3  = 1'b0;
`genendif

  assign final_cycle_f3 = (fused_mac_f3 & double_prec_f3) ? accum_cycle_f3
                                                          : last_cycle_f3;

  assign feedback_val = {55{feedback_sel_f3[0]}} & { 1'b0, acc_val_f3[55:30], mul_sum_f4[53:26]} |
                        {55{feedback_sel_f3[1]}} & mul_sum_f4[54:0]                              |
                        {55{feedback_sel_f3[2]}} & {1'b0, acc_val_f3[55:2]};

  assign feedback_carry_high = feedback_sel_f3[0] & mul_sum_f4[54];
  assign feedback_carry_low  = feedback_sel_f3[2] & accum_cycle_f3 & mul_sum_f4[54];

`genif (NEON_0)
  wire        sat_dbl_f3;

  wire [66:0] partial_1;
  wire [48:0] partial_2;
  wire [48:0] partial_3;
  wire [66:0] partial_4;

  wire [66:0] mul_sum_f3_dbl;
  reg  [63:0] neon_mul_sum_f3;

  // Generate the inputs to the adder

  assign partial_1 = {67{neon_part_sel_f3[0]}} & {2'b00, prod_hi_hi_f3, prod_lo_lo_f3, neon_mul_sat_f3[0]}                  |
                     {67{neon_part_sel_f3[1]}} & {prod_hi_hi_f3, neon_mul_sat_f3[1], 1'b0, prod_lo_lo_f3, neon_mul_sat_f3[0]} |
                     {67{neon_part_sel_f3[2]}} & {prod_hi_lo_f3[15:0], 1'b0, prod_lo_hi_f3[15:0], 1'b0,
                                                  prod_hi_hi_f3[15:0], 1'b0, prod_lo_lo_f3[15:0]};

  assign partial_2 = {49{neon_part_sel_f3[0]}} & {prod_lo_hi_f3, 17'h00000};

  assign partial_3 = {49{neon_part_sel_f3[0]}} & {prod_hi_lo_f3, 17'h00000};

  assign partial_4 = {67{res_nan_f3}}          & {2'b00, prod_hi_lo_f3,prod_lo_hi_f3, 1'b0}           |
                     {67{neon_acc_sel_f3[0]}}  & {2'b00, ~acc_val_f3, 1'b0}                           |
                     {67{neon_acc_sel_f3[1]}}  & {~acc_val_f3[63:32], 2'b00, ~acc_val_f3[31:0], 1'b0} |
                     {67{neon_acc_sel_f3[2]}}  & {3'b000, ~acc_val_f3}                                |
                     {67{neon_acc_sel_f3[3]}}  & {1'b0, ~acc_val_f3[63:32], 2'b00, ~acc_val_f3[31:0]} |
                     {67{neon_part_sel_f3[2]}} & {~acc_val_f3[63:48], 1'b0, ~acc_val_f3[47:32], 1'b0,
                                                  ~acc_val_f3[31:16], 1'b0, ~acc_val_f3[15: 0]}       |
                                                 {11'h000, feedback_val, 1'b0};

  assign mul_sum_raw_f3 = partial_1 + partial_2 + partial_3 + partial_4
                          + {feedback_carry_high, {27{1'b0}}, feedback_carry_low, 1'b0};

  assign sat_dbl_f3 = neon_acc_sel_f3[2] | neon_acc_sel_f3[3];

  assign mul_sum_f3_dbl = sat_dbl_f3 ? {mul_sum_raw_f3[65:0], 1'b0}
                                     : mul_sum_raw_f3;


  ca5dpu_neon_vrec_est u_vrec_est (
    .int_op_f3_i        (neon_int_op_f3),
    .neon_rsqrte_f3_i   (neon_vrsqrte_f3),
    .a_exp_f3_i         (acc_exp_f3[7:0]),
    .a_frac_f3_i        (prod_lo_hi_f3[31:0]),

    .vrec_est_res_f3_o  (neon_vrec_est_res_f3),
    .vrec_est_exp_f3_o  (neon_vrec_est_exp_f3),
    .vrec_udf_f3_o      (neon_vrec_udf_f3)
  );

  assign neon_underflow_f3 = (neon_out_fmt_f3 == `CA5_NEON_MUL_OUT_FMT_VREC) & neon_vrec_udf_f3;

  // Extract the appropriate bits from the adder output to generate the result

  always @*
    case (neon_out_fmt_f3)
      `CA5_NEON_MUL_OUT_FMT_4_8:
          neon_mul_sum_f3 = {mul_sum_f3_dbl[58:51], mul_sum_f3_dbl[41:34], mul_sum_f3_dbl[24:17], mul_sum_f3_dbl[ 7: 0],
                             mul_sum_f3_dbl[58:51], mul_sum_f3_dbl[41:34], mul_sum_f3_dbl[24:17], mul_sum_f3_dbl[ 7: 0]};
      `CA5_NEON_MUL_OUT_FMT_4_16:
          neon_mul_sum_f3 = {mul_sum_f3_dbl[66:51], mul_sum_f3_dbl[49:34], mul_sum_f3_dbl[32:17], mul_sum_f3_dbl[15: 0]};
      `CA5_NEON_MUL_OUT_FMT_2_32:
          neon_mul_sum_f3 = {mul_sum_f3_dbl[66:35], mul_sum_f3_dbl[32: 1]};
      `CA5_NEON_MUL_OUT_FMT_2_16_H:
          neon_mul_sum_f3 = {mul_sum_f3_dbl[66:51], mul_sum_f3_dbl[32:17], mul_sum_f3_dbl[66:51], mul_sum_f3_dbl[32:17]};
      `CA5_NEON_MUL_OUT_FMT_32_L:
          neon_mul_sum_f3 = {mul_sum_f3_dbl[32: 1], mul_sum_f3_dbl[32: 1]};
      `CA5_NEON_MUL_OUT_FMT_32_H:
          neon_mul_sum_f3 = {mul_sum_f3_dbl[64:33], mul_sum_f3_dbl[64:33]};
      `CA5_NEON_MUL_OUT_FMT_64:
          neon_mul_sum_f3 = {mul_sum_f3_dbl[64: 1]};
      `CA5_NEON_MUL_OUT_FMT_VREC:
          neon_mul_sum_f3 = (~res_nan_f3 | neon_int_op_f3) ? neon_vrec_est_res_f3
                                                           : 64'h00030000_00000000;
      default:
          neon_mul_sum_f3 = {64{1'bx}};
    endcase

  assign mul_sum_f3 = neon_mul_sum_f3;
  assign mul_sum_carry_f3 = mul_sum_raw_f3[55];

  // Detect whether the accumulate overflowed and must be saturated
  // Only signed multiplies can saturate, so signed overflow only is detected

  assign neon_acc_sat_f3[0] = (neon_out_fmt_f3 == `CA5_NEON_MUL_OUT_FMT_32_L || neon_out_fmt_f3 == `CA5_NEON_MUL_OUT_FMT_32_H)
                                ? neon_acc_sat_f3[1]
                                : neon_can_sat_f3[0] & (neon_acc_sign_f3[0] != mul_sum_raw_f3[31]);
  assign neon_acc_sat_f3[1] = (neon_can_sat_f3[1] & (neon_acc_sign_f3[1] != (neon_acc_sel_f3[2] ? mul_sum_raw_f3[63]
                                                                                                : mul_sum_raw_f3[65])));

  assign neon_sat_width_f3[1] = neon_out_fmt_f3 == `CA5_NEON_MUL_OUT_FMT_2_32 ||
                                neon_out_fmt_f3 == `CA5_NEON_MUL_OUT_FMT_32_L ||
                                neon_out_fmt_f3 == `CA5_NEON_MUL_OUT_FMT_32_H ||
                                neon_out_fmt_f3 == `CA5_NEON_MUL_OUT_FMT_64;

  assign neon_sat_width_f3[0] = neon_out_fmt_f3 == `CA5_NEON_MUL_OUT_FMT_2_16_H ||
                                neon_out_fmt_f3 == `CA5_NEON_MUL_OUT_FMT_64;

  assign neon_qc_bit_f3 = neon_int_op_f3 & (neon_mul_qc_f3 | neon_acc_sat_f3[1] | (neon_sat_width_f3 != 2'b11 & neon_acc_sat_f3[0]));
`genelse
  assign mul_sum_raw_f3 =   ({54{~mul_zero_f3}} & {prod_hi_hi_f3, prod_lo_lo_f3})
                          + ({43{~mul_zero_f3}} & {prod_lo_hi_f3, 16'h0000})
                          + ({43{~mul_zero_f3}} & {prod_hi_lo_f3, 16'h0000})
                          + feedback_val
                          + {feedback_carry_high, {27{1'b0}}, feedback_carry_low };

  assign mul_sum_f3 = res_nan_f3 ? {prod_hi_lo_f3[26:0], prod_lo_hi_f3[26:0]}
                                 : mul_sum_raw_f3;
  assign mul_sum_carry_f3 = mul_sum_raw_f3[54];
`genendif

  assign mul_sum_was_zero = (mul_sum_f4[54:0] == {acc_sub_f4 ^ neg_result_f3, {54{neg_result_f3}} }) & ~accum_high_f3;

  // Three CLZ blocks are required, as this path is somewhat critical and
  // there's not enough time to mux on the inputs
  assign fmac_clz_operand_high = {neg_result_f3, acc_val_f3[55:3]}
                                    ^ {54{neg_result_f3}};

  assign fmac_clz_operand_mid  = {acc_val_f3[2] ^ mul_sum_f4[54], mul_sum_f4[53:1]}
                                    ^ {54{neg_result_f3}};

  assign fmac_clz_operand_low  = {neg_result_f3, norm_frac_f5[51:0], guardbit_f5}
                                    ^ {54{neg_result_f3}};

  ca5dpu_fp_clz54 u_fmac_clz_high(.opa(fmac_clz_operand_high), .res(fmac_clz_res_high));
  ca5dpu_fp_clz54 u_fmac_clz_mid (.opa(fmac_clz_operand_mid),  .res(fmac_clz_res_mid));
  ca5dpu_fp_clz54 u_fmac_clz_low (.opa(fmac_clz_operand_low),  .res(fmac_clz_res_low));

  assign shift_low_f3 = accum_cycle_f3 & mul_sum_was_zero & ~res_infinite_f3 & (~acc_exp_f3[12] & acc_exp_f3[11:0] >= 6'd54);

  assign fmac_clz_res = shift_low_f3  ? fmac_clz_res_low  :
                        accum_high_f3 ? fmac_clz_res_high :
                                        fmac_clz_res_mid;

  // Number of left shift bits needed to get product in range [1,4) if
  // there was a denormalised input
  // The values are ORed together since if both values are denormal,
  // the final result will be so tiny that this factor is insignificant
  assign mul_renorm_shift = {6{~res_nan_f3}}  & (mant_lz_f3);

  // Shift needed to align a normalized value correctly
  assign align_shift = double_prec_f3 ? 7'd53 :
                       fused_mac_f3   ? 7'd50 :
                                        7'd79;

  assign mul_shift =  // If biased exponent of product (before normalization)
                      // is very negative (< -64 for dp, < -32 for sp), saturate ultimate shift value
                      (acc_exp_f3[12] & (~&acc_exp_f3[11:6] | (~double_prec_f3 & ~acc_exp_f3[5]))) ? 7'h7f :

                      (align_shift -
                        // Otherwise if the normalized exponent is negative or zero
                        // shift right by the alignment shift, minus the prenormalized
                        // exponent (which can be negative), plus one
                        ((acc_exp_f3[12] |
                          mul_renorm_shift >= acc_exp_f3[11:0]) ? (acc_exp_f3[6:0] - 1'b1)

                        // Else shift right by the alignment shift minus the normalization shift
                                                                : {1'b0, mul_renorm_shift}));

  assign mod_acc_exp_f3 = shift_low_f3 ? acc_exp_f3 - 6'd54 : acc_exp_f3;

  assign acc_shift = (mod_acc_exp_f3 == 13'd0)              ? ((fmac_clz_res == 6'd0) ? 7'd55 : 7'd54)  :
                     (acc_exp_f3[12] & ~&acc_exp_f3[11:6])  ? 7'd127                                    :
                     (mod_acc_exp_f3[12] |
                      mod_acc_exp_f3[11:0] < fmac_clz_res)  ? 6'd54 - mod_acc_exp_f3[6:0]               :
                                                              6'd55 - fmac_clz_res - acc_sub_f3;

  assign penultimate_cycle_f3 = double_prec_f3 & last_cycle_f2 & ~last_cycle_f3;

  // Need to use accum_high_f2 here, as it is valid in the accumulate cycle, but it factors into
  // the shift for last_cycle
  assign shift_f3 =  accum_cycle_f3                                   ? acc_shift               :
                     res_nan_f3                                       ? align_shift             :
                     final_cycle_f3                                   ? mul_shift               :
                    (last_cycle_f3 & acc_val_huge_f3 & ~mul_zero_f3)  ? 7'd127                  :
                    (last_cycle_f3 & accum_high_f2)                   ? 7'd55                   :
                    (first_cycle_f3 | penultimate_cycle_f3)           ? 7'd27                   :
                                                                        7'd1;

  // If this is a special to collect the result of a divide, mux in the output of the divider
  always @*
  begin
    case ({neon_int_op_f3,collect_div_f3})
      2'b10: begin
        nxt_mul_sum_f4[54:50] = 5'b00000;
        nxt_div_roundbit_f4   = 1'b0;
        nxt_div_stickybit_f4  = 1'b0;
        nxt_shift_f4          = 7'd26;
        nxt_double_prec_f4    = 1'b1;
        nxt_round_mode_f4     = 2'b00;
        nxt_res_infinite_f4   = 1'b0;
        nxt_res_zero_f4       = 1'b0;
        nxt_res_nan_f4        = 1'b0;
        nxt_invalid_f4        = 1'b0;
        nxt_divbyzero_f4      = 1'b0;
        nxt_in_flushzero_f4   = 1'b0;
        {nxt_out_sign_f4, nxt_acc_exp_f4, nxt_mul_sum_f4[49:0]}
                              = mul_sum_f3;

        // Store the value of the negate control signal in res_sign_f4
        nxt_res_sign_f4       = (out_sign_f3 ^ res_sign_f3);
        nxt_fused_mac_f4      = 1'b0;
        nxt_acc_sub_f4        = 1'b0;
        nxt_neg_result_f4     = 1'b0;
      end

      2'b00: begin
        nxt_mul_sum_f4        = mul_sum_f3[54:0];
        nxt_div_roundbit_f4   = acc_val_f3[1];
        nxt_div_stickybit_f4  = acc_val_f3[0];
        nxt_shift_f4          = shift_f3;
        nxt_acc_exp_f4        = (NEON_0 && neon_out_fmt_f3 == `CA5_NEON_MUL_OUT_FMT_VREC) ? { {5{1'b0}}, neon_vrec_est_exp_f3} : acc_exp_f3;
        nxt_double_prec_f4    = double_prec_f3;
        nxt_out_sign_f4       = out_sign_f3 ^ neg_result_f3;
        nxt_res_sign_f4       = res_sign_f3 ^ neg_result_f3;
        nxt_round_mode_f4     = round_mode_f3;
        nxt_res_infinite_f4   = res_infinite_f3;
        nxt_res_zero_f4       = res_zero_f3;
        nxt_res_nan_f4        = res_nan_f3;
        nxt_invalid_f4        = invalid_f3;
        nxt_divbyzero_f4      = neon_divbyzero_f3;
        nxt_in_flushzero_f4   = in_flushzero_f3;
        nxt_fused_mac_f4      = fused_mac_f3;
        nxt_acc_sub_f4        = acc_sub_f3;
        nxt_neg_result_f4     = neg_result_f3;
      end

      2'b01, 2'b11: begin
        nxt_mul_sum_f4        = {1'b0, div_out_frac_f3};
        nxt_div_roundbit_f4   = div_roundbit_f3;
        nxt_div_stickybit_f4  = div_stickybit_f3;
        nxt_shift_f4          = div_shift_f3;
        nxt_acc_exp_f4        = div_out_exp_f3;
        nxt_out_sign_f4       = div_out_sign_f3;
        nxt_res_sign_f4       = div_out_sign_f3; // div/sqrt can't be inverted, so same as out_sign
        nxt_double_prec_f4    = div_double_prec_f3;
        nxt_round_mode_f4     = div_round_mode_f3;
        nxt_res_infinite_f4   = div_res_infinite_f3;
        nxt_res_zero_f4       = div_res_zero_f3;
        nxt_res_nan_f4        = div_res_nan_f3;
        nxt_invalid_f4        = div_invalid_f3;
        nxt_divbyzero_f4      = div_divbyzero_f3;
        nxt_in_flushzero_f4   = div_in_flushzero_f3;
        nxt_fused_mac_f4      = 1'b0;
        nxt_acc_sub_f4        = 1'b0;
        nxt_neg_result_f4     = 1'b0;
      end

      default:
      begin
        nxt_mul_sum_f4        = {55{1'bx}};
        nxt_div_roundbit_f4   = 1'bx;
        nxt_div_stickybit_f4  = 1'bx;
        nxt_shift_f4          = {7{1'bx}};
        nxt_acc_exp_f4        = {13{1'bx}};
        nxt_double_prec_f4    = 1'bx;
        nxt_out_sign_f4       = 1'bx;
        nxt_res_sign_f4       = 1'bx;
        nxt_round_mode_f4     = {2{1'bx}};
        nxt_res_infinite_f4   = 1'bx;
        nxt_res_zero_f4       = 1'bx;
        nxt_res_nan_f4        = 1'bx;
        nxt_invalid_f4        = 1'bx;
        nxt_divbyzero_f4      = 1'bx;
        nxt_in_flushzero_f4   = 1'bx;
        nxt_fused_mac_f4      = 1'bx;
        nxt_acc_sub_f4        = 1'bx;
        nxt_neg_result_f4     = 1'bx;
      end
    endcase
  end

  always @(posedge clk)
    if (~stall_wr_i | flush_ret_i) begin
      first_cycle_f4  <= first_cycle_f3;
      last_cycle_f4   <= last_cycle_f3;
      accum_cycle_f4  <= accum_cycle_f3;
      enable_f4       <= enable_f3;
      collect_div_f4  <= collect_div_f3;

      if (first_cycle_f3 | collect_div_f3) begin
        div_roundbit_f4       <= nxt_div_roundbit_f4;
        div_stickybit_f4      <= nxt_div_stickybit_f4;
        double_prec_f4        <= nxt_double_prec_f4;
        fused_mac_f4          <= nxt_fused_mac_f4;
        acc_sub_f4            <= nxt_acc_sub_f4;
        round_mode_f4         <= nxt_round_mode_f4;
        res_infinite_f4       <= nxt_res_infinite_f4;
        res_nan_f4            <= nxt_res_nan_f4;
        invalid_f4            <= nxt_invalid_f4;
        divbyzero_f4          <= nxt_divbyzero_f4;
        in_flushzero_f4       <= nxt_in_flushzero_f4;
      end

      if (enable_f3 | collect_div_f3) begin
        shift_low_f4          <= shift_low_f3;
        shift_f4              <= nxt_shift_f4;
        mul_sum_f4            <= nxt_mul_sum_f4;
        neg_result_f4         <= nxt_neg_result_f4;
      end

      if (final_cycle_f3 | collect_div_f3) begin
        acc_exp_f4            <= nxt_acc_exp_f4;
        out_sign_f4           <= nxt_out_sign_f4;
        res_sign_f4           <= nxt_res_sign_f4;
        raw_res_zero_f4       <= nxt_res_zero_f4;
      end
    end

`genif (NEON_0)
  always @(posedge clk)
    if ((~stall_wr_i | flush_ret_i) & (first_cycle_f3 | collect_div_f3)) begin
      raw_neon_int_op_f4      <= neon_int_op_f3;
      neon_acc_sign_f4        <= neon_acc_sign_f3;
      neon_acc_sat_f4         <= neon_acc_sat_f3;
      neon_sat_width_f4       <= neon_sat_width_f3;
      neon_qc_bit_f4          <= neon_qc_bit_f3;
      neon_underflow_f4       <= neon_underflow_f3;
      raw_neon_force_dn_fz_f4 <= raw_neon_force_dn_fz_f3;
    end
`genendif

  // --- F4 stage ---

`genif (NEON_0)
  assign neon_int_op_f4 = raw_neon_int_op_f4 & ~collect_div_f4;
  assign force_dn_fz_f4 = raw_neon_force_dn_fz_f4;
`genelse
  assign neon_int_op_f4 = 1'b0;
  assign force_dn_fz_f4 = 1'b0;
`genendif

  assign final_cycle_f4 = (fused_mac_f4 & double_prec_f4) ? accum_cycle_f4 : last_cycle_f4;

  assign shift_operand = shift_low_f4                      ? {mul_sum_f4[0], norm_frac_f5[51:0], guardbit_f5, roundbit_f5, stickybit_f5, {55{acc_sub_f4}} }                     :
                         (first_cycle_f4 | collect_div_f4) ? {mul_sum_f4[54] ^ acc_sub_f4, mul_sum_f4[53:0], div_roundbit_f4, div_stickybit_f4 | acc_sub_f4, {54{acc_sub_f4}} } :
                                                             {mul_sum_f4[54] ^ acc_sub_f4, mul_sum_f4[53:0], norm_frac_f5[51:0], guardbit_f5, roundbit_f5, {2{stickybit_f5}} };

  assign andbit_in_f4 = first_cycle_f4 ? div_stickybit_f4 : stickyandbit_f5;

  // Do a sticky shift to get the appropriate bits
  // This gives a value in the range [1,4)
  ca5dpu_fp_shift7 #(.in_width(111), .out_width(57)) u_mul_shift1 (
    .data_i     (shift_operand),
    .andbit_i   (andbit_in_f4),
    .fillbit_i  (neg_result_f4),
    .shift_i    (shift_f4),
    .result_o   (shifted_frac_raw),
    .andbit_o   (shifted_andbit)
  );

  assign shifted_frac[56:1] = shifted_frac_raw[56:1] ^ {56{neg_result_f4}};
  assign shifted_frac[0]    = neg_result_f4 ? ~shifted_andbit
                                            : shifted_frac_raw[0];

  // If the multiply result was >= 2, shift to get it in the range [1,2)
  assign shifted_msb = (double_prec_f4 | fused_mac_f4) ? shifted_frac[56] : shifted_frac[27];

  assign extra_shift = (final_cycle_f4 | collect_div_f4) & shifted_msb;

  ca5dpu_fp_shift1 #(.in_width(57), .out_width(56)) u_mul_shift2 (
    .data_i   (shifted_frac),
    .shift_i  (extra_shift),
    .result_o ({norm_frac_f4, guardbit_f4, roundbit_f4, stickybit_f4})
  );

  assign stickyandbit_f4 = shifted_andbit & (~extra_shift | shifted_frac[1]);


  // Offset to subtract from exponent when adding in shift amount
  assign exp_offset_f4 = collect_div_f4 ? shift_f4  :
                         shift_low_f4   ? 7'd107    :
                         double_prec_f4 ? 7'd53     :
                         fused_mac_f4   ? 7'd50     :
                                          7'd79;

  assign acc_renorm_exp_f4 = acc_exp_f4 + shift_f4 - exp_offset_f4;

  assign res_exp_f4 = (acc_renorm_exp_f4[12] | (acc_renorm_exp_f4 == 0)) ? 11'h001 :
                       acc_renorm_exp_f4[11]                             ? 11'h7FF :
                                                                           acc_renorm_exp_f4[10:0];

  assign res_exp_p1 = &res_exp_f4 ? 11'h7FF : res_exp_f4 + 1'b1;

  assign norm_exp_f4 = shifted_msb ? res_exp_p1 : res_exp_f4; // (res_exp_f4[7:0] + shifted_msb);

  // Calculate from shifted_frac instead of norm_frac_f4 to save time
  assign norm_frac_max_f4[0] = &shifted_frac[25: 4] & (extra_shift ? shifted_frac[26] : shifted_frac[ 3]);
  assign norm_frac_max_f4[1] = &shifted_frac[54:27] & (extra_shift ? shifted_frac[55] : shifted_frac[26]);

  assign norm_frac_zero_f4 =                      (shifted_frac[25: 4] == 0 & (extra_shift ? ~shifted_frac[26] : ~shifted_frac[ 3]))
                             & (~double_prec_f4 | (shifted_frac[54:27] == 0 & (extra_shift ? ~shifted_frac[55] : ~shifted_frac[26])));


  assign res_zero_f4 = raw_res_zero_f4 | (accum_cycle_f4 & acc_sub_f4 & ~res_infinite_f4 & neg_result_f4 &
                                          ~norm_frac_f4[52] & norm_frac_zero_f4 & ~guardbit_f4 & ~roundbit_f4 & ~stickybit_f4);

  assign round_updown_f4  = (~double_prec_f4 & fused_mac_f4) ? ~norm_frac_f4[0]
                                                             : ~res_nan_f4 & (res_sign_f4 ? round_mode_f4 == 2 : round_mode_f4 == 1);
  assign round_nearest_f4 = ~res_nan_f4 & ~(~double_prec_f4 & fused_mac_f4) & (round_mode_f4 == 0);

  // If this is a subtraction where the multiply operand was greater,
  // then one needs to be added to shift_operand - there isn't time for
  // that, so fudge the rounding control signals instead
  assign acc_sub_inc_f4 = acc_sub_f4 & ~neg_result_f4 & stickyandbit_f4;

  assign round_val_f4[0] = round_nearest_f4 & (guardbit_f4 & (roundbit_f4 | stickybit_f4 | norm_frac_f4[0])
                                               | acc_sub_inc_f4 & (guardbit_f4 | roundbit_f4 & stickybit_f4 & norm_frac_f4[0])) |
                           round_updown_f4  & (guardbit_f4 | roundbit_f4 | stickybit_f4) |
                           acc_sub_inc_f4   & (guardbit_f4 & roundbit_f4 & stickybit_f4);

  assign round_val_f4[1] = round_val_f4[0] & norm_frac_max_f4[0];

  // Does rounding cause the fraction to overflow into the hidden bit?
  assign frac_round_over_f4 = norm_frac_max_f4[0] & round_val_f4[0] & (~double_prec_f4 | norm_frac_max_f4[1]);

  assign norm_frac_top = (double_prec_f4 | fused_mac_f4) ? norm_frac_f4[52] : norm_frac_f4[23];

  // Increment exponent if so
  assign inc_exp_f4 = ~flush_res_zero_f4 & norm_frac_top & frac_round_over_f4;

  assign out_overflow_f4 = (double_prec_f4 ? (&norm_exp_f4[10:1] & (norm_exp_f4[0] | inc_exp_f4))
                                           : (&norm_exp_f4[ 7:1] & (norm_exp_f4[0] | inc_exp_f4) | (|norm_exp_f4[10:8])))
                              & ~neon_int_op_f4 & ~(~double_prec_f4 & fused_mac_f4);

  assign norm_exp_zero_f4  = ~neon_int_op_f4 & ~norm_frac_top & ~res_zero_f4 & (norm_exp_f4 == 11'h001 || shift_f4 == 7'h7f);

  assign flush_res_zero_f4 = norm_exp_zero_f4 & (force_dn_fz_f4 | fpscr_fz_i) & ~(fused_mac_f4 & ~double_prec_f4);

`genif (NEON_0)
  wire [63:0] neon_sum_f4;
  reg  [63:0] sat_neon_sum_f4;
  wire [63:0] neg_neon_sum_f4;
  wire        negate_f4;

  assign negate_f4 = res_sign_f4;

  assign neon_sum_f4 = {out_sign_f4, acc_exp_f4, mul_sum_f4[49:0]};

  // Saturate the Neon integer result if necessary
  // Saturation is peformed before the negation for a VMLS

  always @*
    case (neon_sat_width_f4)
      2'b00:        // No saturation
        sat_neon_sum_f4 = neon_sum_f4;

      2'b01: begin  // 16-bit saturation
        sat_neon_sum_f4[15: 0] = neon_acc_sat_f4[0] ? {neon_acc_sign_f4[0], {15{~neon_acc_sign_f4[0]}} }
                                                    : neon_sum_f4[15: 0];
        sat_neon_sum_f4[31:16] = neon_acc_sat_f4[1] ? {neon_acc_sign_f4[1], {15{~neon_acc_sign_f4[1]}} }
                                                    : neon_sum_f4[31:16];
        sat_neon_sum_f4[63:32] = sat_neon_sum_f4[31: 0];
      end

      2'b10: begin  // 32-bit saturation
        sat_neon_sum_f4[31: 0] = neon_acc_sat_f4[0] ? {neon_acc_sign_f4[0], {31{~neon_acc_sign_f4[0]}} }
                                                    : neon_sum_f4[31: 0];
        sat_neon_sum_f4[63:32] = neon_acc_sat_f4[1] ? {neon_acc_sign_f4[1], {31{~neon_acc_sign_f4[1]}} }
                                                    : neon_sum_f4[63:32];
      end

      2'b11: begin  // 64-bit saturation
        sat_neon_sum_f4[63: 0] = neon_acc_sat_f4[1] ? {neon_acc_sign_f4[1], {63{~neon_acc_sign_f4[1]}} }
                                                    : neon_sum_f4[63: 0];
      end
    endcase


  assign neg_neon_sum_f4 = sat_neon_sum_f4 ^ {64{negate_f4}};

  assign nxt_norm_frac_f5 = neon_int_op_f4 ? neg_neon_sum_f4[51:0]
                                           : norm_frac_f4[51:0];
  assign nxt_norm_exp_f5  = neon_int_op_f4 ? neg_neon_sum_f4[62:52]
                                           : norm_exp_f4;
  assign nxt_out_sign_f5  = neon_int_op_f4 ? neg_neon_sum_f4[63]
                                           : (accum_cycle_f4 & acc_sub_f4 & res_zero_f4 & ~res_nan_f4) ? round_mode_f4 == 2'b10 : out_sign_f4;
`genelse
  assign nxt_norm_frac_f5 = norm_frac_f4[51:0];
  assign nxt_norm_exp_f5  = norm_exp_f4;
  assign nxt_out_sign_f5  = (accum_cycle_f4 & acc_sub_f4 & res_zero_f4 & ~res_nan_f4) ? round_mode_f4 == 2'b10 : out_sign_f4;
`genendif

  always @(posedge clk)
    if (~stall_wr_i | flush_ret_i) begin
      if (final_cycle_f4 | collect_div_f4) begin
        double_prec_f5    <= double_prec_f4;
        norm_exp_f5       <= nxt_norm_exp_f5;
        out_sign_f5       <= nxt_out_sign_f5;
        round_mode_f5     <= round_mode_f4;
        round_updown_f5   <= round_updown_f4;
        res_infinite_f5   <= res_infinite_f4;
        res_zero_f5       <= res_zero_f4;
        res_nan_f5        <= res_nan_f4;
        invalid_f5        <= invalid_f4;
        divbyzero_f5      <= divbyzero_f4;
        in_flushzero_f5   <= in_flushzero_f4;
        norm_exp_zero_f5  <= norm_exp_zero_f4;
        norm_frac_zero_f5 <= norm_frac_zero_f4;
        frac_round_over_f5<= frac_round_over_f4;
        inc_exp_f5        <= inc_exp_f4;
        out_overflow_f5   <= out_overflow_f4;
        round_val_f5      <= round_val_f4;
        fused_mac_f5      <= fused_mac_f4;
        acc_sub_inc_f5    <= acc_sub_inc_f4;
      end
      if (enable_f4 & (first_cycle_f4 | ~res_nan_f4) | collect_div_f4) begin
        norm_frac_f5      <= nxt_norm_frac_f5;
        guardbit_f5       <= guardbit_f4;
        roundbit_f5       <= roundbit_f4;
        stickybit_f5      <= stickybit_f4;
        stickyandbit_f5   <= stickyandbit_f4;
      end
    end

`genif (NEON_0)
  always @(posedge clk)
    if ((~stall_wr_i | flush_ret_i) & (last_cycle_f4 | collect_div_f4)) begin
      neon_qc_bit_f5          <= neon_qc_bit_f4;
      raw_neon_force_dn_fz_f5 <= force_dn_fz_f4;
      raw_neon_int_op_f5      <= neon_int_op_f4;
      raw_neon_underflow_f5   <= neon_underflow_f4;
    end
`genendif


  // --- F5 stage ---
`genif (NEON_0)
  assign neon_int_op_f5 = raw_neon_int_op_f5;
  assign neon_udf_f5    = raw_neon_underflow_f5;
  assign force_dn_fz_f5 = raw_neon_force_dn_fz_f5;
`genelse
  assign neon_int_op_f5 = 1'b0;
  assign neon_udf_f5    = 1'b0;
  assign force_dn_fz_f5 = 1'b0;
`genendif

  assign inexact_f5 = (guardbit_f5 | roundbit_f5 | stickybit_f5)
                        & ~(guardbit_f5 & roundbit_f5 & stickybit_f5 & acc_sub_inc_f5)
                        & ~neon_int_op_f5 & ~(~double_prec_f5 & fused_mac_f5);

  // Perform rounding on the result

  assign rounded_frac[51:23] = norm_frac_f5[51:23] + round_val_f5[1];
  assign rounded_frac[22: 0] = norm_frac_f5[22: 0] + round_val_f5[0];

  assign round_exp = norm_exp_f5 + inc_exp_f5;

  assign res_denormal = norm_exp_zero_f5 & ~frac_round_over_f5;

  assign flush_res_zero_f5 = norm_exp_zero_f5 & (force_dn_fz_f5 | fpscr_fz_i) & ~(fused_mac_f5 & ~double_prec_f5) & ~(frac_round_over_f5 & acc_sub_inc_f5);

  assign out_flushzero_f5 = (~res_zero_f5 & ~res_nan_f5 & ~out_overflow_f5 & flush_res_zero_f5
                              & (~norm_frac_zero_f5 | guardbit_f5 | roundbit_f5 | stickybit_f5)) | neon_udf_f5;

  assign overflow_to_inf = (round_mode_f5 == 0) | round_updown_f5;

  assign out_exp = (res_nan_f5 | res_infinite_f5
                    | (out_overflow_f5 & ~res_zero_f5 & overflow_to_inf)) ? 11'h7FF :     // Infinite or NaN
                   (out_overflow_f5 & ~res_zero_f5 & ~overflow_to_inf)    ? 11'h7FE :     // Largest non-infinite
                   (res_zero_f5 | res_denormal | out_flushzero_f5)        ? 11'h000 :     // Denormal or zero
                                                                            round_exp;

  assign out_frac_zero = (res_zero_f5 | res_infinite_f5 | (out_overflow_f5 & overflow_to_inf) |
                           ~out_overflow_f5 & frac_round_over_f5 | out_flushzero_f5) & ~res_nan_f5;
  assign out_frac_max = out_overflow_f5 & ~res_zero_f5 & ~overflow_to_inf & ~res_nan_f5;

  assign out_frac = {52{~out_frac_zero}} & ({52{out_frac_max}} | rounded_frac);

  assign mul_inx = (out_overflow_f5 | inexact_f5) & ~res_nan_f5 & ~res_infinite_f5 & ~res_zero_f5 & ~out_flushzero_f5;
  assign mul_udf = ~out_overflow_f5 & ~res_zero_f5 & ~res_nan_f5 & norm_exp_zero_f5 & inexact_f5 & ~(~double_prec_f5 & fused_mac_f5);
  assign mul_ovf =  out_overflow_f5 & ~res_zero_f5 & ~res_nan_f5 & ~res_infinite_f5;
  assign mul_inv = invalid_f5;

  assign fml_data_f5_o = (double_prec_f5 | fused_mac_f5) ? {out_sign_f5, out_exp[10:0], out_frac[51:0]}
                                                         : {out_sign_f5, out_exp[ 7:0], out_frac[22:0],
                                                            out_sign_f5, out_exp[ 7:0], out_frac[22:0]};

  assign mac_round_mode_f5_o  = round_mode_f5;
  assign mac_force_dn_fz_f5_o = force_dn_fz_f5;

  assign fused_mac_f5_o       = fused_mac_f5;

  assign mul_xflags_o[`CA5_XFLAGS_IDC_BITS] = in_flushzero_f5;
  assign mul_xflags_o[`CA5_XFLAGS_IXC_BITS] = mul_inx;
  assign mul_xflags_o[`CA5_XFLAGS_UFC_BITS] = out_flushzero_f5 | (~(force_dn_fz_f5 | fpscr_fz_i) & mul_udf);
  assign mul_xflags_o[`CA5_XFLAGS_OFC_BITS] = mul_ovf;
  assign mul_xflags_o[`CA5_XFLAGS_DZC_BITS] = divbyzero_f5;
  assign mul_xflags_o[`CA5_XFLAGS_IOC_BITS] = mul_inv;

`genif (NEON_0)
  assign mul_xflags_o[`CA5_XFLAGS_QC_BITS]  = neon_qc_bit_f5;
`genendif

endmodule // ca5dpu_fp_mul
