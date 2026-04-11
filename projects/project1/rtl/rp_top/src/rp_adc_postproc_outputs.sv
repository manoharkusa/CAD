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
// Date   : 05/16/2021
//
// Description: ADC post-procesor outputs
//
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module rp_adc_postproc_outputs # (
   parameter ADC_ID        = 0,                 // ADC ID
   parameter BITS_IN       = 20                 // Number of bits in in_data
) (
   // clock/reset cfg/status
   input                         clk,          // clock
   input                         rst_n,        // active low reset

   input      [15:0]             wdg_cnt,       // Watchdog Count

   input                         in_adc_start,   // adc conversion start
   input      [6:0]              in_seq_id  ,    // sequence ID

   input      [BITS_IN-1:0]      in_data,       // Averager data in
   input                         in_dv,         // Averager data in strobe

   output reg                    app_req,       // app request
   input                         app_grant,     // app grant
   output reg                    app_dv  ,      // app_data valid
   output reg [31:0]             app_data,      // app data

   // Error Status / Counters
   output reg                    out_err_timeout,  // error timeout

   // Test I/F
   input      [5:0]              test_mux_sel, // test mux select
   output reg [7:0]              test_data     // test data
);

   // ////////////////////////////////////////////////////////////////////////-
   // Logic
   // ////////////////////////////////////////////////////////////////////////-
   localparam logic[4:0] ADC_ID_LOCAL = ADC_ID;

   logic [31:0]   data_conc;
   logic [15:0]   cnt_wdg;

   // concatenate phase number and input data
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         data_conc      <= '0;
      end else begin
         if (in_adc_start) begin // in_adc_start (pulse)
            data_conc[6:0]  <= in_seq_id;
         end
         if (in_dv) begin
            data_conc[31:12] <= in_data;
         end
         data_conc[11:7] <= ADC_ID_LOCAL;  // !!! This might get synthesized to constant.
      end
   end
   assign app_data          = data_conc;

   // Request and grant handshake
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         app_req  <= 1'b0;
         app_dv   <= 1'b0;
      end else begin
         if (app_grant || out_err_timeout) begin
            app_req  <= 1'b0;
         end else if (in_dv) begin
            app_req  <= 1'b1;
         end
         app_dv   <= (app_grant && ~app_dv && app_req);
      end
   end

  // timeout error check
  always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         cnt_wdg           <= '0;
         out_err_timeout   <= '0;
      end else begin
         out_err_timeout   <= '0;
         if (~app_req)  // if request is deasserted
            cnt_wdg        <= wdg_cnt;  // load new wdg count to wdg counter
         else if (app_req) begin  // when request is asserted
            if (cnt_wdg == 0)           // WDG timer expires
               out_err_timeout   <= 1'b1;  // timeout error
            else
               cnt_wdg           <= cnt_wdg - 1'b1;  // decrement timer
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
         01       : test_data <= cnt_wdg[7:0];
         02       : test_data <= data_conc[31:24];
         03       : test_data <= data_conc[23:16];
         04       : test_data <= data_conc[15:08];
         05       : test_data <= data_conc[07:00];
         06       : test_data <= 8'({app_req, app_grant, app_dv, out_err_timeout});
         default  : test_data <= '0;
         endcase
      end
   end

endmodule
