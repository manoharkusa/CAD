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
//      Checked In          : $Date: 2009-05-22 16:07:59 +0100 (Fri, 22 May 2009) $
//
//      Revision            : $Revision: 109035 $
//
//      Release Information : CORTEX-A5-FPU-r0p1-00rel0
//
//-----------------------------------------------------------------------------


`include "ca5dpu_params.v"

module ca5dpu_fp_clz64 (
  input  wire [63:0] clz_input_f3_i,
  output reg  [5:0]  fp_clz_res_f3_o,
  output wire [63:0] neon_clz_res_f3_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [3:0]  clz_byte0;
  reg [3:0]  clz_byte1;
  reg [3:0]  clz_byte2;
  reg [3:0]  clz_byte3;
  reg [3:0]  clz_byte4;
  reg [3:0]  clz_byte5;
  reg [3:0]  clz_byte6;
  reg [3:0]  clz_byte7;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [7:0]  check_byte;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Byte evaluation
  // ------------------------------------------------------

  // Evaluate each byte to see if it contains a '1'
  assign check_byte[0] = |(clz_input_f3_i[ 7: 0]);
  assign check_byte[1] = |(clz_input_f3_i[15: 8]);
  assign check_byte[2] = |(clz_input_f3_i[23:16]);
  assign check_byte[3] = |(clz_input_f3_i[31:24]);
  assign check_byte[4] = |(clz_input_f3_i[39:32]);
  assign check_byte[5] = |(clz_input_f3_i[47:40]);
  assign check_byte[6] = |(clz_input_f3_i[55:48]);
  assign check_byte[7] = |(clz_input_f3_i[63:56]);

  // ------------------------------------------------------
  // Byte-0 leading '1' check
  // ------------------------------------------------------

  always @*
    case (clz_input_f3_i[7:0])
      // Most significant '1' in bit 7
      `def_1xxx_xxxx : clz_byte0 = 4'b0000;
      // Most significant '1' in bit 6
      `def_01xx_xxxx : clz_byte0 = 4'b0001;
      // Most significant '1' in bit 5
      `def_001x_xxxx : clz_byte0 = 4'b0010;
      // Most significant '1' in bit 4
      `def_0001_xxxx : clz_byte0 = 4'b0011;
      // Most significant '1' in bit 3
      `def_0000_1xxx : clz_byte0 = 4'b0100;
      // Most significant '1' in bit 2
      `def_0000_01xx : clz_byte0 = 4'b0101;
      // Most significant '1' in bit 1
      `def_0000_001x : clz_byte0 = 4'b0110;
      // Most significant '1' in bit 0
      8'b0000_0001   : clz_byte0 = 4'b0111;
      8'b0000_0000   : clz_byte0 = 4'b1000;
      default        : clz_byte0 = 4'bxxxx;
    endcase

  // ------------------------------------------------------
  // Byte-1 leading '1' check
  // ------------------------------------------------------

  always @*
    case (clz_input_f3_i[15:8])
      // Most significant '1' in bit 7
      `def_1xxx_xxxx : clz_byte1 = 4'b0000;
      // Most significant '1' in bit 6
      `def_01xx_xxxx : clz_byte1 = 4'b0001;
      // Most significant '1' in bit 5
      `def_001x_xxxx : clz_byte1 = 4'b0010;
      // Most significant '1' in bit 4
      `def_0001_xxxx : clz_byte1 = 4'b0011;
      // Most significant '1' in bit 3
      `def_0000_1xxx : clz_byte1 = 4'b0100;
      // Most significant '1' in bit 2
      `def_0000_01xx : clz_byte1 = 4'b0101;
      // Most significant '1' in bit 1
      `def_0000_001x : clz_byte1 = 4'b0110;
      // Most significant '1' in bit 0
      8'b0000_0001   : clz_byte1 = 4'b0111;
      8'b0000_0000   : clz_byte1 = 4'b1000;
      default        : clz_byte1 = 4'bxxxx;
    endcase

  // ------------------------------------------------------
  // Byte-2 leading '1' check
  // ------------------------------------------------------

  always @*
    case (clz_input_f3_i[23:16])
      // Most significant '1' in bit 7
      `def_1xxx_xxxx : clz_byte2 = 4'b0000;
      // Most significant '1' in bit 6
      `def_01xx_xxxx : clz_byte2 = 4'b0001;
      // Most significant '1' in bit 5
      `def_001x_xxxx : clz_byte2 = 4'b0010;
      // Most significant '1' in bit 4
      `def_0001_xxxx : clz_byte2 = 4'b0011;
      // Most significant '1' in bit 3
      `def_0000_1xxx : clz_byte2 = 4'b0100;
      // Most significant '1' in bit 2
      `def_0000_01xx : clz_byte2 = 4'b0101;
      // Most significant '1' in bit 1
      `def_0000_001x : clz_byte2 = 4'b0110;
      // Most significant '1' in bit 0
      8'b0000_0001   : clz_byte2 = 4'b0111;
      8'b0000_0000   : clz_byte2 = 4'b1000;
      default        : clz_byte2 = 4'bxxxx;
    endcase

  // ------------------------------------------------------
  // Byte-3 leading '1' check
  // ------------------------------------------------------

  always @*
    case (clz_input_f3_i[31:24])
      // Most significant '1' in bit 7
      `def_1xxx_xxxx : clz_byte3 = 4'b0000;
      // Most significant '1' in bit 6
      `def_01xx_xxxx : clz_byte3 = 4'b0001;
      // Most significant '1' in bit 5
      `def_001x_xxxx : clz_byte3 = 4'b0010;
      // Most significant '1' in bit 4
      `def_0001_xxxx : clz_byte3 = 4'b0011;
      // Most significant '1' in bit 3
      `def_0000_1xxx : clz_byte3 = 4'b0100;
      // Most significant '1' in bit 2
      `def_0000_01xx : clz_byte3 = 4'b0101;
      // Most significant '1' in bit 1
      `def_0000_001x : clz_byte3 = 4'b0110;
      // Most significant '1' in bit 0
      8'b0000_0001   : clz_byte3 = 4'b0111;
      8'b0000_0000   : clz_byte3 = 4'b1000;
      default        : clz_byte3 = 4'bxxxx;
    endcase

  // ------------------------------------------------------
  // Byte-4 leading '1' check
  // ------------------------------------------------------

  always @*
    case (clz_input_f3_i[39:32])
      // Most significant '1' in bit 7
      `def_1xxx_xxxx : clz_byte4 = 4'b0000;
      // Most significant '1' in bit 6
      `def_01xx_xxxx : clz_byte4 = 4'b0001;
      // Most significant '1' in bit 5
      `def_001x_xxxx : clz_byte4 = 4'b0010;
      // Most significant '1' in bit 4
      `def_0001_xxxx : clz_byte4 = 4'b0011;
      // Most significant '1' in bit 3
      `def_0000_1xxx : clz_byte4 = 4'b0100;
      // Most significant '1' in bit 2
      `def_0000_01xx : clz_byte4 = 4'b0101;
      // Most significant '1' in bit 1
      `def_0000_001x : clz_byte4 = 4'b0110;
      // Most significant '1' in bit 0
      8'b0000_0001   : clz_byte4 = 4'b0111;
      8'b0000_0000   : clz_byte4 = 4'b1000;
      default        : clz_byte4 = 4'bxxxx;
    endcase

  // ------------------------------------------------------
  // Byte-5 leading '1' check
  // ------------------------------------------------------

  always @*
    case (clz_input_f3_i[47:40])
      // Most significant '1' in bit 7
      `def_1xxx_xxxx : clz_byte5 = 4'b0000;
      // Most significant '1' in bit 6
      `def_01xx_xxxx : clz_byte5 = 4'b0001;
      // Most significant '1' in bit 5
      `def_001x_xxxx : clz_byte5 = 4'b0010;
      // Most significant '1' in bit 4
      `def_0001_xxxx : clz_byte5 = 4'b0011;
      // Most significant '1' in bit 3
      `def_0000_1xxx : clz_byte5 = 4'b0100;
      // Most significant '1' in bit 2
      `def_0000_01xx : clz_byte5 = 4'b0101;
      // Most significant '1' in bit 1
      `def_0000_001x : clz_byte5 = 4'b0110;
      // Most significant '1' in bit 0
      8'b0000_0001   : clz_byte5 = 4'b0111;
      8'b0000_0000   : clz_byte5 = 4'b1000;
      default        : clz_byte5 = 4'bxxxx;
    endcase

  // ------------------------------------------------------
  // Byte-6 leading '1' check
  // ------------------------------------------------------

  always @*
    case (clz_input_f3_i[55:48])
      // Most significant '1' in bit 7
      `def_1xxx_xxxx : clz_byte6 = 4'b0000;
      // Most significant '1' in bit 6
      `def_01xx_xxxx : clz_byte6 = 4'b0001;
      // Most significant '1' in bit 5
      `def_001x_xxxx : clz_byte6 = 4'b0010;
      // Most significant '1' in bit 4
      `def_0001_xxxx : clz_byte6 = 4'b0011;
      // Most significant '1' in bit 3
      `def_0000_1xxx : clz_byte6 = 4'b0100;
      // Most significant '1' in bit 2
      `def_0000_01xx : clz_byte6 = 4'b0101;
      // Most significant '1' in bit 1
      `def_0000_001x : clz_byte6 = 4'b0110;
      // Most significant '1' in bit 0
      8'b0000_0001   : clz_byte6 = 4'b0111;
      8'b0000_0000   : clz_byte6 = 4'b1000;
      default        : clz_byte6 = 4'bxxxx;
    endcase

  // ------------------------------------------------------
  // Byte-7 leading '1' check
  // ------------------------------------------------------

  always @*
    case (clz_input_f3_i[63:56])
      // Most significant '1' in bit 7
      `def_1xxx_xxxx : clz_byte7 = 4'b0000;
      // Most significant '1' in bit 6yes
      `def_01xx_xxxx : clz_byte7 = 4'b0001;
      // Most significant '1' in bit 5
      `def_001x_xxxx : clz_byte7 = 4'b0010;
      // Most significant '1' in bit 4
      `def_0001_xxxx : clz_byte7 = 4'b0011;
      // Most significant '1' in bit 3
      `def_0000_1xxx : clz_byte7 = 4'b0100;
      // Most significant '1' in bit 2
      `def_0000_01xx : clz_byte7 = 4'b0101;
      // Most significant '1' in bit 1
      `def_0000_001x : clz_byte7 = 4'b0110;
      // Most significant '1' in bit 0
      8'b0000_0001   : clz_byte7 = 4'b0111;
      8'b0000_0000   : clz_byte7 = 4'b1000;
      default        : clz_byte7 = 4'bxxxx;
    endcase

  // ------------------------------------------------------
  // Produce the result
  // ------------------------------------------------------

  always @*
        case (check_byte[7:0])
          // Most significant '1' in bit 7
          `def_1xxx_xxxx : fp_clz_res_f3_o[5:0] = {3'b000, clz_byte7[2:0]};
          // Most significant '1' is in Byte6
          `def_01xx_xxxx : fp_clz_res_f3_o[5:0] = {3'b001, clz_byte6[2:0]};
          // Most significant '1' is in Byte5
          `def_001x_xxxx : fp_clz_res_f3_o[5:0] = {3'b010, clz_byte5[2:0]};
          // Most significant '1' is in Byte4
          `def_0001_xxxx : fp_clz_res_f3_o[5:0] = {3'b011, clz_byte4[2:0]};
          // Most significant '1' is in Byte3
          `def_0000_1xxx : fp_clz_res_f3_o[5:0] = {3'b100, clz_byte3[2:0]};
          // Most significant '1' is in Byte2
          `def_0000_01xx : fp_clz_res_f3_o[5:0] = {3'b101, clz_byte2[2:0]};
          // Most significant '1' is in Byte1
          `def_0000_001x : fp_clz_res_f3_o[5:0] = {3'b110, clz_byte1[2:0]};
          // Most significant '1' is in Byte0 or operand value is zero
           8'b0000_0001,
           8'b0000_0000  : fp_clz_res_f3_o[5:0] = {3'b111, clz_byte0[2:0]};
          default        : fp_clz_res_f3_o[5:0] = {6{1'bx}};
        endcase

  assign neon_clz_res_f3_o[31:0]  = {clz_byte7, clz_byte6, clz_byte5, clz_byte4, clz_byte3, clz_byte2, clz_byte1, clz_byte0};
  assign neon_clz_res_f3_o[63:32] = {{24{1'b0}}, check_byte[7:0]};

endmodule
