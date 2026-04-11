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
// Date   : 07/30/2021
//
// Description: Single Port Memory (Behavioral Model)
//
//-------------------------------------------------------------------------------
`timescale 1ns/1ps
module rp_ram_single #(
   parameter MEM_LOG2DEPTH = 8,          // Memory Log2Depth
   parameter MEM_WIDTH = 8               // Memory Width
) (
   input                            clk,
   input      [MEM_LOG2DEPTH-1:0]   addr,
   input                            we,
   input      [MEM_WIDTH-1:0]       data_in,
   output reg [MEM_WIDTH-1:0]       data_out
);

   reg [MEM_WIDTH-1:0] mem [2**MEM_LOG2DEPTH-1:0];

   always @(posedge clk) begin
      if (we) begin
         mem[addr] <= data_in;
      end
      data_out     <= mem[addr];
   end

endmodule


