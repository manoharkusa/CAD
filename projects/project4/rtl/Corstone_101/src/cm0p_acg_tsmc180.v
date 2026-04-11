//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2008-2013 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//   Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
//   Revision            : $Revision: 371321 $
//   Release information : Cortex-M System Design Kit-r1p1-00rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------

module cm0p_acg
  (input  wire CLKIN,
   input  wire ENABLE,
   input  wire DFTSE,
   output wire CLKOUT);

   // ------------------------------------------------------------
   // NOTE: THIS FILE PROVIDES AN EXAMPLE LIBRARY SPECIFIC ICG
   //       CELL INSTANTIATION. SIGNALS USED ARE AS FOLLOWS:
   //
   //          CLKIN  - CLOCK INPUT
   //          ENABLE - ACTIVE HIGH CLOCK ENABLE INPUT
   //          DFTSE  - ENABLE BYPASS FOR SCAN TEST PURPOSES
   //          CLKOUT - CLOCK OUTPUT OF CLOCK GATE CELL
   //
   // ------------------------------------------------------------

   // ------------------------------------------------------------
   // Library specific clock gate cell instantiation
   // ------------------------------------------------------------

   TLATNTSCA_X8_A7TULL uICGCell
     (.ECK (CLKOUT),
      .E   (ENABLE),
      .SE  (DFTSE),
      .CK  (CLKIN));

endmodule

// ----------------------------------------------------------------------------
// EOF
// ----------------------------------------------------------------------------
