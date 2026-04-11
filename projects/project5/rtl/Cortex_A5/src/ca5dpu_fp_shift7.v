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

module ca5dpu_fp_shift7 #(parameter in_width = 82, out_width = 56)
(
  input  wire [in_width-1:0]    data_i,
  input  wire                   andbit_i,
  input  wire                   fillbit_i,
  input  wire [ 6:0]            shift_i,
  output wire [out_width-1:0]   result_o,
  output wire                   andbit_o
);

  wire [in_width:0] shv00, shv64, shv32, shv16, shv8, shv4, shv2, shv1;

  assign shv00 = {data_i, andbit_i};

  assign shv1  = shift_i[0] ? {     fillbit_i,   shv00[in_width: 3],|shv00[ 2:1],&{shv00[ 2:2], shv00[0]}} : shv00;
  assign shv2  = shift_i[1] ? { { 2{fillbit_i}}, shv1 [in_width: 4],|shv1 [ 3:1],&{shv1 [ 3:2], shv1 [0]}} : shv1 ;
  assign shv4  = shift_i[2] ? { { 4{fillbit_i}}, shv2 [in_width: 6],|shv2 [ 5:1],&{shv2 [ 5:2], shv2 [0]}} : shv2 ;
  assign shv16 = shift_i[4] ? { {16{fillbit_i}}, shv4 [in_width:18],|shv4 [17:1],&{shv4 [17:2], shv4 [0]}} : shv4 ;
  assign shv64 = shift_i[6] ? { {64{fillbit_i}}, shv16[in_width:66],|shv16[65:1],&{shv16[65:2], shv16[0]}} : shv16;
  assign shv32 = shift_i[5] ? { {32{fillbit_i}}, shv64[in_width:34],|shv64[33:1],&{shv64[33:2], shv64[0]}} : shv64;
  assign shv8  = shift_i[3] ? { { 8{fillbit_i}}, shv32[in_width:10],|shv32[ 9:1],&{shv32[ 9:2], shv32[0]}} : shv32;

  assign result_o = shv8[out_width:1];
  assign andbit_o = shv8[0];

endmodule

