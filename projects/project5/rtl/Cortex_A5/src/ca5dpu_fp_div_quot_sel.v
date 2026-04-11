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
//      Checked In          : $Date: 2009-05-20 14:05:16 +0100 (Wed, 20 May 2009) $
//
//      Revision            : $Revision: 108749 $
//
//      Release Information : CORTEX-A5-FPU-r0p1-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Floating point div/sqrt quotient selection logic
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Selects the next result digit for a div/sqrt operation
//

`include "ca5dpu_params.v"

module ca5dpu_fp_div_quot_sel (
  input  wire [2:0] d_top_i,
  input  wire [7:0] rem_sum_top_i,
  input  wire [7:0] rem_carry_top_i,

  output wire [3:0] quot_dig_o
);

  wire       rem_sign;
  wire [6:0] rem_top;
  wire [6:0] mod_rem_top;
  reg  [6:0] m_p2, m_p1;
  reg  [3:0] quot_sel;
  wire [1:0] cmp_res;

  assign {rem_sign, rem_top} = rem_sum_top_i + rem_carry_top_i;

  assign mod_rem_top = rem_top ^ {7{rem_sign}};

  always @*
  begin
    case (d_top_i)
      3'h0: {m_p2, m_p1} = {7'd25, 7'd08};
      3'h1: {m_p2, m_p1} = {7'd28, 7'd09};
      3'h2: {m_p2, m_p1} = {7'd31, 7'd10};
      3'h3: {m_p2, m_p1} = {7'd33, 7'd11};
      3'h4: {m_p2, m_p1} = {7'd36, 7'd11};
      3'h5: {m_p2, m_p1} = {7'd39, 7'd13};
      3'h6: {m_p2, m_p1} = {7'd41, 7'd13};
      3'h7: {m_p2, m_p1} = {7'd47, 7'd13};
      default
      begin
        m_p2 = {7{1'bx}};
        m_p1 = {7{1'bx}};
      end
    endcase
  end

  assign cmp_res = {mod_rem_top < m_p1,
                    mod_rem_top < m_p2};

  always @*
  case ({rem_sign, cmp_res})
    3'b1_00:
      quot_sel = 4'b1000; // -2
    3'b1_01:
      quot_sel = 4'b0100; // -1
    3'b1_11, 3'b1_10, 3'b0_11, 3'b0_10:
      quot_sel = 4'b0000; //  0
    3'b0_01:
      quot_sel = 4'b0010; //  1
    3'b0_00:
      quot_sel = 4'b0001; //  2
    default:
      quot_sel = 4'bxxxx;
  endcase

  assign quot_dig_o = quot_sel;

endmodule
