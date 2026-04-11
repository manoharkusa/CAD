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
//      Checked In          : $Date: 2009-11-13 13:49:58 +0000 (Fri, 13 Nov 2009) $
//
//      Revision            : $Revision: 123483 $
//
//      Release Information : CORTEX-A5-FPU-r0p1-00rel0
//
//-----------------------------------------------------------------------------

`include "ca5dpu_params.v"

module ca5dpu_fp_unpack_opa (
  input  wire [63:0] fad_a_data_f1_i,
  input  wire [ 2:0] out_format_f1_i,
  input  wire        fused_mac_f1_i,

  output wire        sign_a_f1_o,
  output wire [10:0] exp_a_f1_o,
  output wire [52:0] unpack_frc_opa_f1_o,
  output wire        msb_opa_f1_o,
  output wire        max_expa_f1_o,
  output wire        zero_expa_f1_o
);

  reg         sign;
  reg  [10:0] exp;
  reg  [52:0] fraction;
  reg         msb;
  reg         max_exp;
  reg         zero_exp;

  always @*
  begin
    case ({fused_mac_f1_i, 1'b0, out_format_f1_i[1:0]})
      {1'b0, `CA5_FP_FORMAT_F32}: begin
        sign      = fad_a_data_f1_i[31];
        exp       = {3'h0, fad_a_data_f1_i[30:23]};

        zero_exp  = fad_a_data_f1_i[30:23] == 0;
        max_exp   = fad_a_data_f1_i[30:23] == 8'hFF;

        fraction  = {29'h00000000, ~zero_exp, fad_a_data_f1_i[22:0]};
        msb       = fad_a_data_f1_i[22];

      end

      {1'b0, `CA5_FP_FORMAT_F64}: begin
        sign      = fad_a_data_f1_i[63];
        exp       = fad_a_data_f1_i[62:52];

        zero_exp  = fad_a_data_f1_i[62:52] == 0;
        max_exp   = fad_a_data_f1_i[62:52] == 11'h7FF;

        fraction  = {~zero_exp, fad_a_data_f1_i[51:0]};
        msb       = fad_a_data_f1_i[51];
      end

      {1'b0, `CA5_FP_FORMAT_F16_B}: begin
        sign      = 1'b0;
        exp       = 11'h000;

        zero_exp  = 1'b0;
        max_exp   = 1'b0;

        fraction  = {21'h000000, fad_a_data_f1_i[31:16], 16'h0000};
        msb       = 1'b0;
      end

      {1'b0, `CA5_FP_FORMAT_F16_T}: begin
        sign      = 1'b0;
        exp       = 11'h000;

        zero_exp  = 1'b0;
        max_exp   = 1'b0;

        fraction  = {21'h000000, fad_a_data_f1_i[15:0], 16'h0000};
        msb       = 1'b0;
      end

      `def_1xxx: begin
        sign      = fad_a_data_f1_i[31];
        exp       = {3'h0, fad_a_data_f1_i[30:23]};

        zero_exp  = fad_a_data_f1_i[30:23] == 0;
        max_exp   = fad_a_data_f1_i[30:23] == 8'hFF;

        fraction  = {~zero_exp, fad_a_data_f1_i[22:0], 29'h00000000};
        msb       = fad_a_data_f1_i[22];
      end

      default: begin
        sign      = 1'bx;
        exp       = {11{1'bx}};
        zero_exp  = 1'bx;
        max_exp   = 1'bx;
        fraction  = {53{1'bx}};
        msb       = 1'bx;
      end
    endcase
  end

  assign sign_a_f1_o          = sign;
  assign exp_a_f1_o           = exp;
  assign unpack_frc_opa_f1_o  = fraction;
  assign msb_opa_f1_o         = msb;
  assign max_expa_f1_o        = max_exp;
  assign zero_expa_f1_o       = zero_exp;

endmodule
