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
//      Checked In          : $Date: 2009-09-17 17:46:29 +0100 (Thu, 17 Sep 2009) $
//
//      Revision            : $Revision: 118165 $
//
//      Release Information : CORTEX-A5-FPU-r0p1-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Floating point div/sqrt
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs IEEE divide and sqrt with all rounding modes.
// Two bits of the result fraction generated per cycle.
//

`include "ca5dpu_params.v"

module ca5dpu_fp_div (
  input  wire        clk,
  input  wire        stall_wr_i,
  input  wire        flush_ret_i,
  input  wire        start_div_f2_i,
  input  wire        sqrt_f2_i,
  input  wire        double_prec_f2_i,
  input  wire [ 1:0] round_mode_f2_i,
  input  wire        res_zero_f2_i,
  input  wire        res_infinite_f2_i,
  input  wire        res_nan_f2_i,
  input  wire        invalid_f2_i,
  input  wire        divbyzero_f2_i,
  input  wire        in_flushzero_f2_i,
  input  wire        out_sign_f2_i,
  input  wire [10:0] a_exp_f2_i,
  input  wire [10:0] b_exp_f2_i,
  input  wire [52:0] a_mant_f2_i,
  input  wire [52:0] b_mant_f2_i,
  input  wire [ 5:0] a_mant_lz_f2_i,
  input  wire [ 5:0] b_mant_lz_f2_i,
  input  wire        nan_sel_a_f2_i,
  input  wire        nan_sel_b_f2_i,

  output wire        out_sign_f3_o,
  output wire [12:0] out_exp_f3_o,
  output wire [53:0] out_frac_f3_o,
  output wire        roundbit_f3_o,
  output wire        stickybit_f3_o,
  output wire [ 6:0] shift_f3_o,
  output wire        double_prec_f3_o,
  output wire [ 1:0] round_mode_f3_o,
  output wire        res_infinite_f3_o,
  output wire        res_zero_f3_o,
  output wire        res_nan_f3_o,
  output wire        invalid_f3_o,
  output wire        divbyzero_f3_o,
  output wire        in_flushzero_f3_o,
  output wire        div_finished_iss_o
);

  // Register declarations
  reg         divbyzero_f3;
  reg         double_prec_f3;
  reg         in_flushzero_f3;
  reg         invalid_f3;
  reg         new_quot_m1_sel;
  reg         new_quot_sel;
  reg         out_sign_f3;
  reg         res_infinite_f3;
  reg         res_nan_f3;
  reg         res_zero_f3;
  reg         sqrt_f3;
  reg         start_div_f3;
  reg  [ 1:0] round_mode_f3;
  reg  [ 2:0] nxt_sel_bits_f3;
  reg  [ 2:0] sel_bits_f3;
  reg  [ 4:0] div_fsm_f3;
  reg  [ 5:0] a_mant_lz_f3;
  reg  [ 5:0] b_mant_lz_f3;
  reg  [12:0] quot_exp_f3;
  reg  [27:0] nxt_raw_mask_f3;
  reg  [27:0] raw_mask_f3;
  reg  [52:0] divisor_f3;
  reg  [53:0] nxt_rem_carry_f3;
  reg  [53:0] raw_rem_carry_f3;
  reg  [54:0] new_quot_dig;
  reg  [54:0] new_quot_m1_dig;
  reg  [54:0] nxt_quot_f3;
  reg  [54:0] nxt_quot_m1_f3;
  reg  [54:0] quot_f3;
  reg  [54:0] quot_m1_f3;
  reg  [55:0] nxt_rem_sum_f3;
  reg  [55:0] rem_sum_f3;

  // Wire declarations
  wire        enable_f3;
  wire        nxt_sqrt_f3;
  wire        nxt_start_div_f3;
  wire        preantepenultimate_cycle_f3;
  wire        rem_neg;
  wire        rem_nonzero;
  wire        renorm_dividend;
  wire        renorm_divisor;
  wire [ 3:0] quot_dig;
  wire [ 4:0] nxt_div_fsm_f3;
  wire [ 4:0] fsm_start_val;
  wire [ 5:0] renorm_shift_amount;
  wire [ 6:0] shift_f3;
  wire [10:0] bias;
  wire [12:0] a_exp_adj;
  wire [12:0] quot_exp_f2;
  wire [52:0] nxt_divisor_f3;
  wire [53:0] dividend;
  wire [53:0] msk_dig1;
  wire [53:0] new_rem_carry_f3;
  wire [53:0] new_rem_sum_f3;
  wire [55:0] rem_carry_f3;
  wire [53:0] renorm_shift_in;
  wire [53:0] renorm_shift_out;
  wire [53:0] update_val;
  wire [54:0] msk_dig2;
  wire [54:0] msk_inv_quot_f3;
  wire [54:0] nan_frac;
  wire [54:0] new_quot_f3;
  wire [54:0] new_quot_m1_f3;
  wire [54:0] quot_out;
  wire [56:0] mask_f3;

  // --- F2 stage ---

  assign bias = double_prec_f2_i ? 11'h3ff
                                 : 11'h07f;

  assign a_exp_adj = {2'b00, a_exp_f2_i} - a_mant_lz_f2_i + bias;

  assign quot_exp_f2 = sqrt_f2_i ? {1'b0, a_exp_adj[12:1]}
                                 : a_exp_adj - b_exp_f2_i + b_mant_lz_f2_i - 1'b1;

  assign nxt_start_div_f3 = start_div_f2_i & (~stall_wr_i | flush_ret_i) | renorm_divisor | renorm_dividend;


  // Load static register values

  always @(posedge clk)
  begin
    start_div_f3 <= nxt_start_div_f3;
    if (start_div_f2_i & (~stall_wr_i | flush_ret_i)) begin
      sqrt_f3           <= sqrt_f2_i;
      double_prec_f3    <= double_prec_f2_i;
      round_mode_f3     <= round_mode_f2_i;
      res_zero_f3       <= res_zero_f2_i;
      res_infinite_f3   <= res_infinite_f2_i;
      res_nan_f3        <= res_nan_f2_i;
      invalid_f3        <= invalid_f2_i;
      divbyzero_f3      <= divbyzero_f2_i;
      in_flushzero_f3   <= in_flushzero_f2_i;
      out_sign_f3       <= out_sign_f2_i;
      quot_exp_f3       <= quot_exp_f2;
      a_mant_lz_f3      <= a_mant_lz_f2_i;
      b_mant_lz_f3      <= b_mant_lz_f2_i;
    end
  end

  assign nxt_sqrt_f3 = start_div_f2_i ? sqrt_f2_i : sqrt_f3;

  // Calculate whether the operands need to be normalized using extra cycles
  assign renorm_dividend = start_div_f3 & ~res_zero_f3 & ~res_infinite_f3 & ~res_nan_f3 & (~sqrt_f3 & ~rem_sum_f3[52] | sqrt_f3 & ~rem_sum_f3[55]);
  assign renorm_divisor  = start_div_f3 & ~res_zero_f3 & ~res_infinite_f3 & ~res_nan_f3 & ~renorm_dividend & ~sqrt_f3 & ~divisor_f3[52];

  assign renorm_shift_in = {54{renorm_divisor}}  & {1'b0, divisor_f3} |
                           {54{renorm_dividend}} & rem_sum_f3[53:0];
  assign renorm_shift_amount = {6{renorm_divisor}}  & b_mant_lz_f3 |
                               {6{renorm_dividend}} & a_mant_lz_f3;

  assign renorm_shift_out = renorm_shift_in << renorm_shift_amount;


  // Update iteration registers

  assign dividend = start_div_f2_i  ? (~sqrt_f2_i | ~a_exp_adj[0]) ? {1'b0, a_mant_f2_i}
                                                                   : {a_mant_f2_i, 1'b0} :
                    renorm_dividend ? renorm_shift_out :
                                      rem_sum_f3[53:0];

  assign nxt_divisor_f3 = start_div_f2_i ? b_mant_f2_i
                                         : renorm_shift_out[52:0];

  assign nan_frac = {55{nan_sel_a_f2_i}} & {1'b0, a_mant_f2_i, 1'b0}  |
                    {55{nan_sel_b_f2_i}} & {1'b0, b_mant_f2_i, 1'b0}  |
                    {3'b011, {52{1'b0}} };

  always @*
  begin
    case (nxt_start_div_f3)
      1'b0: begin
        nxt_rem_sum_f3    = {new_rem_sum_f3, 2'b00};
        nxt_rem_carry_f3  = new_rem_carry_f3;
        nxt_sel_bits_f3   = new_quot_f3[52:50] | {3{new_quot_f3[54]}};
        nxt_raw_mask_f3   = {1'b1, raw_mask_f3[27:1]};
        nxt_quot_f3       = new_quot_f3;
        nxt_quot_m1_f3    = new_quot_m1_f3;
      end

      1'b1: begin
        nxt_rem_sum_f3    = (nxt_sqrt_f3 & ~(start_div_f2_i & ~a_mant_f2_i[52])) ? {2'b11, dividend}
                                                                                 : {2'b00, dividend};
        nxt_rem_carry_f3  = 54'h00_0000_0000_0000;
        nxt_sel_bits_f3   = nxt_sqrt_f3 ? 3'b101
                                        : nxt_divisor_f3[51:49];
        nxt_raw_mask_f3   = {nxt_sqrt_f3, 27'h000_0000};
        nxt_quot_f3       = start_div_f2_i & res_nan_f2_i ? nan_frac
                                                          : {nxt_sqrt_f3, 54'h00_0000_0000_0000};
        nxt_quot_m1_f3    = 55'h00_0000_0000_0000;
      end

      default: begin
        nxt_rem_sum_f3    = {56{1'bx}};
        nxt_rem_carry_f3  = {54{1'bx}};
        nxt_sel_bits_f3   = {3{1'bx}};
        nxt_raw_mask_f3   = {28{1'bx}};
        nxt_quot_f3       = {55{1'bx}};
        nxt_quot_m1_f3    = {55{1'bx}};
      end
    endcase
  end

  // Update iteration registers

  always @(posedge clk)
  begin
    if (start_div_f2_i & (~stall_wr_i | flush_ret_i) & ~sqrt_f2_i | renorm_divisor)
      divisor_f3        <= nxt_divisor_f3;

    if (start_div_f2_i & (~stall_wr_i | flush_ret_i) | renorm_divisor | enable_f3 & sqrt_f3 & ~res_nan_f3)
    begin
      sel_bits_f3       <= nxt_sel_bits_f3;
    end

    if (start_div_f2_i & (~stall_wr_i | flush_ret_i) | enable_f3 & ~res_nan_f3)
    begin
      rem_sum_f3        <= nxt_rem_sum_f3;
      raw_rem_carry_f3  <= nxt_rem_carry_f3;
      raw_mask_f3       <= nxt_raw_mask_f3;
      quot_f3           <= nxt_quot_f3;
      quot_m1_f3        <= nxt_quot_m1_f3;
    end
  end

  // --- F3 stage ---


  // Generate control signals and drive FSM to control iteration

  assign preantepenultimate_cycle_f3 = ~start_div_f3 & (div_fsm_f3 == 5'h03);
  assign enable_f3 = start_div_f3 | (div_fsm_f3 != 0);

  assign fsm_start_val = double_prec_f3 ? sqrt_f3 ? 5'd26 : 5'd27
                                        : sqrt_f3 ? 5'd12 : 5'd13;

  assign nxt_div_fsm_f3 = start_div_f3 ? fsm_start_val[4:0]
                                       : div_fsm_f3 - 1'b1;

  always @(posedge clk)
    if (enable_f3)
      div_fsm_f3 <= nxt_div_fsm_f3;


  // Calculate output exponent and final shift required
  assign shift_f3 = (~res_nan_f3 &  quot_exp_f3[12] & (~&quot_exp_f3[11:6] | (~double_prec_f3 & ~quot_exp_f3[5])))
                                                                          ? 7'h7f                                               :
                    (~res_nan_f3 & (quot_exp_f3[12] | quot_exp_f3 == 0))  ? (double_prec_f3 ? 7'd54 : 7'd83) - quot_exp_f3[6:0] :
                                                                            (double_prec_f3 ? 7'd53 : 7'd82);


  assign rem_carry_f3 = {raw_rem_carry_f3, 2'b00};

  // Expand mask shift register into mask value
  assign mask_f3 = {1'b1,
                    {2{raw_mask_f3[27]}},
                    {2{raw_mask_f3[26]}},
                    {2{raw_mask_f3[25]}},
                    {2{raw_mask_f3[24]}},
                    {2{raw_mask_f3[23]}},
                    {2{raw_mask_f3[22]}},
                    {2{raw_mask_f3[21]}},
                    {2{raw_mask_f3[20]}},
                    {2{raw_mask_f3[19]}},
                    {2{raw_mask_f3[18]}},
                    {2{raw_mask_f3[17]}},
                    {2{raw_mask_f3[16]}},
                    {2{raw_mask_f3[15]}},
                    {2{raw_mask_f3[14]}},
                    {2{raw_mask_f3[13]}},
                    {2{raw_mask_f3[12]}},
                    {2{raw_mask_f3[11]}},
                    {2{raw_mask_f3[10]}},
                    {2{raw_mask_f3[ 9]}},
                    {2{raw_mask_f3[ 8]}},
                    {2{raw_mask_f3[ 7]}},
                    {2{raw_mask_f3[ 6]}},
                    {2{raw_mask_f3[ 5]}},
                    {2{raw_mask_f3[ 4]}},
                    {2{raw_mask_f3[ 3]}},
                    {2{raw_mask_f3[ 2]}},
                    {2{raw_mask_f3[ 1]}},
                    {2{raw_mask_f3[ 0]}}};



  // Calculate result digit for current iteration

  ca5dpu_fp_div_quot_sel u_quot_sel(.d_top_i          (sel_bits_f3),
                                    .rem_sum_top_i    (rem_sum_f3[55:48]),
                                    .rem_carry_top_i  (rem_carry_f3[55:48]),
                                    .quot_dig_o       (quot_dig));

  // Generate value to update remainder by

  assign msk_inv_quot_f3 = ~quot_f3 & mask_f3[54:0];

  assign msk_dig2 = mask_f3[54:0] ^ mask_f3[56:2];
  assign msk_dig1 = mask_f3[54:1] ^ {1'b1, mask_f3[56:4]};

  assign update_val = {54{quot_dig[0]}} & (sqrt_f3 ? (msk_inv_quot_f3[53:0] | msk_dig2[53:0]) : {     ~divisor_f3,1'b1}) |
                      {54{quot_dig[1]}} & (sqrt_f3 ? (msk_inv_quot_f3[54:1] | msk_dig1[53:0]) : {1'b1,~divisor_f3     }) |
                      {54{quot_dig[2]}} & (sqrt_f3 ? (quot_m1_f3[54:1]      | msk_dig1[53:0]) : {1'b0, divisor_f3     }) |
                      {54{quot_dig[3]}} & (sqrt_f3 ? (quot_m1_f3[53:0]      | msk_dig2[53:0]) : {      divisor_f3,1'b0});

  // Update the remainder

  // The top two bits of the addition are thrown away - they should just be
  // replicated sign bits

  // Perform a carry-save addition

  assign new_rem_sum_f3[53:0]   = rem_sum_f3[53:0] ^ rem_carry_f3[53:0] ^ update_val[53:0];

  assign new_rem_carry_f3[53:1] = rem_sum_f3[52:0]   & rem_carry_f3[52:0] |
                                  rem_sum_f3[52:0]   & update_val[52:0]   |
                                  rem_carry_f3[52:0] & update_val[52:0];
  assign new_rem_carry_f3[0]    = (quot_dig[1] | quot_dig[0]) & ~sqrt_f3;


  // Update result with new digit

  always @*
  begin : update_sqrt_quot
    case (quot_dig)
      4'b1000: // -2
      begin
        new_quot_dig    = 55'h2AAAAAAAAAAAAA;
        new_quot_m1_dig = 55'h55555555555555;
        new_quot_sel    = 1'b1;
        new_quot_m1_sel = 1'b1;
      end
      4'b0100: // -1
      begin
        new_quot_dig    = 55'h7FFFFFFFFFFFFF;
        new_quot_m1_dig = 55'h2AAAAAAAAAAAAA;
        new_quot_sel    = 1'b1;
        new_quot_m1_sel = 1'b1;
      end
      4'b0000: //  0
      begin
        new_quot_dig    = 55'h00000000000000;
        new_quot_m1_dig = 55'h7FFFFFFFFFFFFF;
        new_quot_sel    = 1'b0;
        new_quot_m1_sel = 1'b1;
      end
      4'b0010: //  1
      begin
        new_quot_dig    = 55'h55555555555555;
        new_quot_m1_dig = 55'h00000000000000;
        new_quot_sel    = 1'b0;
        new_quot_m1_sel = 1'b0;
      end
      4'b0001: //  2
      begin
        new_quot_dig    = 55'h2AAAAAAAAAAAAA;
        new_quot_m1_dig = 55'h55555555555555;
        new_quot_sel    = 1'b0;
        new_quot_m1_sel = 1'b0;
      end
      default:
      begin
        new_quot_dig    = {55{1'bx}};
        new_quot_m1_dig = {55{1'bx}};
        new_quot_sel    = 1'bx;
        new_quot_m1_sel = 1'bx;
      end
    endcase
  end

  assign new_quot_f3    = ((new_quot_sel    ? quot_m1_f3 : quot_f3) & mask_f3[54:0])
                               | (new_quot_dig    & msk_dig2);
  assign new_quot_m1_f3 = ((new_quot_m1_sel ? quot_m1_f3 : quot_f3) & mask_f3[54:0])
                               | (new_quot_m1_dig & msk_dig2);


  // Generate final result

  wire [55:0] tmp_res = rem_sum_f3 + rem_carry_f3;

  assign rem_neg     = tmp_res[55];
  assign rem_nonzero = tmp_res != {56{1'b0}};

  assign quot_out = (rem_neg & ~res_nan_f3) ? quot_m1_f3 : quot_f3;


  // Output aliasing

  assign div_finished_iss_o = preantepenultimate_cycle_f3;

  assign double_prec_f3_o   = double_prec_f3;
  assign round_mode_f3_o    = round_mode_f3;
  assign res_zero_f3_o      = res_zero_f3;
  assign res_infinite_f3_o  = res_infinite_f3;
  assign res_nan_f3_o       = res_nan_f3;
  assign invalid_f3_o       = invalid_f3;
  assign divbyzero_f3_o     = divbyzero_f3;
  assign in_flushzero_f3_o  = in_flushzero_f3;

  assign shift_f3_o         = shift_f3;

  assign out_sign_f3_o      = out_sign_f3;
  assign out_exp_f3_o       = quot_exp_f3;
  assign out_frac_f3_o      = quot_out[54:1];
  assign roundbit_f3_o      = quot_out[0];
  assign stickybit_f3_o     = rem_nonzero;

endmodule // ca5dpu_fp_div
