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

module ca5dpu_fp_shift1 #(parameter in_width = 48, out_width = 48)
(
  input  wire [in_width-1:0]    data_i,
  input  wire                   shift_i,
  output wire [out_width-1:0]   result_o
);

wire [in_width-1:0] shv1;

assign shv1  = shift_i ? {1'b0, data_i[in_width-1:2],|data_i[1:0]} : data_i;

assign result_o = shv1[out_width-1:0];

endmodule

