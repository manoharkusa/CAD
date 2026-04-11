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

`include "ca5dpu_params.v"

module ca5dpu_fp_unpack_opb (
  input  wire [63:0] fad_b_data_f1_i,
  input  wire [ 2:0] in_format_f1_i,
  input  wire        fused_mac_f1_i,
  input  wire        ahp_f1_i,
  input  wire [ 5:0] imm_data_f1_i,

  output wire        sign_b_f1_o,
  output wire [10:0] exp_b_f1_o,
  output wire [53:0] unpack_frc_opb_f1_o,
  output wire        msb_opb_f1_o,
  output wire        max_expb_f1_o,
  output wire        can_flush_opb_f1_o,
  output wire        zero_expb_f1_o
);

  reg         sign;
  reg  [10:0] exp;
  reg  [53:0] fraction;
  reg         msb;
  reg         max_exp;
  reg         can_flush;
  reg         zero_exp;

  wire [ 7:0] fixed_point_exp;
  wire [ 2:0] mod_format;

  assign fixed_point_exp = 7'h7D + imm_data_f1_i;

  assign mod_format = fused_mac_f1_i ? `CA5_FP_FORMAT_F64 : in_format_f1_i;

  always @*
  begin
    case (mod_format)
      `CA5_FP_FORMAT_F32: begin
        sign      = fad_b_data_f1_i[31];
        exp       = {3'h0, fad_b_data_f1_i[30:23]};

        zero_exp  = fad_b_data_f1_i[30:23] == 0;
        max_exp   = fad_b_data_f1_i[30:23] == 8'hFF;

        fraction  = {30'h00000000, ~zero_exp, fad_b_data_f1_i[22:0]};
        msb       = fad_b_data_f1_i[22];

        can_flush = 1'b1;
      end

      `CA5_FP_FORMAT_F64: begin
        sign      = fad_b_data_f1_i[63];
        exp       = fad_b_data_f1_i[62:52];

        zero_exp  = fad_b_data_f1_i[62:52] == 0;
        max_exp   = fad_b_data_f1_i[62:52] == 11'h7FF;

        fraction  = {1'b0, ~zero_exp, fad_b_data_f1_i[51:0]};
        msb       = fad_b_data_f1_i[51];

        can_flush = ~fused_mac_f1_i;
      end

      `CA5_FP_FORMAT_F16_B: begin
        sign      = fad_b_data_f1_i[15];
        zero_exp  = fad_b_data_f1_i[14:10] == 0;
        exp       = {3'h0, fad_b_data_f1_i[14], {3{~fad_b_data_f1_i[14]}}, fad_b_data_f1_i[13:11], fad_b_data_f1_i[10] | zero_exp};

        max_exp   = fad_b_data_f1_i[14:10] == 5'h1F & ~ahp_f1_i;

        fraction  = {30'h00000000, ~zero_exp, fad_b_data_f1_i[9:0], 13'h0000};
        msb       = fad_b_data_f1_i[9];

        can_flush = 1'b0;
      end

      `CA5_FP_FORMAT_F16_T: begin
        sign      = fad_b_data_f1_i[31];
        zero_exp  = fad_b_data_f1_i[30:26] == 0;
        exp       = {3'h0, fad_b_data_f1_i[30], {3{~fad_b_data_f1_i[30]}}, fad_b_data_f1_i[29:27], fad_b_data_f1_i[26] | zero_exp};

        max_exp   = fad_b_data_f1_i[30:26] == 5'h1F & ~ahp_f1_i;

        fraction  = {30'h00000000, ~zero_exp, fad_b_data_f1_i[25:16], 13'h0000};
        msb       = fad_b_data_f1_i[25];

        can_flush = 1'b0;
      end

      `CA5_FP_FORMAT_U32, `CA5_FP_FORMAT_S32: begin
        sign      = (in_format_f1_i == `CA5_FP_FORMAT_S32) & fad_b_data_f1_i[31];

        zero_exp  = 0;
        max_exp   = 0;

        exp       = {3'b000, fixed_point_exp};
        fraction  = {fad_b_data_f1_i[31:0], {22{1'b0}} };
        msb       = 0;

        can_flush = 1'b0;
      end

      `CA5_FP_FORMAT_U16, `CA5_FP_FORMAT_S16: begin
        sign      = (in_format_f1_i == `CA5_FP_FORMAT_S16) & fad_b_data_f1_i[15];

        zero_exp  = 0;
        max_exp   = 0;

        exp       = {3'b000, fixed_point_exp};
        fraction  = { {16{sign}}, fad_b_data_f1_i[15:0], {22{1'b0}} };
        msb       = 0;

        can_flush = 1'b0;
      end

      default: begin
        sign      = 1'bx;
        exp       = {11{1'bx}};
        zero_exp  = 1'bx;
        max_exp   = 1'bx;
        fraction  = {54{1'bx}};
        msb       = 1'bx;
        can_flush = 1'bx;
      end
    endcase
  end

  assign sign_b_f1_o          = sign;
  assign exp_b_f1_o           = exp;
  assign unpack_frc_opb_f1_o  = fraction;
  assign msb_opb_f1_o         = msb;
  assign max_expb_f1_o        = max_exp;
  assign can_flush_opb_f1_o   = can_flush;
  assign zero_expb_f1_o       = zero_exp;

endmodule
