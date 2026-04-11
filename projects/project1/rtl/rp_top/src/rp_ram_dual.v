//###################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
 //------------------------------------------------------------------------------
// Copyright 2015-2021 Rockley Photonics. All Rights Reserved
//
// Author : D. Lee
//
// Project: RPS - Uintah
//
// Date   : 04/07/2021
//
// Description: Dual Port Memory (Behavioral Model)
//
//-------------------------------------------------------------------------------
`timescale 1ns/1ps
module rp_ram_dual #(
   parameter MEM_LOG2DEPTH = 8,          // Memory Log2Depth
   parameter MEM_WIDTH = 8               // Memory Width
) (
   input                      we, clk1, clk2,
   output reg [MEM_WIDTH-1:0] q,
   input [MEM_WIDTH-1:0]      d,
   input [MEM_LOG2DEPTH-1:0]  addr_in,
   input [MEM_LOG2DEPTH-1:0]  addr_out
);
// q, addr_in, addr_out, d, we, clk1, clk2);
 
   // reg [6:0] addr_out_reg;
   reg [MEM_WIDTH-1:0] mem [2**MEM_LOG2DEPTH-1:0];
 
   always @(posedge clk1) begin
      if (we)
         mem[addr_in] <= d;
   end
 
   always @(posedge clk2) begin
      q     <= mem[addr_out];
      // addr_out_reg <= addr_out;
   end
        
endmodule


