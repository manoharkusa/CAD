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
// Date   : 05/16/2021
//
// Description: ADC post-procesor top
//
//------------------------------------------------------------------------------

module rp_adc_postproc_top # (
   parameter ADC_ID        = 0,
   parameter DATA_WIDTH    = 32
 ) (

   // GENERIC BUS PORTS

   host_if.slave                           host_if_slave,

   // clock/reset cfg/status
   input                         clk,            // clock
   input                         rst_n,          // active low reset

   input                         in_soc ,        // Decimator start of conversion
   input                         in_eoc ,        // Decimator end of conversion
   input                         in_stb ,        // Decimator data strobe
   input                         in_data,        // Decimator data

   // commands from sequencer
   input                         in_adc_start,   // adc conversion start
   input     [ 6:0]              in_seq_id   ,   // sequence ID
   input                         in_adc_avg_en,  // ADC averager enables
   input     [ 5:0]              in_adc_num_conv,// ADC number of conversions

   output reg                    app_req,        // app request
   input                         app_grant,      // app grant
   output reg                    app_dv  ,       // app_data valid
   output reg [31:0]             app_data,       // app data

   // Status/ Errros
   output reg                    out_err_dec_start,           // Decimator start error
   output reg                    out_err_dec_soc_eoc_overlap, // Decimator soc eoc overlap error
   output reg                    out_err_avg_start, // Averager start error
   output reg                    out_err_timeout,// error timeout
   output reg                    out_rail_err,   // error rail

   // Test I/F
   input      [7:0]              test_mux_sel,   // test mux select
   output reg [7:0]              test_data       // test data
);

   // -------------------------------------------------------------------------
   // Version Log
   // -------------------------------------------------------------------------
   // localparam VERSION  = 16'h01_00;  // Initial VERSION
   localparam VERSION  = 16'h01_01;  // Added soc, eoc, stb inputs for decimation
                                     // Removed averager configuration registers
                                     // Added sequencer commands for averager
                                     // Added ADC ID parameter for tagging the output data


   // -------------------------------------------------------------------------
   // Signal Declarations
   // -------------------------------------------------------------------------
   logic [ 2:0]   if_bypass_accum;
   logic [15:0]   if_wdg_cnt;

   logic          dec_dv;
   logic [19:0]   dec_data;

   logic          avg_dv;
   logic [19:0]   avg_data;

   logic [ 7:0]   test_data_decimator;
   logic [ 7:0]   test_data_averager;
   logic [ 7:0]   test_data_outputs;

   // -------------------------------------------------------------------------
   // Component Instantiation
   // -------------------------------------------------------------------------
   adc_postproc_reg_block #(
      .ADDR_WIDTH       (8))
   host_if0 (
      // FIELD OUTPUT PORTS
      .bypass_accum0_reg_accum_bypass     (if_bypass_accum[0]),
      .bypass_accum1_reg_accum_bypass     (if_bypass_accum[1]),
      .bypass_accum2_reg_accum_bypass     (if_bypass_accum[2]),
      .wdg_cnt_reg_wdg                    (if_wdg_cnt),

      // FIELD INPUT PORTS
      .version_reg_version_ip             (VERSION),

      .clock      (host_if_slave.hclk) , // Register Bus Clock
      .reset      (host_if_slave.hrst_n) , // Register Bus Reset
      .waddr      (host_if_slave.addr) , // Write Address-Bus
      .raddr      (host_if_slave.addr) , // Read Address-Bus
      .wdata      (host_if_slave.wdata) , // Write Data-Bus
      .rdata      (host_if_slave.rdata) , // Read Data-Bus
      .rstrobe    (host_if_slave.rstrobe) , // Read-Strobe
      .wstrobe    (host_if_slave.wstrobe) , // Write-Strobe
      .raddrerr   (host_if_slave.raddrerr) , // Read-Address-Error
      .waddrerr   (host_if_slave.waddrerr) , // Write-Address-Error
      .wack       (host_if_slave.wack) , // Write Acknowledge
      .rack       (host_if_slave.rack)// Read Acknowledge
   );

   rp_adc_postproc_decimator decimator (  // Decimator
      .clk           (clk),
      .rst_n         (rst_n),

      .in_soc        (in_soc),
      .in_eoc        (in_eoc),
      .in_stb        (in_stb),
      .in_data       (in_data),

      .bypass_accum  (if_bypass_accum),

      .out_dv        (dec_dv),
      .out_data      (dec_data),

      .err_start           (out_err_dec_start          ),
      .err_soc_eoc_overlap (out_err_dec_soc_eoc_overlap),

      .test_mux_sel  (test_mux_sel[5:0]),
      .test_data     (test_data_decimator)
   );

   rp_adc_postproc_averager averager (  // averager
      .clk              (clk),
      .rst_n            (rst_n),

      // Averager Config
      .in_adc_start     (in_adc_start   ),
      .in_adc_avg_en    (in_adc_avg_en  ),
      .in_adc_num_conv  (in_adc_num_conv),

      .in_dv            (dec_dv),
      .in_data          (dec_data),

      .out_dv           (avg_dv),
      .out_data         (avg_data),
      .out_rail_err     (out_rail_err),

      .err_avg_start    (out_err_avg_start),

      .test_mux_sel     (test_mux_sel[5:0]),
      .test_data        (test_data_averager)
   );

   rp_adc_postproc_outputs #(
      .ADC_ID           (ADC_ID))
   outputs (  // output module
      .clk              (clk),
      .rst_n            (rst_n),

      .wdg_cnt          (if_wdg_cnt),
      .in_seq_id        (in_seq_id  ),
      .in_adc_start     (in_adc_start),

      .in_dv            (avg_dv),
      .in_data          (avg_data),

      .app_req          (app_req),
      .app_grant        (app_grant),
      .app_dv           (app_dv   ),
      .app_data         (app_data ),

      .out_err_timeout  (out_err_timeout),

      .test_mux_sel     (test_mux_sel[5:0]),
      .test_data        (test_data_outputs)
   );

   // ------------------------------------------------------------------------
   // Test Mux
   // ------------------------------------------------------------------------
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         test_data      <= '0;
      end else begin
         case (test_mux_sel[7:6])
         2'b00   : test_data   <= test_data_decimator;
         2'b01   : test_data   <= test_data_averager;
         2'b10   : test_data   <= test_data_outputs;
         // 2'b11   : test_data   <= '0;
         default : test_data   <= '0;
         endcase
      end
   end

endmodule
