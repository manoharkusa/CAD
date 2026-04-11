//####################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD.
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED.
//# RPLTD NOTICE VERSION: 1.1.1
//###################################################################################################################
// Author : D. Lee
//
// Project: RPS - Uintah
//
// Date   : 06/17/2021
//
// Description: Dual Port Memory wrapper for Sequencer
//
//-------------------------------------------------------------------------------
module rp_sequencer_mem_wrapper #(
   parameter SIMONLY       = 0,           // 1 for behavior mem model, TSMC mem model for others
   parameter MEM_LOG2DEPTH = 10,          // Memory Log2Depth
   parameter MEM_WIDTH     = 128          // Memory Width
) (
   // Common
   input                      clk,           // clock
   input                      rst_n,         // reset (active low)
   // Port A
   input [MEM_LOG2DEPTH-1:0]  addr_a,        // port A clock
   input                      we_a,          // port A write enable
   input  [MEM_WIDTH-1:0]     din_a,         // port A data in
   output [MEM_WIDTH-1:0]     dout_a         // port A data out
);

   // ------------------------------------------------------------------------
   // Local Parameters
   // ------------------------------------------------------------------------
   localparam RTSEL = 2'b00;  // Timing adjustment setting for debug purpose
   localparam WTSEL = 2'b00;  // Timing adjustment setting for debug purpose
   localparam PTSEL = 2'b00;  //

   localparam MASK_BITS_N = 129'd0;             // BIT MASK, active low
   localparam ASYNC_WRITE_THROUGH_OFF = 1'b0;   // Asynchronous write through off

   logic [1:0]                CHIP_EN_N  ;      // Chip enable, active low
   logic [MEM_LOG2DEPTH-2:0]  AA  ;
   logic [MEM_WIDTH-1:0]      DA  ;
   logic [MEM_WIDTH-1:0]      QA[0:1];
   logic                      WEBA;
   logic                      addr_a_msb_q;

   // ------------------------------------------------------------------------
   // Add delays to the inputs to avoid the timing violations.
   // ------------------------------------------------------------------------
   assign #0.1ns AA   = addr_a[$left(addr_a)-1:0];
   assign #0.1ns DA   = din_a ;
   assign #0.1ns WEBA = ~we_a  ;  // active low
   assign #0.1ns CHIP_EN_N[0] = addr_a[$left(addr_a)];
   assign #0.1ns CHIP_EN_N[1] = ~addr_a[$left(addr_a)];

   // ------------------------------------------------------------------------
   // Memory Instantiation
   // ------------------------------------------------------------------------
   generate
      if (SIMONLY == 1) begin  // BEHAVIOR MEMORY MODEL
         logic [1:0]   we_a_sel;
         assign #0.1ns we_a_sel[0] = (~addr_a[$left(addr_a)]) ? we_a : '0;  // we_a if msb of addr_a is 0
         assign #0.1ns we_a_sel[1] = ( addr_a[$left(addr_a)]) ? we_a : '0;  // we_a if msb of addr_a is 1
         
         rp_ram_single #(
            .MEM_LOG2DEPTH (MEM_LOG2DEPTH-1), // Memory Log2Depth
            .MEM_WIDTH     (MEM_WIDTH))     // Memory Width
         U0_SEQ_MEM_BEHAVIOR (
            .clk        (clk),
            .we         (we_a_sel[0]),
            .addr       (AA),
            .data_in    (DA),
            .data_out   (QA[0])
         );
         
         rp_ram_single #(
            .MEM_LOG2DEPTH (MEM_LOG2DEPTH-1), // Memory Log2Depth
            .MEM_WIDTH     (MEM_WIDTH))     // Memory Width
         U1_SEQ_MEM_BEHAVIOR (
            .clk        (clk),
            .we         (we_a_sel[1]),
            .addr       (AA),
            .data_in    (DA),
            .data_out   (QA[1])
         );

      end else begin // TSMC MEMORY (2x   2048 x 129)
         TS1N28HPCPUHDHVTB2048X129M4SWBSO U0_SEQ_MEM // 2048 x 129
         (
            .RTSEL   (RTSEL),
            .WTSEL   (WTSEL),

            .SLP     (1'b0),
            .SD      (1'b0),

            .CLK     (clk      ),
            .CEB     (CHIP_EN_N[0]),
            .WEB     (WEBA     ),
            .A       (AA       ),
            .D       (DA       ),
            .BWEB    (MASK_BITS_N),

            // MBIST
            .CEBM    ('1),
            .WEBM    ('1),
            .AM      ('0),
            .DM      ('0),
            .BWEBM   ('1),
            .BIST    (1'b0),

            // data out
            .Q       (QA[0])
         );

         TS1N28HPCPUHDHVTB2048X129M4SWBSO U1_SEQ_MEM // 2048 x 129
         (
            .RTSEL   (RTSEL),
            .WTSEL   (WTSEL),

            .SLP     (1'b0),
            .SD      (1'b0),

            .CLK     (clk      ),
            .CEB     (CHIP_EN_N[1]),
            .WEB     (WEBA     ),
            .A       (AA       ),
            .D       (DA       ),
            .BWEB    (MASK_BITS_N),

            // MBIST
            .CEBM    ('1),
            .WEBM    ('1),
            .AM      ('0),
            .DM      ('0),
            .BWEBM   ('1),
            .BIST    (1'b0),

            // data out
            .Q       (QA[1])
         );

      end

   endgenerate

   // need to delay addr_a_msb to make the select approriate dout
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         addr_a_msb_q <= 1'b0;
      end else begin
         addr_a_msb_q <= addr_a[$left(addr_a)];
      end
   end

   assign dout_a = (addr_a_msb_q == 0) ? QA[0] : QA[1];


endmodule
