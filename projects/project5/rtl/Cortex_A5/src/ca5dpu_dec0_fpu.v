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
// Abstract: Decoder for FPU instructions
//-----------------------------------------------------------------------------

`include "ca5dpu_params.v"

module ca5dpu_dec0_fpu `DPU_PARAM_DECL (
  // ---------------------------------------------------------
  // Interface signals
  // ---------------------------------------------------------

  // -----------------------------
  // Inputs
  // -----------------------------

  input  wire [28:0]                      iq_instr_jfn_i,     // Instruction input
  input  wire [5:0]                       decoder_fsm_i,      // Current FSM state
  input  wire [5:0]                       lsm_state_i,
  input  wire                             usr_de_i,           // User mode
  input  wire [1:0]                       fpudis_i,           // Coprocessor Access Register
  input  wire                             d32dis_i,           // D32DIS bit from CPACR
  input  wire                             fp_sysreg_vector_f5_i,
  input  wire                             fp_sysreg_en_f5_i,

  // -----------------------------
  // Outputs
  // -----------------------------

  output wire                             rf_rd_en_r0_fpu_o,
  output wire                             rf_rd_en_r2_fpu_o,
  output wire [3:0]                       rf_rd_vaddr_r0_fpu_o,
  output wire [3:0]                       rf_rd_vaddr_r2_fpu_o,
  output wire [`CA5_RF_RD_NEED_W-1:0]     rf_rd_need_r0_fpu_o,
  output wire [`CA5_RF_RD_NEED_W-1:0]     rf_rd_need_r1_fpu_o,
  output wire [2:1]                       rf_rd_need_r2_fpu_o,
  output wire                             rf_wr_en_w0_fpu_o,
  output wire                             rf_wr_en_w1_fpu_o,
  output wire [3:0]                       rf_wr_vaddr_w0_fpu_o,
  output wire [3:0]                       rf_wr_vaddr_w1_fpu_o,
  output wire [3:0]                       rf_wr_src_fpu_o,
  output wire [`CA5_RF_WR_WHEN_W-1:0]     rf_wr_when_w0_fpu_o,
  output wire [`CA5_RF_WR_WHEN_W-1:0]     rf_wr_when_w1_fpu_o,
  output wire [1:0]                       rf_rd_en_fr0_fpu_o,
  output wire [1:0]                       rf_rd_en_fr1_fpu_o,
  output wire [1:0]                       rf_rd_en_fr2_fpu_o,
  output wire [`CA5_FP_RF_ADDR_W-1:0]     rf_rd_addr_fr0_fpu_o,
  output wire [`CA5_FP_RF_ADDR_W-1:0]     rf_rd_addr_fr1_fpu_o,
  output wire [`CA5_FP_RF_ADDR_W-1:0]     rf_rd_addr_fr2_fpu_o,
  output wire [1:0]                       rf_rd_need_fr0_fpu_o,
  output wire [1:0]                       rf_rd_need_fr1_fpu_o,
  output wire [1:0]                       rf_rd_need_fr2_fpu_o,
  output wire [1:0]                       rf_wr_en_fw0_fpu_o,
  output wire [`CA5_FP_RF_ADDR_W-1:0]     rf_wr_addr_fw0_fpu_o,
  output wire [`CA5_RF_FWR_SRC_W-1:0]     rf_wr_src_fw0_fpu_o,
  output wire                             rf_wr_when_fw0_fpu_o,
  output wire [`CA5_SEL_SHF_A_W-1:0]      dp_data_a_sel_fpu_o,
  output wire [`CA5_SEL_SHF_B_W-1:0]      dp_data_b_sel_fpu_o,
  output wire [`CA5_SEL_SHF_C_W-1:0]      dp_data_c_sel_fpu_o,
  output wire [`CA5_SEL_DCU_A_W-1:0]      agu_data_a_sel_fpu_o,
  output wire [`CA5_SEL_DCU_B_W-1:0]      agu_data_b_sel_fpu_o,
  output wire [`CA5_SEL_STR_S_W-1:0]      str_data_sel_fpu_o,
  output wire [`CA5_EX_PIPE_W-1:0]        ex_pipe_fpu_o,
  output reg  [`CA5_IMM_DATA_W-1:0]       imm_data_fpu_o,
  output wire [`CA5_DP_PIPECTL_W-1:0]     dp_pipectl_fpu_o,
  output wire                             req_strict_algn_fpu_o,
  output wire [2:0]                       algn_size_fpu_o,
  output wire                             wd_align_pc_fpu_o,
  output wire                             ls_store_fpu_o,
  output wire [`CA5_LS_INSTR_TYPE_W-1:0]  ls_instr_type_fpu_o,
  output wire [1:0]                       ls_size_fpu_o,
  output wire [5:0]                       ls_length_fpu_o,
  output wire                             agu_sub_b_fpu_o,
  output wire                             no_interrupt_fpu_o,
  output wire [`CA5_FP_EX_PIPE_W-1:0]     fp_ex_pipe_fpu_o,
  output wire [5:0]                       nxt_lsm_state_fpu_o,
  output wire [5:0]                       psr_wr_en_fpu_o,
  output wire [3:0]                       psr_wr_src_fpu_o,
  output wire [`CA5_INSTR_TYPE_W-1:0]     instr_type_fpu_o,
  output wire                             head_instr_fpu_o,
  output wire                             end_instr_fpu_o,
  output wire [5:0]                       nxt_decoder_fsm_fpu_o,
  output wire                             instr_undef_fpu_o,
  output wire                             instr_fmstat_fpu_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [(`CA5_MAC_ISS_CTL_W-1):0] mac_iss_ctl;
  reg  [(`CA5_ALU_EX1_CTL_W-1):0] alu_ex1_ctl;
  reg  [(`CA5_DP_EX2_CTL_W-1):0]  dp_ex2_ctl;
  reg  [(`CA5_DP_WR_CTL_W-1):0]   dp_wr_ctl;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                            head_instr_fpu;
  wire                            end_instr_fpu;
  wire [4:0]                      ex_pipe_fpu;
  wire                            fp_vlsm_fpu;
  wire                            fp_undef_if_vector;
  wire                            fp_sysreg_priv;
  wire [1:0]                      ex2_ctl_flag_set_fpu;
  wire [(`CA5_ALU_OP_COMP_W-1):0] ex2_ctl_op_comp_fpu;
  wire [(`CA5_LU_CTL_W-1):0]      ex2_ctl_au_carry_lu_fpu;
  wire [5:0]                      psr_wr_en_fpu;
  wire [4:0]                      imm_sel_fpu;
  wire [1:0]                      fp_ex_pipe_fpu;
  wire [5:0]                      ls_length;
  wire [5:0]                      ls_length_lsm;
  wire [5:0]                      ls_length_fpu;
  wire [5:0]                      nxt_decoder_fsm;
  wire [5:0]                      nxt_decoder_fsm_lsm;
  wire [5:0]                      nxt_decoder_fsm_fpu;
  wire [5:0]                      lsm_regnum;
  wire [7:0]                      lsm_num_sp_regs;
  wire [5:0]                      lsm_firstreg;
  wire [6:0]                      lsm_lastreg;
  wire                            lsm_undef;
  wire                            set_19_16_i;
  wire                            set_15_12_i;
  wire                            one_cycle_vfp_lsm_i;
  wire                            first_cycle;
  wire                            last_cycle;
  wire [2:0]                      rf_rd_ctl_r0_fpu;
  wire [2:0]                      rf_rd_ctl_r1_fpu;
  wire [2:0]                      rf_rd_ctl_r2_fpu;
  wire [2:0]                      rf_wr_ctl_w0_fpu;
  wire [2:0]                      rf_wr_ctl_w1_fpu;
  wire [13:0]                     rf_rd_ctl_fr0_fpu;
  wire [13:0]                     rf_rd_ctl_fr1_fpu;
  wire [13:0]                     rf_rd_ctl_fr2_fpu;
  wire [13:0]                     rf_wr_ctl_fw0_fpu;
  wire [4:0]                      raw_rf_rd_addr_fr0_fpu;
  wire [4:0]                      raw_rf_rd_addr_fr1_fpu;
  wire [4:0]                      raw_rf_rd_addr_fr2_fpu;
  wire [4:0]                      raw_rf_wr_addr_fw0_fpu;
  wire [1:0]                      rf_wr_en_fw0_fpu;
  wire                            cpacr_undef;
  wire                            fpexc_undef;
  wire                            priv_undef;
  wire                            d32_undef;
  wire                            vector_undef;
  wire                            instr_undef;

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
  // Input signals for espresso equations (non-registered)
  // ------------------------------------------------------

  assign set_19_16_i = iq_instr_jfn_i[19:16] == 4'b1111;
  assign set_15_12_i = iq_instr_jfn_i[15:12] == 4'b1111;

  assign one_cycle_vfp_lsm_i = iq_instr_jfn_i[7:0] == 8'h01;

  assign last_cycle = decoder_fsm_i[5:1] == 5'b00001;

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire         net_1, net_2, net_3, net_4, net_5, net_6, net_7, net_8, net_9, net_10,
         net_11, net_13, net_14, net_15, net_16, net_17, net_18, net_19,
         net_20, net_22, net_23, net_24, net_25, net_26, net_27, net_28,
         net_29, net_30, net_31, net_32, net_33, net_34, net_35, net_36,
         net_37, net_38, net_39, net_40, net_41, net_42, net_43, net_44,
         net_45, net_46, net_47, net_48, net_49, net_50, net_51, net_52,
         net_53, net_54, net_55, net_56, net_57, net_58, net_59, net_60,
         net_61, net_62, net_63, net_64, net_65, net_66, net_67, net_68,
         net_69, net_70, net_71, net_72, net_73, net_74, net_75, net_76,
         net_77, net_78, net_79, net_80, net_81, net_82, net_83, net_84,
         net_85, net_86, net_87, net_88, net_89, net_90, net_91, net_92,
         net_93, net_94, net_95, net_96, net_97, net_98, net_99, net_100,
         net_101, net_102, net_103, net_104, net_105, net_106, net_107,
         net_108, net_109, net_110, net_111, net_112, net_113, net_114,
         net_115, net_116, net_117, net_118, net_119, net_120, net_121,
         net_122, net_123, net_124, net_125, net_126, net_127, net_128,
         net_129, net_130, net_131, net_132, net_133, net_134, net_135,
         net_136, net_137, net_138, net_139, net_140, net_141, net_142,
         net_143, net_144, net_145, net_146, net_147, net_148, net_149,
         net_150, net_151, net_152, net_153, net_154, net_155, net_156,
         net_157, net_158, net_159, net_160, net_161, net_162, net_163,
         net_164, net_165, net_166, net_167, net_168, net_169, net_170,
         net_171, net_172, net_173, net_174, net_175, net_176, net_177,
         net_178, net_179, net_180, net_181, net_182, net_183, net_184,
         net_185, net_186, net_187, net_188, net_189, net_190, net_191,
         net_192, net_193, net_194, net_195, net_196, net_197, net_198,
         net_199, net_200, net_201, net_202, net_203, net_204, net_205,
         net_206, net_207, net_208, net_209, net_210, net_211, net_212,
         net_213, net_214, net_215, net_216, net_217, net_218, net_219,
         net_220, net_221, net_222, net_223, net_224, net_225, net_226,
         net_227, net_228, net_229, net_230, net_231, net_232, net_233,
         net_234, net_235, net_236, net_237, net_238, net_239, net_240,
         net_241, net_242, net_243, net_244, net_245, net_246, net_247,
         net_248, net_249, net_250, net_251, net_252, net_253, net_254,
         net_255, net_256, net_257, net_258, net_259, net_260, net_261,
         net_262, net_263, net_264, net_265, net_266, net_267, net_268,
         net_269, net_270, net_271, net_272, net_273, net_274, net_275,
         net_276, net_277, net_278, net_279, net_280, net_281, net_282,
         net_283, net_284, net_285, net_286, net_287, net_288, net_289,
         net_290, net_291, net_292, net_293, net_294, net_295, net_296,
         net_297, net_298, net_299, net_300, net_301, net_302, net_303,
         net_304, net_305, net_306, net_307, net_308, net_309, net_310,
         net_311, net_312, net_313, net_314, net_315, net_316, net_317,
         net_318, net_319, net_320, net_321, net_322, net_323, net_324,
         net_325, net_326, net_327, net_328, net_329, net_330, net_331,
         net_332, net_333, net_334, net_335, net_336, net_337, net_338,
         net_339, net_340, net_341, net_342, net_343, net_344, net_345,
         net_346, net_347, net_348, net_349, net_350, net_351, net_352,
         net_353, net_354, net_355, net_356, net_357, net_358, net_359,
         net_360, net_361, net_362, net_363, net_364, net_365, net_366,
         net_367, net_368, net_369, net_370, net_371, net_372, net_373,
         net_374, net_375, net_376, net_377, net_378, net_379, net_380,
         net_381, net_382, net_383, net_384, net_385, net_386, net_387,
         net_388, net_389, net_390, net_391, net_392, net_393, net_394,
         net_395, net_396, net_397, net_398, net_399, net_400, net_401,
         net_402, net_403, net_404, net_405, net_406, net_407, net_408;

  assign rf_rd_need_r0_fpu_o[1] = rf_rd_need_r0_fpu_o[2];
  assign rf_rd_ctl_r0_fpu[0] = rf_rd_need_r0_fpu_o[2];
  assign rf_rd_need_r0_fpu_o[0] = rf_rd_need_r0_fpu_o[2];
  assign dp_data_a_sel_fpu_o[0] = rf_wr_ctl_w1_fpu[0];
  assign dp_data_a_sel_fpu_o[1] = rf_wr_src_fpu_o[2];
  assign rf_wr_ctl_w1_fpu[1] = rf_wr_src_fpu_o[1];
  assign rf_wr_when_w0_fpu_o[0] = rf_wr_when_w0_fpu_o[1];
  assign rf_wr_ctl_w0_fpu[1] = rf_wr_when_w0_fpu_o[1];
  assign rf_wr_when_w1_fpu_o[0] = rf_wr_when_w1_fpu_o[1];
  assign rf_rd_ctl_fr0_fpu[4] = rf_rd_ctl_fr1_fpu[5];
  assign fp_ex_pipe_fpu[1] = rf_rd_need_fr0_fpu_o[0];
  assign rf_rd_need_fr1_fpu_o[0] = rf_rd_need_fr1_fpu_o[1];
  assign rf_rd_need_fr2_fpu_o[0] = rf_rd_need_fr2_fpu_o[1];
  assign dp_data_b_sel_fpu_o[0] = dp_data_b_sel_fpu_o[1];
  assign ex2_ctl_au_carry_lu_fpu[0] = ex2_ctl_op_comp_fpu[1];
  assign ls_size_fpu_o[1] = wd_align_pc_fpu_o;
  assign ls_instr_type_fpu_o[1] = wd_align_pc_fpu_o;
  assign algn_size_fpu_o[1] = wd_align_pc_fpu_o;
  assign ex_pipe_fpu[4] = wd_align_pc_fpu_o;
  assign ls_instr_type_fpu_o[3] = wd_align_pc_fpu_o;
  assign psr_wr_src_fpu_o[1] = psr_wr_src_fpu_o[2];
  assign psr_wr_en_fpu[1] = psr_wr_src_fpu_o[2];
  assign instr_fmstat_fpu_o = psr_wr_src_fpu_o[2];
  assign ex2_ctl_flag_set_fpu[1] = psr_wr_src_fpu_o[2];
  assign psr_wr_en_fpu[0] = psr_wr_src_fpu_o[2];
  assign psr_wr_en_fpu[3] = psr_wr_src_fpu_o[2];
  assign str_data_sel_fpu_o[2] = 1'b0;
  assign rf_wr_src_fw0_fpu_o[3] = 1'b0;
  assign rf_wr_ctl_w1_fpu[2] = 1'b0;
  assign rf_wr_ctl_w0_fpu[2] = 1'b0;
  assign rf_wr_ctl_w0_fpu[0] = 1'b0;
  assign rf_wr_ctl_fw0_fpu[11] = 1'b0;
  assign rf_wr_ctl_fw0_fpu[10] = 1'b0;
  assign rf_rd_need_r2_fpu_o[2] = 1'b0;
  assign rf_rd_need_r2_fpu_o[1] = 1'b0;
  assign rf_rd_need_r1_fpu_o[2] = 1'b0;
  assign rf_rd_need_r1_fpu_o[1] = 1'b0;
  assign rf_rd_need_r1_fpu_o[0] = 1'b0;
  assign rf_rd_ctl_r2_fpu[2] = 1'b0;
  assign rf_rd_ctl_r1_fpu[2] = 1'b0;
  assign rf_rd_ctl_r1_fpu[1] = 1'b0;
  assign rf_rd_ctl_r1_fpu[0] = 1'b0;
  assign rf_rd_ctl_r0_fpu[2] = 1'b0;
  assign rf_rd_ctl_r0_fpu[1] = 1'b0;
  assign rf_rd_ctl_fr2_fpu[9] = 1'b0;
  assign rf_rd_ctl_fr2_fpu[8] = 1'b0;
  assign rf_rd_ctl_fr2_fpu[7] = 1'b0;
  assign rf_rd_ctl_fr2_fpu[6] = 1'b0;
  assign rf_rd_ctl_fr2_fpu[5] = 1'b0;
  assign rf_rd_ctl_fr2_fpu[4] = 1'b0;
  assign rf_rd_ctl_fr2_fpu[3] = 1'b0;
  assign rf_rd_ctl_fr2_fpu[13] = 1'b0;
  assign rf_rd_ctl_fr1_fpu[9] = 1'b0;
  assign rf_rd_ctl_fr1_fpu[7] = 1'b0;
  assign rf_rd_ctl_fr1_fpu[6] = 1'b0;
  assign rf_rd_ctl_fr1_fpu[4] = 1'b0;
  assign rf_rd_ctl_fr1_fpu[1] = 1'b0;
  assign rf_rd_ctl_fr1_fpu[13] = 1'b0;
  assign rf_rd_ctl_fr1_fpu[11] = 1'b0;
  assign rf_rd_ctl_fr0_fpu[5] = 1'b0;
  assign rf_rd_ctl_fr0_fpu[3] = 1'b0;
  assign rf_rd_ctl_fr0_fpu[12] = 1'b0;
  assign psr_wr_src_fpu_o[3] = 1'b0;
  assign psr_wr_src_fpu_o[0] = 1'b0;
  assign psr_wr_en_fpu[5] = 1'b0;
  assign psr_wr_en_fpu[4] = 1'b0;
  assign psr_wr_en_fpu[2] = 1'b0;
  assign nxt_decoder_fsm[5] = 1'b0;
  assign nxt_decoder_fsm[4] = 1'b0;
  assign ls_size_fpu_o[0] = 1'b0;
  assign ls_length[5] = 1'b0;
  assign ls_length[4] = 1'b0;
  assign ls_length[3] = 1'b0;
  assign ls_length[2] = 1'b0;
  assign ls_instr_type_fpu_o[2] = 1'b0;
  assign ex_pipe_fpu[3] = 1'b0;
  assign ex_pipe_fpu[2] = 1'b0;
  assign ex2_ctl_op_comp_fpu[0] = 1'b0;
  assign ex2_ctl_flag_set_fpu[0] = 1'b0;
  assign ex2_ctl_au_carry_lu_fpu[3] = 1'b0;
  assign ex2_ctl_au_carry_lu_fpu[2] = 1'b0;
  assign ex2_ctl_au_carry_lu_fpu[1] = 1'b0;
  assign dp_data_c_sel_fpu_o[1] = 1'b0;
  assign dp_data_c_sel_fpu_o[0] = 1'b0;
  assign algn_size_fpu_o[2] = 1'b0;
  assign algn_size_fpu_o[0] = 1'b0;
  assign agu_data_b_sel_fpu_o[0] = 1'b0;
  assign net_1 = ~net_258;
  assign net_2 = ~net_307;
  assign net_3 = ~decoder_fsm_i[0];
  assign net_4 = ~one_cycle_vfp_lsm_i;
  assign net_5 = ~net_109;
  assign net_6 = ~net_56;
  assign net_7 = ~net_247;
  assign net_8 = ~net_178;
  assign net_9 = ~iq_instr_jfn_i[23];
  assign net_10 = ~net_153;
  assign net_11 = ~iq_instr_jfn_i[21];
  assign net_13 = ~iq_instr_jfn_i[19];
  assign net_14 = ~net_193;
  assign net_15 = ~iq_instr_jfn_i[18];
  assign net_16 = ~net_114;
  assign net_17 = ~iq_instr_jfn_i[16];
  assign net_18 = ~iq_instr_jfn_i[8];
  assign net_19 = ~iq_instr_jfn_i[7];
  assign net_20 = ~iq_instr_jfn_i[4];
  assign str_data_sel_fpu_o[1] = (net_22 | rf_wr_when_w0_fpu_o[1]);
  assign str_data_sel_fpu_o[0] = (net_23 | net_24);
  assign net_24 = (net_25 | net_26);
  assign net_26 = (net_22 | net_27);
  assign net_22 = ~(net_28 & net_29);
  assign net_29 = (net_30 | net_31);
  assign net_30 = (iq_instr_jfn_i[19] | net_15);
  assign net_28 = ~(net_32 | wd_align_pc_fpu_o);
  assign rf_wr_when_fw0_fpu_o = ~(net_33 & net_34);
  assign net_34 = ~(net_35 & net_36);
  assign net_36 = (net_9 | net_37);
  assign net_37 = (net_38 | net_39);
  assign net_39 = (net_40 | net_41);
  assign net_41 = (net_42 & net_15);
  assign net_40 = (net_43 & net_44);
  assign rf_wr_src_fw0_fpu_o[2] = (rf_rd_ctl_r2_fpu[0] | net_45);
  assign net_45 = ~(net_46 & net_47);
  assign net_47 = ~(iq_instr_jfn_i[20] & wd_align_pc_fpu_o);
  assign net_46 = (net_48 & net_49);
  assign net_49 = ~(imm_sel_fpu[2] & net_18);
  assign rf_wr_src_fw0_fpu_o[1] = (rf_rd_ctl_r2_fpu[0] | net_50);
  assign net_50 = (net_51 | net_52);
  assign net_52 = ~(net_53 & net_54);
  assign net_54 = ~(net_55 & net_56);
  assign net_55 = (net_57 | net_58);
  assign net_58 = (net_59 | net_60);
  assign net_60 = (net_20 & net_61);
  assign net_61 = (net_62 | net_63);
  assign net_63 = ~(iq_instr_jfn_i[6] | iq_instr_jfn_i[8]);
  assign net_62 = (net_64 | net_9);
  assign net_64 = (net_43 & net_65);
  assign net_65 = ~(net_66 & net_67);
  assign net_66 = (net_68 & net_69);
  assign net_69 = (net_13 | net_70);
  assign net_68 = (net_14 & net_71);
  assign net_59 = (net_72 & net_408);
  assign rf_wr_src_fw0_fpu_o[0] = (net_35 & net_73);
  assign net_73 = (net_74 | net_75);
  assign net_75 = ~(net_10 & net_76);
  assign net_76 = (net_77 | net_9);
  assign net_77 = (iq_instr_jfn_i[6] & net_78);
  assign net_78 = ~(net_79 & net_80);
  assign rf_wr_src_fpu_o[3] = (net_81 | rf_wr_when_w1_fpu_o[1]);
  assign rf_wr_src_fpu_o[0] = (rf_wr_src_fpu_o[1] | net_82);
  assign rf_wr_when_w0_fpu_o[1] = (rf_wr_src_fpu_o[2] | net_81);
  assign net_81 = (net_56 & net_83);
  assign net_83 = (net_84 & net_72);
  assign rf_wr_ctl_fw0_fpu[9] = ~(net_408 | net_85);
  assign rf_wr_ctl_fw0_fpu[8] = (iq_instr_jfn_i[20] & ls_length[1]);
  assign rf_wr_ctl_fw0_fpu[7] = (iq_instr_jfn_i[21] & net_86);
  assign rf_wr_ctl_fw0_fpu[6] = (net_86 & net_11);
  assign rf_wr_ctl_fw0_fpu[5] = (iq_instr_jfn_i[8] & rf_rd_ctl_r2_fpu[0]);
  assign rf_wr_ctl_fw0_fpu[4] = ~(net_18 | net_53);
  assign rf_wr_ctl_fw0_fpu[3] = (rf_rd_ctl_r2_fpu[0] & net_18);
  assign rf_wr_ctl_fw0_fpu[2] = ~(net_87 & net_88);
  assign net_88 = ~(net_35 & net_89);
  assign net_89 = (net_90 | net_91);
  assign net_91 = (net_92 & net_93);
  assign net_93 = (net_94 | net_95);
  assign net_95 = (net_96 & iq_instr_jfn_i[8]);
  assign net_90 = (net_18 & net_97);
  assign net_97 = (net_98 | net_99);
  assign net_99 = (iq_instr_jfn_i[20] & net_100);
  assign net_100 = (net_101 | net_102);
  assign net_102 = (net_13 & net_15);
  assign net_101 = (iq_instr_jfn_i[19] & net_103);
  assign net_103 = (iq_instr_jfn_i[17] | net_17);
  assign net_87 = ~(iq_instr_jfn_i[20] & net_104);
  assign rf_wr_ctl_fw0_fpu[13] = (iq_instr_jfn_i[20] & net_105);
  assign rf_wr_ctl_fw0_fpu[12] = ~(net_106 & net_107);
  assign net_107 = ~(net_96 & net_108);
  assign net_108 = (net_109 & net_18);
  assign net_106 = (net_110 | net_18);
  assign net_110 = ~(fp_undef_if_vector | net_111);
  assign net_111 = (net_112 & net_35);
  assign net_112 = (iq_instr_jfn_i[20] & net_113);
  assign net_113 = ~(net_67 & net_16);
  assign rf_wr_ctl_fw0_fpu[0] = ~(iq_instr_jfn_i[8] | net_53);
  assign rf_rd_need_fr2_fpu_o[1] = (net_115 | rf_rd_ctl_fr2_fpu[12]);
  assign net_115 = (net_116 & net_117);
  assign net_117 = (net_118 | net_119);
  assign net_119 = (net_120 & net_121);
  assign net_121 = (net_122 | net_123);
  assign net_123 = ~(net_124 | net_15);
  assign rf_rd_need_fr1_fpu_o[1] = ~(net_33 & net_125);
  assign net_125 = ~(net_35 & net_126);
  assign net_126 = ~(iq_instr_jfn_i[23] & net_127);
  assign net_127 = ~(net_43 & net_128);
  assign net_33 = ~(rf_wr_src_fpu_o[2] | net_51);
  assign net_51 = (net_35 & net_129);
  assign rf_rd_need_fr0_fpu_o[1] = (rf_wr_src_fpu_o[2] | net_130);
  assign net_130 = (net_131 | net_132);
  assign net_132 = (rf_rd_need_fr0_fpu_o[0] | net_133);
  assign rf_rd_ctl_r2_fpu[1] = (net_27 | net_134);
  assign net_134 = ~(net_48 & net_135);
  assign net_135 = ~(net_136 & net_137);
  assign net_48 = (net_138 & net_53);
  assign net_138 = ~(rf_wr_ctl_fw0_fpu[1] | net_86);
  assign net_86 = (net_139 & net_408);
  assign rf_wr_ctl_fw0_fpu[1] = (net_140 & net_408);
  assign net_140 = (iq_instr_jfn_i[4] & net_141);
  assign net_27 = ~(iq_instr_jfn_i[20] | net_142);
  assign rf_rd_need_r0_fpu_o[2] = (net_143 | net_144);
  assign net_143 = ~(net_145 | net_146);
  assign net_146 = ~(net_147 | net_7);
  assign rf_rd_ctl_fr2_fpu[2] = (net_148 & net_13);
  assign net_148 = (net_109 & net_122);
  assign net_122 = (net_70 & net_149);
  assign rf_rd_ctl_fr2_fpu[1] = (net_150 & net_151);
  assign rf_rd_ctl_fr2_fpu[12] = (iq_instr_jfn_i[23] & net_152);
  assign net_152 = (net_153 & net_154);
  assign rf_rd_ctl_fr2_fpu[11] = (net_154 & net_151);
  assign net_151 = (iq_instr_jfn_i[21] & net_118);
  assign rf_rd_ctl_fr2_fpu[10] = (net_32 & net_17);
  assign rf_rd_ctl_fr2_fpu[0] = (net_155 & net_17);
  assign net_155 = (net_156 & net_18);
  assign rf_rd_ctl_fr1_fpu[8] = (net_157 & net_15);
  assign rf_rd_ctl_fr1_fpu[3] = (rf_wr_src_fpu_o[2] & net_18);
  assign rf_rd_ctl_fr1_fpu[2] = (net_18 & net_158);
  assign net_158 = (net_156 | net_159);
  assign rf_rd_ctl_fr1_fpu[12] = (net_32 | net_160);
  assign net_160 = (iq_instr_jfn_i[18] & net_157);
  assign net_157 = (iq_instr_jfn_i[8] & net_159);
  assign net_32 = (iq_instr_jfn_i[8] & net_156);
  assign net_156 = (iq_instr_jfn_i[18] & net_161);
  assign net_161 = ~(net_162 | net_5);
  assign rf_rd_ctl_fr1_fpu[10] = (net_154 & net_163);
  assign net_163 = (net_129 | net_164);
  assign net_164 = ~(net_165 & net_166);
  assign net_166 = ~(net_43 & net_167);
  assign net_167 = (net_96 | net_168);
  assign net_168 = ~(net_14 | net_79);
  assign net_96 = ~(iq_instr_jfn_i[19] | net_71);
  assign net_71 = ~(iq_instr_jfn_i[7] & net_169);
  assign rf_rd_ctl_fr1_fpu[0] = (net_35 & net_170);
  assign net_170 = (net_171 | net_172);
  assign net_172 = (net_129 & net_18);
  assign net_171 = ~(net_173 & net_174);
  assign net_174 = (net_175 & net_176);
  assign net_176 = ~(net_177 & net_92);
  assign net_92 = (net_178 & net_43);
  assign net_175 = (iq_instr_jfn_i[8] | net_165);
  assign net_165 = (iq_instr_jfn_i[23] & net_179);
  assign net_179 = ~(net_94 & net_43);
  assign net_94 = (iq_instr_jfn_i[18] & net_180);
  assign net_173 = ~(net_42 & net_181);
  assign net_181 = ~(net_182 & net_183);
  assign net_183 = (iq_instr_jfn_i[18] | net_79);
  assign net_182 = ~(iq_instr_jfn_i[17] & net_79);
  assign net_42 = (net_120 & net_18);
  assign net_120 = (net_43 & net_13);
  assign rf_rd_ctl_fr0_fpu[9] = ~(iq_instr_jfn_i[20] | net_85);
  assign rf_rd_ctl_fr0_fpu[8] = (ls_length[1] & net_408);
  assign rf_rd_ctl_fr0_fpu[7] = (iq_instr_jfn_i[21] & net_133);
  assign rf_rd_ctl_fr0_fpu[6] = (net_133 & net_11);
  assign net_133 = (iq_instr_jfn_i[20] & net_139);
  assign net_139 = (iq_instr_jfn_i[4] & net_184);
  assign net_184 = ~(net_6 | net_185);
  assign rf_rd_ctl_fr1_fpu[5] = (rf_wr_src_fpu_o[2] & iq_instr_jfn_i[8]);
  assign rf_rd_ctl_fr0_fpu[2] = (net_104 & net_408);
  assign rf_rd_ctl_fr0_fpu[1] = (net_131 | net_186);
  assign net_186 = (net_150 & net_187);
  assign net_150 = (net_35 & net_18);
  assign net_131 = (iq_instr_jfn_i[20] & net_141);
  assign net_141 = ~(net_6 | net_188);
  assign rf_rd_ctl_fr0_fpu[13] = (net_408 & net_105);
  assign net_105 = (net_1 | net_189);
  assign rf_rd_ctl_fr0_fpu[11] = (net_154 & net_187);
  assign net_154 = (iq_instr_jfn_i[8] & net_35);
  assign rf_rd_ctl_fr0_fpu[10] = ~(net_14 | net_31);
  assign net_31 = ~(iq_instr_jfn_i[8] & net_190);
  assign rf_rd_ctl_fr0_fpu[0] = (net_18 & net_191);
  assign net_191 = (rf_wr_src_fpu_o[2] | net_192);
  assign net_192 = (net_193 & net_190);
  assign net_190 = (net_79 & net_109);
  assign req_strict_algn_fpu_o = (wd_align_pc_fpu_o | net_194);
  assign net_194 = (net_195 | rf_wr_src_fpu_o[2]);
  assign net_195 = (net_196 & net_197);
  assign net_197 = (iq_instr_jfn_i[8] & net_198);
  assign net_198 = (net_199 | net_200);
  assign nxt_decoder_fsm[3] = (net_201 & net_202);
  assign net_202 = ~(net_203 & net_204);
  assign net_204 = ~(net_205 & net_206);
  assign net_206 = (decoder_fsm_i[1] ^ decoder_fsm_i[2]);
  assign net_205 = (decoder_fsm_i[3] & net_3);
  assign nxt_decoder_fsm[2] = (net_201 & net_207);
  assign net_207 = ~(net_208 & net_203);
  assign net_203 = ~(net_209 & net_210);
  assign net_210 = (net_211 | net_193);
  assign net_209 = (net_212 & net_213);
  assign net_208 = ~(net_214 & net_215);
  assign net_215 = ~(decoder_fsm_i[0] | net_216);
  assign net_216 = ~(decoder_fsm_i[3] ^ decoder_fsm_i[2]);
  assign net_214 = (decoder_fsm_i[3] ^ decoder_fsm_i[1]);
  assign net_201 = ~(iq_instr_jfn_i[20] | net_217);
  assign nxt_decoder_fsm[1] = ~(net_218 & net_53);
  assign net_53 = ~(net_200 & net_219);
  assign net_218 = ~(ls_length[1] | net_220);
  assign net_220 = ~(net_221 | net_222);
  assign net_222 = (net_217 | decoder_fsm_i[1]);
  assign net_217 = ~(net_223 & net_224);
  assign net_221 = (net_225 & net_226);
  assign net_226 = (decoder_fsm_i[0] | net_227);
  assign net_227 = (iq_instr_jfn_i[20] | net_212);
  assign net_225 = ~(net_212 & net_228);
  assign net_228 = ~(set_15_12_i | net_229);
  assign net_229 = ~(net_80 & net_230);
  assign net_230 = (iq_instr_jfn_i[16] & decoder_fsm_i[0]);
  assign nxt_decoder_fsm[0] = (net_231 | net_232);
  assign net_231 = (net_233 & net_234);
  assign net_234 = ~(net_235 & net_236);
  assign net_236 = ~(net_237 & net_408);
  assign net_235 = ~(net_238 | net_239);
  assign net_239 = (net_114 & iq_instr_jfn_i[20]);
  assign no_interrupt_fpu_o = (rf_rd_ctl_r2_fpu[0] | agu_data_b_sel_fpu_o[2]);
  assign rf_rd_ctl_r2_fpu[0] = (net_199 & net_219);
  assign net_219 = (net_196 & net_408);
  assign ls_instr_type_fpu_o[0] = (net_189 | net_240);
  assign net_240 = (ls_length[1] | agu_data_b_sel_fpu_o[2]);
  assign ls_length[1] = (net_241 & net_242);
  assign net_242 = (iq_instr_jfn_i[8] & net_200);
  assign imm_sel_fpu[4] = (iq_instr_jfn_i[7] & net_159);
  assign imm_sel_fpu[3] = (net_159 & net_19);
  assign net_159 = ~(net_67 | net_5);
  assign imm_sel_fpu[1] = ~(net_243 & net_244);
  assign net_244 = ~(net_245 | net_246);
  assign net_246 = ~(net_247 | net_145);
  assign imm_sel_fpu[0] = ~(net_70 | net_248);
  assign net_248 = ~(net_109 & net_180);
  assign net_180 = ~(iq_instr_jfn_i[17] | net_13);
  assign net_109 = ~(net_8 | net_249);
  assign head_instr_fpu = (net_250 | net_251);
  assign net_251 = (net_252 | net_253);
  assign net_253 = ~(net_243 & net_254);
  assign net_254 = ~(net_25 | net_255);
  assign net_25 = (net_256 & net_257);
  assign fp_vlsm_fpu = ~(net_258 & net_259);
  assign net_259 = ~(net_4 & net_189);
  assign fp_undef_if_vector = (net_35 & net_260);
  assign net_260 = (net_80 | net_98);
  assign fp_sysreg_priv = (net_261 & net_257);
  assign net_261 = (net_224 & net_211);
  assign rf_rd_need_fr0_fpu_o[0] = ~(net_262 & net_263);
  assign net_263 = ~(net_35 & net_187);
  assign net_187 = (net_74 | net_129);
  assign net_129 = ~(net_10 & net_264);
  assign net_264 = (iq_instr_jfn_i[20] | iq_instr_jfn_i[6]);
  assign net_74 = (net_408 & net_9);
  assign net_262 = ~(net_193 & net_265);
  assign net_265 = ~(net_249 | net_266);
  assign net_266 = ~(iq_instr_jfn_i[23] & net_79);
  assign net_249 = ~(net_35 & net_43);
  assign fp_ex_pipe_fpu[0] = (net_116 & net_267);
  assign net_267 = (net_118 | net_268);
  assign net_268 = (net_43 & net_128);
  assign net_128 = (net_269 | net_270);
  assign net_270 = ~(net_271 & net_272);
  assign net_272 = (net_162 | iq_instr_jfn_i[7]);
  assign net_43 = (iq_instr_jfn_i[20] & iq_instr_jfn_i[6]);
  assign net_118 = (iq_instr_jfn_i[20] & net_9);
  assign net_116 = (iq_instr_jfn_i[21] & net_35);
  assign ex_pipe_fpu[1] = (ls_store_fpu_o | net_273);
  assign net_273 = (net_23 | net_274);
  assign net_274 = (net_275 | rf_wr_when_w1_fpu_o[1]);
  assign rf_wr_when_w1_fpu_o[1] = (rf_wr_src_fpu_o[2] | rf_wr_src_fpu_o[1]);
  assign rf_wr_src_fpu_o[1] = (net_276 & net_277);
  assign net_277 = (net_211 | net_238);
  assign net_211 = (net_278 | net_114);
  assign net_276 = (iq_instr_jfn_i[20] & net_224);
  assign net_275 = (net_279 | net_280);
  assign net_280 = ~(net_281 & net_282);
  assign net_282 = ~(net_196 & net_200);
  assign net_281 = (net_142 & net_283);
  assign net_283 = ~(imm_sel_fpu[2] & iq_instr_jfn_i[8]);
  assign net_142 = ~(net_136 & net_177);
  assign net_177 = (iq_instr_jfn_i[19] & net_114);
  assign net_136 = (net_284 & net_224);
  assign net_23 = ~(net_285 | net_286);
  assign net_286 = ~(net_287 & net_288);
  assign net_288 = ~(net_289 & net_290);
  assign net_290 = ~(iq_instr_jfn_i[25] & net_72);
  assign net_289 = ~(iq_instr_jfn_i[22] & net_291);
  assign net_291 = (net_292 & net_293);
  assign net_293 = (net_294 | net_295);
  assign net_295 = ~(net_8 | net_296);
  assign net_296 = ~(net_137 & net_297);
  assign net_297 = ~(iq_instr_jfn_i[8] | net_298);
  assign net_298 = ~(iq_instr_jfn_i[25] & net_213);
  assign net_137 = (net_299 & net_408);
  assign net_299 = (iq_instr_jfn_i[16] & net_193);
  assign net_294 = ~(iq_instr_jfn_i[25] | net_300);
  assign net_300 = ~(net_301 & net_302);
  assign ls_store_fpu_o = (net_408 & wd_align_pc_fpu_o);
  assign ex_pipe_fpu[0] = (imm_sel_fpu[2] | net_303);
  assign net_303 = (psr_wr_src_fpu_o[2] | rf_wr_ctl_w1_fpu[0]);
  assign psr_wr_src_fpu_o[2] = (iq_instr_jfn_i[16] & net_279);
  assign net_279 = (net_304 & net_224);
  assign net_224 = (iq_instr_jfn_i[4] & net_233);
  assign end_instr_fpu = ~(net_305 & net_306);
  assign net_306 = (net_145 | net_2);
  assign net_145 = ~(net_199 & net_308);
  assign net_305 = ~(net_252 | net_232);
  assign net_232 = ~(net_309 & net_310);
  assign net_310 = ~(net_196 & net_199);
  assign net_309 = ~(rf_wr_src_fpu_o[2] | net_311);
  assign net_311 = (net_250 | ls_length[0]);
  assign ls_length[0] = (net_104 | net_312);
  assign net_312 = (net_313 | net_314);
  assign net_313 = (one_cycle_vfp_lsm_i & net_189);
  assign net_189 = (net_200 & net_315);
  assign net_315 = (net_316 | net_317);
  assign net_317 = (net_318 & net_319);
  assign net_250 = (net_56 & net_320);
  assign net_320 = (net_321 | net_322);
  assign net_322 = (net_323 | net_57);
  assign net_57 = (net_324 & net_269);
  assign net_269 = (net_15 & net_149);
  assign net_149 = (iq_instr_jfn_i[17] & net_18);
  assign net_324 = (iq_instr_jfn_i[20] & net_20);
  assign net_323 = (net_20 & net_325);
  assign net_325 = (net_98 | net_326);
  assign net_326 = (iq_instr_jfn_i[20] & net_44);
  assign net_44 = ~(net_271 & net_162);
  assign net_271 = (net_327 & net_67);
  assign net_67 = ~(iq_instr_jfn_i[17] & iq_instr_jfn_i[19]);
  assign net_327 = (net_328 & net_329);
  assign net_329 = ~(net_79 & iq_instr_jfn_i[18]);
  assign net_79 = (iq_instr_jfn_i[7] & iq_instr_jfn_i[16]);
  assign net_328 = (iq_instr_jfn_i[17] | net_70);
  assign net_70 = (iq_instr_jfn_i[16] & net_15);
  assign net_98 = ~(iq_instr_jfn_i[23] & net_330);
  assign net_330 = (iq_instr_jfn_i[6] & net_10);
  assign net_153 = ~(iq_instr_jfn_i[20] ^ net_11);
  assign net_321 = (net_331 | net_72);
  assign net_72 = ~(net_185 & net_188);
  assign net_188 = ~(net_332 & net_11);
  assign net_332 = ~(iq_instr_jfn_i[8] | net_333);
  assign net_185 = ~(net_38 & net_334);
  assign net_334 = ~(iq_instr_jfn_i[5] | net_333);
  assign net_333 = (iq_instr_jfn_i[22] | iq_instr_jfn_i[23]);
  assign net_38 = ~(iq_instr_jfn_i[6] | net_18);
  assign net_331 = (net_335 & net_336);
  assign net_336 = (net_304 | net_337);
  assign net_337 = (net_84 & net_278);
  assign net_278 = (net_338 & net_13);
  assign net_84 = (iq_instr_jfn_i[20] & iq_instr_jfn_i[4]);
  assign net_304 = (net_80 & net_339);
  assign net_339 = (iq_instr_jfn_i[12] & net_340);
  assign net_340 = (net_341 & net_342);
  assign net_342 = (iq_instr_jfn_i[15] & iq_instr_jfn_i[14]);
  assign net_341 = (iq_instr_jfn_i[13] & set_15_12_i);
  assign net_80 = (iq_instr_jfn_i[20] & net_193);
  assign net_252 = (net_233 & net_343);
  assign net_343 = (net_344 | net_345);
  assign net_345 = (iq_instr_jfn_i[20] & net_238);
  assign net_238 = (net_346 & net_237);
  assign net_237 = (net_292 & net_302);
  assign net_346 = ~(set_15_12_i | net_14);
  assign net_193 = ~(iq_instr_jfn_i[18] | net_162);
  assign net_162 = (iq_instr_jfn_i[17] | iq_instr_jfn_i[19]);
  assign net_344 = (net_347 & net_257);
  assign net_257 = (iq_instr_jfn_i[20] | net_284);
  assign net_347 = (net_114 | net_348);
  assign net_348 = ~(net_349 | iq_instr_jfn_i[20]);
  assign net_349 = (iq_instr_jfn_i[19] | net_350);
  assign net_350 = (iq_instr_jfn_i[18] ^ iq_instr_jfn_i[17]);
  assign net_114 = ~(iq_instr_jfn_i[18] | net_124);
  assign net_124 = (iq_instr_jfn_i[16] | iq_instr_jfn_i[17]);
  assign net_233 = (net_56 & net_335);
  assign net_335 = (iq_instr_jfn_i[22] & net_351);
  assign net_351 = ~(iq_instr_jfn_i[8] | net_8);
  assign dp_data_b_sel_fpu_o[1] = (imm_sel_fpu[2] | net_82);
  assign imm_sel_fpu[2] = ~(net_8 | net_352);
  assign net_352 = ~(net_35 & net_353);
  assign net_353 = ~(iq_instr_jfn_i[6] | net_408);
  assign net_35 = (net_56 & net_20);
  assign net_56 = (iq_instr_jfn_i[25] & net_354);
  assign net_354 = ~(iq_instr_jfn_i[24] | net_285);
  assign rf_wr_ctl_w1_fpu[0] = (rf_wr_src_fpu_o[2] | net_82);
  assign net_82 = (net_245 | ex2_ctl_op_comp_fpu[1]);
  assign ex2_ctl_op_comp_fpu[1] = (net_7 & net_355);
  assign net_245 = (net_147 & net_355);
  assign net_355 = (net_356 & net_357);
  assign net_357 = ~(net_358 & net_359);
  assign net_359 = ~(net_308 & net_302);
  assign net_308 = (last_cycle & net_4);
  assign net_358 = ~(net_213 & one_cycle_vfp_lsm_i);
  assign net_147 = (net_360 & net_178);
  assign net_178 = (iq_instr_jfn_i[21] & iq_instr_jfn_i[23]);
  assign rf_wr_src_fpu_o[2] = (iq_instr_jfn_i[20] & net_256);
  assign net_256 = (net_361 & net_196);
  assign net_196 = (net_362 & net_287);
  assign net_287 = ~(iq_instr_jfn_i[24] | net_20);
  assign net_362 = (iq_instr_jfn_i[22] & net_301);
  assign net_301 = ~(iq_instr_jfn_i[21] | net_363);
  assign net_363 = (iq_instr_jfn_i[23] | net_364);
  assign net_364 = (iq_instr_jfn_i[6] | iq_instr_jfn_i[7]);
  assign wd_align_pc_fpu_o = (net_255 | agu_data_b_sel_fpu_o[1]);
  assign net_255 = (net_365 & net_366);
  assign net_366 = (net_319 | net_360);
  assign agu_sub_b_fpu_o = ~(net_367 & net_368);
  assign net_368 = ~(net_104 & net_9);
  assign net_104 = (net_18 & net_369);
  assign net_367 = ~(net_370 & net_371);
  assign net_371 = (net_372 | iq_instr_jfn_i[21]);
  assign net_370 = (net_373 & net_200);
  assign agu_data_b_sel_fpu_o[1] = (net_314 | net_374);
  assign net_374 = ~(net_243 & net_258);
  assign net_243 = (net_375 & net_376);
  assign net_376 = (net_247 | net_377);
  assign net_377 = ~(net_361 & net_284);
  assign net_375 = ~(net_369 & net_378);
  assign net_369 = (net_361 & net_241);
  assign agu_data_a_sel_fpu_o[1] = (net_379 | agu_data_b_sel_fpu_o[2]);
  assign agu_data_b_sel_fpu_o[2] = ~(net_258 & net_85);
  assign net_85 = ~(net_314 & iq_instr_jfn_i[8]);
  assign net_314 = (net_241 & net_199);
  assign net_241 = (net_380 & net_372);
  assign net_372 = ~(set_19_16_i & net_381);
  assign net_379 = ~(net_382 | net_383);
  assign net_383 = ~(set_19_16_i & net_319);
  assign net_319 = ~(iq_instr_jfn_i[21] | net_381);
  assign net_382 = ~(net_365 | net_384);
  assign net_384 = (iq_instr_jfn_i[24] & net_385);
  assign net_385 = (net_361 & net_378);
  assign net_365 = (iq_instr_jfn_i[23] & net_200);
  assign net_200 = (net_356 & net_213);
  assign agu_data_a_sel_fpu_o[0] = (net_144 | net_386);
  assign net_386 = (net_387 | net_1);
  assign net_258 = (one_cycle_vfp_lsm_i | net_388);
  assign net_388 = ~(net_361 & net_389);
  assign net_389 = ~(net_390 | decoder_fsm_i[0]);
  assign net_390 = ~(net_391 | net_392);
  assign net_392 = (net_292 & net_393);
  assign net_393 = (decoder_fsm_i[1] & net_307);
  assign net_307 = (net_316 | net_394);
  assign net_394 = (net_318 & net_11);
  assign net_391 = ~(last_cycle | net_395);
  assign net_395 = ~(net_318 | net_7);
  assign net_318 = ~(iq_instr_jfn_i[24] | net_9);
  assign net_387 = (net_380 & net_396);
  assign net_396 = (net_199 & net_397);
  assign net_397 = ~(set_19_16_i & net_398);
  assign net_398 = (net_18 | net_381);
  assign net_381 = ~(net_169 & iq_instr_jfn_i[19]);
  assign net_169 = (iq_instr_jfn_i[16] & net_338);
  assign net_338 = (iq_instr_jfn_i[18] & iq_instr_jfn_i[17]);
  assign net_199 = (net_356 & net_302);
  assign net_302 = (net_3 & decoder_fsm_i[1]);
  assign net_356 = (net_361 & net_292);
  assign net_144 = (net_361 & net_399);
  assign net_399 = (net_400 | net_401);
  assign net_401 = (net_284 & net_316);
  assign net_316 = ~(net_402 & net_247);
  assign net_247 = ~(iq_instr_jfn_i[21] & net_373);
  assign net_373 = (iq_instr_jfn_i[24] & net_9);
  assign net_402 = ~(iq_instr_jfn_i[23] & net_360);
  assign net_360 = ~(iq_instr_jfn_i[24] | set_19_16_i);
  assign net_400 = ~(set_19_16_i | net_403);
  assign net_403 = ~(net_378 & net_380);
  assign net_380 = (iq_instr_jfn_i[24] & net_11);
  assign net_378 = (net_284 | net_18);
  assign net_284 = (net_292 & net_213);
  assign net_213 = ~(net_3 | decoder_fsm_i[1]);
  assign net_292 = (net_212 & net_223);
  assign net_223 = ~(decoder_fsm_i[5] | decoder_fsm_i[4]);
  assign net_212 = ~(decoder_fsm_i[2] | decoder_fsm_i[3]);
  assign net_361 = ~(iq_instr_jfn_i[25] | net_285);
  assign net_285 = ~(iq_instr_jfn_i[26] & net_404);
  assign net_404 = (iq_instr_jfn_i[27] & net_405);
  assign net_405 = ~(iq_instr_jfn_i[10] | net_406);
  assign net_406 = (iq_instr_jfn_i[28] | net_407);
  assign net_407 = ~(iq_instr_jfn_i[9] & iq_instr_jfn_i[11]);
  assign net_408 = ~iq_instr_jfn_i[20];

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  assign first_cycle = decoder_fsm_i[0];

  assign cpacr_undef  = ~((fpudis_i[0] & ~usr_de_i) | fpudis_i[1]);
  assign fpexc_undef  = ~fp_sysreg_en_f5_i & ~fp_sysreg_priv & first_cycle;
  assign priv_undef   = fp_sysreg_priv & usr_de_i;
  assign vector_undef = fp_undef_if_vector & fp_sysreg_vector_f5_i & (iq_instr_jfn_i[15:14] != 2'b00)
                         & ~cpacr_undef & ~fpexc_undef & ~d32_undef;

  assign instr_undef  = lsm_undef | cpacr_undef | fpexc_undef | d32_undef | priv_undef | vector_undef;

  // ------------------------------------------------------
  // Bundle up the dp_pipectl bus
  // ------------------------------------------------------

  always @*
  begin
    dp_wr_ctl   = {`CA5_DP_WR_CTL_W{1'b0}};
    dp_ex2_ctl  = {`CA5_DP_EX2_CTL_W{1'b0}};
    alu_ex1_ctl = {`CA5_ALU_EX1_CTL_W{1'b0}};
    mac_iss_ctl = {`CA5_MAC_ISS_CTL_W{1'b0}};

    dp_ex2_ctl[`CA5_ALU_EX2_CTL_FLAG_ID_BITS]       = ex2_ctl_flag_set_fpu; // alu_flag_set - 2'b10 = CC flag setting
                                                                        //                2'b00 = not flag setting

    dp_ex2_ctl[`CA5_ALU_EX2_CTL_OP_COMP_SHF_B_BIT]  = ex2_ctl_op_comp_fpu[1];
    dp_ex2_ctl[`CA5_ALU_EX2_CTL_OP_COMP_SHF_A_BIT]  = ex2_ctl_op_comp_fpu[0];
    dp_ex2_ctl[`CA5_ALU_EX2_CTL_LU_CTL_BITS]        = ex2_ctl_au_carry_lu_fpu;
  end

  assign dp_pipectl_fpu_o = {dp_wr_ctl,
                             dp_ex2_ctl,
                             alu_ex1_ctl,
                             mac_iss_ctl};

  // ------------------------------------------------------
  // Load/store multiple control generation
  // ------------------------------------------------------

  assign lsm_num_sp_regs = iq_instr_jfn_i[7:0] & {7'b1111111, ~iq_instr_jfn_i[8]};

  assign nxt_decoder_fsm_lsm = {(first_cycle ? (lsm_num_sp_regs[4:0])
                                             : decoder_fsm_i[5:1])
                                    - 1'b1,
                                decoder_fsm_i == 6'b000010};

  assign ls_length_lsm = first_cycle ? (lsm_num_sp_regs[5:0])
                                     : {1'b0, decoder_fsm_i[5:1]};

  assign lsm_firstreg = iq_instr_jfn_i[8] ? {iq_instr_jfn_i[22], iq_instr_jfn_i[15:12], 1'b0}
                                          : {1'b0,               iq_instr_jfn_i[15:12], iq_instr_jfn_i[22]};

  assign lsm_lastreg = lsm_firstreg + lsm_num_sp_regs[5:0] - 1'b1;

  assign lsm_undef = (fp_vlsm_fpu &
                      ((lsm_num_sp_regs[7:0] > 8'h20) |                    // Undef if accessing more than 16 D registers
                       (lsm_num_sp_regs[5:0] == 6'b000_000) |              // or if zero registers are being LS'ed
                       lsm_lastreg[6] |                                    // or accessing off the end of the D32 regbank
                       (d32dis_i | ~iq_instr_jfn_i[8]) & lsm_lastreg[5])); // or using an upper register if D32 is disabled
                                                                           // or this is an SP instruction

  assign lsm_regnum = first_cycle ? lsm_firstreg
                                  : lsm_state_i;

  assign nxt_lsm_state_fpu_o = lsm_regnum + 1'b1;


  assign nxt_decoder_fsm_fpu = fp_vlsm_fpu ? nxt_decoder_fsm_lsm
                                           : nxt_decoder_fsm;
  assign ls_length_fpu       = fp_vlsm_fpu ? ls_length_lsm
                                           : ls_length;

  // ------------------------------------------------------
  // Register file address and enable generation
  // ------------------------------------------------------

  // Core registers

  // Read addresses and enable
  assign rf_rd_vaddr_r0_fpu_o[3:0] = (({4{rf_rd_ctl_r0_fpu[0]}} & iq_instr_jfn_i[19:16]) |
                                      ({4{rf_rd_ctl_r0_fpu[1]}} & iq_instr_jfn_i[15:12]) |
                                      ({4{rf_rd_ctl_r0_fpu[2]}} & `CA5_VADDR_R15));

  assign rf_rd_vaddr_r2_fpu_o[3:0] = (({4{rf_rd_ctl_r2_fpu[0]}} & iq_instr_jfn_i[19:16]) |
                                      ({4{rf_rd_ctl_r2_fpu[1]}} & iq_instr_jfn_i[15:12]) |
                                      ({4{rf_rd_ctl_r2_fpu[2]}} & `CA5_VADDR_R15));

  assign rf_rd_en_r0_fpu_o = ~instr_undef & (|rf_rd_ctl_r0_fpu[2:0]);
  assign rf_rd_en_r2_fpu_o = ~instr_undef & (|rf_rd_ctl_r2_fpu[2:0]);

  // Write addresses and enable
  assign rf_wr_vaddr_w0_fpu_o[3:0] = (({4{rf_wr_ctl_w0_fpu[0]}} & iq_instr_jfn_i[19:16]) |
                                      ({4{rf_wr_ctl_w0_fpu[1]}} & iq_instr_jfn_i[15:12]) |
                                      ({4{rf_wr_ctl_w0_fpu[2]}} & `CA5_VADDR_R15));

  assign rf_wr_vaddr_w1_fpu_o[3:0] = (({4{rf_wr_ctl_w1_fpu[0]}} & iq_instr_jfn_i[19:16]) |
                                      ({4{rf_wr_ctl_w1_fpu[1]}} & iq_instr_jfn_i[15:12]) |
                                      ({4{rf_wr_ctl_w1_fpu[2]}} & `CA5_VADDR_R15));

  assign rf_wr_en_w0_fpu_o = ~instr_undef & (|rf_wr_ctl_w0_fpu[2:0]);
  assign rf_wr_en_w1_fpu_o = ~instr_undef & (|rf_wr_ctl_w1_fpu[2:0]);

  // VFP registers

  function [6:0] decode_regnum;
    input [FPU_REG_CTL_W-1:0]   ctl;
    input [35:0]                iq_instr_jfn_i;
    input [5:0]                 lsm_regnum;

    reg [4:0] regnum;
    reg [1:0] en;

    begin
      regnum =
          // Single precision
          (({5{ctl[0]}} &  {1'b0, iq_instr_jfn_i[3:0]  })                    |
           ({5{ctl[1]}} &  {1'b0, iq_instr_jfn_i[19:16]})                    |
           ({5{ctl[2]}} &  {1'b0, iq_instr_jfn_i[15:12]})                    |
           ({5{ctl[3]}} & ({1'b0, iq_instr_jfn_i[3:0] + iq_instr_jfn_i[5]})) |
          // Double precision
           ({5{ctl[4] | ctl[5] | ctl[10]}} &  {iq_instr_jfn_i[5],  iq_instr_jfn_i[3:0]  })      |
           ({5{ctl[6] | ctl[7] | ctl[11]}} &  {iq_instr_jfn_i[7],  iq_instr_jfn_i[19:16]})      |
           ({5{ctl[8] | ctl[9] | ctl[12]}} &  {iq_instr_jfn_i[22], iq_instr_jfn_i[15:12]})      |
          // LSM register
           ({5{ctl[13]}} & lsm_regnum[5:1]));

      en = ({2{ctl[ 0]}} & { iq_instr_jfn_i[5],  ~iq_instr_jfn_i[5] }) |
           ({2{ctl[ 1]}} & { iq_instr_jfn_i[7],  ~iq_instr_jfn_i[7] }) |
           ({2{ctl[ 2]}} & { iq_instr_jfn_i[22], ~iq_instr_jfn_i[22]}) |
           ({2{ctl[ 3]}} & {~iq_instr_jfn_i[5],   iq_instr_jfn_i[5] }) |
           ({2{ctl[13]}} & { lsm_regnum[0],      ~lsm_regnum[0]})      |
            {ctl[5] | ctl[7] | ctl[9] | ctl[10] | ctl[11] | ctl[12],
             ctl[4] | ctl[6] | ctl[8] | ctl[10] | ctl[11] | ctl[12]};

      decode_regnum = {regnum, en};
    end
  endfunction

  // Read addresses and enable
  assign {raw_rf_rd_addr_fr0_fpu, rf_rd_en_fr0_fpu_o} = decode_regnum(rf_rd_ctl_fr0_fpu, iq_instr_jfn_i, lsm_regnum);
  assign {raw_rf_rd_addr_fr1_fpu, rf_rd_en_fr1_fpu_o} = decode_regnum(rf_rd_ctl_fr1_fpu, iq_instr_jfn_i, lsm_regnum);
  assign {raw_rf_rd_addr_fr2_fpu, rf_rd_en_fr2_fpu_o} = decode_regnum(rf_rd_ctl_fr2_fpu, iq_instr_jfn_i, lsm_regnum);

  // Write addresses and enable
  assign {raw_rf_wr_addr_fw0_fpu, rf_wr_en_fw0_fpu}   = decode_regnum(rf_wr_ctl_fw0_fpu, iq_instr_jfn_i, lsm_regnum);

  assign d32_undef = d32dis_i & (raw_rf_rd_addr_fr0_fpu[4] | raw_rf_rd_addr_fr1_fpu[4] | raw_rf_rd_addr_fr2_fpu[4] | raw_rf_wr_addr_fw0_fpu[4]);

  // ------------------------------------------------------
  // Immediate generation
  // ------------------------------------------------------

  always @* begin
    imm_data_fpu_o      = {`CA5_IMM_DATA_W{1'b0}};

    case (imm_sel_fpu)
      5'b0_0000: begin
        // Do nothing
      end

      5'b0_0001:
        imm_data_fpu_o[5:0] = 6'd32;

      5'b0_0010: // LDC and STC from ARMv4
        imm_data_fpu_o[9:0] = {iq_instr_jfn_i[7:0], 2'b00};

      5'b0_0100: // Floating point FCONST instruction
        imm_data_fpu_o[7:0] = {iq_instr_jfn_i[19:16], iq_instr_jfn_i[3:0]}; // abcdefgh

      5'b0_1000: // Floating point/16 bit fixed point conversion
        imm_data_fpu_o[5:0] = {iq_instr_jfn_i[3], ~iq_instr_jfn_i[3], iq_instr_jfn_i[2:0], iq_instr_jfn_i[5]};

      5'b1_0000: // Floating point/32 bit fixed point conversion
        imm_data_fpu_o[4:0] = {iq_instr_jfn_i[3:0], iq_instr_jfn_i[5]};

      default:
        imm_data_fpu_o      = {`CA5_IMM_DATA_W{1'bx}};
    endcase
  end

  // ------------------------------------------------------
  // Output aliasing
  // ------------------------------------------------------

  // Force signals to defaults if a nop/undefined instruction occurs
  assign head_instr_fpu_o           = instr_undef ? 1'b1 : head_instr_fpu;
  assign end_instr_fpu_o            = instr_undef ? 1'b1 : end_instr_fpu;
  assign nxt_decoder_fsm_fpu_o      = instr_undef ? {{5{1'b0}}, 1'b1} : nxt_decoder_fsm_fpu;
  assign ex_pipe_fpu_o              = instr_undef ? {5{1'b0}} : ex_pipe_fpu[4:0];
  assign ls_length_fpu_o            = instr_undef ? {6{1'b0}} : ls_length_fpu[5:0];

  assign rf_rd_addr_fr0_fpu_o       = raw_rf_rd_addr_fr0_fpu[(`CA5_FP_RF_ADDR_W-1):0];
  assign rf_rd_addr_fr1_fpu_o       = raw_rf_rd_addr_fr1_fpu[(`CA5_FP_RF_ADDR_W-1):0];
  assign rf_rd_addr_fr2_fpu_o       = raw_rf_rd_addr_fr2_fpu[(`CA5_FP_RF_ADDR_W-1):0];
  assign rf_wr_addr_fw0_fpu_o       = raw_rf_wr_addr_fw0_fpu[(`CA5_FP_RF_ADDR_W-1):0];

  assign rf_wr_en_fw0_fpu_o         = instr_undef ? 2'b00 : rf_wr_en_fw0_fpu;

  assign instr_undef_fpu_o          = instr_undef;

  assign psr_wr_en_fpu_o            = instr_undef ? {6{1'b0}} : psr_wr_en_fpu;

  assign fp_ex_pipe_fpu_o[1:0]      = instr_undef ? 2'b00 : fp_ex_pipe_fpu;

  assign instr_type_fpu_o           = vector_undef  ? `CA5_INSTR_TYPE_UNDEF_VEC :
                                      instr_undef   ? `CA5_INSTR_TYPE_UNDEF     :
                                                      `CA5_INSTR_TYPE_NULL;

endmodule // ca5dpu_dec0_fpu
