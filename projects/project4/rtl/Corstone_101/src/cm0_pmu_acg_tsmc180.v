//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2008-2011 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : $Date: 2010-06-04 11:57:55 +0100 (Fri, 04 Jun 2010) $
//
//      Revision            : $Revision: 140055 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : Clock gating cell instantiation on TSMC 180 for Power Management Unit
//-----------------------------------------------------------------------------

module cm0_pmu_acg #(parameter ACG  = 1)
                  (input  wire CLKIN,
                   input  wire ENABLE,
                   input  wire BYPASS,
                   output wire CLKOUT );

   //       If clock gating is not required,
   //       indicated by the ACG parameter being passed in as 0,
   //       CLKOUT must be assigned directly from CLKIN
   // ------------------------------------------------------------

  //----------------------------------------------------------------------------
   // Extra terms present to remove model if cfg_acg is 0

   wire          gated_clk;
   wire cfg_acg    =  (ACG == 1) ;

   wire clk_out    = cfg_acg ? gated_clk : CLKIN;

   assign CLKOUT   = clk_out;

  //----------------------------------------------------------------------------
  // Instantiated clock gating cell
  //----------------------------------------------------------------------------

  TLATNTSCA_X8_A7TULL ICGCell (.ECK (gated_clk), .E (ENABLE), .SE (BYPASS), .CK (CLKIN));


endmodule
// ---------------------------------------------------------------
// EOF
// ---------------------------------------------------------------
