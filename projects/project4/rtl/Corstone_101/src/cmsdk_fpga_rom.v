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
//      Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
//
//      Revision            : $Revision: 371321 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//
// ----------------------------------------------------------------------------
//  Abstract : FPGA BlockRam/OnChip ROM
// ----------------------------------------------------------------------------

module cmsdk_fpga_rom #(
// --------------------------------------------------------------------------
// Parameter Declarations
// --------------------------------------------------------------------------
  parameter AW = 16,
  parameter filename = ""
)
 (
  // Inputs
  input  wire          CLK,
  input  wire [AW-1:2] ADDR,
  input  wire [31:0]   WDATA,
  input  wire [3:0]    WREN,
  input  wire          CS,

  // Outputs
  output wire [31:0]   RDATA);

// -----------------------------------------------------------------------------
// Constant Declarations
// -----------------------------------------------------------------------------
localparam AWT = ((1<<(AW-2))-1);

  // Memory Array
  reg     [7:0]   BRAM0 [0:AWT];
  reg     [7:0]   BRAM1 [0:AWT];
  reg     [7:0]   BRAM2 [0:AWT];
  reg     [7:0]   BRAM3 [0:AWT];
  reg             cs_reg;
  wire    [31:0]  read_data;

  // Internal signals
  reg     [AW-3:0]  addr_q1;

  always @ (posedge CLK)
    begin
    cs_reg <= CS;
    end

  // Infer Block RAM - syntax is very specific.
  always @ (posedge CLK)
    begin
      if (WREN[0])
        BRAM0[ADDR] <= WDATA[7:0];
      if (WREN[1])
        BRAM1[ADDR] <= WDATA[15:8];
      if (WREN[2])
        BRAM2[ADDR] <= WDATA[23:16];
      if (WREN[3])
        BRAM3[ADDR] <= WDATA[31:24];
      // do not use enable on read interface.
      addr_q1 <= ADDR[AW-1:2];
    end

  assign read_data  = {BRAM3[addr_q1],BRAM2[addr_q1],BRAM1[addr_q1],BRAM0[addr_q1]};

  assign RDATA      = (cs_reg) ? read_data : {32{1'b0}};

  integer i;
  reg [7:0] fileimage [((1<<AW)-1):0];

  initial begin
`ifdef CM1_ITCM_INIT
    $readmemh("itcm3", BRAM3);
    $readmemh("itcm2", BRAM2);
    $readmemh("itcm1", BRAM1);
    $readmemh("itcm0", BRAM0);
`else
`ifdef ARM_ASSERT_ON
    //  Initialize memory content to avoid X value on bus
    for (i = 0; i <= AWT; i=i+1)
      begin
        BRAM0[i] = 8'h00;
        BRAM1[i] = 8'h00;
        BRAM2[i] = 8'h00;
        BRAM3[i] = 8'h00;
      end
`endif // ARM_ASSERT_ON
    if (filename != "")
      begin
      $readmemh(filename, fileimage);
      // Copy from single array to splitted array
      for (i=0;i<AWT; i= i+1)
        begin
        BRAM0[i] = fileimage[ 4*i];
        BRAM1[i] = fileimage[(4*i)+1];
        BRAM2[i] = fileimage[(4*i)+2];
        BRAM3[i] = fileimage[(4*i)+3];
        end
      end
`endif

  end


endmodule
