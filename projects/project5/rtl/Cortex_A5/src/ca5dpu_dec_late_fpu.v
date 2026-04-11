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
//      Checked In          : $Date: 2009-11-13 17:42:18 +0000 (Fri, 13 Nov 2009) $
//
//      Revision            : $Revision: 123594 $
//
//      Release Information : CORTEX-A5-FPU-r0p1-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract: Issue-stage decoder for FPU instructions
//-----------------------------------------------------------------------------

`include "ca5dpu_params.v"

module ca5dpu_dec_late_fpu `DPU_PARAM_DECL (
  // ---------------------------------------------------------
  // Interface signals
  // ---------------------------------------------------------

  // -----------------------------
  // Inputs
  // -----------------------------

  input  wire [28:0]                          iq_instr_jfn_i,     // Instruction input
  input  wire [5:0]                           decoder_fsm_i,      // Current FSM state
  input  wire                                 instr_undef_iss_i,

  // -----------------------------
  // Outputs
  // -----------------------------

  output wire [`CA5_SEL_FML_A_W-1:0]          sel_fml_a_fpu_o,
  output wire [`CA5_SEL_FML_B_W-1:0]          sel_fml_b_fpu_o,
  output wire [`CA5_SEL_FML_C_W-1:0]          sel_fml_c_fpu_o,
  output wire [`CA5_SEL_FAD_A_W-1:0]          sel_fad_a_fpu_o,
  output wire [`CA5_SEL_FAD_B_W-1:0]          sel_fad_b_fpu_o,

  output reg  [`CA5_FP_PIPECTL_W-1:0]         fp_pipectl_fpu_o,

  output wire [`CA5_FP_CFLAG_SRC_W-1:0]       fp_cflag_src_fpu_o,
  output wire [`CA5_FP_XFLAG_SRC_W-1:0]       fp_xflag_src_fpu_o,
  output wire [`CA5_FP_SYSREG_ADDR_W-1:0]     fp_sysreg_addr_fpu_o,
  output wire                                 fp_sysreg_wen_fpu_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [(`CA5_FP_MUL_CTL_W-1):0]    fp_mul_ctl;
  reg  [(`CA5_FP_ADD_CTL_W-1):0]    fp_add_ctl;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [(`CA5_FP_CFLAG_SRC_W-1):0]  fp_cflag_src_fpu;
  wire [(`CA5_FP_XFLAG_SRC_W-1):0]  fp_xflag_src_fpu;
  wire                              fp_sysreg_wen_fpu;
  wire [2:0]                        add_in_format;
  wire [2:0]                        add_out_format;
  wire [1:0]                        add_negate;
  wire                              abs_neg_mov;
  wire                              add_cmp;
  wire                              add_qnan_exception;
  wire                              add_fix_point;
  wire                              mul_fused_mac;
  wire                              mul_accumulate;
  wire                              mul_precision;
  wire                              mul_divide;
  wire                              mul_sqrt;
  wire                              mul_negate;
  wire                              force_round_zero;
  wire                              force_round_nearest;

  // -----------------------------
  // Local parameters
  // -----------------------------

  localparam FPU_REG_CTL_W = 14;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire net_1, net_2, net_4,
         net_5, net_6, net_7, net_8, net_9, net_10, net_11, net_12, net_13,
         net_15, net_16, net_17, net_18, net_19, net_20, net_21, net_22,
         net_23, net_24, net_25, net_26, net_27, net_28, net_29, net_30,
         net_31, net_32, net_33, net_34, net_35, net_36, net_37, net_38,
         net_39, net_40, net_42, net_43, net_44, net_45, net_46, net_47,
         net_48, net_49, net_50, net_51, net_52, net_53, net_54, net_55,
         net_56, net_57, net_58, net_59, net_60, net_61, net_62, net_63,
         net_64, net_65, net_66, net_67, net_68, net_69, net_70, net_71,
         net_72, net_73, net_74, net_75, net_76, net_77, net_78, net_79,
         net_80, net_81, net_82, net_83, net_84, net_85, net_86, net_87,
         net_88, net_89, net_90, net_91, net_92, net_93, net_94, net_95,
         net_96, net_97, net_98, net_99, net_100, net_101, net_102, net_103,
         net_104, net_105, net_106, net_107, net_108, net_109, net_110,
         net_111, net_112, net_113, net_114, net_115, net_116, net_117,
         net_118, net_119, net_120, net_121, net_122, net_123, net_124,
         net_125, net_126, net_127, net_128, net_129, net_130, net_131,
         net_132, net_133, net_134, net_135, net_136, net_137, net_138,
         net_139, net_140, net_141, net_142, net_143, net_144, net_145,
         net_146, net_147;

  assign add_cmp = fp_cflag_src_fpu[1];
  assign fp_cflag_src_fpu[0] = fp_xflag_src_fpu[2];
  assign sel_fml_b_fpu_o[1] = 1'b0;
  assign sel_fad_b_fpu_o[1] = 1'b0;
  assign sel_fad_a_fpu_o[1] = 1'b0;
  assign net_1 = ~net_114;
  assign net_2 = ~net_44;
  assign net_4 = ~iq_instr_jfn_i[21];
  assign net_5 = ~iq_instr_jfn_i[20];
  assign net_6 = ~net_31;
  assign net_7 = ~iq_instr_jfn_i[19];
  assign net_8 = ~iq_instr_jfn_i[18];
  assign net_9 = ~iq_instr_jfn_i[17];
  assign net_10 = ~iq_instr_jfn_i[16];
  assign net_11 = ~iq_instr_jfn_i[8];
  assign net_12 = ~iq_instr_jfn_i[7];
  assign net_13 = ~iq_instr_jfn_i[4];
  assign sel_fml_c_fpu_o = ~(net_15 | net_16);
  assign net_15 = (net_11 | net_17);
  assign sel_fml_b_fpu_o[0] = (net_18 | net_19);
  assign net_19 = (net_20 & net_21);
  assign sel_fml_a_fpu_o = (net_22 | net_23);
  assign net_23 = (net_24 | net_18);
  assign net_18 = ~(iq_instr_jfn_i[4] | net_25);
  assign net_25 = ~(net_26 | net_27);
  assign net_27 = (iq_instr_jfn_i[25] & net_28);
  assign net_28 = ~(net_29 & net_30);
  assign net_30 = (iq_instr_jfn_i[6] | iq_instr_jfn_i[8]);
  assign net_24 = (net_31 & net_21);
  assign net_21 = (iq_instr_jfn_i[18] & net_32);
  assign net_32 = ~(iq_instr_jfn_i[8] | net_33);
  assign net_22 = ~(net_33 | net_34);
  assign net_34 = ~(net_35 & net_36);
  assign net_36 = (net_37 | net_38);
  assign sel_fad_b_fpu_o[0] = ~(net_39 & net_40);
  assign net_40 = (iq_instr_jfn_i[25] | net_147);
  assign net_39 = (net_42 & net_43);
  assign net_43 = (net_38 | net_44);
  assign net_42 = (net_45 & net_46);
  assign net_46 = ~(net_47 & net_9);
  assign net_45 = ~(iq_instr_jfn_i[21] & net_48);
  assign sel_fad_a_fpu_o[0] = (net_49 | net_50);
  assign net_50 = (net_51 | net_48);
  assign net_51 = (net_37 & net_47);
  assign net_47 = (iq_instr_jfn_i[18] & net_52);
  assign net_49 = ~(iq_instr_jfn_i[8] | net_53);
  assign net_53 = ~(net_54 | net_55);
  assign net_55 = (iq_instr_jfn_i[20] & net_56);
  assign net_56 = (net_57 | net_58);
  assign net_58 = ~(net_59 & net_60);
  assign net_60 = (net_33 | iq_instr_jfn_i[6]);
  assign net_57 = (net_61 & net_62);
  assign net_62 = (iq_instr_jfn_i[21] & iq_instr_jfn_i[25]);
  assign net_61 = (net_63 & iq_instr_jfn_i[16]);
  assign mul_precision = (iq_instr_jfn_i[8] & net_64);
  assign net_64 = (net_65 | net_66);
  assign net_66 = ~(net_17 | net_67);
  assign net_67 = ~(net_38 & net_35);
  assign mul_negate = (iq_instr_jfn_i[6] & net_65);
  assign net_65 = ~(net_29 | net_33);
  assign mul_divide = (mul_sqrt | net_68);
  assign net_68 = ~(iq_instr_jfn_i[20] | net_59);
  assign mul_sqrt = (net_69 & net_38);
  assign net_38 = (iq_instr_jfn_i[16] & net_70);
  assign mul_accumulate = (net_71 | mul_fused_mac);
  assign mul_fused_mac = ~(net_72 & net_73);
  assign net_73 = ~(iq_instr_jfn_i[23] & net_54);
  assign net_54 = (iq_instr_jfn_i[21] & net_74);
  assign net_74 = ~(iq_instr_jfn_i[20] | net_33);
  assign net_72 = (net_5 | net_59);
  assign net_59 = (iq_instr_jfn_i[21] | net_17);
  assign net_17 = ~(iq_instr_jfn_i[23] & iq_instr_jfn_i[25]);
  assign fp_xflag_src_fpu[1] = (net_75 | net_76);
  assign net_76 = (net_77 | net_78);
  assign net_77 = (net_52 & net_63);
  assign net_63 = (net_79 & net_8);
  assign net_75 = (net_2 & net_80);
  assign net_80 = (iq_instr_jfn_i[18] | net_81);
  assign net_81 = ~(net_7 | iq_instr_jfn_i[8]);
  assign fp_xflag_src_fpu[0] = ~(iq_instr_jfn_i[8] | net_82);
  assign net_82 = ~(net_71 | net_83);
  assign net_83 = ~(net_16 | net_33);
  assign net_16 = ~(iq_instr_jfn_i[21] ^ iq_instr_jfn_i[20]);
  assign net_71 = (net_48 & net_4);
  assign fp_sysreg_wen_fpu = (fp_xflag_src_fpu[2] | net_84);
  assign net_84 = (iq_instr_jfn_i[19] & net_85);
  assign fp_sysreg_addr_fpu_o[2] = (net_86 & net_6);
  assign fp_sysreg_addr_fpu_o[1] = (net_86 & net_87);
  assign net_87 = (iq_instr_jfn_i[17] | net_20);
  assign net_86 = (net_88 & net_89);
  assign net_89 = (iq_instr_jfn_i[20] | decoder_fsm_i[0]);
  assign fp_sysreg_addr_fpu_o[0] = (iq_instr_jfn_i[16] & net_90);
  assign net_90 = (net_88 & net_91);
  assign net_91 = (iq_instr_jfn_i[20] | net_92);
  assign net_92 = (decoder_fsm_i[0] & net_9);
  assign fp_xflag_src_fpu[2] = (iq_instr_jfn_i[16] & net_93);
  assign net_93 = (net_85 & net_9);
  assign net_85 = ~(iq_instr_jfn_i[20] | net_94);
  assign net_94 = ~(net_88 & decoder_fsm_i[0]);
  assign net_88 = (iq_instr_jfn_i[25] & net_95);
  assign net_95 = (iq_instr_jfn_i[4] & iq_instr_jfn_i[22]);
  assign force_round_zero = (add_out_format[2] & net_96);
  assign net_96 = (iq_instr_jfn_i[7] | iq_instr_jfn_i[17]);
  assign add_qnan_exception = (iq_instr_jfn_i[7] & fp_cflag_src_fpu[1]);
  assign add_out_format[1] = ~(net_97 & net_98);
  assign net_98 = ~(net_99 & net_12);
  assign net_99 = (iq_instr_jfn_i[17] & add_out_format[2]);
  assign net_97 = (net_10 | net_100);
  assign add_out_format[0] = ~(net_101 & net_102);
  assign net_102 = ~(iq_instr_jfn_i[8] & net_103);
  assign net_103 = (net_104 | net_78);
  assign net_104 = (net_52 & net_105);
  assign net_105 = (net_106 | net_107);
  assign net_107 = (net_108 | net_109);
  assign net_108 = ~(iq_instr_jfn_i[18] | net_70);
  assign net_70 = (iq_instr_jfn_i[7] & net_9);
  assign net_106 = (net_10 & net_9);
  assign net_101 = ~(net_110 & net_111);
  assign net_111 = (add_out_format[2] | net_112);
  assign net_112 = ~(net_9 | net_113);
  assign net_113 = (net_114 | net_115);
  assign net_115 = (iq_instr_jfn_i[19] | net_116);
  assign net_116 = ~(iq_instr_jfn_i[7] & net_117);
  assign net_117 = ~(iq_instr_jfn_i[8] | iq_instr_jfn_i[4]);
  assign add_out_format[2] = (iq_instr_jfn_i[18] & net_118);
  assign net_110 = ~(net_9 ^ net_10);
  assign add_negate[1] = ~(net_119 & net_120);
  assign net_120 = ~(net_121 & net_8);
  assign net_121 = (net_2 & net_122);
  assign net_122 = (net_123 | net_124);
  assign net_44 = ~(net_13 & net_52);
  assign net_119 = ~(net_26 & net_125);
  assign add_negate[0] = (iq_instr_jfn_i[20] & net_126);
  assign net_126 = ~(net_127 | net_33);
  assign net_33 = ~(net_13 & iq_instr_jfn_i[25]);
  assign net_127 = (iq_instr_jfn_i[21] & net_128);
  assign net_128 = ~(iq_instr_jfn_i[23] & net_129);
  assign net_129 = (net_35 & net_124);
  assign net_124 = (iq_instr_jfn_i[7] & net_37);
  assign net_35 = (iq_instr_jfn_i[6] & net_8);
  assign add_in_format[1] = (net_130 | net_131);
  assign net_131 = (force_round_nearest & net_12);
  assign force_round_nearest = (add_fix_point & net_8);
  assign add_in_format[0] = (net_132 | net_133);
  assign net_133 = (net_134 | net_135);
  assign net_135 = (iq_instr_jfn_i[8] & net_136);
  assign net_136 = (net_78 | net_137);
  assign net_137 = (net_52 & net_138);
  assign net_138 = ~(net_139 & net_140);
  assign net_140 = (net_10 | iq_instr_jfn_i[7]);
  assign net_139 = ~(iq_instr_jfn_i[18] | net_20);
  assign net_20 = ~(iq_instr_jfn_i[19] | iq_instr_jfn_i[16]);
  assign net_78 = (net_29 & net_48);
  assign net_48 = (net_13 & net_26);
  assign net_26 = ~(iq_instr_jfn_i[23] | iq_instr_jfn_i[24]);
  assign net_134 = (iq_instr_jfn_i[19] & net_141);
  assign net_141 = (iq_instr_jfn_i[16] & net_142);
  assign net_132 = ~(net_143 & net_144);
  assign net_144 = ~(net_130 & iq_instr_jfn_i[7]);
  assign net_130 = ~(iq_instr_jfn_i[16] | net_100);
  assign net_100 = ~(net_142 & net_79);
  assign net_79 = ~(iq_instr_jfn_i[19] | net_9);
  assign net_143 = ~(add_in_format[2] & net_145);
  assign add_in_format[2] = (iq_instr_jfn_i[19] & net_69);
  assign add_fix_point = (iq_instr_jfn_i[17] & net_118);
  assign net_118 = ~(net_7 | net_114);
  assign fp_cflag_src_fpu[1] = (net_1 & net_109);
  assign net_109 = (iq_instr_jfn_i[18] & net_31);
  assign abs_neg_mov = (net_69 & net_146);
  assign net_146 = (net_37 | net_123);
  assign net_123 = (iq_instr_jfn_i[16] & net_145);
  assign net_145 = ~(iq_instr_jfn_i[7] | iq_instr_jfn_i[17]);
  assign net_37 = (net_31 & net_10);
  assign net_31 = (net_7 & net_9);
  assign net_69 = (net_13 & net_142);
  assign net_142 = (net_8 & net_1);
  assign net_114 = ~(iq_instr_jfn_i[23] & net_52);
  assign net_52 = (iq_instr_jfn_i[25] & net_125);
  assign net_125 = (net_29 & iq_instr_jfn_i[6]);
  assign net_29 = (iq_instr_jfn_i[21] & iq_instr_jfn_i[20]);
  assign net_147 = ~(net_26 & iq_instr_jfn_i[20]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // Do this in an always block to allow extra signals to be added to fp_pipectl
  // without requiring decoder changes
  always @*
  begin
    fp_mul_ctl        = {`CA5_FP_MUL_CTL_W{1'b0}};
    fp_add_ctl        = {`CA5_FP_ADD_CTL_W{1'b0}};
    fp_pipectl_fpu_o  = {`CA5_FP_PIPECTL_W{1'b0}};

    fp_mul_ctl[`CA5_FP_MUL_FUSED_MAC_BITS]  = mul_fused_mac;
    fp_mul_ctl[`CA5_FP_MUL_ACCUMULATE_BITS] = (mul_fused_mac & mul_precision) ? add_negate[0]
                                                                          : mul_accumulate;
    fp_mul_ctl[`CA5_FP_MUL_PRECISION_BITS]  = mul_precision;
    fp_mul_ctl[`CA5_FP_MUL_DIVIDE_BITS]     = mul_divide;
    fp_mul_ctl[`CA5_FP_MUL_NEG_SQRT_BITS]   = mul_sqrt | mul_negate;

    fp_add_ctl[`CA5_FP_ADD_IN_FORMAT_BITS]   = add_in_format;
    fp_add_ctl[`CA5_FP_ADD_OUT_FORMAT_BITS]  = add_out_format;
    fp_add_ctl[`CA5_FP_ADD_NEGATE_BITS]      = add_negate;
    fp_add_ctl[`CA5_FP_ADD_ABS_NEG_BITS]     = abs_neg_mov;
    fp_add_ctl[`CA5_FP_ADD_CMP_BITS]         = add_cmp;
    fp_add_ctl[`CA5_FP_ADD_QNAN_EXCEP_BITS]  = add_qnan_exception;
    fp_add_ctl[`CA5_FP_ADD_FIXED_POINT_BITS] = add_fix_point;

    fp_pipectl_fpu_o[`CA5_FP_PIPECTL_FORCE_RZ_BITS] = force_round_zero;
    fp_pipectl_fpu_o[`CA5_FP_PIPECTL_FORCE_RN_BITS] = force_round_nearest;

    fp_pipectl_fpu_o[`CA5_FP_PIPECTL_MUL_CTL_BITS]  = fp_mul_ctl;
    fp_pipectl_fpu_o[`CA5_FP_PIPECTL_ADD_CTL_BITS]  = fp_add_ctl;
  end

  // ------------------------------------------------------
  // Output aliasing
  // ------------------------------------------------------

  // Force signals to defaults if a nop/undefined instruction occurs
  assign fp_cflag_src_fpu_o         = instr_undef_iss_i ? {`CA5_FP_CFLAG_SRC_W{1'b0}} : fp_cflag_src_fpu;
  assign fp_xflag_src_fpu_o         = instr_undef_iss_i ? {`CA5_FP_XFLAG_SRC_W{1'b0}} : fp_xflag_src_fpu;
  assign fp_sysreg_wen_fpu_o        = instr_undef_iss_i ? 1'b0                        : fp_sysreg_wen_fpu;

endmodule // ca5dpu_dec_late_fpu
