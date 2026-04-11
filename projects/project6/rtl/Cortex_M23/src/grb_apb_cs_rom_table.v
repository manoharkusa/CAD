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



module grb_apb_cs_rom_table
  #(
    parameter BASE = 32'h00000000,

    parameter JEPID           = 7'b0000000,
    parameter JEPCONTINUATION = 4'h0,
    parameter PARTNUMBER      = 12'h000,
    parameter REVISION        = 4'h0,

    parameter ENTRY0BASEADDR = 32'h00000000,
    parameter ENTRY0PRESENT  = 1'b0,

    parameter ENTRY1BASEADDR = 32'h00000000,
    parameter ENTRY1PRESENT  = 1'b0,

    parameter ENTRY2BASEADDR = 32'h00000000,
    parameter ENTRY2PRESENT  = 1'b0,

    parameter ENTRY3BASEADDR = 32'h00000000,
    parameter ENTRY3PRESENT  = 1'b0
    )
   (
    input wire         pclk,
    input wire         psel_i,
    input wire  [11:2] paddr,
    input wire  [ 3:0] ecorevnum,
    output wire [31:0] prdata_o,
    output wire        pready_o);









   localparam [19:0] ENTRY0OFFSET = ENTRY0BASEADDR[31:12] - BASE[31:12];
   localparam [19:0] ENTRY1OFFSET = ENTRY1BASEADDR[31:12] - BASE[31:12];
   localparam [19:0] ENTRY2OFFSET = ENTRY2BASEADDR[31:12] - BASE[31:12];
   localparam [19:0] ENTRY3OFFSET = ENTRY3BASEADDR[31:12] - BASE[31:12];

   localparam [31:0] ENTRY0 = { ENTRY0OFFSET, 10'b0, 1'b1, ENTRY0PRESENT };
   localparam [31:0] ENTRY1 = { ENTRY1OFFSET, 10'b0, 1'b1, ENTRY1PRESENT };
   localparam [31:0] ENTRY2 = { ENTRY2OFFSET, 10'b0, 1'b1, ENTRY2PRESENT };
   localparam [31:0] ENTRY3 = { ENTRY3OFFSET, 10'b0, 1'b1, ENTRY3PRESENT };



   reg         pselrom_q ;
   reg [ 31:0] prdata_q ;
   wire [31:0] prdata ;
   wire [11:0] word_addr      = {paddr, 2'b00};
   wire       cid3_en         = (word_addr[11:0] == 12'hFFC);
   wire       cid2_en         = (word_addr[11:0] == 12'hFF8);
   wire       cid1_en         = (word_addr[11:0] == 12'hFF4);
   wire       cid0_en         = (word_addr[11:0] == 12'hFF0);

   wire       pid7_en         = (word_addr[11:0] == 12'hFDC);
   wire       pid6_en         = (word_addr[11:0] == 12'hFD8);
   wire       pid5_en         = (word_addr[11:0] == 12'hFD4);
   wire       pid4_en         = (word_addr[11:0] == 12'hFD0);
   wire       pid3_en         = (word_addr[11:0] == 12'hFEC);
   wire       pid2_en         = (word_addr[11:0] == 12'hFE8);
   wire       pid1_en         = (word_addr[11:0] == 12'hFE4);
   wire       pid0_en         = (word_addr[11:0] == 12'hFE0);

   wire       systemaccess_en = (word_addr[11:0] == 12'hFCC);

   wire       entry0_en       = (word_addr[11:0] == 12'h000);
   wire       entry1_en       = (word_addr[11:0] == 12'h004);
   wire       entry2_en       = (word_addr[11:0] == 12'h008);
   wire       entry3_en       = (word_addr[11:0] == 12'h00C);

   wire [7:0] ids =
              ( ( {8{cid3_en}} & 8'hB1 ) |
                ( {8{cid2_en}} & 8'h05 ) |
                ( {8{cid1_en}} & 8'h10 ) |
                ( {8{cid0_en}} & 8'h0D ) |

                ( {8{pid7_en}} & 8'h00 ) |
                ( {8{pid6_en}} & 8'h00 ) |
                ( {8{pid5_en}} & 8'h00 ) |
                ( {8{pid4_en}} & { {4{1'b0}}, JEPCONTINUATION[3:0] } ) |
                ( {8{pid3_en}} & { ecorevnum[3:0], {4{1'b0}} } ) |
                ( {8{pid2_en}} & { REVISION[3:0], 1'b1, JEPID[6:4] } ) |
                ( {8{pid1_en}} & { JEPID[3:0], PARTNUMBER[11:8] } ) |
                ( {8{pid0_en}} &   PARTNUMBER[7:0] )
                );

   assign     prdata[31:0] =
              ( ( {{24{1'b0}}, ids[7:0] } )              |
                ( {32{systemaccess_en}} & 32'h00000001 ) |
                ( {32{entry0_en}} & ENTRY0[31:0] )       |
                ( {32{entry1_en}} & ENTRY1[31:0] )       |
                ( {32{entry2_en}} & ENTRY2[31:0] )       |
                ( {32{entry3_en}} & ENTRY3[31:0] )
                );

   always @(posedge pclk)
   begin
      pselrom_q <= psel_i;
      prdata_q  <= prdata ;
   end
   assign pready_o=pselrom_q;
   assign prdata_o=prdata_q;

endmodule
