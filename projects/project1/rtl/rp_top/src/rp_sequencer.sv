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
// Date   : 04/07/2021
//
// Description: Sequencer Core
//
//-------------------------------------------------------------------------------

`timescale 1ns/1ps

import rp_sequencer_pkg::*;

module rp_sequencer #(
   parameter SIMONLY          = 0 ,          // 1 for behavior mem model TSMC mem model for others
   parameter MEM_LOG2DEPTH    = 10,          // Memory Log2Depth
   parameter MEM_WIDTH        = 56           // Memory Width
) (
   // Memory I/F
   input [MEM_LOG2DEPTH-1:0]  hif_mem_addr  , // memory address
   input [MEM_WIDTH-1: 0]     hif_mem_wdata , // memory write data
   input                      hif_mem_write , // memory write
   output reg [MEM_WIDTH-1:0] hif_mem_rdata , // memory read data

   // clock/reset cfg/cmd
   input                      clk,                 // clock
   input                      rst_n,               // active low reset
   input                      seq_start,           // sequencer start (pulse)
   input                      seq_terminate,       // sequencer terminate (pulse)
   input [MEM_LOG2DEPTH-1:0]  seq_start_addr,      // sequencer start address
   input                      parity_odd_not_even, // Parity odd not even
   input                      clear_err_addr,      // clear error address (pulse)
   input                      clear_done,          // clear done (pulse)

   // Sequencer instruction
   output reg                     seq_strobe     ,     // sequencer strobe
   output reg [ 7:0]              seq_opcode     ,     // sequencer opcode
   output reg [95:0]              seq_data       ,     // sequencer data

   // Status
   output reg                     seq_busy,            // Sequencer busy
   output reg                     err_parity,          // Parity error
   output reg [MEM_LOG2DEPTH-1:0] err_addr,            // Error location
   output reg                     err_opcode,          // Bad opcode
   output reg                     err_seq_mem_access,  // Seq memory acess fail
   output reg                     seq_done_pulse,      // Sequencer Done (pulse)
   output reg                     seq_done,            // Sequencer Done

   // Test I/F
   input      [6:0]           test_mux_sel, // test mux select
   output reg [7:0]           test_data     // test data
);
   // Signal Declaration -------------------------------------------------------
   enum logic [3:0]
   {ST_IDLE = 4'b0001,
    ST_READ = 4'b0010,
    ST_PROC = 4'b0100,
    ST_WAIT = 4'b1000}
    state;

   // logic addr_inc addr_reset;
   logic                      mem_write;
   logic [MEM_LOG2DEPTH-1:0]  mem_addr ;
   logic [MEM_WIDTH:0]        mem_wdata;
   logic [MEM_WIDTH:0]        mem_rdata;
   logic [MEM_LOG2DEPTH-1:0]  hif_mem_addr_q;
   logic [MEM_LOG2DEPTH-1:0]  seq_mem_addr;
   logic [MEM_LOG2DEPTH-1:0]  mem_addr_q;
   logic                      parity_bit;
   logic                      parity_check;
   logic [BITS_NUM_CYC-1:0]   cnt_cyc;
   logic                      read_stb;
   logic                      read_stb_q;

   data_t                     obj_mem_rdata_b;


   // LOGIC STARTS HERE --------------------------------------------------------

   // Assign mem_rdata_b_wparity[128:1] to obj_mem_data_b
   // last bit in mem_rdata_b_wparity is parity bit
   assign obj_mem_rdata_b = {>>{mem_rdata[128:1]}};

   // ------------------------------------------------------------------------
   // FSM Process
   // ------------------------------------------------------------------------
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         state             <= ST_IDLE;
         cnt_cyc           <= '0;
         read_stb          <= '0;
         seq_done          <= '0;
         seq_done_pulse    <= '0;
         err_opcode        <= '0;
         seq_mem_addr      <= '0;
         seq_busy          <= '0;
         seq_strobe        <= '0;
         seq_opcode        <= '0;
         seq_data          <= '0;

      end else begin
         read_stb          <= '0;
         err_opcode        <= '0;
         seq_done_pulse    <= '0;
         seq_strobe        <= '0;

         case(state)  // State Machine
         ST_IDLE : begin  // IDLE STATE
            cnt_cyc        <= '0;
            seq_busy       <= '0;
            seq_done       <= seq_done & ~clear_done;  // clear out done when commanded
            seq_mem_addr   <= '0;
            if (seq_start) begin
               state          <= ST_READ;
               seq_busy       <= '1;
               seq_done       <= '0;
               seq_mem_addr   <= seq_start_addr;
               read_stb       <= 1'b1;
            end
         end

         ST_READ : begin // READ STATE
            state    <= ST_PROC;
         end

         ST_PROC : begin  // PROC STATE
            case (obj_mem_rdata_b.opcode)
            OPCODE_PAUSE : begin  // Pause / Done instruction
               seq_done       <= 1'b1;
               seq_done_pulse <= 1'b1;
               seq_busy       <= '0;
               state          <= ST_IDLE;
            end
            OPCODE_WAIT : begin  // Wait instruction
               if (obj_mem_rdata_b.num_cyc != 0) begin
                  state          <= ST_WAIT;
                  cnt_cyc        <= obj_mem_rdata_b.num_cyc - 1'b1;
               end else begin
                  state          <= ST_READ;
                  read_stb       <= 1'b1;
                  seq_mem_addr   <= seq_mem_addr + 1'b1;
               end
            end
            OPCODE_BRANCH : begin  // Branching
               state          <= ST_READ;
               read_stb       <= 1'b1;
               seq_mem_addr   <= obj_mem_rdata_b.num_cyc[MEM_LOG2DEPTH-1 :0];
            end
            OPCODE_CFG_TX   ,
            OPCODE_CFG_TIA  ,
            OPCODE_CFG_ADC1 ,
            OPCODE_CFG_ADC2 ,
            OPCODE_CFG_WLM  ,
            OPCODE_CFG_OPA0 ,
            OPCODE_CFG_OPA1 ,
            OPCODE_CFG_OPA2 ,
            OPCODE_CFG_OPA3 ,
            OPCODE_CFG_OPA4 ,
            OPCODE_CTRL     : begin  // Config & Controls
               seq_strobe     <= 1'b1;
               seq_opcode     <= obj_mem_rdata_b.opcode;
               seq_data       <= obj_mem_rdata_b.outputs;

               if (obj_mem_rdata_b.num_cyc != 0) begin
                  state          <= ST_WAIT;
                  cnt_cyc        <= obj_mem_rdata_b.num_cyc - 1'b1;
               end else begin
                  read_stb       <= 1'b1;
                  seq_mem_addr   <= seq_mem_addr + 1'b1;
               end
            end
            default : begin  // Invalid opcode
               state      <= ST_IDLE;
               err_opcode <= 1'b1;
            end
            endcase
         end

         ST_WAIT : begin // WAIT STATE
            if (cnt_cyc != 0) begin
               cnt_cyc        <= cnt_cyc - 1'b1; // Decrement count cycle
            end else begin
               state          <= ST_READ;
               seq_mem_addr   <= seq_mem_addr + 1'b1;
               read_stb       <= 1'b1;
            end
         end

         default : begin // CASE OTHERS
            state <= ST_IDLE;
         end

         endcase

         if (seq_terminate || err_parity) begin // sequence terminate or parity error
            state    <= ST_IDLE;
            seq_busy <= '0;
         end

      end
   end

   // ------------------------------------------------------------------------
   // Parity Generator / Check
   // parity_odd_not_even =0 (Even parity),
   //                         add parity to make all bits add up to even
   // parity_odd_not_even =1 (Odd parity) ,
   //                         add parity to make all bits add up to odd
   // ------------------------------------------------------------------------
   assign parity_bit = ^{hif_mem_wdata, parity_odd_not_even};
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         mem_write            <= '0;
         mem_wdata            <= '0;
         hif_mem_addr_q       <= '0;
         hif_mem_rdata        <= '0;
         err_seq_mem_access   <= '0;
      end else begin
         mem_write            <= '0;
         // assertion of err_seq_mem_access
         // for attempting memory write while sequencer is busy
         err_seq_mem_access   <= (hif_mem_write & seq_busy);

         if (~seq_busy) begin
            // memory access is controlled by the host interface
            hif_mem_addr_q     <= hif_mem_addr;
            mem_write          <= hif_mem_write;
            mem_wdata          <= {hif_mem_wdata, parity_bit};
            hif_mem_rdata      <= mem_rdata[128:1];
         end

      end
   end
   // select memory address based on sequence busy
   assign mem_addr = (seq_busy) ? seq_mem_addr : hif_mem_addr_q;

   assign parity_check = ^{parity_odd_not_even, mem_rdata};
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         read_stb_q     <= '0;
         mem_addr_q     <= '0;
         err_parity     <= '0;
         err_addr       <= '0;
      end else begin
         read_stb_q     <= read_stb;
         mem_addr_q     <= mem_addr;

         err_parity     <= '0;
         if (read_stb_q) begin  // read pulse
            err_parity  <= parity_check;  // err_parity is a pulse output
         end

         if (clear_err_addr) begin
            err_addr    <= '0;
         end else if (parity_check && read_stb_q) begin
            // latch address with parity error
            err_addr <= mem_addr_q;
         end

      end
   end

   // ------------------------------------------------------------------------
   // Memory Wrapper
   // ------------------------------------------------------------------------
   rp_sequencer_mem_wrapper #(
      .SIMONLY       (SIMONLY      ),
      .MEM_LOG2DEPTH (MEM_LOG2DEPTH),
      .MEM_WIDTH     (MEM_WIDTH+1  ))  // MEM_WIDTH of 128 + one bit for parity
   rp_sequencer_mem_wrapper0(  // 4096 x 129
      // Common
      .clk     (clk)     ,
      .rst_n   (rst_n)   ,
      .addr_a  (mem_addr) ,
      .we_a    (mem_write),
      .din_a   (mem_wdata),
      .dout_a  (mem_rdata)
   );

   // ------------------------------------------------------------------------
   // Test Mux Logic
   // ------------------------------------------------------------------------
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         test_data      <= '0;
      end else begin
         case (test_mux_sel)
         00       : test_data <= '0;
         01       : test_data <= 8'(state);
         02       : test_data <= seq_mem_addr[7:0];
         03       : test_data <= 8'({seq_start, seq_busy, seq_done_pulse});
         04       : test_data <= 8'({parity_odd_not_even, err_parity, err_opcode, err_seq_mem_access});
         05       : test_data <= obj_mem_rdata_b.opcode;
         06       : test_data <= obj_mem_rdata_b.num_cyc[ 7: 0];
         07       : test_data <= obj_mem_rdata_b.outputs[15: 8];
         08       : test_data <= obj_mem_rdata_b.outputs[23:16];
         09       : test_data <= obj_mem_rdata_b.outputs[31:24];
         10       : test_data <= obj_mem_rdata_b.outputs[39:32];
         11       : test_data <= obj_mem_rdata_b.outputs[47:40];
         12       : test_data <= obj_mem_rdata_b.outputs[55:48];
         13       : test_data <= obj_mem_rdata_b.outputs[63:56];
         14       : test_data <= obj_mem_rdata_b.outputs[71:64];
         15       : test_data <= obj_mem_rdata_b.outputs[79:72];
         16       : test_data <= obj_mem_rdata_b.outputs[87:80];
         17       : test_data <= obj_mem_rdata_b.outputs[95:88];
         default  : test_data <= '0;
         endcase
      end
   end

endmodule