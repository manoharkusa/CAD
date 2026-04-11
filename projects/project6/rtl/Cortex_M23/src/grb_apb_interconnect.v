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


module grb_apb_interconnect
#(
parameter MCUROMBASE = 32'hE0000000,
parameter TPIUBASE   = 32'hE0000000,
parameter ETMBASE    = 32'hE0000000,
parameter CTIBASE    = 32'hE0000000,
parameter SBISTBASE  = 32'hE0000000
)
(
  input wire      [19:12] paddr_i,
  input wire              psel_i,

  input wire              pready0_i,
  input wire      [31:0]  prdata0_i,

  input wire              pready1_i,
  input wire      [31:0]  prdata1_i,

  input wire              pready2_i,
  input wire      [31:0]  prdata2_i,
  input wire              pslverr2_i,

  input wire              pready3_i,
  input wire      [31:0]  prdata3_i,
  input wire              pslverr3_i,

  input wire              pready4_i,
  input wire      [31:0]  prdata4_i,
  input wire              pslverr4_i,
  input wire              pready4chk_i,
  input wire       [3:0]  prdata4chk_i,
  input wire              pslverr4chk_i,

  output wire             psel0_o,
  output wire             psel1_o,
  output wire             psel2_o,
  output wire             psel3_o,
  output wire             psel4_o,
  output wire             pready_o,
  output wire     [31:0]  prdata_o,
  output wire             pslverr_o,
  output wire             preadychk_o,
  output wire      [3:0]  prdatachk_o,
  output wire             pslverrchk_o
);


  wire psel0 = psel_i & (paddr_i == MCUROMBASE[19:12]);
  wire psel1 = psel_i & (paddr_i == TPIUBASE[19:12]);
  wire psel2 = psel_i & (paddr_i == ETMBASE[19:12]);
  wire psel3 = psel_i & (paddr_i == CTIBASE[19:12]);
  wire psel4 = psel_i & (paddr_i == SBISTBASE[19:12]);

  assign psel0_o = psel0;
  assign psel1_o = psel1;
  assign psel2_o = psel2;
  assign psel3_o = psel3;
  assign psel4_o = psel4;

  assign pready_o = psel0 & pready0_i
                  | psel1 & pready1_i
                  | psel2 & pready2_i
                  | psel3 & pready3_i
                  | psel4 & pready4_i
                  | ~psel_i;

  assign prdata_o  = ({32{psel0}} & prdata0_i)
                   | ({32{psel1}} & prdata1_i)
                   | ({32{psel2}} & prdata2_i)
                   | ({32{psel3}} & prdata3_i)
                   | ({32{psel4}} & prdata4_i);


  assign pslverr_o =  psel2 & pslverr2_i
                   |  psel3 & pslverr3_i
                   |  psel4 & pslverr4_i;

  assign prdatachk_o = prdata4chk_i;
  assign pslverrchk_o = pslverr4chk_i;
  assign preadychk_o = pready4chk_i;
endmodule
