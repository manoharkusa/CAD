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
// Abstract :
//-----------------------------------------------------------------------------
//
// Overview
// --------
//

`include "ca5dpu_params.v"

module ca5dpu_fp_shift6 #(parameter in_width = 48, out_width = 49, guard_width = 1)
(
  input  wire [in_width-1:0]    data_i,
  input  wire [ 5:0]            shift_i,
  output wire [out_width-1:0]   result_o
);

wire [in_width+guard_width-1:0] shv00, shv32, shv16, shv8, shv4, shv2, shv1;

assign shv00 = {data_i,{guard_width{1'd0}}};

assign shv32 = shift_i[5] ? {32'h0000_0000,shv00[in_width+guard_width-1:33],|shv00[32:0]} : shv00;
assign shv16 = shift_i[4] ? {16'h0000,     shv32[in_width+guard_width-1:17],|shv32[16:0]} : shv32;
assign shv8  = shift_i[3] ? { 8'h00,       shv16[in_width+guard_width-1: 9],|shv16[ 8:0]} : shv16;
assign shv4  = shift_i[2] ? { 4'h0,        shv8 [in_width+guard_width-1: 5],|shv8 [ 4:0]} : shv8 ;
assign shv2  = shift_i[1] ? { 2'b00,       shv4 [in_width+guard_width-1: 3],|shv4 [ 2:0]} : shv4 ;
assign shv1  = shift_i[0] ? { 1'b0,        shv2 [in_width+guard_width-1: 2],|shv2 [ 1:0]} : shv2 ;

assign result_o = shv1[out_width-1:0];

endmodule

