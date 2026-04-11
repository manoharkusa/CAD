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
//      Checked In          : $Date: 2009-11-13 17:42:18 +0000 (Fri, 13 Nov 2009) $
//
//      Revision            : $Revision: 123594 $
//
//      Release Information : CORTEX-A5-FPU-r0p1-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Register Bank for the Floating Point Unit.
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This block contains the main working register set for the FPU.
//
// The FPU register file is a 3 read port, 1 write port register file.  There
// are 16 entries in the register file and each entry is 64 bits wide.
// In single precision mode odd/even adjacent registers are taken from the
// low/high halves of the registers (e.g. D0 = {S1,S0} etc).
//
//-----------------------------------------------------------------------------

`include "ca5dpu_params.v"

module ca5dpu_fp_regbank `DPU_PARAM_DECL (
  // Inputs
  input  wire                           clk,
  input  wire                           reset_n,                    // Assertion check only
  input  wire [(`CA5_FP_RF_ADDR_W-1):0] rf_rd_addr_fr0_iss_i,       // Read address port 0
  input  wire [(`CA5_FP_RF_ADDR_W-1):0] rf_rd_addr_fr1_iss_i,       // Read address port 1
  input  wire [(`CA5_FP_RF_ADDR_W-1):0] rf_rd_addr_fr2_iss_i,       // Read address port 2
  input  wire                           issue_to_ex1_i,             // Issue control
  input  wire [1:0]                     rf_rd_en_fr0_iss_i,         // Read enable port 0
  input  wire [1:0]                     rf_rd_en_fr1_iss_i,         // Read enable port 1
  input  wire [1:0]                     rf_rd_en_fr2_iss_i,         // Read enable port 2
  input  wire [1:0]                     rf_wr_en_fw0_f5_i,          // Enable for write port 0
  input  wire [(`CA5_FP_RF_ADDR_W-1):0] rf_wr_addr_fw0_f5_i,        // Write address port 0
  input  wire [63:0]                    rf_wr_data_fw0_f5_i,        // Write data port 0
  // Outputs
  output wire [63:0]                    rf_rd_data_fr0_ex1_o,       // Read port 0
  output wire [63:0]                    rf_rd_data_fr1_ex1_o,       // Read port 1
  output wire [63:0]                    rf_rd_data_fr2_ex1_o        // Read port 2
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [31:0]                    rbank_0;
  reg [31:0]                    rbank_1;
  reg [31:0]                    rbank_2;
  reg [31:0]                    rbank_3;
  reg [31:0]                    rbank_4;
  reg [31:0]                    rbank_5;
  reg [31:0]                    rbank_6;
  reg [31:0]                    rbank_7;
  reg [31:0]                    rbank_8;
  reg [31:0]                    rbank_9;
  reg [31:0]                    rbank_10;
  reg [31:0]                    rbank_11;
  reg [31:0]                    rbank_12;
  reg [31:0]                    rbank_13;
  reg [31:0]                    rbank_14;
  reg [31:0]                    rbank_15;
  reg [31:0]                    rbank_16;
  reg [31:0]                    rbank_17;
  reg [31:0]                    rbank_18;
  reg [31:0]                    rbank_19;
  reg [31:0]                    rbank_20;
  reg [31:0]                    rbank_21;
  reg [31:0]                    rbank_22;
  reg [31:0]                    rbank_23;
  reg [31:0]                    rbank_24;
  reg [31:0]                    rbank_25;
  reg [31:0]                    rbank_26;
  reg [31:0]                    rbank_27;
  reg [31:0]                    rbank_28;
  reg [31:0]                    rbank_29;
  reg [31:0]                    rbank_30;
  reg [31:0]                    rbank_31;
  reg [(`CA5_FP_RF_ADDR_W-1):0] rf_rd_addr_fr0_ex1;
  reg [(`CA5_FP_RF_ADDR_W-1):0] rf_rd_addr_fr1_ex1;
  reg [(`CA5_FP_RF_ADDR_W-1):0] rf_rd_addr_fr2_ex1;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [31:0]                   wrmask_even_qual;
  wire [31:0]                   wrmask_odd_qual;
  wire [63:0]                   fr0_read_data_lo;
  wire [63:0]                   fr0_read_data_hi;
  wire [63:0]                   fr1_read_data_lo;
  wire [63:0]                   fr1_read_data_hi;
  wire [63:0]                   fr2_read_data_lo;
  wire [63:0]                   fr2_read_data_hi;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Write mask and enable generation
  // ------------------------------------------------------

`genif (NEON_0)

  reg [31:0]  wrmask;

  always @*
    case (rf_wr_addr_fw0_f5_i)
      `CA5_FPU_ADDR_R00 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
      `CA5_FPU_ADDR_R01 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_0000_0000_0010;
      `CA5_FPU_ADDR_R02 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_0000_0000_0100;
      `CA5_FPU_ADDR_R03 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
      `CA5_FPU_ADDR_R04 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_0000_0001_0000;
      `CA5_FPU_ADDR_R05 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_0000_0010_0000;
      `CA5_FPU_ADDR_R06 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_0000_0100_0000;
      `CA5_FPU_ADDR_R07 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_0000_1000_0000;
      `CA5_FPU_ADDR_R08 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_0001_0000_0000;
      `CA5_FPU_ADDR_R09 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_0010_0000_0000;
      `CA5_FPU_ADDR_R10 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_0100_0000_0000;
      `CA5_FPU_ADDR_R11 : wrmask[31:0] = 32'b0000_0000_0000_0000_0000_1000_0000_0000;
      `CA5_FPU_ADDR_R12 : wrmask[31:0] = 32'b0000_0000_0000_0000_0001_0000_0000_0000;
      `CA5_FPU_ADDR_R13 : wrmask[31:0] = 32'b0000_0000_0000_0000_0010_0000_0000_0000;
      `CA5_FPU_ADDR_R14 : wrmask[31:0] = 32'b0000_0000_0000_0000_0100_0000_0000_0000;
      `CA5_FPU_ADDR_R15 : wrmask[31:0] = 32'b0000_0000_0000_0000_1000_0000_0000_0000;
      `CA5_FPU_ADDR_R16 : wrmask[31:0] = 32'b0000_0000_0000_0001_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R17 : wrmask[31:0] = 32'b0000_0000_0000_0010_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R18 : wrmask[31:0] = 32'b0000_0000_0000_0100_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R19 : wrmask[31:0] = 32'b0000_0000_0000_1000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R20 : wrmask[31:0] = 32'b0000_0000_0001_0000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R21 : wrmask[31:0] = 32'b0000_0000_0010_0000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R22 : wrmask[31:0] = 32'b0000_0000_0100_0000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R23 : wrmask[31:0] = 32'b0000_0000_1000_0000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R24 : wrmask[31:0] = 32'b0000_0001_0000_0000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R25 : wrmask[31:0] = 32'b0000_0010_0000_0000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R26 : wrmask[31:0] = 32'b0000_0100_0000_0000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R27 : wrmask[31:0] = 32'b0000_1000_0000_0000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R28 : wrmask[31:0] = 32'b0001_0000_0000_0000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R29 : wrmask[31:0] = 32'b0010_0000_0000_0000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R30 : wrmask[31:0] = 32'b0100_0000_0000_0000_0000_0000_0000_0000;
      `CA5_FPU_ADDR_R31 : wrmask[31:0] = 32'b1000_0000_0000_0000_0000_0000_0000_0000;
      default           : wrmask[31:0] = {32{1'bx}};
    endcase

  assign wrmask_even_qual = wrmask[31:0] & {32{rf_wr_en_fw0_f5_i[0]}};
  assign wrmask_odd_qual  = wrmask[31:0] & {32{rf_wr_en_fw0_f5_i[1]}};

`genelse

  reg [15:0]  wrmask;

  always @*
    case (rf_wr_addr_fw0_f5_i)
      `CA5_FPU_ADDR_R00 : wrmask[15:0] = 16'b0000_0000_0000_0001;
      `CA5_FPU_ADDR_R01 : wrmask[15:0] = 16'b0000_0000_0000_0010;
      `CA5_FPU_ADDR_R02 : wrmask[15:0] = 16'b0000_0000_0000_0100;
      `CA5_FPU_ADDR_R03 : wrmask[15:0] = 16'b0000_0000_0000_1000;
      `CA5_FPU_ADDR_R04 : wrmask[15:0] = 16'b0000_0000_0001_0000;
      `CA5_FPU_ADDR_R05 : wrmask[15:0] = 16'b0000_0000_0010_0000;
      `CA5_FPU_ADDR_R06 : wrmask[15:0] = 16'b0000_0000_0100_0000;
      `CA5_FPU_ADDR_R07 : wrmask[15:0] = 16'b0000_0000_1000_0000;
      `CA5_FPU_ADDR_R08 : wrmask[15:0] = 16'b0000_0001_0000_0000;
      `CA5_FPU_ADDR_R09 : wrmask[15:0] = 16'b0000_0010_0000_0000;
      `CA5_FPU_ADDR_R10 : wrmask[15:0] = 16'b0000_0100_0000_0000;
      `CA5_FPU_ADDR_R11 : wrmask[15:0] = 16'b0000_1000_0000_0000;
      `CA5_FPU_ADDR_R12 : wrmask[15:0] = 16'b0001_0000_0000_0000;
      `CA5_FPU_ADDR_R13 : wrmask[15:0] = 16'b0010_0000_0000_0000;
      `CA5_FPU_ADDR_R14 : wrmask[15:0] = 16'b0100_0000_0000_0000;
      `CA5_FPU_ADDR_R15 : wrmask[15:0] = 16'b1000_0000_0000_0000;
      default           : wrmask[15:0] = {16{1'bx}};
    endcase

  assign wrmask_even_qual = {{16{1'b0}}, (wrmask[15:0] & {16{rf_wr_en_fw0_f5_i[0]}})};
  assign wrmask_odd_qual  = {{16{1'b0}}, (wrmask[15:0] & {16{rf_wr_en_fw0_f5_i[1]}})};

`genendif

  // -----------------------------------------------------------
  // Register file
  // -----------------------------------------------------------
  // 32-entries, 32-registers per entry

  always @(posedge clk)
    if(wrmask_even_qual[0])
      rbank_0 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[0])
      rbank_1 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[1])
      rbank_2 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[1])
      rbank_3 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[2])
      rbank_4 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[2])
      rbank_5 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[3])
      rbank_6 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[3])
      rbank_7 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[4])
      rbank_8 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[4])
      rbank_9 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[5])
      rbank_10 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[5])
      rbank_11 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[6])
      rbank_12 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[6])
      rbank_13 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[7])
      rbank_14 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[7])
      rbank_15 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[8])
      rbank_16 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[8])
      rbank_17 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[9])
      rbank_18 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[9])
      rbank_19 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[10])
      rbank_20 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[10])
      rbank_21 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[11])
      rbank_22 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[11])
      rbank_23 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[12])
      rbank_24 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[12])
      rbank_25 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[13])
      rbank_26 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[13])
      rbank_27 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[14])
      rbank_28 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[14])
      rbank_29 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[15])
      rbank_30 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[15])
      rbank_31 <= rf_wr_data_fw0_f5_i[63:32];

  // ------------------------------------------------------
  // Read path
  // ------------------------------------------------------

  always @(posedge clk)
    if (issue_to_ex1_i & |rf_rd_en_fr0_iss_i)
        rf_rd_addr_fr0_ex1 <= rf_rd_addr_fr0_iss_i;

  always @(posedge clk)
    if (issue_to_ex1_i & |rf_rd_en_fr1_iss_i)
        rf_rd_addr_fr1_ex1 <= rf_rd_addr_fr1_iss_i;

  always @(posedge clk)
    if (issue_to_ex1_i & |rf_rd_en_fr2_iss_i)
        rf_rd_addr_fr2_ex1 <= rf_rd_addr_fr2_iss_i;

  // Read port fr0
  assign fr0_read_data_lo  = (({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R00}} & {rbank_1,  rbank_0})  |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R01}} & {rbank_3,  rbank_2})  |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R02}} & {rbank_5,  rbank_4})  |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R03}} & {rbank_7,  rbank_6})  |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R04}} & {rbank_9,  rbank_8})  |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R05}} & {rbank_11, rbank_10}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R06}} & {rbank_13, rbank_12}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R07}} & {rbank_15, rbank_14}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R08}} & {rbank_17, rbank_16}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R09}} & {rbank_19, rbank_18}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R10}} & {rbank_21, rbank_20}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R11}} & {rbank_23, rbank_22}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R12}} & {rbank_25, rbank_24}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R13}} & {rbank_27, rbank_26}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R14}} & {rbank_29, rbank_28}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R15}} & {rbank_31, rbank_30}));

  // Read port fr1
  assign fr1_read_data_lo  = (({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R00}} & {rbank_1,  rbank_0})  |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R01}} & {rbank_3,  rbank_2})  |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R02}} & {rbank_5,  rbank_4})  |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R03}} & {rbank_7,  rbank_6})  |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R04}} & {rbank_9,  rbank_8})  |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R05}} & {rbank_11, rbank_10}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R06}} & {rbank_13, rbank_12}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R07}} & {rbank_15, rbank_14}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R08}} & {rbank_17, rbank_16}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R09}} & {rbank_19, rbank_18}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R10}} & {rbank_21, rbank_20}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R11}} & {rbank_23, rbank_22}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R12}} & {rbank_25, rbank_24}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R13}} & {rbank_27, rbank_26}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R14}} & {rbank_29, rbank_28}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R15}} & {rbank_31, rbank_30}));

  // Read port fr2
  assign fr2_read_data_lo  = (({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R00}} & {rbank_1,  rbank_0})  |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R01}} & {rbank_3,  rbank_2})  |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R02}} & {rbank_5,  rbank_4})  |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R03}} & {rbank_7,  rbank_6})  |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R04}} & {rbank_9,  rbank_8})  |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R05}} & {rbank_11, rbank_10}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R06}} & {rbank_13, rbank_12}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R07}} & {rbank_15, rbank_14}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R08}} & {rbank_17, rbank_16}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R09}} & {rbank_19, rbank_18}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R10}} & {rbank_21, rbank_20}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R11}} & {rbank_23, rbank_22}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R12}} & {rbank_25, rbank_24}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R13}} & {rbank_27, rbank_26}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R14}} & {rbank_29, rbank_28}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R15}} & {rbank_31, rbank_30}));

`genif (NEON_0) : NEON1
  reg [31:0]                    rbank_32;
  reg [31:0]                    rbank_33;
  reg [31:0]                    rbank_34;
  reg [31:0]                    rbank_35;
  reg [31:0]                    rbank_36;
  reg [31:0]                    rbank_37;
  reg [31:0]                    rbank_38;
  reg [31:0]                    rbank_39;
  reg [31:0]                    rbank_40;
  reg [31:0]                    rbank_41;
  reg [31:0]                    rbank_42;
  reg [31:0]                    rbank_43;
  reg [31:0]                    rbank_44;
  reg [31:0]                    rbank_45;
  reg [31:0]                    rbank_46;
  reg [31:0]                    rbank_47;
  reg [31:0]                    rbank_48;
  reg [31:0]                    rbank_49;
  reg [31:0]                    rbank_50;
  reg [31:0]                    rbank_51;
  reg [31:0]                    rbank_52;
  reg [31:0]                    rbank_53;
  reg [31:0]                    rbank_54;
  reg [31:0]                    rbank_55;
  reg [31:0]                    rbank_56;
  reg [31:0]                    rbank_57;
  reg [31:0]                    rbank_58;
  reg [31:0]                    rbank_59;
  reg [31:0]                    rbank_60;
  reg [31:0]                    rbank_61;
  reg [31:0]                    rbank_62;
  reg [31:0]                    rbank_63;

  // -----------------------------------------------------------
  // Upper bank of register file
  // -----------------------------------------------------------
  // 32-entries, 32-registers per entry

  always @(posedge clk)
    if(wrmask_even_qual[16])
      rbank_32 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[16])
      rbank_33 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[17])
      rbank_34 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[17])
      rbank_35 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[18])
      rbank_36 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[18])
      rbank_37 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[19])
      rbank_38 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[19])
      rbank_39 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[20])
      rbank_40 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[20])
      rbank_41 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[21])
      rbank_42 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[21])
      rbank_43 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[22])
      rbank_44 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[22])
      rbank_45 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[23])
      rbank_46 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[23])
      rbank_47 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[24])
      rbank_48 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[24])
      rbank_49 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[25])
      rbank_50 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[25])
      rbank_51 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[26])
      rbank_52 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[26])
      rbank_53 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[27])
      rbank_54 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[27])
      rbank_55 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[28])
      rbank_56 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[28])
      rbank_57 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[29])
      rbank_58 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[29])
      rbank_59 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[30])
      rbank_60 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[30])
      rbank_61 <= rf_wr_data_fw0_f5_i[63:32];

  always @(posedge clk)
    if(wrmask_even_qual[31])
      rbank_62 <= rf_wr_data_fw0_f5_i[31:0];

  always @(posedge clk)
    if(wrmask_odd_qual[31])
      rbank_63 <= rf_wr_data_fw0_f5_i[63:32];

  // ------------------------------------------------------
  // Read path
  // ------------------------------------------------------

  // Read port fr0
  assign fr0_read_data_hi  = (({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R16}} & {rbank_33, rbank_32}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R17}} & {rbank_35, rbank_34}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R18}} & {rbank_37, rbank_36}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R19}} & {rbank_39, rbank_38}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R20}} & {rbank_41, rbank_40}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R21}} & {rbank_43, rbank_42}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R22}} & {rbank_45, rbank_44}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R23}} & {rbank_47, rbank_46}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R24}} & {rbank_49, rbank_48}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R25}} & {rbank_51, rbank_50}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R26}} & {rbank_53, rbank_52}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R27}} & {rbank_55, rbank_54}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R28}} & {rbank_57, rbank_56}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R29}} & {rbank_59, rbank_58}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R30}} & {rbank_61, rbank_60}) |
                              ({64{rf_rd_addr_fr0_ex1 == `CA5_FPU_ADDR_R31}} & {rbank_63, rbank_62}));

  // Read port fr1
  assign fr1_read_data_hi  = (({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R16}} & {rbank_33, rbank_32}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R17}} & {rbank_35, rbank_34}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R18}} & {rbank_37, rbank_36}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R19}} & {rbank_39, rbank_38}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R20}} & {rbank_41, rbank_40}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R21}} & {rbank_43, rbank_42}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R22}} & {rbank_45, rbank_44}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R23}} & {rbank_47, rbank_46}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R24}} & {rbank_49, rbank_48}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R25}} & {rbank_51, rbank_50}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R26}} & {rbank_53, rbank_52}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R27}} & {rbank_55, rbank_54}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R28}} & {rbank_57, rbank_56}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R29}} & {rbank_59, rbank_58}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R30}} & {rbank_61, rbank_60}) |
                              ({64{rf_rd_addr_fr1_ex1 == `CA5_FPU_ADDR_R31}} & {rbank_63, rbank_62}));

  // Read port fr2
  assign fr2_read_data_hi  = (({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R16}} & {rbank_33, rbank_32}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R17}} & {rbank_35, rbank_34}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R18}} & {rbank_37, rbank_36}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R19}} & {rbank_39, rbank_38}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R20}} & {rbank_41, rbank_40}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R21}} & {rbank_43, rbank_42}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R22}} & {rbank_45, rbank_44}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R23}} & {rbank_47, rbank_46}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R24}} & {rbank_49, rbank_48}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R25}} & {rbank_51, rbank_50}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R26}} & {rbank_53, rbank_52}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R27}} & {rbank_55, rbank_54}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R28}} & {rbank_57, rbank_56}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R29}} & {rbank_59, rbank_58}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R30}} & {rbank_61, rbank_60}) |
                              ({64{rf_rd_addr_fr2_ex1 == `CA5_FPU_ADDR_R31}} & {rbank_63, rbank_62}));
`genelse
  assign fr0_read_data_hi = {64{1'b0}};
  assign fr1_read_data_hi = {64{1'b0}};
  assign fr2_read_data_hi = {64{1'b0}};
`genendif

  assign rf_rd_data_fr0_ex1_o[63:0] = fr0_read_data_lo[63:0] | fr0_read_data_hi[63:0];
  assign rf_rd_data_fr1_ex1_o[63:0] = fr1_read_data_lo[63:0] | fr1_read_data_hi[63:0];
  assign rf_rd_data_fr2_ex1_o[63:0] = fr2_read_data_lo[63:0] | fr2_read_data_hi[63:0];

//------------------------------------------------------------------------------
// OVL Assertions
//------------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_regbank_retite_data_w0
  // Should not be writing Xs to the regbank
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_ERROR,32,`OVL_ASSERT,"Writing Xs into the FPU RF port W0 low half")
    ovl_fpu_regbank_retite_data_w0 (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (rf_wr_en_fw0_f5_i[0]),
                                   .test_expr (rf_wr_data_fw0_f5_i[31:0]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_fpu_regbank_retite_data_w1
  // Should not be writing Xs to the regbank
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_ERROR,32,`OVL_ASSERT,"Writing Xs into the FPU RF port W0 high half")
    ovl_fpu_regbank_retite_data_w1 (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (rf_wr_en_fw0_f5_i[1]),
                                   .test_expr (rf_wr_data_fw0_f5_i[63:32]));
  // OVL_ASSERT_END

`endif

endmodule // ca5dpu_fp_regbank
