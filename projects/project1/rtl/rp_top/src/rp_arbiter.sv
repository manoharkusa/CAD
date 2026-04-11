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
// Date   : 05/18/2021
//
// Description: Arbiter
//
//-------------------------------------------------------------------------------

`timescale 1ns/1ps

module rp_arbiter #(
   parameter NUM_DEV = 10             // Number of devices
) (
   input                       clk,          // clock
   input                       rst_n,        // active low reset

   input      [15:0]           cfg_wdg_cnt ,          // watchdog timer count
   input      [NUM_DEV-1:0]    cfg_bus_mask,          // bus mask

   input      [NUM_DEV-1:0]    app_req              , // app request
   output reg [NUM_DEV-1:0]    app_grant            , // app grant
   input      [NUM_DEV-1:0]    app_dv               , // app_data valid
   input      [31:0]           app_data[0:NUM_DEV-1], // app data

   output reg                  out_dv  ,     // out_data valid
   output reg [31:0]           out_data,     // out data

   output reg                  err_timeout,  // error timeout

   // Test I/F
   input      [7:0]            test_mux_sel, // test mux select
   output reg [7:0]            test_data     // test data
);
   // Function Declaration -----------------------------------------------------
   localparam BITS_NUM_DEV = $clog2(NUM_DEV);

   function [BITS_NUM_DEV-1:0] one_hot2binary
      (input [NUM_DEV-1:0] in_data);
      begin
         one_hot2binary = '0;
         for (int i = 0; i < NUM_DEV; i++) begin
            if (in_data[i] == 1'b1) begin
               one_hot2binary = BITS_NUM_DEV'(unsigned'(i));
               break;
            end
         end
      end
   endfunction

   // Signal Declaration -------------------------------------------------------
   enum logic [1:0]
   {ST_IDLE  = 2'b01,
    ST_GRANT = 2'b10}
    state;
   logic [BITS_NUM_DEV-1:0]      chan_sel;
   logic [$left(cfg_wdg_cnt):0]  timeout_cnt;

   // LOGIC STARTS HERE --------------------------------------------------------

   // FSM
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         state                <= ST_IDLE;
         chan_sel             <= '0;
         app_grant            <= '0;
      end else begin
         case (state)
         ST_IDLE : begin
            app_grant         <= '0;
            if (|(app_req & cfg_bus_mask)) begin  // request has been asserted
               chan_sel    <= one_hot2binary(app_req & cfg_bus_mask);
               state       <= ST_GRANT;
            end
         end
         ST_GRANT : begin
            app_grant[chan_sel]  <= 1'b1;  // grant stays high as long as req is high
            if ( (~app_req[chan_sel]) || (err_timeout)) begin // request has been deasserted or time out error
               state       <= ST_IDLE;
               app_grant   <= '0;
            end
         end
         default : begin
            state          <= ST_IDLE;
            app_grant      <= '0;
         end
         endcase
      end
   end

   // Watchdog Timer
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         timeout_cnt          <= '0;
         err_timeout          <= '0;
      end else begin
         if (state == ST_GRANT) // count down timer
            if (timeout_cnt == 0) begin  // timeout error
               err_timeout    <= 1'b1;
               timeout_cnt    <= timeout_cnt;
            end else begin
               err_timeout    <= 1'b0;
               timeout_cnt    <= timeout_cnt - 1'b1;
            end
         else begin
            err_timeout        <= 1'b0;
            timeout_cnt        <= cfg_wdg_cnt;  // load timer
         end
      end
   end

   // output process
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         out_dv               <= '0;
         out_data             <= '0;
      end else begin
         out_dv               <= app_dv  [chan_sel];
         out_data             <= app_data[chan_sel];
      end
   end

   // Test Mux
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         test_data      <= '0;
      end else begin
         case (test_mux_sel)
         00      : test_data <= '0;
         01      : test_data <= 8'(state);
         02      : test_data <= timeout_cnt[7:0];
         03      : test_data <= 8'(chan_sel);
         04      : test_data <= app_grant[7:0];
         default : test_data <= '0;
         endcase
      end
   end

endmodule
