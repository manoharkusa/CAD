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
// Date   : 04/30/2021
//
// Description: Test Mux
//
//-------------------------------------------------------------------------------

`timescale 1ns/1ps

module rp_test_mux #(
   parameter NUM_BLOCKS = 10             // Number of test ports
) (
   // clock/reset
   input                       clk,          // clock
   input                       rst_n,        // active low reset

   // block select interface
   input                       nibble_sel,                  // nibble select
   input      [ 7:0]           test_mux_sel_block,          // test mux select (in)

   // data select interface
   input      [ 7:0]           in_test_mux_sel_data ,        // Test Mus Data Select
   output reg [ 7:0]           out_test_mux_sel_data,        // Test Mus Data Select

   input      [ 7:0]           test_data_in[0:NUM_BLOCKS-1], // test data in
   output reg [ 3:0]           test_data_out,                // test data out

   // Status
   output reg                  err_invalid_block             // invalid block selected
);
   // Signal Declaration -------------------------------------------------------
   localparam BITS_BLOCKS     = $clog2(NUM_BLOCKS);
   logic [BITS_BLOCKS-1 :0]   mux_sel_block;

   // LOGIC STARTS HERE --------------------------------------------------------
   assign mux_sel_block = test_mux_sel_block[BITS_BLOCKS-1 :0];

   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         err_invalid_block       <= 1'b0;
         test_data_out           <= '0;
         out_test_mux_sel_data   <= '0;
      end else begin
         // check to see if test_mux_sel_block within range
         err_invalid_block <= 1'b0;
         if (test_mux_sel_block < NUM_BLOCKS) begin
            if (nibble_sel) begin // upper nibble
               test_data_out  <= test_data_in[mux_sel_block][7:4];
            end else begin        // lower nibble
               test_data_out  <= test_data_in[mux_sel_block][3:0];
            end
            out_test_mux_sel_data   <= in_test_mux_sel_data;
         end else begin // mux_sel_block is out of range
            test_data_out           <= '0;
            err_invalid_block       <= 1'b1;
            out_test_mux_sel_data   <= '0;
         end
      end
   end

endmodule
