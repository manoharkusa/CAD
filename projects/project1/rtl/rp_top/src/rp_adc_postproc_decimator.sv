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
// Date   : 05/12/2021
//
// Description: ADC post-procesor decimator
//
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module rp_adc_postproc_decimator (
   // clock/reset cfg/status
   input                      clk,          // clock
   input                      rst_n,        // active low reset

   input                      in_soc,        // start of conversion
   input                      in_eoc,        // end of conversion
   input                      in_stb,        // input strobe
   input                      in_data,       // input data

   input      [2:0]           bypass_accum,  // Decimator accumulator mask

   output reg                 out_dv        ,  // output data valid
   output reg [19:0]          out_data      ,  // output data

   output reg                 err_start,           // Decimator start error
   output reg                 err_soc_eoc_overlap, // Decimator soc eoc overlap error

   // Test I/F
   input      [5:0]           test_mux_sel, // test mux select
   output reg [7:0]           test_data     // test data
);

   // -------------------------------------------------------------------------
   // Logic
   // -------------------------------------------------------------------------

   // logic signed   [1:0]   data_in_signed;
   logic signed   [9:0]   s1_accum;  // 1st stage accumulator
   logic signed   [15:0]  s2_accum;  // 2nd stage accumulator
   logic signed   [23:0]  s3_accum;  // 3rd stage accumulator
   logic                  s3_dv;
   logic signed   [23:0]  s3_accum_mult3;  // s3 accumulator x 3;
   logic                  flag_start;

   // Error Checks
   always @ (posedge clk, negedge rst_n)  // Output process
   begin
      if (!rst_n) begin
         flag_start          <= 1'b0;
         err_start           <= 1'b0;
         err_soc_eoc_overlap <= 1'b0;
      end else begin
         if (in_stb) begin
            if (in_soc) begin
               flag_start  <= 1'b1;
            end else if (in_eoc) begin
               flag_start  <= 1'b0;
            end
         end
         err_start            <= (flag_start & in_soc & in_stb) ;  // back to back soc's without eoc
         err_soc_eoc_overlap  <= (in_soc & in_eoc);      // overlap in soc & eoc event
      end
   end

   // 3rd order cascaded integrators
   // assign data_in_signed = (in_data) ? 1 : -1;  // +1 if data is 1, -1 if data is 0

   always @ (posedge clk, negedge rst_n)  // 1st stage
   begin
      if (!rst_n) begin
         s1_accum       <= '0;
         s2_accum       <= '0;
         s3_accum       <= '0;
         s3_dv          <= '0;
      end else begin
         s3_dv          <= '0;
         if (in_stb) begin
            if (in_soc) begin  // first data
               s1_accum <= 10'(signed'({~in_data, 1'b1}));  // +1 if data is 1, -1 if data is 0
               s2_accum <= '0;
               s3_accum <= '0;
            end else begin
               if (bypass_accum[0]) begin  // bypass accumulation
                  s1_accum <= 10'(signed'({~in_data, 1'b1}));  // +1 if data is 1, -1 if data is 0
               end else begin
                  s1_accum <= s1_accum + 10'(signed'({~in_data, 1'b1}));  // +1 if data is 1, -1 if data is 0
               end
               if (bypass_accum[1]) begin  // bypass accumulation
                  s2_accum <= 16'(s1_accum);
               end else begin
                  s2_accum <= s2_accum + s1_accum;
               end
               if (bypass_accum[2]) begin  // bypass accumulation
                  s3_accum <= 24'(s2_accum);
               end else begin
                  s3_accum <= s3_accum + s2_accum;
               end
            end
            s3_dv       <= in_eoc;
         end
      end
   end

   // scaling (multiply by 3 divide by 16)
   assign s3_accum_mult3 = (s3_accum <<< 1) + s3_accum;  // accum3 * 2 + accum

   always @ (posedge clk, negedge rst_n)  // Output process
   begin
      if (!rst_n) begin
         out_dv         <= '0;
         out_data       <= '0;
      end else begin
         out_dv         <= s3_dv;
         if (s3_dv) begin
            // discard 4 lsbs to perform division of 16
            out_data    <= s3_accum_mult3[23:4];
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
         01       : test_data <= s1_accum[7:0];
         02       : test_data <= s2_accum[7:0];
         03       : test_data <= s3_accum[7:0];
         04       : test_data <= 8'(s3_dv);
         05       : test_data <= out_data[7:0];
         06       : test_data <= 8'(out_dv);
         default  : test_data <= '0;
         endcase
      end
   end

endmodule
