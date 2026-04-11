//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016,2021-2023 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//   Release Information   : AT621-MN-70005-r2p0-00rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------



`include "grebe_defs.v"

module grb_dbg_misc
  #(`GRB_TOP_PARAM_DECL)

(
  input  wire      dclk,
  input  wire      ndbgreset,

  input  wire      afvalid_tpiu_i,
  output wire      afready_tpiu_o,
  input  wire      afready_etm_i,


  input  wire      pselc_i,
  input  wire      penablec_i,
  input  wire      preadyc_i,

  input  wire      pselt_i,
  input  wire      penablet_i,

  input  wire      dbg_apb_powered_up_i,

  output wire      pselc_o,
  output wire      penablec_o,
  output wire      preadyc_o,
  output wire      preadyt_o,
  output wire      pslverrc_o,

  output wire      pselt_o,
  output wire      penablet_o,
  output wire      pslverrt_o

);

wire               cfg_cti, cfg_etm;

`ifdef ARM_GRBDBG_IS_CBAW
  localparam CBAW = 1;
`else
  localparam CBAW = 0;
`endif

generate
if(CBAW == 0) begin : gen_cbaw
   assign cfg_cti = (CTI != 0);
   assign cfg_etm = (ETM != 0);
end
endgenerate



  reg [4:0]  flush_cnt_q;

  wire flush_cnt_rst = cfg_etm ? (afvalid_tpiu_i & afready_etm_i |
                                  (flush_cnt_q == 5'd23)) :
                                  1'b1;

wire   flush_cnt_incr = cfg_etm & afvalid_tpiu_i & ~afready_etm_i;

    always @(posedge dclk or negedge ndbgreset)
       if(~ndbgreset)
         flush_cnt_q <= 5'h00;
       else if(flush_cnt_rst)
         flush_cnt_q <= 5'h00;
       else if(flush_cnt_incr)
         flush_cnt_q <= flush_cnt_q + 5'h01;

   assign  afready_tpiu_o = ~cfg_etm | (afready_etm_i | (flush_cnt_q == 5'd23));




  assign pselt_o = cfg_etm & pselt_i & dbg_apb_powered_up_i;
  assign pselc_o = cfg_cti & pselc_i & dbg_apb_powered_up_i;

  assign penablet_o = cfg_etm & penablet_i & dbg_apb_powered_up_i;
  assign penablec_o = cfg_cti & penablec_i & dbg_apb_powered_up_i;

  assign preadyc_o = preadyc_i | ~dbg_apb_powered_up_i;
  assign preadyt_o = 1'b1;

  assign pslverrt_o = cfg_etm & pselt_i & penablet_i & ~dbg_apb_powered_up_i;
  assign pslverrc_o = cfg_cti & pselc_i & penablec_i & ~dbg_apb_powered_up_i;

endmodule
