//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2011 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
//
//      Revision            : $Revision: 371321 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : IRQ synchronizer
//-----------------------------------------------------------------------------
module cmsdk_irq_sync (
  input  wire  RSTn,
  input  wire  CLK,
  input  wire  IRQIN,
  output wire  IRQOUT);

  reg  [2:0] sync_reg;
  wire [2:0] nxt_sync_reg;

  assign nxt_sync_reg = {sync_reg[1:0],IRQIN};

  always @(posedge CLK or negedge RSTn)
    begin
    if (~RSTn)
      sync_reg <= 3'b000;
    else
      sync_reg <= nxt_sync_reg;
    end

  // Only consider valid if it is high for two cycles
  assign   IRQOUT  = sync_reg[2] & sync_reg[1];


endmodule
