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
// Date   : 05/14/2021
//
// Description: ADC post-procesor averager
//
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module rp_adc_postproc_averager (
   // clock/reset cfg/status
   input                         clk,          // clock
   input                         rst_n,        // active low reset

   // Averager Config
   input                         in_adc_start,      // adc conversion start
   input                         in_adc_avg_en,     // ADC averager enables
   input     [ 5:0]              in_adc_num_conv,   // ADC number of conversions

   input      [19:0]             in_data,       // Averager data in
   input                         in_dv,         // Averager data in strobe

   output reg                    out_dv      ,  // output data valid
   output reg [19:0]             out_data    ,  // output data
   output reg                    out_rail_err,  // output error rail

   // Status/ Errros
   output reg                    err_avg_start, // Averager start error

   // Test I/F
   input      [5:0]              test_mux_sel, // test mux select
   output reg [7:0]              test_data     // test data
);

   // ////////////////////////////////////////////////////////////////////////-
   // Function(s)
   // ////////////////////////////////////////////////////////////////////////-
   function [2:0] shift_len (input [5:0] data_in);
      begin
         if (data_in[5]) begin
            shift_len = 3'd5;
         end else if (data_in[4]) begin
            shift_len = 3'd4;
         end else if (data_in[3]) begin
            shift_len = 3'd3;
         end else if (data_in[2]) begin
            shift_len = 3'd2;
         end else if (data_in[1]) begin
            shift_len = 3'd1;
         end else if (data_in[0]) begin
            shift_len = 3'd0;
         end else begin
            shift_len = 3'd0;
         end

      end
   endfunction


   // ////////////////////////////////////////////////////////////////////////-
   // Logic
   // ////////////////////////////////////////////////////////////////////////-

   localparam BITS_STG1    = 25; // # of bits required for accumulator  (5-bit groth, for 32 averaging)
   localparam MAX_NEG      = -1 * (2**19);
   localparam MAX_POS      =      (2**19)-1;

   // stage 1 accumulator
   logic                               s1_dv;
   logic signed   [BITS_STG1-1:0]      s1_accum;  // 1st stage accumulator
   logic unsigned [5:0]                s1_cnt;
   logic unsigned [2:0]                s1_right_shift;  // 0 to 7

   // stage 2 rounding + shifter
   logic                               s2_dv;
   logic signed   [BITS_STG1-1:0]      s2_data;  // 1nd stage data
   logic signed   [$left(s1_accum):0]  s2_half;
   logic signed   [$left(s1_accum):0]  s2_temp ;

   // Averager
   always @ (posedge clk, negedge rst_n)  // 1st stage - Accumulator / Counter
   begin
      if (!rst_n) begin
         s1_accum       <= '0;
         s1_dv          <= '0;
         s1_cnt         <= '0;
         s1_right_shift <= '0;  // Need a look up table
         err_avg_start  <= '0;
      end else begin
         s1_dv          <= '0;
         err_avg_start  <= '0;
         // assume that in_adc_start doesn't coincide with in_dv
         // since in_adc_start will occur before receiving adc data
         if (in_adc_start) begin
            s1_cnt         <= '0;
            s1_accum       <= '0;  // reset accumulator
            s1_right_shift <= shift_len(in_adc_num_conv);
            // Check to see if counter is 0.  Nonzero in counter indicates
            // previous averaging operation wasn't finished.
            if (s1_cnt != 0)
               err_avg_start <= 1'b1;
         end else if (in_dv) begin // in_dv = 1
            if ((s1_cnt+1) == in_adc_num_conv) begin  // count = avg_len (reset counter)
               s1_cnt   <= '0;
               s1_dv    <= 1'b1;
            end else begin
               s1_cnt   <= s1_cnt + 1'b1;
               s1_dv    <= 1'b0;
            end
            if (s1_cnt == 0)
               s1_accum <= BITS_STG1'(signed'(in_data));
            else
               s1_accum <= s1_accum + signed'(in_data);
         end
      end
   end

   // rounding
   // assign s2_half     = (1 <<< (s1_right_shift-1));  // left shift
   // half data LUT
   always_comb
   begin
      case (s1_right_shift)
      // 0        : s2_half   = '0;
      1        : s2_half   = 25'd1;
      2        : s2_half   = 25'd2;
      3        : s2_half   = 25'd4;
      4        : s2_half   = 25'd8;
      5        : s2_half   = 25'd16;
      6        : s2_half   = 25'd32;
      7        : s2_half   = 25'd64;
      default  : s2_half   = 25'd0;
      endcase
   end

   assign s2_temp     = s1_accum + s2_half;
   always @ (posedge clk, negedge rst_n)  // 2nd stage - Rounding & Shift  
   begin
      if (!rst_n) begin
         s2_data        <= '0;
         s2_dv          <= '0;
      end else begin
         s2_dv          <= s1_dv;
         if (s1_dv) begin
            // right shift
            s2_data     <= (s2_temp >>> s1_right_shift);
         end
      end
   end

   always @ (posedge clk, negedge rst_n)  // Output process (clipping in case of railing)
   begin
      if (!rst_n) begin
         out_dv         <= '0;
         out_data       <= '0;
         out_rail_err   <= '0;
      end else begin
         out_dv         <= '0;
         out_rail_err   <= '0;

         if (in_adc_avg_en) begin  // averaging enable
            out_dv         <= s2_dv;
            if ((&s2_data[$left(s2_data):20] != 1) &   // All msbs are not 1s = not negative
               (|s2_data[$left(s2_data):20] != 0)) begin   // All msbs are not 0s = not positive
               out_rail_err   <= 1'b1;
               if (s2_data[$left(s2_data)]) // negative - clipping
                  out_data       <= {1'b1, {19{1'b0}}};
               else                         // positive - clipping
                  out_data       <= {1'b0, {19{1'b1}}};
            end else begin
               out_rail_err   <= '0;
               out_data       <= s2_data[19:0];  // 20lsbs of s2_data
            end
         end else begin  // average bypas
            out_dv         <= in_dv;
            out_data       <= in_data;
         end
      end
   end

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
         01       : test_data <= 8'({s1_dv, s1_cnt});
         02       : test_data <= s1_accum [07:00];
         03       : test_data <= 8'(s1_right_shift);
         04       : test_data <= 8'(s2_dv);
         05       : test_data <= s2_data[07:00];
         default  : test_data <= '0;
         endcase
      end
   end

endmodule
