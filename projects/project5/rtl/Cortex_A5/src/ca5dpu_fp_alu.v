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
// Abstract : Floating point single/double precision add datapath
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs SP and DP addition
//

`include "ca5dpu_params.v"

module ca5dpu_fp_alu `DPU_PARAM_DECL (
  // Inputs
  input  wire                             clk,
  input  wire                             stall_wr_i,       // Stall pipeline
  input  wire                             flush_ret_i,
  input  wire [1:0]                       rm_f1_i,          // Round mode {round to nearest,+infinity,-infinity,zero}
  input  wire                             force_dn_fz_f1_i, // Force DN and FZ modes
  input  wire                             fpscr_fz_i,       // Flush-to-zero mode
  input  wire                             fpscr_dn_i,       // Default NaN mode
  input  wire                             ahp_f1_i,         // Alternative half-precision mode
  input  wire                             enable_f1_i,      // Enable signal
  input  wire [(`CA5_FP_ADD_CTL_W-1):0]   add_ctl_f1_i,
  input  wire                             dec_exp_f1_i,     // Decrement the result exponent (for VRSQRTS)
  input  wire                             fused_mac_f1_i,   // The addition is part of a Fused MAC
  input  wire [5:0]                       imm_data_f1_i,
  input  wire [7:0]                       imm_data_f2_i,
  input  wire [63:0]                      fad_a_data_f1_i,  // First operand
  input  wire [63:0]                      fad_b_data_f1_i,  // Second operand
  input  wire [63:0]                      fad_c_data_f1_i,  // Third operand
  // Outputs
  output wire [63:0]                      fad_data_f5_o,    // Addition result
  output wire [(`CA5_XFLAGS_W-1):0]       add_xflags_f5_o,  // Exception flags
  output wire [3:0]                       fp_cmpflags_f3_o  // Comparison NZCV flags
);

  // -------------------------------
  // Local parameters  declarations
  // -------------------------------

  localparam WIDTHN11 = NEON_0 ? 16 : 11;
  localparam WIDTHN52 = NEON_0 ? 64 : 52;
  localparam WIDTHN53 = NEON_0 ? 64 : 53;
  localparam WIDTHN54 = NEON_0 ? 64 : 54;
  localparam WIDTHN57 = NEON_0 ? 64 : 57;

  // -------------------------------
  // Reg declarations
  // -------------------------------
  reg                     abs_neg_f2;
  reg                     abs_neg_f3;
  reg                     abs_neg_f4;
  reg                     can_flush_opb_f2;
  reg  [WIDTHN57-1:0]     clz_input_f4;
  reg  [ 5:0]             clz_res_f4;
  reg                     cmp_aeqb_f2;
  reg                     cmp_agtb_f2;
  reg  [ 1:0]             cmp_cmd_f2;
  reg  [ 3:0]             cmpflags_f3;
  reg                     d2fix_f2;
  reg                     d2fix_f3;
  reg                     d2fix_f4;
  reg                     d2fix_f5;
  reg                     enable_f2;
  reg                     enable_f3;
  reg                     enable_f4;
  reg  [ 3:0]             eqfrc_f2;
  reg  [ 2:0]             eqfrc_fmac_f2;
  reg  [10:0]             exp_a_f2;
  reg  [10:0]             exp_b_f2;
  reg  [10:0]             exp_nres_f5;
  reg  [10:0]             exp_opd_f3;
  reg  [WIDTHN11-1:0]     exp_opd_f4;
  reg                     f2i_b32_f5;
  reg                     f2i_neg_sat_f5;
  reg                     f2i_overflow_f3;
  reg                     f2i_overflow_f4;
  reg                     f2i_pos_sat_f5;
  reg  [WIDTHN53-1:0]     frc_opa_f2;
  reg  [WIDTHN53-1:0]     frc_opa_f3;
  reg  [WIDTHN54-1:0]     frc_opb_f2;
  reg  [WIDTHN57-1:0]     frc_opb_f3;
  reg  [WIDTHN52-1:0]     frc_sres_f5;
  reg                     fused_mac_f2;
  reg  [ 3:0]             gtfrc_f2;
  reg  [ 1:0]             gtfrc_fmac_f2;
  reg                     ifz_f3;
  reg                     ifz_f4;
  reg                     ifz_f5;
  reg  [ 2:0]             in_format_f2;
  reg                     inc_exp_res_f5;
  reg                     inc_frc_f5;
  reg                     infinity_op_f3;
  reg                     infinity_op_f4;
  reg                     infinity_op_f5;
  reg                     invalid_op_f3;
  reg                     invalid_op_f4;
  reg                     max_expa_f2;
  reg                     max_expb_f2;
  reg                     msb_opa_f2;
  reg                     msb_opb_f2;
  reg                     nan_inv_op_f3;
  reg                     nan_inv_op_f4;
  reg                     nan_inv_op_f5;
  reg  [ 1:0]             negate_f2;
  reg  [ 7:0]             neon_carry_f3;
  reg  [63:0]             neon_cls_res_f2;
  reg  [63:0]             neon_clz_result_f4;
  reg                     neon_dec_exp_f2;
  reg                     neon_dec_exp_f3;
  reg                     neon_dec_exp_f4;
  reg                     neon_dec_exp_f5;
  reg  [ 3:0]             neon_fctn_sel_f2;
  reg                     neon_force_dn_fz_f2;
  reg                     neon_force_dn_fz_f3;
  reg                     neon_force_dn_fz_f4;
  reg                     neon_fp_cmp_sel_f3;
  reg                     neon_fp_cmp_sel_f4;
  reg                     neon_fp_cmp_sel_f5;
  reg  [63:0]             neon_frc_opc_f2;
  reg  [63:0]             neon_frc_opc_f3;
  reg  [63:0]             neon_halved_res_f3;
  reg                     neon_int_sel_f2;
  reg                     neon_int_sel_f3;
  reg                     neon_int_sel_f4;
  reg                     neon_int_sel_f5;
  reg  [ 3:0]             neon_lu_ctl_f2;
  reg  [ 3:0]             neon_lu_ctl_f3;
  reg                     neon_mask_sel_f2;
  reg  [ 1:0]             neon_mux_sel_f2;
  reg  [ 1:0]             neon_mux_sel_f3;
  reg  [ 1:0]             neon_mux_sel_f4;
  reg  [31:0]             neon_narrow_res_f4;
  reg  [63:0]             neon_opa_f2;
  reg  [63:0]             neon_opb_f2;
  reg  [63:0]             neon_rnd_opb_f2;
  reg  [15:0]             neon_sat_detect_f3;
  reg  [15:0]             neon_sat_dtect_ctl_f3;
  reg                     neon_sat_flag_f4;
  reg                     neon_sat_flag_f5;
  reg  [ 1:0]             neon_sat_op_sel_f2;
  reg  [ 1:0]             neon_sat_op_sel_f3;
  reg  [ 1:0]             neon_sat_op_sel_f4;
  reg  [63:0]             neon_sat_res_f4;
  reg                     neon_shift_reg_f2;
  reg  [ 1:0]             neon_size_sel_f2;
  reg  [ 1:0]             neon_size_sel_f3;
  reg  [ 1:0]             neon_size_sel_f4;
  reg                     neon_unsigned_op_f2;
  reg                     neon_unsigned_op_f3;
  reg                     neon_unsigned_op_f4;
  reg                     neon_vtb_cycle_f2;
  reg                     neon_vtst_op_sel_f2;
  reg                     neon_vtst_op_sel_f3;
  reg                     neon_vtst_op_sel_f4;
  reg  [15:0]             neon_vtst_res_f4;
  reg  [ 2:0]             neon_width_op_sel_f2;
  reg  [ 2:0]             neon_width_op_sel_f3;
  reg  [ 2:0]             neon_width_op_sel_f4;
  reg                     nzero_grt_bits_f5;
  reg  [ 2:0]             out_format_f2;
  reg  [ 2:0]             out_format_f3;
  reg  [ 2:0]             out_format_f4;
  reg  [ 2:0]             out_format_f5;
  reg                     ovf_tmp_f5;
  reg                     ovf_to_inf_f5;
  reg                     raw_invalid_op_f5;
  reg                     raw_zero_expb_f2;
  reg                     realign_f32_f3;
  reg  [63:0]             res_f5;
  reg  [ 1:0]             rnd_mode_f2;
  reg  [ 1:0]             rnd_mode_f3;
  reg  [ 1:0]             rnd_mode_f4;
  reg                     sign_a_f2;
  reg                     sign_f3;
  reg                     sign_f4;
  reg                     sign_nnanb_f2;
  reg                     sign_res_f5;
  reg                     sub_f2;
  reg                     sub_f3;
  reg                     undf_res_f5;
  reg                     zero_expa_f2;
  reg                     zero_op_f3;
  reg                     zero_op_f4;
  reg                     zero_out_f5;
  reg                     zres_f3;
  reg                     zres_f4;

  // -----------------------------
  // Wire declarations
  // -----------------------------
  wire                    abs_neg_f1;
  wire                    abs_sign_a_f2;
  wire                    abs_sign_b_f2;
  wire                    can_flush_opb_f1;
  wire [WIDTHN57-1:0]     clz_input_f3;
  wire                    clz_less_f4;
  wire [ 1:0]             cmp_cmd_f1;
  wire                    cmp_op_sel_f2 = cmp_cmd_f2[1];
  wire [ 3:0]             cmpflags_f2;
  wire                    d2fix_f1;
  wire                    d2s_cmd_f1;
  wire                    d2s_f2;
  wire [52:0]             d2s_nan_opa_f2;
  wire                    dec_exp_res_f5;
  wire                    denorm_fz_f4;
  wire                    dp_op_sel_f1;
  wire                    dp_op_sel_f2;
  wire                    dp_op_sel_f4;
  wire [63:0]             dp_res;
  wire                    eqexp_f2;
  wire [ 3:0]             eqfrc_f1;
  wire [ 2:0]             eqfrc_fmac_f1;
  wire                    equal_opnd_f2;
  wire                    exc_res;
  wire [10:0]             exp_a_f1;
  wire [10:0]             exp_add_f2;
  wire [10:0]             exp_b_f1;
  wire [10:0]             exp_inc_res;
  wire [10:0]             exp_narrow_f2;
  wire [10:0]             exp_nres_f4;
  wire [10:0]             exp_opd_f2;
  wire [10:0]             exp_res;
  wire [10:0]             exp_s2d_f2;
  wire [WIDTHN11-1:0]     exp_sat_opd_f3;
  wire                    f2i_b32_f4;
  wire                    f2i_cmd_f1;
  wire                    f2i_f2;
  wire                    f2i_f3;
  wire                    f2i_f4;
  wire                    f2i_f5;
  wire                    f2i_inc_frc_f4;
  wire                    f2i_max_14_0_f4;
  wire                    f2i_max_30_15_f4;
  wire                    f2i_msb_f4;
  wire                    f2i_neg_sat_f4;
  wire                    f2i_overflow_f2;
  wire                    f2i_pos_sat_f4;
  wire                    f2i_sign;
  wire                    f2i_signed_f4;
  wire                    fixed_point_f1;
  wire                    force_dn_fz_f2;
  wire                    force_dn_fz_f4;
  wire [ 5:0]             fp_clz_res_f3;
  wire [51:0]             frc_inc_res;
  wire [WIDTHN53-1:0]     frc_opa_f1;
  wire [WIDTHN54-1:0]     frc_opb_f1;
  wire [51:0]             frc_res;
  wire [WIDTHN57-1:0]     frc_res_f3;
  wire                    frc_res_msb_f4;
  wire [52:0]             frc_sres_f4;
  wire                    gtexp_f2;
  wire [ 3:0]             gtfrc_f1;
  wire [ 1:0]             gtfrc_fmac_f1;
  wire                    gtopnd_f2;
  wire                    h2s_f1;
  wire                    i2f_cmd_f1;
  wire                    i2f_f2;
  wire                    ifz_f2;
  wire                    ifz_opa_f2;
  wire                    ifz_opb_f2;
  wire [ 2:0]             in_format_f1;
  wire                    inc_exp_res_f4;
  wire                    inc_frc_f4;
  wire                    inexact_excpt;
  wire                    infinite_opa_f2;
  wire                    infinite_opb_f2;
  wire                    infinity_op_f2;
  wire                    invalid_excpt;
  wire                    invalid_op_f2;
  wire                    invalid_op_f5;
  wire                    max_expa_f1;
  wire                    max_expb_f1;
  wire                    msb_opa_f1;
  wire                    msb_opb_f1;
  wire [WIDTHN57-1:0]     mux_res_f3;
  wire [52:0]             muxfrc_opa_f2;
  wire [56:0]             muxfrc_opb_f2;
  wire                    nan_inv_inf_op;
  wire                    nan_inv_op_f2;
  wire                    nan_op_f2;
  wire                    nan_opa_f2;
  wire                    nan_opb_f2;
  wire [11:0]             narrow_exp_sub_f2;
  wire [ 5:0]             narrow_sh_amount_f2;
  wire                    narrow_sh_max_f2;
  wire                    narrow_sh_min_f2;
  wire [ 1:0]             negate_f1;
  wire [63:0]             neon_clz_res_f3;
  wire [63:0]             neon_cmp_eq_f2;
  wire [63:0]             neon_cmp_gt_f2;
  wire [63:0]             neon_cnt_res_f2;
  wire [ 1:0]             neon_dcr_size_sel_f4;
  wire [63:0]             neon_ext_opa_f1;
  wire [63:0]             neon_ext_opb_f1;
  wire [ 3:0]             neon_fctn_sel_f1;
  wire [63:0]             neon_fp_max_opnd_f2;
  wire                    neon_fp_max_sign_f2;
  wire [63:0]             neon_fp_min_opnd_f2;
  wire                    neon_fp_min_sign_f2;
  wire [ 1:0]             neon_inc_size_sel_f1;
  wire                    neon_int_op_f2;
  wire                    neon_int_sel_f1;
  wire [ 3:0]             neon_lu_ctl_f1;
  wire [63:0]             neon_lu_res_f3;
  wire                    neon_mask_sel_f1;
  wire [ 1:0]             neon_mux_sel_f1;
  wire [63:0]             neon_nxt_frc_opc_f2;
  wire [63:0]             neon_nxt_frc_opc_f3;
  wire [70:0]             neon_opa_f3;
  wire [70:0]             neon_opb_f3;
  wire [63:0]             neon_perm_ctl_f1;
  wire [63:0]             neon_perm_opa_f2;
  wire [63:0]             neon_perm_opb_f2;
  wire [ 3:0]             neon_perm_sel_f1;
  wire [63:0]             neon_polymul_res_f3;
  wire [71:0]             neon_res_f3;
  wire [63:0]             neon_sat_dtect_f2;
  wire [15:0]             neon_sat_dtect_f3;
  wire [15:0]             neon_sat_dtect_res_f4;
  wire [63:0]             neon_sat_in_res_f4;
  wire [ 1:0]             neon_sat_op_sel_f1;
  wire                    neon_sat_unsigned_f4;
  wire [63:0]             neon_shift_mask_f2;
  wire                    neon_shift_reg_f1;
  wire [63:0]             neon_shift_res_f2;
  wire [63:0]             neon_shift_round_f2;
  wire [15:0]             neon_shift_sat_f3;
  wire [ 1:0]             neon_size_sel_f1;
  wire [63:0]             neon_swap_max_f2;
  wire [63:0]             neon_swap_min_f2;
  wire                    neon_unsigned_op_f1;
  wire [63:0]             neon_valid_bytes_vector_f2;
  wire                    neon_vrhadd_f3;
  wire                    neon_vtb_cycle_f1;
  wire                    neon_vtst_byte0_f4;
  wire                    neon_vtst_byte1_f4;
  wire                    neon_vtst_byte2_f4;
  wire                    neon_vtst_byte3_f4;
  wire                    neon_vtst_byte4_f4;
  wire                    neon_vtst_byte5_f4;
  wire                    neon_vtst_byte6_f4;
  wire                    neon_vtst_byte7_f4;
  wire                    neon_vtst_op_sel_f1;
  wire [ 2:0]             neon_width_op_sel_f1;
  wire [WIDTHN52-1:0]     nfrc_sres_f4;
  wire                    nsnan_opb_f2;
  wire                    nswap_opnd_f2;
  wire [WIDTHN53-1:0]     nxt_frc_opa_f3;
  wire [WIDTHN57-1:0]     nxt_frc_opb_f3;
  wire                    nxt_sign_a_f1;
  wire                    nxt_sign_b_f1;
  wire                    nzero_grt_bits_f4;
  wire [ 2:0]             out_format_f1;
  wire                    ovf_res;
  wire                    ovf_tmp_f4;
  wire                    ovf_to_inf_f4;
  wire                    quiet_f2 = ~(cmp_cmd_f2[0] | out_format_f2[2]);
  wire [10:0]             raw_exp_a_f1;
  wire                    realign_f32_f2;
  wire                    rnd_ninfi_f4;
  wire                    rnd_nrst_f4;
  wire                    rnd_pinfi_f4;
  wire                    rnd_zero_f4;
  wire                    round_bit_f4;
  wire                    round_infinity_f4;
  wire                    s2d_cmd_f1;
  wire                    s2d_f2;
  wire                    s2h_f1;
  wire                    s2h_f2;
  wire                    s2h_f3;
  wire                    s2h_f4;
  wire                    s2h_f5;
  wire [56:0]             s2h_nan_opb_f2;
  wire                    s2i_f2;
  wire [ 5:0]             sh_amount_f2;
  wire [60:0]             sh_op_f4;
  wire [56:0]             shfrc_opb_f2;
  wire                    shift_deca_f2;
  wire                    shift_decb_f2;
  wire [ 5:0]             shift_mode_f4;
  wire [60:0]             shifted_frc_f4;
  wire                    sign_a;
  wire                    sign_a_f1;
  wire                    sign_b;
  wire                    sign_b_f1;
  wire                    sign_b_f2;
  wire                    sign_f2;
  wire                    sign_res_f4;
  wire                    snan_op_f2;
  wire                    snan_opa_f2;
  wire                    snan_opb_f2;
  wire [31:0]             sp_res;
  wire                    sticky_bit_f4;
  wire                    sub_f1;
  wire                    sub_mux_f2;
  wire [52:0]             swap_frc_opa_f2;
  wire [53:0]             swap_frc_opb_f2;
  wire                    undf_res_f4;
  wire [52:0]             unpack_frc_opa_f1;
  wire [53:0]             unpack_frc_opb_f1;
  wire                    zero_exp_f4;
  wire                    zero_expa_f1;
  wire                    zero_expb_f1;
  wire                    zero_expb_f2;
  wire                    zero_frca_f2;
  wire                    zero_frcb_f2;
  wire                    zero_op_f2;
  wire                    zero_opa_f2;
  wire                    zero_opb_f2;
  wire                    zero_out_f4;
  wire                    zero_res_f2;
  wire                    zres_f2;


  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  //----------------------------------------------------------
  // First execution stage f1
  //----------------------------------------------------------

  // Unpack the floating point operands
  ca5dpu_fp_unpack_opa u_fp_unpack_opa (
    .fad_a_data_f1_i      (fad_a_data_f1_i),
    .out_format_f1_i      (out_format_f1),
    .fused_mac_f1_i       (fused_mac_f1_i),
    .sign_a_f1_o          (sign_a),
    .exp_a_f1_o           (raw_exp_a_f1),
    .unpack_frc_opa_f1_o  (unpack_frc_opa_f1),
    .msb_opa_f1_o         (msb_opa_f1),
    .max_expa_f1_o        (max_expa_f1),
    .zero_expa_f1_o       (zero_expa_f1)
  );

  ca5dpu_fp_unpack_opb u_fp_unpack_opb (
    .fad_b_data_f1_i      (fad_b_data_f1_i),
    .in_format_f1_i       (in_format_f1),
    .fused_mac_f1_i       (fused_mac_f1_i),
    .ahp_f1_i             (ahp_f1_i),
    .imm_data_f1_i        (imm_data_f1_i[5:0]),
    .sign_b_f1_o          (sign_b),
    .exp_b_f1_o           (exp_b_f1),
    .unpack_frc_opb_f1_o  (unpack_frc_opb_f1),
    .msb_opb_f1_o         (msb_opb_f1),
    .max_expb_f1_o        (max_expb_f1),
    .can_flush_opb_f1_o   (can_flush_opb_f1),
    .zero_expb_f1_o       (zero_expb_f1)
  );

  // Extract control signals
  assign in_format_f1   = add_ctl_f1_i[`CA5_FP_ADD_IN_FORMAT_BITS];         // Input operands' format
  assign out_format_f1  = add_ctl_f1_i[`CA5_FP_ADD_OUT_FORMAT_BITS];        // Output operands' format
  assign negate_f1      = add_ctl_f1_i[`CA5_FP_ADD_NEGATE_BITS];            // Negate command {no negation,negA,negB,abs}
  assign abs_neg_f1     = add_ctl_f1_i[`CA5_FP_ADD_ABS_NEG_BITS];           // VABS, VNEG or  VMOV instruction
  assign cmp_cmd_f1[1]  = add_ctl_f1_i[`CA5_FP_ADD_CMP_BITS];               // Comparison command {quiet=~cmd[0], enable=cmd[1]}
  assign cmp_cmd_f1[0]  = add_ctl_f1_i[`CA5_FP_ADD_QNAN_EXCEP_BITS];
  assign fixed_point_f1 = add_ctl_f1_i[`CA5_FP_ADD_FIXED_POINT_BITS];       // Fixed point controls

`genif (NEON_0)
  // Extract Neon signals
  assign neon_int_sel_f1        = add_ctl_f1_i[`CA5_FP_NEON_ADD_NEON_INT_SEL_BITS]; // Neon operation// Select neon integer operation's result
  assign neon_mux_sel_f1        = add_ctl_f1_i[`CA5_FP_NEON_ADD_NEON_MUX_SEL_BITS]; // Select adder, polymult or logical result
  assign neon_lu_ctl_f1         = add_ctl_f1_i[`CA5_FP_NEON_ADD_LU_CTL_BITS];       // Logical unit operation
  assign neon_size_sel_f1       = add_ctl_f1_i[`CA5_FP_NEON_ADD_SIZE_SEL_BITS]      // Size of SIMD operations
                                   | {2{~neon_int_sel_f1}};
  assign neon_perm_sel_f1       = add_ctl_f1_i[`CA5_FP_NEON_ADD_PERM_SEL_BITS];     // Selects permutation operation
  assign neon_vtb_cycle_f1      = add_ctl_f1_i[`CA5_FP_NEON_ADD_VTB_CYCLE_BITS];    // Indicates the number of the current cycle for VTBL/VTBX instructions
  assign neon_unsigned_op_f1    = add_ctl_f1_i[`CA5_FP_NEON_ADD_UNSIGNED_OP_BITS];  // Selects signed or unsigned comparison
  assign neon_fctn_sel_f1       = add_ctl_f1_i[`CA5_FP_NEON_ADD_FCTN_SEL_BITS];     // Selects neon operation in the second stage
  assign neon_width_op_sel_f1   = add_ctl_f1_i[`CA5_FP_NEON_ADD_WIDTH_OP_SEL_BITS]; // Width operation (widening or narrow) of source and destination operands respectively
  assign neon_sat_op_sel_f1     = add_ctl_f1_i[`CA5_FP_NEON_ADD_SAT_OP_SEL_BITS];   // Selects the saturation detect bits according to the operation
  assign neon_vtst_op_sel_f1    = add_ctl_f1_i[`CA5_FP_NEON_ADD_VTST_OP_SEL_BITS];  // Selects the VTST operation
  assign neon_mask_sel_f1       = add_ctl_f1_i[`CA5_FP_NEON_ADD_MASK_SEL_BITS];     // Selects the mask produced from the shift block as the 2nd operand
`genendif

  // Double precision input format
  assign dp_op_sel_f1 = (in_format_f1 == `CA5_FP_FORMAT_F64);

  // Floating to integer and integer to floating input formats
  assign f2i_cmd_f1 = out_format_f1[2];
  assign i2f_cmd_f1 = in_format_f1[2];

  // Single to double and double to single input formats
  assign s2d_cmd_f1 = in_format_f1 == `CA5_FP_FORMAT_F32 & out_format_f1 == `CA5_FP_FORMAT_F64;
  assign d2s_cmd_f1 = in_format_f1 == `CA5_FP_FORMAT_F64 & out_format_f1 == `CA5_FP_FORMAT_F32;

  assign s2h_f1 = out_format_f1 == `CA5_FP_FORMAT_F16_B | out_format_f1 == `CA5_FP_FORMAT_F16_T;
  assign h2s_f1 = in_format_f1  == `CA5_FP_FORMAT_F16_B | in_format_f1  == `CA5_FP_FORMAT_F16_T;

  // For float-to-int conversions, create a fake exponent for operand A
  // which causes the align logic used for adds to shift the value properly
  assign exp_a_f1 = raw_exp_a_f1 | ({11{f2i_cmd_f1}} & ({dp_op_sel_f1, 2'b00, ~dp_op_sel_f1, 7'd19} + imm_data_f1_i[5:0]));

  // Negate operand's sign if required
  // For convert operations, make the a sign equal to the b sign
  // Negate the sign for the operand b for VNEG and subtraction
`genif (NEON_0)
  assign sign_a_f1 = (negate_f1 == 1)                  ^ (sign_a & ~neon_int_sel_f1);
  assign sign_b_f1 = (negate_f1 == 2 | negate_f1 == 3) ^ (sign_b & ~neon_int_sel_f1);
`genelse
  assign sign_a_f1 = (negate_f1 == 1) ^ sign_a;
  assign sign_b_f1 = (negate_f1 == 2) ^ sign_b;
`genendif

  // Compare the fractions of the input operands
  assign eqfrc_f1[3] = fad_a_data_f1_i[51:38] == fad_b_data_f1_i[51:38];
  assign eqfrc_f1[2] = fad_a_data_f1_i[37:23] == fad_b_data_f1_i[37:23];
  assign eqfrc_f1[1] = fad_a_data_f1_i[22:12] == fad_b_data_f1_i[22:12];
  assign eqfrc_f1[0] = fad_a_data_f1_i[11: 0] == fad_b_data_f1_i[11: 0];

  assign gtfrc_f1[3] = fad_a_data_f1_i[51:38] >  fad_b_data_f1_i[51:38];
  assign gtfrc_f1[2] = fad_a_data_f1_i[37:23] >  fad_b_data_f1_i[37:23];
  assign gtfrc_f1[1] = fad_a_data_f1_i[22:12] >  fad_b_data_f1_i[22:12];
  assign gtfrc_f1[0] = fad_a_data_f1_i[11: 0] >  fad_b_data_f1_i[11: 0];

  assign eqfrc_fmac_f1[2] = fad_a_data_f1_i[22:12] == fad_b_data_f1_i[51:41];
  assign eqfrc_fmac_f1[1] = fad_a_data_f1_i[11: 0] == fad_b_data_f1_i[40:29];
  assign eqfrc_fmac_f1[0] = {29{1'b0}}             == fad_b_data_f1_i[28: 0];

  assign gtfrc_fmac_f1[1] = fad_a_data_f1_i[22:12] >  fad_b_data_f1_i[51:41];
  assign gtfrc_fmac_f1[0] = fad_a_data_f1_i[11: 0] >  fad_b_data_f1_i[40:29];

  // Select addition or subtraction operation
  assign sub_f1 = (~s2d_cmd_f1 & ~d2s_cmd_f1 & ~abs_neg_f1 & ~s2h_f1) & (sign_a_f1 ^ sign_b_f1);

  // Compute sign for the first operand
  assign nxt_sign_a_f1 = ~(negate_f1 == 3) & (sign_a_f1 | (sign_b_f1 & (i2f_cmd_f1 | f2i_cmd_f1 | s2h_f1 | h2s_f1)));

  // Compute the sign of the second operand for the VABS operation
  assign nxt_sign_b_f1 = ~(negate_f1 == 3) & sign_b_f1;

  assign d2fix_f1 = f2i_cmd_f1 & dp_op_sel_f1 & fixed_point_f1;

  // Select inputs for neon or normal fpu operation
`genif (NEON_0)

  // When the input operands are extended increase the size element by one
  // Also increase for narrowing operations, as the instruction encodes the
  // result element size, not the source element size
  assign neon_inc_size_sel_f1 = (neon_width_op_sel_f1[2:1] == 2'b01 || neon_width_op_sel_f1[2:1] == 2'b10) ? neon_size_sel_f1 + 1'b1 : neon_size_sel_f1;

  // Zero or sign extends input operands
  function [63:0] extend_opnd;
    input         sign_ext;
    input [1:0]   size;
    input [63:0]  opa;

    case (size)
      2'b00: begin // 8-bits
        extend_opnd[63:48] = { { 8{sign_ext & opa[31]}}, opa[31:24]};
        extend_opnd[47:32] = { { 8{sign_ext & opa[23]}}, opa[23:16]};
        extend_opnd[31:16] = { { 8{sign_ext & opa[15]}}, opa[15: 8]};
        extend_opnd[15: 0] = { { 8{sign_ext & opa[ 7]}}, opa[ 7: 0]};
      end
      2'b01: begin // 16-bits
        extend_opnd[63:32] = { {16{sign_ext & opa[31]}}, opa[31:16]};
        extend_opnd[31: 0] = { {16{sign_ext & opa[15]}}, opa[15: 0]};
      end
      2'b10: begin // 32-bits
        extend_opnd[63: 0] = { {32{sign_ext & opa[31]}}, opa[31: 0]};
      end
      default: extend_opnd = {64{1'bx}};
    endcase
  endfunction

  assign neon_ext_opa_f1 = extend_opnd(~neon_unsigned_op_f1, neon_size_sel_f1, fad_a_data_f1_i);
  assign neon_ext_opb_f1 = extend_opnd(~neon_unsigned_op_f1, neon_size_sel_f1, fad_b_data_f1_i);

  ca5dpu_neon_perm_ctl u_perm_ctl (
    .neon_inc_size_sel_f1 (neon_inc_size_sel_f1),
    .neon_perm_sel_f1_i   (neon_perm_sel_f1),
    .fad_c_data_f1_i      (fad_c_data_f1_i),
    .neon_perm_ctl_f1_o   (neon_perm_ctl_f1)
  );

  assign neon_shift_reg_f1 = (neon_fctn_sel_f1 == 4'b0111 || neon_fctn_sel_f1 == 4'b1101)
                             && neon_width_op_sel_f1 != 3'b001;

  assign neon_nxt_frc_opc_f2 = neon_perm_ctl_f1;

  assign frc_opa_f1 = ~neon_int_sel_f1                      ? { {11{1'b0}}, unpack_frc_opa_f1} :
                      (neon_width_op_sel_f1[2:0] == 3'b011) ? neon_ext_opa_f1                  :
                                                              fad_a_data_f1_i;

  assign frc_opb_f1 = ~neon_int_sel_f1                      ? { {10{1'b0}}, unpack_frc_opb_f1} :
                      neon_shift_reg_f1                     ? fad_c_data_f1_i                  :
                      (neon_width_op_sel_f1[2:1] == 2'b01)  ? neon_ext_opb_f1                  :
                                                              fad_b_data_f1_i;
`genelse
  assign frc_opa_f1 = unpack_frc_opa_f1;
  assign frc_opb_f1 = unpack_frc_opb_f1;
`genendif

  always @(posedge clk)
    if (~stall_wr_i | flush_ret_i)
      enable_f2         <= enable_f1_i;

  always @(posedge clk)
    if ((~stall_wr_i | flush_ret_i) & enable_f1_i)
      begin
       rnd_mode_f2      <= rm_f1_i;
       cmp_cmd_f2       <= cmp_cmd_f1;
       in_format_f2     <= in_format_f1;
       out_format_f2    <= out_format_f1;
       d2fix_f2         <= d2fix_f1;
       abs_neg_f2       <= abs_neg_f1;
       negate_f2        <= negate_f1;
       sub_f2           <= sub_f1;
       sign_a_f2        <= nxt_sign_a_f1;
       sign_nnanb_f2    <= nxt_sign_b_f1;
       frc_opa_f2       <= frc_opa_f1;
       frc_opb_f2       <= frc_opb_f1;
       can_flush_opb_f2 <= can_flush_opb_f1;
       max_expa_f2      <= max_expa_f1;
       max_expb_f2      <= max_expb_f1;
       msb_opa_f2       <= msb_opa_f1;
       msb_opb_f2       <= msb_opb_f1;
       eqfrc_f2         <= eqfrc_f1;
       gtfrc_f2         <= gtfrc_f1;
       eqfrc_fmac_f2    <= eqfrc_fmac_f1;
       gtfrc_fmac_f2    <= gtfrc_fmac_f1;
       exp_a_f2         <= exp_a_f1;
       exp_b_f2         <= exp_b_f1;
       zero_expa_f2     <= zero_expa_f1;
       raw_zero_expb_f2 <= zero_expb_f1;
       fused_mac_f2     <= fused_mac_f1_i;
     end

`genif (NEON_0)
  always @(posedge clk)
    if ((~stall_wr_i | flush_ret_i) & enable_f1_i)
      begin
        neon_int_sel_f2       <= neon_int_sel_f1;
        neon_fctn_sel_f2      <= neon_fctn_sel_f1;
        neon_mux_sel_f2       <= neon_mux_sel_f1;
        neon_lu_ctl_f2        <= neon_lu_ctl_f1;
        neon_frc_opc_f2       <= neon_nxt_frc_opc_f2;
        neon_size_sel_f2      <= neon_inc_size_sel_f1;
        neon_vtb_cycle_f2     <= neon_vtb_cycle_f1;
        neon_unsigned_op_f2   <= neon_unsigned_op_f1;
        neon_width_op_sel_f2  <= neon_width_op_sel_f1;
        neon_sat_op_sel_f2    <= neon_sat_op_sel_f1;
        neon_mask_sel_f2      <= neon_mask_sel_f1;
        neon_vtst_op_sel_f2   <= neon_vtst_op_sel_f1;
        neon_force_dn_fz_f2   <= force_dn_fz_f1_i;
        neon_dec_exp_f2       <= dec_exp_f1_i;
        neon_shift_reg_f2     <= neon_shift_reg_f1;
      end
`genendif

  //----------------------------------------------------------
  // Second execution stage f2
  //----------------------------------------------------------

`genif (NEON_0)
  assign neon_int_op_f2 = neon_int_sel_f2;
  assign force_dn_fz_f2 = neon_force_dn_fz_f2;
`genelse
  assign neon_int_op_f2 = 1'b0;
  assign force_dn_fz_f2 = 1'b0;
`genendif

  // Floating to integer and integer to floating input formats
  assign f2i_f2 = out_format_f2[2];
  assign i2f_f2 = in_format_f2[2];

  assign s2i_f2 = in_format_f2 == `CA5_FP_FORMAT_F32 & f2i_f2;

  // Single to double and double to single input formats
  assign s2d_f2 = in_format_f2 == `CA5_FP_FORMAT_F32 & out_format_f2 == `CA5_FP_FORMAT_F64;
  assign d2s_f2 = in_format_f2 == `CA5_FP_FORMAT_F64 & out_format_f2 == `CA5_FP_FORMAT_F32;

  assign s2h_f2 = out_format_f2 == `CA5_FP_FORMAT_F16_B | out_format_f2 == `CA5_FP_FORMAT_F16_T;

  assign dp_op_sel_f2 = (out_format_f2 == `CA5_FP_FORMAT_F64);

  assign realign_f32_f2 = (in_format_f2 == `CA5_FP_FORMAT_F32   && out_format_f2 == `CA5_FP_FORMAT_F32) & ~fused_mac_f2 |
                          (in_format_f2 == `CA5_FP_FORMAT_F32   && out_format_f2 == `CA5_FP_FORMAT_F64)                 |
                          (in_format_f2 == `CA5_FP_FORMAT_F64   && out_format_f2 == `CA5_FP_FORMAT_F32)                 |
                          (in_format_f2 == `CA5_FP_FORMAT_F16_T && out_format_f2 == `CA5_FP_FORMAT_F32)                 |
                          (in_format_f2 == `CA5_FP_FORMAT_F16_B && out_format_f2 == `CA5_FP_FORMAT_F32);

  // Check exponents and fractions if non-zero, zero or all ones
  assign zero_frca_f2 = (frc_opa_f2[22:0] == 0) & (in_format_f2 == `CA5_FP_FORMAT_F32 & ~fused_mac_f2 | frc_opa_f2[51:23] == 0);
  assign zero_frcb_f2 = (frc_opb_f2[22:0] == 0) & (in_format_f2 == `CA5_FP_FORMAT_F32 & ~fused_mac_f2 |
                                                   in_format_f2 == `CA5_FP_FORMAT_F16_B               |
                                                   in_format_f2 == `CA5_FP_FORMAT_F16_T               | frc_opb_f2[51:23] == 0)
                                                & (~i2f_f2 | frc_opb_f2[53:52] == 0);

  // If the B operand was an integer, set zero_exp to zero_frc
  assign zero_expb_f2 = i2f_f2 ? zero_frcb_f2 : raw_zero_expb_f2;

  assign nan_opa_f2  = ~neon_int_op_f2 & max_expa_f2 & ~zero_frca_f2;
  assign nan_opb_f2  = ~neon_int_op_f2 & max_expb_f2 & ~zero_frcb_f2;
  assign snan_opa_f2 = nan_opa_f2 & ~msb_opa_f2;
  assign snan_opb_f2 = nan_opb_f2 & ~msb_opb_f2;

  // Flush to zero mode signal
  assign ifz_opa_f2  =                    (force_dn_fz_f2 | fpscr_fz_i) & zero_expa_f2 & ~zero_frca_f2;
  assign ifz_opb_f2  = can_flush_opb_f2 & (force_dn_fz_f2 | fpscr_fz_i) & zero_expb_f2 & ~zero_frcb_f2;
  assign zero_opa_f2 = zero_expa_f2 & zero_frca_f2 | ifz_opa_f2;
  assign zero_opb_f2 = zero_expb_f2 & zero_frcb_f2 | ifz_opb_f2;

    // Negate the sign if it is nan
  assign sign_b_f2 = ((nan_opb_f2 & ~abs_neg_f2) & (negate_f2 == 2)) ^ sign_nnanb_f2;

  // Select the sign of the 1st NaN operand when ~(~sp_snan_opa_f1&sp_snan_opb_f1)
  assign nsnan_opb_f2 = nan_opa_f2 & (snan_opa_f2 | ~snan_opb_f2);

  // Check if one (or both) of the operands is NaN or signalling NaN
  assign nan_op_f2  = nan_opa_f2 | nan_opb_f2;
  assign snan_op_f2 = snan_opa_f2 | snan_opb_f2;

  // Check if zero operation
  assign zero_op_f2 = zero_opa_f2 & zero_opb_f2;

  // Check if operands are infinite
  assign infinite_opa_f2 = ~neon_int_op_f2 & max_expa_f2 & zero_frca_f2;
  assign infinite_opb_f2 = ~neon_int_op_f2 & max_expb_f2 & zero_frcb_f2;

  // Check if invalid operation
  assign invalid_op_f2 = infinite_opa_f2 & infinite_opb_f2 & sub_f2;

  // Compare the two exponents of the input operands
  assign gtexp_f2   = exp_a_f2 >  exp_b_f2 | infinite_opa_f2;
  assign eqexp_f2   = exp_a_f2 == exp_b_f2;

   // Choose the maximum of the two input exponents
  assign exp_add_f2 = gtexp_f2 ? exp_a_f2 : exp_b_f2;

  // Calculate if the magnitude of a float is too large to fit into an int/fixed-point
  assign f2i_overflow_f2 = exp_b_f2 > (exp_a_f2 - (out_format_f2[1] ? 6'd37 : 6'd21));

  // Adjust exponent when single to double conversion exp+1024-128
  assign exp_s2d_f2 = {exp_b_f2[7], {3{~exp_b_f2[7]}}, exp_b_f2[6:1], exp_b_f2[0] | zero_expb_f2} & {11{~zero_opb_f2}};

  // Compute the shift amount for narrowing conversion
  assign narrow_sh_max_f2 = s2h_f2 ? exp_b_f2[7:6] == 2'b00 : exp_b_f2[10:5] < 6'b011011;
  assign narrow_sh_min_f2 = s2h_f2 ? exp_b_f2[7:0] > 8'h70 : ((exp_b_f2[10:5] > 6'b011011) & (exp_b_f2[10:0] !=  11'h380));


  assign narrow_sh_amount_f2 = narrow_sh_max_f2 ? 6'h3f :
                               narrow_sh_min_f2 ? (s2h_f2 ? 6'd13 : 6'd29) :
                                                  ((s2h_f2 ? 6'h3e : 6'h1e) - exp_b_f2[5:0]);

  assign narrow_exp_sub_f2   = {1'b0, exp_b_f2} - (s2h_f2 ? 12'h070 : 12'h380);
  assign exp_narrow_f2       = {11{~narrow_exp_sub_f2[11]}} & narrow_exp_sub_f2[10:0];

  // Select exponent
  assign exp_opd_f2 = {11{s2d_f2 | i2f_f2 & dp_op_sel_f2}} & exp_s2d_f2 |
                      {11{(~s2d_f2 & ~d2s_f2 & ~i2f_f2 & ~f2i_f2 & ~s2h_f2) | i2f_f2 & ~dp_op_sel_f2}} & exp_add_f2 |
                      {10'h000, f2i_f2} | {11{d2s_f2 | s2h_f2}} & exp_narrow_f2;

  function [5:0] exp_sub;
    // Performs the (expa - expb) -(expb == 0) or
    // (expb - expa) - (expa == 0 and expb != 0)
    input [10:0] opa;
    input [10:0] opb;
    input        sh_dec;

    reg  [3:0]   carry_high;
    reg  [6:0]   sub_res_low;
    reg  [4:0]   sub_res_high;
    reg          zero_res;

    begin
      sub_res_low   = {1'b0, opa[5:0]} + {1'b0, ~opb[5:0]} + sh_dec;
      sub_res_high  = opa[10:6] ^ (~opb[10:6]);
      carry_high    = opa[9:6] | (~opb[9:6]);
      zero_res      = sub_res_high == {carry_high, sub_res_low[6]};
      exp_sub       = zero_res ? sub_res_low[5:0] : 6'd63;
    end
  endfunction

  // Compute the shift amount for the alignment of the operands
  assign shift_deca_f2 = zero_expb_f2;
  assign shift_decb_f2 = zero_expa_f2 & (~zero_expb_f2);
  assign sh_amount_f2  = i2f_f2 | s2d_f2 | abs_neg_f2 ? 6'b000000                                    :
                         d2s_f2 | s2h_f2              ? narrow_sh_amount_f2                          :
                         gtexp_f2                     ? exp_sub (exp_a_f2, exp_b_f2, ~shift_deca_f2) :
                                                        exp_sub (exp_b_f2, exp_a_f2, ~shift_decb_f2);

  // Compute the flush to zero output
  assign ifz_f2 = ifz_opa_f2 | ifz_opb_f2;

  // Check if invalid exception for addition/subtraction or comparison
  assign invalid_excpt = snan_op_f2 | (~cmp_op_sel_f2 & invalid_op_f2) | (nan_op_f2 & (~quiet_f2 | s2h_f2 & ahp_f1_i)) | infinite_opb_f2 & s2h_f2 & ahp_f1_i;

  // Check if invalid or NaN operation
  assign nan_inv_op_f2 = nan_op_f2 | invalid_op_f2;

  // Check if one (or both) of the operands is infinity
  assign infinity_op_f2 = (infinite_opa_f2 | infinite_opb_f2) & ~f2i_f2 & ~(s2h_f2 & ahp_f1_i);

  // Check if possible zero result
  assign equal_opnd_f2 = eqexp_f2 & (fused_mac_f2 ? &eqfrc_fmac_f2[2:0] :
                                     dp_op_sel_f2 ? &eqfrc_f2[3:0]      :
                                                    &eqfrc_f2[1:0]);
  assign zres_f2 = sub_f2 & equal_opnd_f2 & ~f2i_f2;
  assign zero_res_f2 = ~nan_op_f2 & (zres_f2 | zero_op_f2);

  // Swap operands if required
  assign gtopnd_f2 =  gtexp_f2 | eqexp_f2 & (fused_mac_f2 ? ~ifz_opa_f2 & {gtfrc_fmac_f2[1:0], 1'b0} > ({~gtfrc_fmac_f2[1:0], 1'b1} & ~eqfrc_fmac_f2[2:0]) :
                                             dp_op_sel_f2 ? gtfrc_f2[3:0] > (~gtfrc_f2[3:0] & ~eqfrc_f2[3:0]) :
                                                            gtfrc_f2[1:0] > (~gtfrc_f2[1:0] & ~eqfrc_f2[1:0]));

  assign nswap_opnd_f2 = nan_op_f2 & ~s2h_f2 ? nsnan_opb_f2 : (gtopnd_f2 | d2s_f2 | s2d_f2 | i2f_f2 | f2i_f2 | s2h_f2 | abs_neg_f2);

  assign swap_frc_opa_f2 = ({53{ nswap_opnd_f2 &  ~ifz_opa_f2}} & frc_opa_f2[52:0]) |
                           ({53{~nswap_opnd_f2 &  ~ifz_opb_f2}} & frc_opb_f2[52:0]);

  assign swap_frc_opb_f2 = ({54{ nswap_opnd_f2 & (~ifz_opb_f2 | abs_neg_f2) & ~s2i_f2}} & frc_opb_f2[53:0])                     |
                           ({54{~nswap_opnd_f2 &  ~ifz_opa_f2               & ~s2i_f2}} & {1'b0, frc_opa_f2[52:0]})             |
                           ({54{                  ~ifz_opb_f2               & s2i_f2}}  & {1'b0, frc_opb_f2[23:0], {29{1'b0}} });

  // Shift second operand
  ca5dpu_fp_shift6  #(.in_width(54),
                      .out_width(57),
                      .guard_width(3))
                    u_fp_shift6
                    (
                      .data_i   (swap_frc_opb_f2),
                      .shift_i  (sh_amount_f2),
                      .result_o (shfrc_opb_f2)
                    );

  // Shift operand if NaN and narrowing conversion
  assign d2s_nan_opa_f2 = nan_op_f2 & d2s_f2 ? { {29{1'b0}}, swap_frc_opa_f2[52:29]} : swap_frc_opa_f2;
  assign s2h_nan_opb_f2 = {57{s2h_f2 & ~ahp_f1_i}} & { 45'h000000000003, {9{~(force_dn_fz_f2 | fpscr_dn_i)}} & frc_opb_f2[21:13], 3'b000 };

  // Select second operand to be zero if NaN operation
  assign sub_mux_f2 = nan_inv_op_f2 ? 1'b0 : sub_f2;
  assign muxfrc_opa_f2 = ({53{~nan_op_f2 | ~(force_dn_fz_f2 | fpscr_dn_i) | s2h_f2 | abs_neg_f2}} & d2s_nan_opa_f2) |
                          {{2{nan_inv_op_f2 & ~realign_f32_f2 & ~abs_neg_f2}}, {27{1'b0}},
                           {2{nan_inv_op_f2 &  realign_f32_f2 & ~abs_neg_f2 & ~s2h_f2}}, {22{1'b0}} };
  assign muxfrc_opb_f2 = cmp_op_sel_f2 | nan_inv_op_f2 ? s2h_nan_opb_f2 : shfrc_opb_f2;

  // Compute the sign
  assign sign_f2 = ~invalid_op_f2 & (zero_res_f2 ? (((rnd_mode_f2 == 2) | s2d_f2 | d2s_f2 | abs_neg_f2) & (sign_a_f2 | sign_b_f2)) | (sign_a_f2 & sign_b_f2)
                                                 : nswap_opnd_f2 & ~s2d_f2 & ~d2s_f2 & ~abs_neg_f2 ? sign_a_f2 : sign_b_f2);

  // Absolute floating point comparison
  assign abs_sign_a_f2 = ~abs_neg_f2 & sign_a_f2;
  assign abs_sign_b_f2 = ~abs_neg_f2 & sign_b_f2;

  // Performs comparison
  always @*
    case (nan_op_f2)
      1'b0 :// Not a NaN operation
         case ({infinite_opa_f2, infinite_opb_f2})
          2'b11 : // A and B are both infinite.  Comparison depends on the sign of both.
              case (abs_sign_a_f2 == abs_sign_b_f2)
                1'b0 : // Differing signs, must look at which is positive
                  {cmp_agtb_f2, cmp_aeqb_f2} = {~abs_sign_a_f2, 1'b0};
                1'b1 : // Same sign, therefore equal
                  {cmp_agtb_f2, cmp_aeqb_f2} = 2'b01;
                default :
                  {cmp_agtb_f2, cmp_aeqb_f2} = 2'bxx;
              endcase
          2'b10 : // A is infinite.  Comparison depends on the sign of A.
            {cmp_agtb_f2, cmp_aeqb_f2} = {~abs_sign_a_f2, 1'b0};
          2'b01 : // B is infinite.  Comparison depends on the sign of B.
            {cmp_agtb_f2, cmp_aeqb_f2} = {abs_sign_b_f2, 1'b0};
          2'b00 : // Neither A nor B are infinite.  Must examine values.
              case (zero_op_f2)
                1'b1 : // Both zero (ignore signs)
                  {cmp_agtb_f2, cmp_aeqb_f2} = 2'b01;
                1'b0 :
                    case (abs_sign_a_f2 == abs_sign_b_f2)
                      1'b0: // Differing signs, must look at which is positive
                        {cmp_agtb_f2, cmp_aeqb_f2} = {~abs_sign_a_f2, 1'b0};
                      1'b1: // Same sign, must look at magnitude and which is positive
                        {cmp_agtb_f2, cmp_aeqb_f2} = {(gtopnd_f2^abs_sign_a_f2) & (~equal_opnd_f2), equal_opnd_f2};
                      default :
                        {cmp_agtb_f2, cmp_aeqb_f2} = 2'bxx;
                    endcase
                default :
                  {cmp_agtb_f2, cmp_aeqb_f2} = 2'bxx;
              endcase
        endcase
      1'b1 : // NaN operation
        {cmp_agtb_f2, cmp_aeqb_f2} = 2'b00;
      default :
        {cmp_agtb_f2, cmp_aeqb_f2} = 2'bxx;
    endcase

  //  RESULT   | N Z C V
  // -------------------
  //   A = B   | 0 1 1 0
  //   A < B   | 1 0 0 0
  //   A > B   | 0 0 1 0
  // Unordered | 0 0 1 1

  assign cmpflags_f2 = {cmp_agtb_f2, cmp_aeqb_f2, ~cmp_agtb_f2, nan_op_f2};

`genif (NEON_0)
  //----------------------------------
  // Neon Permutation Block
  //----------------------------------

  ca5dpu_neon_permutation u_permutation (
    // Inputs
    .frc_opa_f2_i          (frc_opa_f2),
    .frc_opb_f2_i          (frc_opb_f2),
    .neon_frc_opc_f2_i     (neon_frc_opc_f2),
    // Outputs
    .neon_perm_opa_f2_o    (neon_perm_opa_f2),
    .neon_perm_opb_f2_o    (neon_perm_opb_f2)
  );

  //----------------------------------
  // Neon Comparison Block
  //----------------------------------

  ca5dpu_neon_swap_max u_neon_swap_max (
    // Inputs
    .neon_size_sel_f2_i     (neon_size_sel_f2),
    .neon_unsigned_op_f2_i  (neon_unsigned_op_f2),
    .neon_perm_opa_f2_i     (neon_perm_opa_f2),
    .neon_perm_opb_f2_i     (neon_perm_opb_f2),
    // Outputs
    .neon_swap_max_f2_o     (neon_swap_max_f2),
    .neon_swap_min_f2_o     (neon_swap_min_f2),
    .neon_cmp_gt_f2_o       (neon_cmp_gt_f2),
    .neon_cmp_eq_f2_o       (neon_cmp_eq_f2)
  );

  //----------------------------------
  // Neon Shift Block
  //----------------------------------

  ca5dpu_neon_shift u_neon_shift (
    // Inputs
    .neon_size_f2_i         (neon_size_sel_f2),
    .neon_unsigned_f2_i     (neon_unsigned_op_f2),
    .neon_width_op_sel_f2_i (neon_width_op_sel_f2),
    .neon_mask_sel_f2_i     (neon_mask_sel_f2),
    .neon_shift_reg_f2_i    (neon_shift_reg_f2),
    .imm_data_f2_i          (imm_data_f2_i),
    .frc_opa_f2_i           (frc_opa_f2),
    .frc_opb_f2_i           (frc_opb_f2),
    .neon_perm_opa_f2_i     (neon_perm_opa_f2),
    .neon_perm_opb_f2_i     (neon_perm_opb_f2),
    // Outputs
    .neon_shift_res_f2_o    (neon_shift_res_f2),
    .neon_shift_round_f2_o  (neon_shift_round_f2),
    .neon_shift_mask_f2_o   (neon_shift_mask_f2),
    .neon_sat_res_f2_o      (neon_sat_dtect_f2)
  );

  //----------------------------------
  // Neon CLS block
  //----------------------------------

  // Check the sign of the operand and if
  // negative invert it in order to use the
  // count leading zeros block in the next stage
  always @*
    begin
      case (neon_size_sel_f2)
        2'b00: begin // 8-bits
          neon_cls_res_f2[63:56] = {{7{frc_opa_f2[63]}} ^ frc_opa_f2[62:56], 1'b1};
          neon_cls_res_f2[55:48] = {{7{frc_opa_f2[55]}} ^ frc_opa_f2[54:48], 1'b1};
          neon_cls_res_f2[47:40] = {{7{frc_opa_f2[47]}} ^ frc_opa_f2[46:40], 1'b1};
          neon_cls_res_f2[39:32] = {{7{frc_opa_f2[39]}} ^ frc_opa_f2[38:32], 1'b1};
          neon_cls_res_f2[31:24] = {{7{frc_opa_f2[31]}} ^ frc_opa_f2[30:24], 1'b1};
          neon_cls_res_f2[23:16] = {{7{frc_opa_f2[23]}} ^ frc_opa_f2[22:16], 1'b1};
          neon_cls_res_f2[15:8]  = {{7{frc_opa_f2[15]}} ^ frc_opa_f2[14:8], 1'b1};
          neon_cls_res_f2[7:0]   = {{7{frc_opa_f2[7]}}  ^ frc_opa_f2[6:0], 1'b1};
        end
        2'b01: begin // 16-bits
          neon_cls_res_f2[63:48] = {{15{frc_opa_f2[63]}} ^ frc_opa_f2[62:48], 1'b1};
          neon_cls_res_f2[47:32] = {{15{frc_opa_f2[47]}} ^ frc_opa_f2[46:32], 1'b1};
          neon_cls_res_f2[31:16] = {{15{frc_opa_f2[31]}} ^ frc_opa_f2[30:16], 1'b1};
          neon_cls_res_f2[15:0]  = {{15{frc_opa_f2[15]}} ^ frc_opa_f2[14:0], 1'b1};
        end
        2'b10: begin // 32-bits
          neon_cls_res_f2[63:32] = {{31{frc_opa_f2[63]}} ^ frc_opa_f2[62:32], 1'b1};
          neon_cls_res_f2[31:0]  = {{31{frc_opa_f2[31]}} ^ frc_opa_f2[30:0], 1'b1};
        end
        default:
          neon_cls_res_f2[63:0] = {64{1'bx}};
      endcase
    end

  //----------------------------------
  // Neon CNT block
  //----------------------------------
  function [3:0] count_ones;
  // Counts ones of an input operand
    input [7:0]   opa;
    begin
      count_ones = (opa[7]  +
                    opa[6]  +
                    opa[5]  +
                    opa[4]  +
                    opa[3]  +
                    opa[2]  +
                    opa[1]  +
                    opa[0]);
    end
  endfunction

  // Counts ones for every 8-bit element of an input operand
  // and produces a vector result
  assign neon_cnt_res_f2[63:56] = {4'b0000, count_ones(frc_opa_f2[63:56])};
  assign neon_cnt_res_f2[55:48] = {4'b0000, count_ones(frc_opa_f2[55:48])};
  assign neon_cnt_res_f2[47:40] = {4'b0000, count_ones(frc_opa_f2[47:40])};
  assign neon_cnt_res_f2[39:32] = {4'b0000, count_ones(frc_opa_f2[39:32])};
  assign neon_cnt_res_f2[31:24] = {4'b0000, count_ones(frc_opa_f2[31:24])};
  assign neon_cnt_res_f2[23:16] = {4'b0000, count_ones(frc_opa_f2[23:16])};
  assign neon_cnt_res_f2[15:8]  = {4'b0000, count_ones(frc_opa_f2[15:8])};
  assign neon_cnt_res_f2[7:0]   = {4'b0000, count_ones(frc_opa_f2[7:0])};

  //----------------------------------
  // Neon valid vector for VTBL/VTBX
  //----------------------------------
  function [7:0] valid_bytes_vector;
  // Checks if the byte indexes from the control vector
  // are within a valid range and produces a valid vector
    input [7:0] vector_ctl;
    input [1:0] length;
    input       cycle;
    reg         valid_byte;
    begin
      valid_byte = (~(|vector_ctl[7:5])) & (vector_ctl[4:3] <= length) & ~(cycle & (vector_ctl[4:3] < 2'b10));
      valid_bytes_vector = {8{valid_byte}};

    end
  endfunction

  // Produces the valid vector for VTBL/VTBX
  assign neon_valid_bytes_vector_f2[63:56] = valid_bytes_vector(neon_frc_opc_f2[63:56], neon_size_sel_f2, neon_vtb_cycle_f2);
  assign neon_valid_bytes_vector_f2[55:48] = valid_bytes_vector(neon_frc_opc_f2[55:48], neon_size_sel_f2, neon_vtb_cycle_f2);
  assign neon_valid_bytes_vector_f2[47:40] = valid_bytes_vector(neon_frc_opc_f2[47:40], neon_size_sel_f2, neon_vtb_cycle_f2);
  assign neon_valid_bytes_vector_f2[39:32] = valid_bytes_vector(neon_frc_opc_f2[39:32], neon_size_sel_f2, neon_vtb_cycle_f2);
  assign neon_valid_bytes_vector_f2[31:24] = valid_bytes_vector(neon_frc_opc_f2[31:24], neon_size_sel_f2, neon_vtb_cycle_f2);
  assign neon_valid_bytes_vector_f2[23:16] = valid_bytes_vector(neon_frc_opc_f2[23:16], neon_size_sel_f2, neon_vtb_cycle_f2);
  assign neon_valid_bytes_vector_f2[15:8]  = valid_bytes_vector(neon_frc_opc_f2[15:8],  neon_size_sel_f2, neon_vtb_cycle_f2);
  assign neon_valid_bytes_vector_f2[7:0]   = valid_bytes_vector(neon_frc_opc_f2[7:0],   neon_size_sel_f2, neon_vtb_cycle_f2);

  // Select the maximum and the minimum operand. If one of them is a NaN then the output operand will be the default NaN.
  assign neon_fp_max_sign_f2 = sign_a_f2 & sign_b_f2;
  assign neon_fp_min_sign_f2 = sign_a_f2 | sign_b_f2;

  assign neon_fp_max_opnd_f2 = nan_op_f2      ? {1'b0, 8'hff, 1'b1, {22{1'b0}}, 1'b0, 8'hff, 1'b1, {22{1'b0}}} :
                               cmpflags_f2[3] ? {neon_fp_max_sign_f2, exp_a_f2[7:0], {23{~ifz_opa_f2}} & frc_opa_f2[22:0], neon_fp_max_sign_f2, exp_a_f2[7:0], {23{~ifz_opa_f2}} & frc_opa_f2[22:0]} :
                                                {neon_fp_max_sign_f2, exp_b_f2[7:0], {23{~ifz_opb_f2}} & frc_opb_f2[22:0], neon_fp_max_sign_f2, exp_b_f2[7:0], {23{~ifz_opb_f2}} & frc_opb_f2[22:0]};

  assign neon_fp_min_opnd_f2 = nan_op_f2      ? {1'b0, 8'hff, 1'b1, {22{1'b0}}, 1'b0, 8'hff, 1'b1, {22{1'b0}}} :
                               cmpflags_f2[3] ? {neon_fp_min_sign_f2, exp_b_f2[7:0], {23{~ifz_opb_f2}} & frc_opb_f2[22:0], neon_fp_min_sign_f2, exp_b_f2[7:0], {23{~ifz_opb_f2}} & frc_opb_f2[22:0]} :
                                                {neon_fp_min_sign_f2, exp_a_f2[7:0], {23{~ifz_opa_f2}} & frc_opa_f2[22:0], neon_fp_min_sign_f2, exp_a_f2[7:0], {23{~ifz_opa_f2}} & frc_opa_f2[22:0]};

  // MUX to select between the 3d input operand and the feedback mask result
  // of the F3 stage for the VTBL/VTBX instructions or the saturation detect
  // result from
  assign neon_nxt_frc_opc_f3 = ((neon_fctn_sel_f2==3 & neon_vtb_cycle_f2) ||
                                 neon_fctn_sel_f2==4)                               ? neon_lu_res_f3      :
                               (neon_sat_op_sel_f2 == `CA5_NEON_SAT_SHF_SIGNED ||
                                neon_sat_op_sel_f2 == `CA5_NEON_SAT_SHF_UNSIGNED )  ? neon_sat_dtect_f2   :
                                neon_mask_sel_f2                                    ? neon_shift_mask_f2  :
                                neon_frc_opc_f2;

  // Rounding logic for VRADDHN/VRSUBHN instructions
  always @*
    begin
      case (neon_size_sel_f2)
        2'b01: // 16-bits
          neon_rnd_opb_f2 = {16'h0080, 16'h0080, 16'h0080, 16'h0080};
        2'b10: // 32-bits
          neon_rnd_opb_f2 = {32'h00008000, 32'h00008000};
        2'b11: // 64-bits
          neon_rnd_opb_f2 = {{32{1'b0}}, 32'h80000000};
        default:
          neon_rnd_opb_f2 = {64{1'bx}};
        endcase
    end

  // Neon MUX that selects the output operands from Neon blocks

  always @*
    begin
      case (neon_fctn_sel_f2)
        4'b0000: begin // floating-point operation
          neon_opa_f2 = {8'h00, muxfrc_opa_f2, 3'b000};
          neon_opb_f2 = {7'h00, muxfrc_opb_f2};
        end
        4'b0001: begin // permutation operation only
          neon_opa_f2 = neon_perm_opa_f2;
          neon_opb_f2 = neon_perm_opb_f2;
        end
        4'b0010: begin // VRADDHN/VRSUBHN  operation
          neon_opa_f2 = frc_res_f3;
          neon_opb_f2 = neon_rnd_opb_f2;
        end
        4'b0011: begin // VTBL/VTBX operation
          neon_opa_f2 = neon_perm_opa_f2;
          neon_opb_f2 = neon_valid_bytes_vector_f2;
        end
        4'b0100: begin // VTBX operation in the 3d cycle
          neon_opa_f2 = frc_opa_f2;
          neon_opb_f2 = neon_valid_bytes_vector_f2;
        end
        4'b0101: begin // swap_max operation
          neon_opa_f2 = neon_swap_max_f2;
          neon_opb_f2 = neon_swap_min_f2;
        end
        4'b0110: begin // comparison operation
          neon_opa_f2 = neon_int_sel_f2 ? neon_cmp_gt_f2 : {64{cmp_agtb_f2}};
          neon_opb_f2 = neon_int_sel_f2 ? neon_cmp_eq_f2 : {64{cmp_aeqb_f2}};
        end
        4'b0111: begin // shift operation
          neon_opa_f2 = neon_shift_res_f2;
          neon_opb_f2 = 64'h0000000000000000;
        end
        4'b1000: begin // no change in the input operands
          neon_opa_f2 = frc_opa_f2;
          neon_opb_f2 = frc_opb_f2;
        end
        4'b1001: begin // count leading sign bits operation
          neon_opa_f2 = neon_cls_res_f2;
          neon_opb_f2 = 64'h0000000000000000;
        end
        4'b1010: begin // count ones operation
          neon_opa_f2 = neon_cnt_res_f2;
          neon_opb_f2 = 64'h0000000000000000;
        end
        4'b1011: begin // addition feedback result for accumulation
          neon_opa_f2 = frc_opa_f2;
          neon_opb_f2 = frc_res_f3;
        end
        4'b1100: begin // fp max-min instructions
          neon_opa_f2 = neon_fp_max_opnd_f2;
          neon_opb_f2 = neon_fp_min_opnd_f2;
        end
        4'b1101: begin // rounding shift operation
          neon_opa_f2 = neon_shift_res_f2;
          neon_opb_f2 = neon_shift_round_f2;
        end
        4'b1110: begin // shift and accumulate/insert
          neon_opa_f2 = neon_shift_res_f2;
          neon_opb_f2 = frc_opb_f2;
        end
        default: begin
          neon_opa_f2 = {64{1'bx}};
          neon_opb_f2 = {64{1'bx}};
        end
      endcase
    end

  // MUX that selects Neon integer or floating-point output operands
  assign nxt_frc_opa_f3 = neon_opa_f2;
  assign nxt_frc_opb_f3 = neon_opb_f2;

`genelse
  assign nxt_frc_opa_f3 = muxfrc_opa_f2;
  assign nxt_frc_opb_f3 = muxfrc_opb_f2;
`genendif

  always @(posedge clk)
    if (~stall_wr_i | flush_ret_i)
      enable_f3      <= enable_f2;

  always @(posedge clk)
    if ((~stall_wr_i | flush_ret_i) & enable_f2)
      begin
        rnd_mode_f3     <= rnd_mode_f2;
        realign_f32_f3  <= realign_f32_f2;
        d2fix_f3        <= d2fix_f2;
        abs_neg_f3      <= abs_neg_f2;
        zero_op_f3      <= zero_op_f2;
        zres_f3         <= zres_f2;
        sign_f3         <= sign_f2;
        exp_opd_f3      <= exp_opd_f2;
        frc_opa_f3      <= nxt_frc_opa_f3;
        frc_opb_f3      <= nxt_frc_opb_f3;
        sub_f3          <= sub_mux_f2;
        invalid_op_f3   <= invalid_excpt;
        infinity_op_f3  <= infinity_op_f2;
        nan_inv_op_f3   <= nan_inv_op_f2;
        out_format_f3   <= out_format_f2;
        cmpflags_f3     <= cmpflags_f2;
        f2i_overflow_f3 <= f2i_overflow_f2;
        ifz_f3          <= ifz_f2;
      end

`genif (NEON_0)
  always @(posedge clk)
    if ((~stall_wr_i | flush_ret_i) & enable_f2)
      begin
        neon_int_sel_f3       <= neon_int_sel_f2;
        neon_mux_sel_f3       <= neon_mux_sel_f2;
        neon_lu_ctl_f3        <= neon_lu_ctl_f2;
        neon_frc_opc_f3       <= neon_nxt_frc_opc_f3;
        neon_size_sel_f3      <= neon_size_sel_f2;
        neon_unsigned_op_f3   <= neon_unsigned_op_f2;
        neon_width_op_sel_f3  <= neon_width_op_sel_f2;
        neon_sat_op_sel_f3    <= neon_sat_op_sel_f2;
        neon_vtst_op_sel_f3   <= neon_vtst_op_sel_f2;
        neon_force_dn_fz_f3   <= neon_force_dn_fz_f2;
        neon_dec_exp_f3       <= neon_dec_exp_f2;
        neon_fp_cmp_sel_f3    <= cmp_op_sel_f2;
      end
`genendif

  //----------------------------------------------------------
  // Third execution stage f3
  //----------------------------------------------------------

`genif (NEON_0)

  assign neon_vrhadd_f3 = neon_width_op_sel_f3 == 3'b111;

  // ------------------------------------------------------
  // SIMD carry control bit generation
  // ------------------------------------------------------
  //
  // Depending on the type of operation being performed we need to interleave
  // SIMD control bits between the operands.  These control bits either
  // kill a carry (a=0, b=0), propagate a carry (a=1, b=0) or create a carry
  // (a=1, b=1).
  //
  //                 A6 A5 A4 A3 A2 A1 A0  B6 B5 B4 B3 B2 B1 B0
  // 64-bit Add       1  1  1  1  1  1  1   0  0  0  0  0  0  0
  // 32-bit Add       1  1  1  0  1  1  1   0  0  0  0  0  0  0
  // 16-bit Add       1  0  1  0  1  0  1   0  0  0  0  0  0  0
  // 8-bit Add        0  0  0  0  0  0  0   0  0  0  0  0  0  0
  //
  // 64-bit Sub       1  1  1  1  1  1  1   0  0  0  0  0  0  0
  // 32-bit Sub       1  1  1  1  1  1  1   0  0  0  1  0  0  0
  // 16-bit Sub       1  1  1  1  1  1  1   0  1  0  1  0  1  0
  // 8-bit Sub        1  1  1  1  1  1  1   1  1  1  1  1  1  1

  // Create SIMD bits
  always @*
    begin
      case (neon_size_sel_f3)
        2'b11 : // 64-bits
          neon_carry_f3 = {8{sub_f3 | neon_vrhadd_f3}} ^ 8'b11111110;
        2'b10 : // 32-bits
          neon_carry_f3 = {8{sub_f3 | neon_vrhadd_f3}} ^ 8'b11101110;
        2'b01 : // 16-bits
          neon_carry_f3 = {8{sub_f3 | neon_vrhadd_f3}} ^ 8'b10101010;
        2'b00 : // 8-bits
          neon_carry_f3 = {8{sub_f3 | neon_vrhadd_f3}};
        default :
          neon_carry_f3 = {8{1'bx}};
      endcase
    end

  // ------------------------------------------------------
  // SIMD Operand generation
  // ------------------------------------------------------
  //
  // Interleave the control bits to create the operands we
  // will pass into the 71-bit adder.

  assign neon_opa_f3 = {frc_opa_f3[63:56], neon_carry_f3[7],
                        frc_opa_f3[55:48], neon_carry_f3[6],
                        frc_opa_f3[47:40], neon_carry_f3[5],
                        frc_opa_f3[39:32], neon_carry_f3[4],
                        frc_opa_f3[31:24], neon_carry_f3[3],
                        frc_opa_f3[23:16], neon_carry_f3[2],
                        frc_opa_f3[15: 8], neon_carry_f3[1],
                        frc_opa_f3[7:0]};

  assign neon_opb_f3 = {frc_opb_f3[63:56], neon_vrhadd_f3,
                        frc_opb_f3[55:48], neon_vrhadd_f3,
                        frc_opb_f3[47:40], neon_vrhadd_f3,
                        frc_opb_f3[39:32], neon_vrhadd_f3,
                        frc_opb_f3[31:24], neon_vrhadd_f3,
                        frc_opb_f3[23:16], neon_vrhadd_f3,
                        frc_opb_f3[15: 8], neon_vrhadd_f3,
                        frc_opb_f3[7:0]};

`genendif

  //----------------------------------
  // Adder
  //----------------------------------

  assign f2i_f3 = out_format_f3[2];
  assign s2h_f3 = out_format_f3 == `CA5_FP_FORMAT_F16_B | out_format_f3 == `CA5_FP_FORMAT_F16_T;

  // Perform addition/subtraction
`genif (NEON_0)
  assign neon_res_f3 = neon_opa_f3 + ({71{sub_f3}}^neon_opb_f3) + neon_carry_f3[0];

  // Create result bus
  assign frc_res_f3 = {neon_res_f3[70:63], neon_res_f3[61:54],
                       neon_res_f3[52:45], neon_res_f3[43:36],
                       neon_res_f3[34:27], neon_res_f3[25:18],
                       neon_res_f3[16:9] , neon_res_f3[7:0]};

  // Halving result logic for VHADD, VHSUB, VRHADD
  always @*
    case (neon_size_sel_f3)
      2'b00:  // Signed 8-bit
        neon_halved_res_f3 = {neon_res_f3[71] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[70] ^ neon_opb_f3[70])),
                              neon_res_f3[70:64],
                              neon_res_f3[62] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[61] ^ neon_opb_f3[61])),
                              neon_res_f3[61:55],
                              neon_res_f3[53] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[52] ^ neon_opb_f3[52])),
                              neon_res_f3[52:46],
                              neon_res_f3[44] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[43] ^ neon_opb_f3[43])),
                              neon_res_f3[43:37],
                              neon_res_f3[35] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[34] ^ neon_opb_f3[34])),
                              neon_res_f3[34:28],
                              neon_res_f3[26] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[25] ^ neon_opb_f3[25])),
                              neon_res_f3[25:19],
                              neon_res_f3[17] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[16] ^ neon_opb_f3[16])),
                              neon_res_f3[16:10] ,
                              neon_res_f3[ 8] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[ 7] ^ neon_opb_f3[ 7])),
                              neon_res_f3[ 7: 1]};

      2'b01:  // Signed 16-bit
        neon_halved_res_f3 = {neon_res_f3[71] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[70] ^ neon_opb_f3[70])),
                              neon_res_f3[70:64], neon_res_f3[63], neon_res_f3[61:55],
                              neon_res_f3[53] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[52] ^ neon_opb_f3[52])),
                              neon_res_f3[52:46], neon_res_f3[45], neon_res_f3[43:37],
                              neon_res_f3[35] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[34] ^ neon_opb_f3[34])),
                              neon_res_f3[34:28], neon_res_f3[27], neon_res_f3[25:19],
                              neon_res_f3[17] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[16] ^ neon_opb_f3[16])),
                              neon_res_f3[16:10], neon_res_f3[ 9], neon_res_f3[ 7: 1]};

      2'b10:  // Signed 32-bit
        neon_halved_res_f3 = {neon_res_f3[71] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[70] ^ neon_opb_f3[70])),
                              neon_res_f3[70:64], neon_res_f3[63], neon_res_f3[61:55],
                              neon_res_f3[54], neon_res_f3[52:46], neon_res_f3[45], neon_res_f3[43:37],
                              neon_res_f3[35] ^ sub_f3 ^ (~neon_unsigned_op_f3 & (neon_opa_f3[34] ^ neon_opb_f3[34])),
                              neon_res_f3[34:28], neon_res_f3[27], neon_res_f3[25:19],
                              neon_res_f3[18], neon_res_f3[16:10], neon_res_f3[ 9], neon_res_f3[ 7: 1]};

      default:
        neon_halved_res_f3 = {64{1'bx}};
    endcase

  assign clz_input_f3 = neon_fp_cmp_sel_f3 | neon_int_sel_f3 ? (neon_width_op_sel_f3[2:1] == 2'b11) ? neon_halved_res_f3
                                                                                                    : frc_res_f3
                                                             :  realign_f32_f3 ? {frc_res_f3[27:0], 36'h000000000}
                                                                               : {frc_res_f3[56] & ~f2i_f3, frc_res_f3[55] | s2h_f3, frc_res_f3[54:0], 7'h00};
`genelse
  assign frc_res_f3 = {frc_opa_f3,2'b00,sub_f3} + ({57{sub_f3}}^frc_opb_f3) ;
  assign clz_input_f3 = realign_f32_f3 ? {frc_res_f3[27:0], 29'h00000000}
                                       : {frc_res_f3[56] & ~f2i_f3, frc_res_f3[55] | s2h_f3, frc_res_f3[54:0]};
`genendif

`genif (NEON_0)
  //----------------------------------
  // Polynomial mult unit
  //----------------------------------

  ca5dpu_neon_polymul u_polymul (
    // Inputs
    .frc_opa_f3_i           (frc_opa_f3[31:0]),
    .frc_opb_f3_i           (frc_opb_f3[31:0]),
    // Outputs
    .neon_polymul_res_f3_o  (neon_polymul_res_f3)
  );

  //----------------------------------
  // Logical unit
  //----------------------------------
  ca5dpu_neon_lu u_lu (
    // Inputs
    .neon_lu_ctl_f3_i   (neon_lu_ctl_f3),
    .frc_opa_f3_i       (frc_opa_f3),
    .frc_opb_f3_i       (frc_opb_f3),
    .neon_frc_opc_f3_i  (neon_frc_opc_f3),
    // Outputs
    .neon_lu_res_f3_o   (neon_lu_res_f3)
  );

  //----------------------------------
  // Saturation detect
  //----------------------------------
  always @*
    begin
      case (neon_unsigned_op_f3)
        1'b1: begin // unsigned
          neon_sat_detect_f3[ 1: 0] = {sub_f3, sub_f3 ^ neon_res_f3[ 8]};
          neon_sat_detect_f3[ 3: 2] = {sub_f3, sub_f3 ^ neon_res_f3[17]};
          neon_sat_detect_f3[ 5: 4] = {sub_f3, sub_f3 ^ neon_res_f3[26]};
          neon_sat_detect_f3[ 7: 6] = {sub_f3, sub_f3 ^ neon_res_f3[35]};
          neon_sat_detect_f3[ 9: 8] = {sub_f3, sub_f3 ^ neon_res_f3[44]};
          neon_sat_detect_f3[11:10] = {sub_f3, sub_f3 ^ neon_res_f3[53]};
          neon_sat_detect_f3[13:12] = {sub_f3, sub_f3 ^ neon_res_f3[62]};
          neon_sat_detect_f3[15:14] = {sub_f3, sub_f3 ^ neon_res_f3[71]};
        end
        1'b0: begin // signed
          neon_sat_detect_f3[ 1: 0] = frc_opa_f3[7]  != (frc_opb_f3[ 7] ^ sub_f3) ? 2'b00 : {2{frc_opa_f3[ 7] != neon_res_f3[ 7]}} & {frc_opa_f3[ 7], 1'b1};
          neon_sat_detect_f3[ 3: 2] = frc_opa_f3[15] != (frc_opb_f3[15] ^ sub_f3) ? 2'b00 : {2{frc_opa_f3[15] != neon_res_f3[16]}} & {frc_opa_f3[15], 1'b1};
          neon_sat_detect_f3[ 5: 4] = frc_opa_f3[23] != (frc_opb_f3[23] ^ sub_f3) ? 2'b00 : {2{frc_opa_f3[23] != neon_res_f3[25]}} & {frc_opa_f3[23], 1'b1};
          neon_sat_detect_f3[ 7: 6] = frc_opa_f3[31] != (frc_opb_f3[31] ^ sub_f3) ? 2'b00 : {2{frc_opa_f3[31] != neon_res_f3[34]}} & {frc_opa_f3[31], 1'b1};
          neon_sat_detect_f3[ 9: 8] = frc_opa_f3[39] != (frc_opb_f3[39] ^ sub_f3) ? 2'b00 : {2{frc_opa_f3[39] != neon_res_f3[43]}} & {frc_opa_f3[39], 1'b1};
          neon_sat_detect_f3[11:10] = frc_opa_f3[47] != (frc_opb_f3[47] ^ sub_f3) ? 2'b00 : {2{frc_opa_f3[47] != neon_res_f3[52]}} & {frc_opa_f3[47], 1'b1};
          neon_sat_detect_f3[13:12] = frc_opa_f3[55] != (frc_opb_f3[55] ^ sub_f3) ? 2'b00 : {2{frc_opa_f3[55] != neon_res_f3[61]}} & {frc_opa_f3[55], 1'b1};
          neon_sat_detect_f3[15:14] = frc_opa_f3[63] != (frc_opb_f3[63] ^ sub_f3) ? 2'b00 : {2{frc_opa_f3[63] != neon_res_f3[70]}} & {frc_opa_f3[63], 1'b1};
        end
        default:
          neon_sat_detect_f3 = {16{1'bx}};
      endcase
    end

  always @*
    begin
      case (neon_size_sel_f3)
        2'b00: // 8-bit elements
          neon_sat_dtect_ctl_f3 = neon_sat_detect_f3;
        2'b01: // 16-bit elements
          neon_sat_dtect_ctl_f3 = {{8{1'b0}}, neon_sat_detect_f3[15:14], neon_sat_detect_f3[11:10], neon_sat_detect_f3[7:6], neon_sat_detect_f3[3:2]};
        2'b10: // 32-bit elements
          neon_sat_dtect_ctl_f3 = {{12{1'b0}}, neon_sat_detect_f3[15:14], neon_sat_detect_f3[7:6]};
        2'b11: // 64-bit elements
          neon_sat_dtect_ctl_f3 = {{14{1'b0}}, neon_sat_detect_f3[15:14]};
        default:
          neon_sat_dtect_ctl_f3 = {16{1'bx}};
      endcase
    end

  // Process the saturation control from the shift module
  ca5dpu_neon_shift_sat u_neon_shift_sat (
    // Inputs
    .neon_size_sel_f3_i       (neon_size_sel_f3),
    .neon_width_op_sel_f3_i   (neon_width_op_sel_f3),
    .neon_sat_op_sel_f3_i     (neon_sat_op_sel_f3),
    .frc_opa_f3_i             (frc_opa_f3),
    .neon_frc_opc_f3_i        (neon_frc_opc_f3),
    .frc_res_f3_i             (frc_res_f3),
    // Outputs
    .neon_shift_sat_f3_o      (neon_shift_sat_f3)
  );

  // OR the saturation control signals from shift and add/sub operations
  // and pipe the final saturation detect signal to the next stage
  assign neon_sat_dtect_f3 = (neon_sat_op_sel_f3 == `CA5_NEON_SAT_ADD) ? neon_sat_dtect_ctl_f3
                                                                       : neon_shift_sat_f3;

  assign exp_sat_opd_f3 = (neon_sat_op_sel_f3 != `CA5_NEON_SAT_NONE) ?  neon_sat_dtect_f3 : {{5{1'b0}}, exp_opd_f3};

  // Count leading zeros 64 bits for integer Neon operations
  ca5dpu_fp_clz64 u_clz64 (
    .clz_input_f3_i     (clz_input_f3),
    .fp_clz_res_f3_o    (fp_clz_res_f3),
    .neon_clz_res_f3_o  (neon_clz_res_f3)
  );

  // MUX to select the result from adder, polymult or logical unit
  assign mux_res_f3 = {64{(neon_mux_sel_f3 == 2'b00)}} & clz_input_f3      |
                      {64{(neon_mux_sel_f3 == 2'b01)}} & neon_clz_res_f3     |
                      {64{(neon_mux_sel_f3 == 2'b10)}} & neon_polymul_res_f3 |
                      {64{(neon_mux_sel_f3 == 2'b11)}} & neon_lu_res_f3;

`genelse

  // Count leading zeros
  ca5dpu_fp_clz54 u_clz54(.opa(clz_input_f3[56:3]), .res(fp_clz_res_f3));
  assign mux_res_f3 = clz_input_f3;
  assign exp_sat_opd_f3 = exp_opd_f3;

`genendif

  // Comparison result flags
  assign fp_cmpflags_f3_o = cmpflags_f3;

  always @(posedge clk)
    if (~stall_wr_i | flush_ret_i)
      enable_f4      <= enable_f3;

  always @(posedge clk)
    if ((~stall_wr_i | flush_ret_i) & enable_f3)
      begin
        rnd_mode_f4     <= rnd_mode_f3;
        abs_neg_f4      <= abs_neg_f3;
        zero_op_f4      <= zero_op_f3;
        zres_f4         <= zres_f3;
        sign_f4         <= sign_f3;
        exp_opd_f4      <= exp_sat_opd_f3;
        clz_input_f4    <= mux_res_f3;
        clz_res_f4      <= fp_clz_res_f3;
        invalid_op_f4   <= invalid_op_f3;
        infinity_op_f4  <= infinity_op_f3;
        nan_inv_op_f4   <= nan_inv_op_f3;
        d2fix_f4        <= d2fix_f3;
        out_format_f4   <= out_format_f3;
        f2i_overflow_f4 <= f2i_overflow_f3;
        ifz_f4          <= ifz_f3;
      end

`genif (NEON_0)
  always @(posedge clk)
    if ((~stall_wr_i | flush_ret_i) & enable_f3)
      begin
        neon_int_sel_f4       <= neon_int_sel_f3;
        neon_mux_sel_f4       <= neon_mux_sel_f3;
        neon_size_sel_f4      <= neon_size_sel_f3;
        neon_unsigned_op_f4   <= neon_unsigned_op_f3;
        neon_width_op_sel_f4  <= neon_width_op_sel_f3;
        neon_sat_op_sel_f4    <= neon_sat_op_sel_f3;
        neon_vtst_op_sel_f4   <= neon_vtst_op_sel_f3;
        neon_force_dn_fz_f4   <= neon_force_dn_fz_f3;
        neon_fp_cmp_sel_f4    <= neon_fp_cmp_sel_f3;
        neon_dec_exp_f4       <= neon_dec_exp_f3;
      end
`genendif

  //----------------------------------------------------------
  // Fourth execution stage f4
  //----------------------------------------------------------

`genif (NEON_0)
  assign force_dn_fz_f4 = neon_force_dn_fz_f4;
`genelse
  assign force_dn_fz_f4 = 1'b0;
`genendif

`genif (NEON_0)

  // ---------------------------------------------------------
  // Produce final result from neon count leading zeros block
  // clz_byte[7:0] = clz_input_f4[39:32]
  // ---------------------------------------------------------

  always @*
    case (neon_size_sel_f4)
      2'b10: begin // 32-bits
        case (clz_input_f4[39:36])
          // Most significant '1' is in Byte7
          `def_1xxx : neon_clz_result_f4[63:32] = {27'h0000000, 2'b00, clz_input_f4[30:28]};
          // Most significant '1' is in Byte6
          `def_01xx : neon_clz_result_f4[63:32] = {27'h0000000, 2'b01, clz_input_f4[26:24]};
          // Most significant '1' is in Byte5
          `def_001x : neon_clz_result_f4[63:32] = {27'h0000000, 2'b10, clz_input_f4[22:20]};
          // Most significant '1' is in Byte4
          4'b0001   : neon_clz_result_f4[63:32] = {27'h0000000, 2'b11, clz_input_f4[18:16]};
          // Operand value is zero
          4'b0000   : neon_clz_result_f4[63:32] = {26'h0000000, 6'b100000};
          default   : neon_clz_result_f4[63:32] = {32{1'bx}};
        endcase
        case (clz_input_f4[35:32])
          // Most significant '1' is in Byte3
          `def_1xxx : neon_clz_result_f4[31:0] = {27'h0000000, 2'b00, clz_input_f4[14:12]};
          // Most significant '1' is in Byte2
          `def_01xx : neon_clz_result_f4[31:0] = {27'h0000000, 2'b01, clz_input_f4[10:8]};
          // Most significant '1' is in Byte1
          `def_001x : neon_clz_result_f4[31:0] = {27'h0000000, 2'b10, clz_input_f4[6:4]};
          // Most significant '1' is in Byte0
          4'b0001   : neon_clz_result_f4[31:0] = {27'h0000000, 2'b11, clz_input_f4[2:0]};
          // Operand value is zero
          4'b0000   : neon_clz_result_f4[31:0] = {26'h0000000, 6'b100000};
          default   : neon_clz_result_f4[31:0] = {32{1'bx}};
        endcase
      end
      2'b01: begin // 16-bits
        case (clz_input_f4[39:38])
          // Most significant '1' is in Byte7
          2'b10,
          2'b11  : neon_clz_result_f4[63:48] = {12'h000, 1'b0, clz_input_f4[30:28]};
          // Most significant '1' is in Byte6
          2'b01  : neon_clz_result_f4[63:48] = {12'h000, 1'b1, clz_input_f4[26:24]};
          2'b00  : neon_clz_result_f4[63:48] = {11'h000, 5'b10000};
          default: neon_clz_result_f4[63:48] = {16{1'bx}};
        endcase
        case (clz_input_f4[37:36])
          // Most significant '1' is in Byte5
          2'b10,
          2'b11  : neon_clz_result_f4[47:32] = {12'h000, 1'b0, clz_input_f4[22:20]};
          // Most significant '1' is in Byte4
          2'b01  : neon_clz_result_f4[47:32] = {12'h000, 1'b1, clz_input_f4[18:16]};
          2'b00  : neon_clz_result_f4[47:32] = {11'h000, 5'b10000};
          default: neon_clz_result_f4[47:32] = {16{1'bx}};
        endcase
        case (clz_input_f4[35:34])
          // Most significant '1' is in Byte3
          2'b10,
          2'b11  : neon_clz_result_f4[31:16] = {12'h000, 1'b0, clz_input_f4[14:12]};
          // Most significant '1' is in Byte2
          2'b01  : neon_clz_result_f4[31:16] = {12'h000, 1'b1, clz_input_f4[10:8]};
          2'b00  : neon_clz_result_f4[31:16] = {11'h000, 5'b10000};
          default: neon_clz_result_f4[31:16] = {16{1'bx}};
        endcase
        case (clz_input_f4[33:32])
          // Most significant '1' is in Byte1
          2'b10,
          2'b11  : neon_clz_result_f4[15:0]  = {12'h000, 1'b0, clz_input_f4[6:4]};
          // Most significant '1' is in Byte0
          2'b01  : neon_clz_result_f4[15:0]  = {12'h000, 1'b1, clz_input_f4[2:0]};
          2'b00  : neon_clz_result_f4[15:0]  = {11'h000, 5'b10000};
          default: neon_clz_result_f4[15:0]  = {16{1'bx}};
        endcase
      end
      2'b00: begin // 8-bits
        neon_clz_result_f4[63:56] = {4'b0000, ~clz_input_f4[39], clz_input_f4[30:28]};
        neon_clz_result_f4[55:48] = {4'b0000, ~clz_input_f4[38], clz_input_f4[26:24]};
        neon_clz_result_f4[47:40] = {4'b0000, ~clz_input_f4[37], clz_input_f4[22:20]};
        neon_clz_result_f4[39:32] = {4'b0000, ~clz_input_f4[36], clz_input_f4[18:16]};
        neon_clz_result_f4[31:24] = {4'b0000, ~clz_input_f4[35], clz_input_f4[14:12]};
        neon_clz_result_f4[23:16] = {4'b0000, ~clz_input_f4[34], clz_input_f4[10:8]};
        neon_clz_result_f4[15:8]  = {4'b0000, ~clz_input_f4[33], clz_input_f4[6:4]};
        neon_clz_result_f4[7:0]   = {4'b0000, ~clz_input_f4[32], clz_input_f4[2:0]};
      end
      default: neon_clz_result_f4 = {64{1'bx}};
    endcase

  //----------------------------------
  // Narrow result logic
  //----------------------------------

  // Copy the high-half or the low-half of the element
  always @*
    begin
      case (neon_size_sel_f4)
        2'b01: begin //  16-bit elements
          neon_narrow_res_f4 = neon_width_op_sel_f4[0] ? {clz_input_f4[63:56], clz_input_f4[47:40], clz_input_f4[31:24], clz_input_f4[15:8]}
                                                       : {clz_input_f4[55:48], clz_input_f4[39:32], clz_input_f4[23:16], clz_input_f4[7:0]};
        end
        2'b10: begin // 32-bit elements
          neon_narrow_res_f4 = neon_width_op_sel_f4[0] ? {clz_input_f4[63:48], clz_input_f4[31:16]}
                                                       : {clz_input_f4[47:32], clz_input_f4[15:0]};
        end
        2'b11: begin // 64-bit elements
          neon_narrow_res_f4 = neon_width_op_sel_f4[0] ? clz_input_f4[63:32] : clz_input_f4[31:0];
        end
        default:
          neon_narrow_res_f4 = {32{1'bx}};
      endcase
    end

  // Select the narrow result or the original from the previous stage
  // as an input to the saturation block
  // Double up if narrowing, as result can come from either half of 64-bit result,
  // depending on which half of a register is being written
  assign neon_sat_in_res_f4 = (neon_width_op_sel_f4[2:1]==2'b10) ? {neon_narrow_res_f4[31:0], neon_narrow_res_f4[31:0]} : clz_input_f4[63:0];

  //-------------------------------------
  // Logic for the VTST instruction
  //-------------------------------------

  //Compare each byte with zero
  assign neon_vtst_byte0_f4 = clz_input_f4[7:0]   == 8'h00;
  assign neon_vtst_byte1_f4 = clz_input_f4[15:8]  == 8'h00;
  assign neon_vtst_byte2_f4 = clz_input_f4[23:16] == 8'h00;
  assign neon_vtst_byte3_f4 = clz_input_f4[31:24] == 8'h00;
  assign neon_vtst_byte4_f4 = clz_input_f4[39:32] == 8'h00;
  assign neon_vtst_byte5_f4 = clz_input_f4[47:40] == 8'h00;
  assign neon_vtst_byte6_f4 = clz_input_f4[55:48] == 8'h00;
  assign neon_vtst_byte7_f4 = clz_input_f4[63:56] == 8'h00;

  always @*
    begin
      case (neon_size_sel_f4)
        2'b00: begin // 8-bit elements
          neon_vtst_res_f4 = {neon_vtst_byte7_f4, 1'b1, neon_vtst_byte6_f4, 1'b1, neon_vtst_byte5_f4, 1'b1, neon_vtst_byte4_f4, 1'b1,
                              neon_vtst_byte3_f4, 1'b1, neon_vtst_byte2_f4, 1'b1, neon_vtst_byte1_f4, 1'b1, neon_vtst_byte0_f4, 1'b1};
        end
        2'b01: begin // 16-bit elements
          neon_vtst_res_f4 = {{8{1'b0}}, neon_vtst_byte7_f4 & neon_vtst_byte6_f4, 1'b1, neon_vtst_byte5_f4 &  neon_vtst_byte4_f4, 1'b1,
                              neon_vtst_byte3_f4 & neon_vtst_byte2_f4, 1'b1, neon_vtst_byte1_f4 &  neon_vtst_byte0_f4, 1'b1};
        end
        2'b10: begin // 16-bit elements
          neon_vtst_res_f4 = {{12{1'b0}}, neon_vtst_byte7_f4 & neon_vtst_byte6_f4 & neon_vtst_byte5_f4 &  neon_vtst_byte4_f4, 1'b1,
                              neon_vtst_byte3_f4 & neon_vtst_byte2_f4 & neon_vtst_byte1_f4 &  neon_vtst_byte0_f4, 1'b1};
        end
        default:
          neon_vtst_res_f4 = {16{1'bx}};
      endcase
    end

  //-------------------------------------
  // Saturation result
  //-------------------------------------

  assign neon_sat_dtect_res_f4 = neon_vtst_op_sel_f4 ? neon_vtst_res_f4 : exp_opd_f4[15:0];

  // In case of narrow result the size element is decreased by one
  assign neon_dcr_size_sel_f4 = (neon_width_op_sel_f4[2:1] == 2'b10) ? neon_size_sel_f4 - 1'b1 : neon_size_sel_f4;

  assign neon_sat_unsigned_f4 = (neon_sat_op_sel_f4 == `CA5_NEON_SAT_SHF_UNSIGNED) ? 1'b1               :
                                (neon_sat_op_sel_f4 == `CA5_NEON_SAT_SHF_SIGNED)   ? 1'b0               :
                                                                                     neon_unsigned_op_f4;

  // Perform saturation
  // If saturation, it will saturate to the negative value or positive value else it
  // will remain unchanged. The result MSB for the unsigned case is the same with the
  // other bits while for the signed is the inverted value of the other bits.
  always @*
    begin
      case (neon_dcr_size_sel_f4)
        2'b00: begin // 8-bit elements
          neon_sat_flag_f4       = neon_sat_dtect_res_f4[14] | neon_sat_dtect_res_f4[12] | neon_sat_dtect_res_f4[10] | neon_sat_dtect_res_f4[ 8] |
                                   neon_sat_dtect_res_f4[ 6] | neon_sat_dtect_res_f4[ 4] | neon_sat_dtect_res_f4[ 2] | neon_sat_dtect_res_f4[ 0];
          neon_sat_res_f4[63:56] = neon_sat_dtect_res_f4[14] ? (neon_sat_dtect_res_f4[15] ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                             : neon_sat_in_res_f4[63:56];
          neon_sat_res_f4[55:48] = neon_sat_dtect_res_f4[12] ? (neon_sat_dtect_res_f4[13] ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                             : neon_sat_in_res_f4[55:48];
          neon_sat_res_f4[47:40] = neon_sat_dtect_res_f4[10] ? (neon_sat_dtect_res_f4[11] ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                             : neon_sat_in_res_f4[47:40];
          neon_sat_res_f4[39:32] = neon_sat_dtect_res_f4[8]  ? (neon_sat_dtect_res_f4[9]  ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                             : neon_sat_in_res_f4[39:32];
          neon_sat_res_f4[31:24] = neon_sat_dtect_res_f4[6]  ? (neon_sat_dtect_res_f4[7]  ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                             : neon_sat_in_res_f4[31:24];
          neon_sat_res_f4[23:16] = neon_sat_dtect_res_f4[4]  ? (neon_sat_dtect_res_f4[5]  ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                             : neon_sat_in_res_f4[23:16];
          neon_sat_res_f4[15:8]  = neon_sat_dtect_res_f4[2]  ? (neon_sat_dtect_res_f4[3]  ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                             : neon_sat_in_res_f4[15:8];
          neon_sat_res_f4[7:0]   = neon_sat_dtect_res_f4[0]  ? (neon_sat_dtect_res_f4[1]  ? {~neon_sat_unsigned_f4, {7{1'b0}}} : {neon_sat_unsigned_f4, {7{1'b1}}})
                                                             : neon_sat_in_res_f4[7:0];
        end
        2'b01: begin // 16-bit elements
          neon_sat_flag_f4       = neon_sat_dtect_res_f4[6] | neon_sat_dtect_res_f4[4] | neon_sat_dtect_res_f4[2] | neon_sat_dtect_res_f4[0];
          neon_sat_res_f4[63:48] = neon_sat_dtect_res_f4[6] ? (neon_sat_dtect_res_f4[7] ? {~neon_sat_unsigned_f4, {15{1'b0}}} : {neon_sat_unsigned_f4, {15{1'b1}}})
                                                            : neon_sat_in_res_f4[63:48];
          neon_sat_res_f4[47:32] = neon_sat_dtect_res_f4[4] ? (neon_sat_dtect_res_f4[5] ? {~neon_sat_unsigned_f4, {15{1'b0}}} : {neon_sat_unsigned_f4, {15{1'b1}}})
                                                            : neon_sat_in_res_f4[47:32];
          neon_sat_res_f4[31:16] = neon_sat_dtect_res_f4[2] ? (neon_sat_dtect_res_f4[3] ? {~neon_sat_unsigned_f4, {15{1'b0}}} : {neon_sat_unsigned_f4, {15{1'b1}}})
                                                            : neon_sat_in_res_f4[31:16];
          neon_sat_res_f4[15:0]  = neon_sat_dtect_res_f4[0] ? (neon_sat_dtect_res_f4[1] ? {~neon_sat_unsigned_f4, {15{1'b0}}} : {neon_sat_unsigned_f4, {15{1'b1}}})
                                                            : neon_sat_in_res_f4[15:0];
        end
        2'b10: begin // 32-bit elements
          neon_sat_flag_f4       = neon_sat_dtect_res_f4[2] | neon_sat_dtect_res_f4[0];
          neon_sat_res_f4[63:32] = neon_sat_dtect_res_f4[2] ? (neon_sat_dtect_res_f4[3] ? {~neon_sat_unsigned_f4, {31{1'b0}}} : {neon_sat_unsigned_f4, {31{1'b1}}})
                                                            : neon_sat_in_res_f4[63:32];
          neon_sat_res_f4[31:0]  = neon_sat_dtect_res_f4[0] ? (neon_sat_dtect_res_f4[1] ? {~neon_sat_unsigned_f4, {31{1'b0}}} : {neon_sat_unsigned_f4, {31{1'b1}}})
                                                            : neon_sat_in_res_f4[31:0];
        end
        2'b11: begin // 64-bit elements
          neon_sat_flag_f4       = neon_sat_dtect_res_f4[0];
          neon_sat_res_f4[63:0]  = neon_sat_dtect_res_f4[0] ? (neon_sat_dtect_res_f4[1] ? {~neon_sat_unsigned_f4, {63{1'b0}}} : {neon_sat_unsigned_f4, {63{1'b1}}})
                                                            : neon_sat_in_res_f4[63:0];
        end
        default: begin
          neon_sat_flag_f4       = 1'bx;
          neon_sat_res_f4[63:0]  = {64{1'bx}};
        end
      endcase
    end

`genendif

  assign f2i_f4 = out_format_f4[2];
  assign dp_op_sel_f4 = (out_format_f4 == `CA5_FP_FORMAT_F64);
  assign s2h_f4 = out_format_f4 == `CA5_FP_FORMAT_F16_B | out_format_f4 == `CA5_FP_FORMAT_F16_T;

`genif (NEON_0)
  // Move shift operand to low bits if single precision
  assign sh_op_f4 = {clz_input_f4[63:7], 4'h0};
`genelse
  // Move shift operand to low bits if single precision
  assign sh_op_f4 = {clz_input_f4, 4'h0};
`genendif

  // Check MSB bit of the significand is zero
  assign frc_res_msb_f4 = out_format_f4 == `CA5_FP_FORMAT_F64 ? sh_op_f4[59] :
                          out_format_f4 == `CA5_FP_FORMAT_F32 ? sh_op_f4[59] :
                                                                sh_op_f4[17];

  // Non zero exponent result
  assign zero_exp_f4 = (exp_opd_f4[10:0] == 0) & ~f2i_f4;

  // Round modes
  assign rnd_nrst_f4  = (rnd_mode_f4 == 0);
  assign rnd_pinfi_f4 = (rnd_mode_f4 == 1);
  assign rnd_ninfi_f4 = (rnd_mode_f4 == 2);
  assign rnd_zero_f4  = (rnd_mode_f4 == 3);

  // Perform normalization
  assign clz_less_f4 = (|exp_opd_f4[10:6]) | (clz_res_f4 <= exp_opd_f4[5:0]);

  // Shortcut calculation of top bit for timing
  assign shift_mode_f4[5] = clz_res_f4[5] & (|exp_opd_f4[10:5]);
  assign shift_mode_f4[4:0] = clz_less_f4 ? clz_res_f4[4:0] : (exp_opd_f4[4:0] | {{4{1'b0}}, zero_exp_f4});

  // Perform normalization shift
  assign shifted_frc_f4 = sh_op_f4 << shift_mode_f4;

  assign frc_sres_f4   = (out_format_f4 == `CA5_FP_FORMAT_F32) ? {29'h00000000, shifted_frc_f4[60:37]}
                                                               : shifted_frc_f4[60:8];

  assign round_bit_f4  = (out_format_f4 == `CA5_FP_FORMAT_F32) ?  shifted_frc_f4[36]   :  shifted_frc_f4[7];
  assign sticky_bit_f4 = (out_format_f4 == `CA5_FP_FORMAT_F32) ? |shifted_frc_f4[35:0] : |shifted_frc_f4[6:0];

  // Set increment exponent signal
  assign inc_exp_res_f4 = inc_frc_f4 & (s2h_f4 ? (&sh_op_f4[16:7])
                                               : (&frc_sres_f4[22:0])
                                                  & (~dp_op_sel_f4 | (&frc_sres_f4[52:23])));

  // Set the rounding control signals
  assign round_infinity_f4 = (rnd_pinfi_f4 & (~sign_f4 | f2i_f4)) | ((f2i_f4 ? rnd_zero_f4 : rnd_ninfi_f4) & sign_f4);
  assign ovf_to_inf_f4     = (rnd_nrst_f4 | round_infinity_f4) & ~(s2h_f4 & ahp_f1_i);

  // Adjust exponent result
  assign exp_nres_f4 = ~clz_less_f4 ? { {10{1'b0}}, zero_exp_f4 & frc_res_msb_f4}
                                    : exp_opd_f4[10:0] + 1'b1 - {5'b00000, clz_res_f4};

  // Check the guard, round and sticky bits for round to
  // infinity and round to nearest cases
  assign nzero_grt_bits_f4 = round_bit_f4 | sticky_bit_f4;

  // Check if the result is denormalised
  assign denorm_fz_f4 = (force_dn_fz_f4 | fpscr_fz_i) & (~|exp_nres_f4) & (~(zres_f4 | zero_op_f4))
                          & (out_format_f4 == `CA5_FP_FORMAT_F32 | out_format_f4 == `CA5_FP_FORMAT_F64);

  // Increment significand signal
  assign inc_frc_f4 = ~(denorm_fz_f4 & ~f2i_f4) &
                        (rnd_nrst_f4 & round_bit_f4 & (sticky_bit_f4 | frc_sres_f4[0]) |
                         round_infinity_f4 & (round_bit_f4 | sticky_bit_f4));

  // Compute result sign
  assign sign_res_f4 = (~((force_dn_fz_f4 | fpscr_dn_i) & ~(s2h_f4 & ahp_f1_i) & nan_inv_op_f4) | abs_neg_f4)
                       & ((~nan_inv_op_f4 & zres_f4) ? rnd_ninfi_f4 : sign_f4);

  // Compute zero result signal
  assign zero_out_f4 = zres_f4 | zero_op_f4 | nan_inv_op_f4 & s2h_f4 & ahp_f1_i;

  assign ovf_tmp_f4 = (out_format_f4 == `CA5_FP_FORMAT_F64 ? (&exp_nres_f4[10:1] & (exp_nres_f4[0] | inc_exp_res_f4)) :
                       out_format_f4 == `CA5_FP_FORMAT_F32 ? (&exp_nres_f4[ 7:1] & (exp_nres_f4[0] | inc_exp_res_f4)
                                                                | (|exp_nres_f4[10:8]))                               :
                                                             (&exp_nres_f4[ 4:1] & (ahp_f1_i ? (exp_nres_f4[0] & inc_exp_res_f4)
                                                                                             : (exp_nres_f4[0] | inc_exp_res_f4))
                                                                | (|exp_nres_f4[10:5])))
                        & ~nan_inv_op_f4;

  // Check if underflow flag is set
  assign undf_res_f4 = denorm_fz_f4 & ~nan_inv_op_f4 & ~infinity_op_f4;

  // For float-to-int, the shift value is always 1, so the reduction AND
  // can be completely calculated in F4.

  assign f2i_max_14_0_f4  = &sh_op_f4[21:7];
  assign f2i_max_30_15_f4 = &sh_op_f4[37:22];

  assign f2i_inc_frc_f4 = (rnd_nrst_f4 & sh_op_f4[6] & ((|sh_op_f4[5:0]) | sh_op_f4[7]) |
                           round_infinity_f4 & (|sh_op_f4[6:0]));

  // Precalculate the MSB of the float-to-int result after rounding
  assign f2i_msb_f4 = (out_format_f4 == `CA5_FP_FORMAT_S32 ||
                       out_format_f4 == `CA5_FP_FORMAT_U32) ? (sh_op_f4[38] ^ (f2i_max_30_15_f4 & f2i_max_14_0_f4 & f2i_inc_frc_f4))
                                                            : (sh_op_f4[22] ^ (                   f2i_max_14_0_f4 & f2i_inc_frc_f4));

  assign f2i_b32_f4 = sh_op_f4[39] ^ (sh_op_f4[38] & f2i_max_30_15_f4 & f2i_max_14_0_f4 & f2i_inc_frc_f4);

  assign f2i_signed_f4 = out_format_f4 == `CA5_FP_FORMAT_S32 || out_format_f4 == `CA5_FP_FORMAT_S16;

  assign f2i_pos_sat_f4 = f2i_f4 & (f2i_overflow_f4 ? ~(sign_res_f4 | nan_inv_op_f4) : f2i_signed_f4 ? (f2i_msb_f4 | f2i_b32_f4) & ~sign_f4
                                                                                                     :               f2i_b32_f4  & ~sign_f4);
  assign f2i_neg_sat_f4 = f2i_f4 & (f2i_overflow_f4 ?  (sign_res_f4 | nan_inv_op_f4) : f2i_signed_f4 ? ~f2i_msb_f4 & f2i_b32_f4  &  sign_f4
                                                                                                     :               f2i_b32_f4  &  sign_f4);

`genif (NEON_0)
  // MUX to select result output
  assign nfrc_sres_f4 = (out_format_f4 == `CA5_FP_FORMAT_F16_T &&
                         neon_width_op_sel_f4 == 3'b001)            ? { {32{1'b0}}, res_f5[15:0], frc_sres_f4[15:0]}  :
                        ~neon_int_sel_f4 & ~neon_fp_cmp_sel_f4      ? {clz_input_f4[63:53], frc_sres_f4}              :
                        (neon_mux_sel_f4 == 2'b01)                  ? neon_clz_result_f4                              :
                        (neon_sat_op_sel_f4 != `CA5_NEON_SAT_NONE)  ? neon_sat_res_f4                                 :
                                                                      neon_sat_in_res_f4;

`genelse
  assign nfrc_sres_f4 = frc_sres_f4[51:0];

`genendif

  always @(posedge clk)
    if ((~stall_wr_i | flush_ret_i) & enable_f4)
      begin
        zero_out_f5       <= zero_out_f4;
        sign_res_f5       <= sign_res_f4;
        exp_nres_f5       <= exp_nres_f4;
        frc_sres_f5       <= nfrc_sres_f4;
        inc_exp_res_f5    <= inc_exp_res_f4;
        inc_frc_f5        <= inc_frc_f4;
        raw_invalid_op_f5 <= invalid_op_f4;
        infinity_op_f5    <= infinity_op_f4;
        nan_inv_op_f5     <= nan_inv_op_f4;
        ovf_to_inf_f5     <= ovf_to_inf_f4;
        nzero_grt_bits_f5 <= nzero_grt_bits_f4;
        out_format_f5     <= out_format_f4;
        d2fix_f5          <= d2fix_f4;
        undf_res_f5       <= undf_res_f4;
        f2i_b32_f5        <= f2i_b32_f4;
        ovf_tmp_f5        <= ovf_tmp_f4;
        f2i_pos_sat_f5    <= f2i_pos_sat_f4;
        f2i_neg_sat_f5    <= f2i_neg_sat_f4;
        ifz_f5            <= ifz_f4;
      end

`genif (NEON_0)
  always @(posedge clk)
    if ((~stall_wr_i | flush_ret_i) & enable_f4)
      begin
        neon_int_sel_f5     <= neon_int_sel_f4;
        neon_fp_cmp_sel_f5  <= neon_fp_cmp_sel_f4;
        neon_sat_flag_f5    <= neon_sat_flag_f4;
        neon_dec_exp_f5     <= neon_dec_exp_f4;
      end
`genendif

  //----------------------------------------------------------
  // F5 stage
  //----------------------------------------------------------

  // Floating to integer conversion signal
  assign f2i_f5 = out_format_f5[2];
  assign s2h_f5 = out_format_f5 == `CA5_FP_FORMAT_F16_B | out_format_f5 == `CA5_FP_FORMAT_F16_T;

  // Not invalid, Nan or infinity operation
  assign nan_inv_inf_op = nan_inv_op_f5 & ~(s2h_f5 & ahp_f1_i) | infinity_op_f5;

`genif (NEON_0)
  assign dec_exp_res_f5 = neon_dec_exp_f5;
`genelse
  assign dec_exp_res_f5 = 1'b0;
`genendif

  // Increment exponent result if required
  assign exp_inc_res = exp_nres_f5 + inc_exp_res_f5 - dec_exp_res_f5;

  // Increment fraction result if required
  assign frc_inc_res = (inc_frc_f5 & ~nan_inv_op_f5) ? frc_sres_f5[51:0] + 1'b1
                                                     : frc_sres_f5[51:0];

  // Compute the inexact flag
  assign inexact_excpt = (ovf_tmp_f5 | nzero_grt_bits_f5) & ~nan_inv_inf_op & ~undf_res_f5;

  // Check if overflow flag is set
  assign ovf_res = ovf_tmp_f5 & ~nan_inv_inf_op;

  // AHP single-to-half operations return invalid operation rather than overflow exception
  assign invalid_op_f5 = raw_invalid_op_f5 | s2h_f5 & ahp_f1_i & ovf_res;

  // Check if there is an exception
  assign exc_res = (ovf_tmp_f5 & ovf_to_inf_f5) | (infinity_op_f5 & ~nan_inv_op_f5);

  // Compute final exponent result
  assign exp_res = {{10{nan_inv_inf_op | exc_res | ovf_tmp_f5}}, nan_inv_inf_op | exc_res | ovf_tmp_f5 & s2h_f5 & ahp_f1_i} |
                   ({{10{~zero_out_f5}}, ~(zero_out_f5 | (ovf_tmp_f5 & ~ovf_to_inf_f5))} & exp_inc_res);

  // Floating to integer conversion signals
  assign f2i_sign = f2i_neg_sat_f5 & ~nan_inv_op_f5 | f2i_b32_f5 & ~f2i_pos_sat_f5 & ~nan_inv_op_f5;

  // Compute final fraction result
  assign frc_res = {52{~(exc_res | undf_res_f5 | f2i_neg_sat_f5)}} & ({52{ovf_tmp_f5 | f2i_pos_sat_f5}} | frc_inc_res);

  // Single-precision result
  assign sp_res = {sign_res_f5, exp_res[7:0], frc_res[22:0]};

  // Double-precision result
  assign dp_res = {sign_res_f5, exp_res[10:0], frc_res[51:0]};

  always @*
  begin
    case (out_format_f5)
      `CA5_FP_FORMAT_F32: begin
        res_f5 = {sp_res, sp_res};
      end

      `CA5_FP_FORMAT_F64: begin
        res_f5 = dp_res;
      end

      `CA5_FP_FORMAT_F16_B: begin
        res_f5 = { frc_sres_f5[31:16],
                   sign_res_f5, exp_res[4:0], frc_res[9:0],
                   frc_sres_f5[31:16],
                   sign_res_f5, exp_res[4:0], frc_res[9:0] };
      end

      `CA5_FP_FORMAT_F16_T: begin
        res_f5 = { sign_res_f5, exp_res[4:0], frc_res[9:0],
                   frc_sres_f5[31:16],
                   sign_res_f5, exp_res[4:0], frc_res[9:0],
                   frc_sres_f5[31:16] };
      end

      `CA5_FP_FORMAT_U32: begin
        res_f5 = { {32{~d2fix_f5}} & frc_res[31:0],
                   frc_res[31:0]};
      end

      `CA5_FP_FORMAT_S32: begin
        res_f5 = { f2i_sign, d2fix_f5 ? {31{f2i_sign}} : frc_res[30:0],
                   f2i_sign, frc_res[30:0]};
      end

      `CA5_FP_FORMAT_U16: begin
        res_f5 = { 16'h0000, {16{~d2fix_f5}} & frc_res[15:0],
                   16'h0000, frc_res[15:0]};
      end

      `CA5_FP_FORMAT_S16: begin
        res_f5 = { {17{f2i_sign}}, d2fix_f5 ? {15{f2i_sign}} : frc_res[14:0],
                   {17{f2i_sign}}, frc_res[14:0]};
      end

      default:
        res_f5 = {64{1'bx}};
    endcase
  end

`genif (NEON_0)
  assign fad_data_f5_o                         =  neon_int_sel_f5 | neon_fp_cmp_sel_f5 ? frc_sres_f5 : res_f5;
  assign add_xflags_f5_o[`CA5_XFLAGS_QC_BITS]  =  neon_int_sel_f5 & neon_sat_flag_f5;
  assign add_xflags_f5_o[`CA5_XFLAGS_IDC_BITS] = ~neon_int_sel_f5 & ifz_f5;
  assign add_xflags_f5_o[`CA5_XFLAGS_IXC_BITS] = ~neon_int_sel_f5 & ~neon_fp_cmp_sel_f5 & inexact_excpt & ~f2i_pos_sat_f5 & ~f2i_neg_sat_f5 & ~invalid_op_f5;
  assign add_xflags_f5_o[`CA5_XFLAGS_IOC_BITS] = ~neon_int_sel_f5 & (invalid_op_f5 |  f2i_pos_sat_f5 |  f2i_neg_sat_f5);
  assign add_xflags_f5_o[`CA5_XFLAGS_OFC_BITS] = ~neon_int_sel_f5 & ~neon_fp_cmp_sel_f5 & ovf_res & ~invalid_op_f5;
  assign add_xflags_f5_o[`CA5_XFLAGS_UFC_BITS] = ~neon_int_sel_f5 & ~neon_fp_cmp_sel_f5 & (undf_res_f5 | exp_nres_f5 == 0 & nzero_grt_bits_f5 & ~f2i_f5);
`genelse
  assign fad_data_f5_o                         = res_f5;
  assign add_xflags_f5_o[`CA5_XFLAGS_IDC_BITS] = ifz_f5;
  assign add_xflags_f5_o[`CA5_XFLAGS_IXC_BITS] = inexact_excpt & ~f2i_pos_sat_f5 & ~f2i_neg_sat_f5 & ~invalid_op_f5;
  assign add_xflags_f5_o[`CA5_XFLAGS_IOC_BITS] = invalid_op_f5 |  f2i_pos_sat_f5 |  f2i_neg_sat_f5;
  assign add_xflags_f5_o[`CA5_XFLAGS_OFC_BITS] = ovf_res & ~invalid_op_f5;
  assign add_xflags_f5_o[`CA5_XFLAGS_UFC_BITS] = undf_res_f5 | exp_nres_f5 == 0 & nzero_grt_bits_f5 & ~f2i_f5;
`genendif

  assign add_xflags_f5_o[`CA5_XFLAGS_DZC_BITS] = 1'b0;

endmodule // ca5dpu_fp_alu
