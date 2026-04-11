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
// Description: Test Mux Top
//
//------------------------------------------------------------------------------

module rp_test_mux_top # (
   parameter NUM_BLOCKS    = 10,             // Number of test block
   parameter ADDR_WIDTH    = 32,
   parameter DATA_WIDTH    = 32
 ) (
   // GENERIC BUS PORTS
   host_if.slave               host_if_slave,


   // clock/reset cfg/status
   input                       clk,          // clock
   input                       rst_n,        // active low reset
   // data interface
   output reg [ 7:0]           test_mux_sel_data, // test mux select data

   // Test I/F
   input      [ 7:0]           test_data_in[0:NUM_BLOCKS-1], // test data in
   output reg [ 3:0]           test_data_out,    // test data

   // Invalid block error
   output reg                  err_invalid_block   // invalid block error
);

   // -------------------------------------------------------------------------
   // Version Log
   // -------------------------------------------------------------------------
   localparam VERSION          = 16'h01_00;  // Initial VERSION

   // -------------------------------------------------------------------------
   // Signal Declarations
   // -------------------------------------------------------------------------
   logic[ 7:0] test_mux_sel_block_i;
   logic[ 7:0] test_mux_sel_data_i;
   logic       nibble_sel;

   // -------------------------------------------------------------------------
   // Component Instantiation
   // -------------------------------------------------------------------------
   test_mux_reg_block # (
      .ADDR_WIDTH       (8))
   host_if0 (
   // Config/Status

  // FIELD OUTPUT PORTS
      .sel_data_reg_mux_sel                  (test_mux_sel_data_i),
      .sel_module_reg_mux_sel                (test_mux_sel_block_i),
      .nibble_sel_reg_mux_cfg                (nibble_sel),
  // FIELD INPUT PORTS
      .version_reg_version_ip                (VERSION),

   // GENERIC BUS PORTS
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

   rp_test_mux #(
      .NUM_BLOCKS             (NUM_BLOCKS))
   test_mux0 (
      .clk                    (clk  ),
      .rst_n                  (rst_n),
      // block select interface
      .nibble_sel             (nibble_sel),
      .test_mux_sel_block     (test_mux_sel_block_i),

      // data select interface
      .in_test_mux_sel_data   (test_mux_sel_data_i),
      .out_test_mux_sel_data  (test_mux_sel_data),
      .test_data_in           (test_data_in ),
      .test_data_out          (test_data_out),

      // error / interrupt
      .err_invalid_block      (err_invalid_block )
   );

endmodule
