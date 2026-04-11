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
// Date   : 08/12/2021
//
// Description: Local Top
//
//------------------------------------------------------------------------------

module rp_local_top # (
   parameter logic [15:0] VERSION = 16'h00_00,
   parameter              NUM_ADC = 1,
   parameter              NUM_TOC = 1,
   parameter              NUM_OPA = 1
 ) (
   // GENERIC BUS PORTS
   host_if.slave               host_if_slave,

   // clock/reset cfg/status
   input                       clk,          // clock
   input                       rst_n        // active low reset
);

   // -------------------------------------------------------------------------
   // Component Instantiation
   // -------------------------------------------------------------------------
   local_reg_block # (
      .ADDR_WIDTH       (8))
   host_if0 (
   // Config/Status
      .version_reg_version_ip       (VERSION),
      .num_opa_reg_capability_ip    (8'(NUM_OPA)),
      .num_toc_reg_capability_ip    (8'(NUM_TOC)),
      .num_adc_reg_capability_ip    (8'(NUM_ADC)),
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
      .waddrerr   () , // Write-Address-Error
      .wack       () , // Write Acknowledge
      .rack       (host_if_slave.rack)// Read Acknowledge
    );

   assign host_if_slave.waddrerr = 1'b0; // no write in this block (tie the signal to 0)
   assign host_if_slave.wack = 1'b0;  // no write in this block (tie the signal to 0)

endmodule
