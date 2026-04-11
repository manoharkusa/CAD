//###################################################################################################################
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
// Description: Dual Port Memory wrapper for FIFO
//
//-------------------------------------------------------------------------------
module rp_fifo_mem_wrapper #(
   parameter SIMONLY       = 0,              // 1 for behavior mem model, 0 for TSMC mem model
   parameter MEM_LOG2DEPTH = 14,             // Memory Log2Depth
   parameter MEM_WIDTH     = 33              // Memory Width
) (
   // Common
   input                      clk,           // clock
   input                      rst_n,         // reset(Active low)
   // Port A
   input [MEM_LOG2DEPTH-1:0]  addr_a,        // port A address
   input                      we_a,          // port A write enable
   input  [MEM_WIDTH-1:0]     din_a,         // port A data in
   output [MEM_WIDTH-1:0]     dout_a,        // port A data out
   // Port B
   input [MEM_LOG2DEPTH-1:0]  addr_b,        // port B address
   input                      we_b,          // port B write enable
   input  [MEM_WIDTH-1:0]     din_b,         // port B data in
   output [MEM_WIDTH-1:0]     dout_b         // port B data out
);

   // ------------------------------------------------------------------------
   // Local Parameters
   // ------------------------------------------------------------------------
   localparam RTSEL = 2'b00;                      // Timing adjustment setting for debug purpose
   localparam WTSEL = 2'b00;                      // Timing adjustment setting for debug purpose
   localparam PTSEL = 2'b00;                      //

   localparam MASK_BITS_N = 33'h0000_0000;       // BIT MASK, active low
   localparam ASYNC_WRITE_THROUGH_OFF = 1'b0;    // Asynchronous write through off


   logic [3:0]                CHIP_EN_N_A;      //Chip enable A, active low - write
   logic                      CHIP_EN_N_B;      //Chip enable B, active low - read
   logic [MEM_LOG2DEPTH-3:0]  AA  ;
   logic [MEM_WIDTH-1:0]      DA  ;
   logic                      WEBA;
   logic [MEM_LOG2DEPTH-3:0]  AB  ;
   logic [MEM_WIDTH-1:0]      DB  ;
   logic                      WEBB;
   logic [MEM_WIDTH-1:0]      Q [3:0];
   logic [MEM_WIDTH-1:0]      dout_b_next;
   logic [1:0]                addr_b_q;
   // ------------------------------------------------------------------------
   // Add delays to the inputs to avoid the timing violations.
   // ------------------------------------------------------------------------
   assign #0.1ns AA   = addr_a[$left(addr_a)-2:0]; //
   assign #0.1ns DA   = din_a ;
   assign #0.1ns WEBA = ~we_a ;  // active low
   assign #0.1ns AB   = addr_b[$left(addr_b)-2:0]; //
   assign #0.1ns DB   = din_b ;
   assign #0.1ns WEBB = ~we_b ;  // active low
   //WRITE EN
   assign #0.1ns CHIP_EN_N_A[0] = ({(addr_a[$left(addr_a)]) , (addr_a[$left(addr_a)-1])} == 2'b00) ? 1'b0 : 1'b1; //MEM 1
   assign #0.1ns CHIP_EN_N_A[1] = ({(addr_a[$left(addr_a)]) , (addr_a[$left(addr_a)-1])} == 2'b01) ? 1'b0 : 1'b1; //MEM 2
   assign #0.1ns CHIP_EN_N_A[2] = ({(addr_a[$left(addr_a)]) , (addr_a[$left(addr_a)-1])} == 2'b10) ? 1'b0 : 1'b1; //MEM 3
   assign #0.1ns CHIP_EN_N_A[3] = ({(addr_a[$left(addr_a)]) , (addr_a[$left(addr_a)-1])} == 2'b11) ? 1'b0 : 1'b1; //MEM 4
   //READ EN
   assign #0.1ns CHIP_EN_N_B = 0;


   // ------------------------------------------------------------------------
   // Memory Instantiation
   // ------------------------------------------------------------------------
   generate
      if(SIMONLY == 1) begin //BEVH MEM MODEL
         logic [3:0] we_a_sel;
         assign #0.1ns we_a_sel[0] = ((addr_a[$left(addr_a)-:2]) == 2'b00) ? we_a : 1'b0;  // compare 2 msbs of the address
         assign #0.1ns we_a_sel[1] = ((addr_a[$left(addr_a)-:2]) == 2'b01) ? we_a : 1'b0;  // compare 2 msbs of the address
         assign #0.1ns we_a_sel[2] = ((addr_a[$left(addr_a)-:2]) == 2'b10) ? we_a : 1'b0;  // compare 2 msbs of the address
         assign #0.1ns we_a_sel[3] = ((addr_a[$left(addr_a)-:2]) == 2'b11) ? we_a : 1'b0;  // compare 2 msbs of the address

         rp_ram_dual#(
            .MEM_LOG2DEPTH (MEM_LOG2DEPTH-2),     // 1st mem
            .MEM_WIDTH     (MEM_WIDTH    ))
         mem_infer0 (
            .clk1       (clk),
            .we         (we_a_sel[0]),
            .addr_in    (AA),
            .d          (DA),
            .clk2       (clk),
            .addr_out   (AB),
            .q          (Q[0])
         );

         rp_ram_dual#(
            .MEM_LOG2DEPTH (MEM_LOG2DEPTH-2),     // 2nd mem
            .MEM_WIDTH     (MEM_WIDTH    ))
         mem_infer1 (
            .clk1       (clk),
            .we         (we_a_sel[1]),
            .addr_in    (AA),
            .d          (DA),
            .clk2       (clk),
            .addr_out   (AB),
            .q          (Q[1])
         );

         rp_ram_dual#(
            .MEM_LOG2DEPTH (MEM_LOG2DEPTH-2),     // 3rd mem
            .MEM_WIDTH     (MEM_WIDTH    ))
         mem_infer2 (
            .clk1       (clk),
            .we         (we_a_sel[2]),
            .addr_in    (AA),
            .d          (DA),
            .clk2       (clk),
            .addr_out   (AB),
            .q          (Q[2])
         );

         rp_ram_dual#(
            .MEM_LOG2DEPTH (MEM_LOG2DEPTH-2),     // 4th mem
            .MEM_WIDTH     (MEM_WIDTH    ))
         mem_infer3 (
            .clk1       (clk),
            .we         (we_a_sel[3]),
            .addr_in    (AA),
            .d          (DA),
            .clk2       (clk),
            .addr_out   (AB),
            .q          (Q[3])
         );
      end

      else begin  // TSMC Memories
         TSDN28HPCPUHDB4096X33M4MWA U0_FIFO_MEM // 4096 x 33
         (
            .RTSEL   (RTSEL),
            .WTSEL   (WTSEL),
            .PTSEL   (PTSEL),
            // common
            .CLK     (clk  ),
            // port A
            .AA      (AA         ),
            .DA      (DA         ),
            .BWEBA   (MASK_BITS_N),
            .WEBA    (WEBA       ),
            .CEBA    (CHIP_EN_N_A[0]),
            .QA      ( ),
            // port B
            .AB      (AB         ),
            .DB      (DB         ),
            .BWEBB   (MASK_BITS_N),
            .WEBB    (WEBB       ),
            .CEBB    (CHIP_EN_N_B),
            .QB      (Q[0]),
            //
            .AWT     (ASYNC_WRITE_THROUGH_OFF)
         );
         TSDN28HPCPUHDB4096X33M4MWA U1_FIFO_MEM // 4096 x 33
         (
            .RTSEL   (RTSEL),
            .WTSEL   (WTSEL),
            .PTSEL   (PTSEL),
            // common
            .CLK     (clk  ),
            // port A
            .AA      (AA         ),
            .DA      (DA         ),
            .BWEBA   (MASK_BITS_N),
            .WEBA    (WEBA       ),
            .CEBA    (CHIP_EN_N_A[1]),
            .QA      (  ),
            // port B
            .AB      (AB         ),
            .DB      (DB         ),
            .BWEBB   (MASK_BITS_N),
            .WEBB    (WEBB       ),
            .CEBB    (CHIP_EN_N_B),
            .QB      (Q[1]  ),
            //
            .AWT     (ASYNC_WRITE_THROUGH_OFF)
         );
         TSDN28HPCPUHDB4096X33M4MWA U2_FIFO_MEM // 4096 x 33
         (
            .RTSEL   (RTSEL),
            .WTSEL   (WTSEL),
            .PTSEL   (PTSEL),
            // common
            .CLK     (clk  ),
            // port A
            .AA      (AA         ),
            .DA      (DA         ),
            .BWEBA   (MASK_BITS_N),
            .WEBA    (WEBA       ),
            .CEBA    (CHIP_EN_N_A[2]),
            .QA      ( ),
            // port B
            .AB      (AB         ),
            .DB      (DB         ),
            .BWEBB   (MASK_BITS_N),
            .WEBB    (WEBB       ),
            .CEBB    (CHIP_EN_N_B),
            .QB      (Q[2]  ),
            //
            .AWT     (ASYNC_WRITE_THROUGH_OFF)
         );
         TSDN28HPCPUHDB4096X33M4MWA U3_FIFO_MEM // 4096 x 33
         (
            .RTSEL   (RTSEL),
            .WTSEL   (WTSEL),
            .PTSEL   (PTSEL),
            // common
            .CLK     (clk  ),
            // port A
            .AA      (AA         ),
            .DA      (DA         ),
            .BWEBA   (MASK_BITS_N),
            .WEBA    (WEBA       ),
            .CEBA    (CHIP_EN_N_A[3]),
            .QA      (  ),
            // port B
            .AB      (AB         ),
            .DB      (DB         ),
            .BWEBB   (MASK_BITS_N),
            .WEBB    (WEBB       ),
            .CEBB    (CHIP_EN_N_B),
            .QB      (Q[3]  ),
            //
            .AWT     (ASYNC_WRITE_THROUGH_OFF)
         );
      end
   endgenerate

   always@(posedge clk, negedge rst_n)begin
      if(!rst_n) begin
         addr_b_q <= 0;
      end
      else begin
         addr_b_q <= {(addr_b[$left(addr_b)]) , (addr_b[$left(addr_b)-1])};
      end
   end

   always_comb
   begin
      case (addr_b_q)
      //  2'b00   :  dout_b_next = Q[0];
      2'b01   :  dout_b_next = Q[1];
      2'b10   :  dout_b_next = Q[2];
      2'b11   :  dout_b_next = Q[3];
      default :  dout_b_next = Q[0];
      endcase
      end
   assign dout_b = dout_b_next;

endmodule
