//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2013 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : $Date: 2010-12-13 15:27:42 +0000 (Mon, 13 Dec 2010) $
//
//      Revision            : $Revision: 156631 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract :TSMC 180ULL library clock gating cell
//-----------------------------------------------------------------------------

module cm0_acg   #(parameter CBAW = 0,
                   parameter ACG  = 1)
                  (input  wire CLKIN,
                   input  wire ENABLE,
                   input  wire SE,
                   output wire CLKOUT );

  // ------------------------------------------------------------
  //       If clock gating is not required,
  //       indicated by the ACG parameter being passed in as 0,
  //       CLKOUT must be assigned directly from CLKIN
  // ------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Extra terms present to remove model if cfg_acg is 0

   wire          gated_clk;
   wire cfg_acg    = (CBAW == 0) ? (ACG != 0) : 1'bZ;

   wire clk_out    = cfg_acg ? gated_clk : CLKIN;

   assign CLKOUT   = clk_out;

  //----------------------------------------------------------------------------
  // Instantiated clock gating cell
  //----------------------------------------------------------------------------

  TLATNTSCA_X8_A7TULL ICGCell (.ECK (gated_clk), .E (ENABLE), .SE (SE), .CK (CLKIN));

endmodule
