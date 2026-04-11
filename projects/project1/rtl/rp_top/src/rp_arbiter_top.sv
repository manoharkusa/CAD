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
// Description: Arbiter Top
//
//------------------------------------------------------------------------------

module rp_arbiter_top # (
   parameter NUM_DEV       = 1,
   parameter ADDR_WIDTH    = 32,
   parameter DATA_WIDTH    = 32
 ) (
   // GENERIC BUS PORTS
   host_if.slave               host_if_slave,

   // clock/reset cfg/status
   input                       clk,          // clock
   input                       rst_n,        // active low reset

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

   // -------------------------------------------------------------------------
   // Signal Declarations
   // -------------------------------------------------------------------------
   // localparam VERSION            = 16'h00_01;     // Version Number
   // localparam VERSION            = 16'h00_02;     // Increased bus mask width to 32-bits
   localparam VERSION            = 16'h01_01;     // Fixed RDA-98 bug.  cfg_bus_mask failed to disable arbiter operation.
                                                  // Preset wdg timer to 64.
                                                  // Preset interrupt mask to 0xFFFF_FFFF

   logic    [15:0]               cfg_wdg_cnt ;
   logic    [31:0]               cfg_bus_mask;

   // -------------------------------------------------------------------------
   // Component Instantiation
   // -------------------------------------------------------------------------
   arbiter_reg_block #(
      .ADDR_WIDTH    (8),
      .DATA_WIDTH    (32))
   host_if0 (
      // Config/Status
      .wdg_cnt_reg_wdg_cnt   (cfg_wdg_cnt   ),
      .def_fld_reg_bus_mask  (cfg_bus_mask  ),
      .version_reg_version_ip(VERSION),
      .num_dev_reg_num_dev_ip(8'(NUM_DEV)),
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

   rp_arbiter #(
      .NUM_DEV          (NUM_DEV))
   arbiter (
      .clk              (clk           ),
      .rst_n            (rst_n         ),
      .cfg_wdg_cnt      (cfg_wdg_cnt   ),
      .cfg_bus_mask     (cfg_bus_mask[NUM_DEV-1:0]),
      .app_req          (app_req       ),
      .app_grant        (app_grant     ),
      .app_dv           (app_dv        ),
      .app_data         (app_data      ),
      .out_dv           (out_dv        ),
      .out_data         (out_data      ),
      .err_timeout      (err_timeout   ),
      .test_mux_sel     (test_mux_sel  ),
      .test_data        (test_data     )
   );

endmodule
