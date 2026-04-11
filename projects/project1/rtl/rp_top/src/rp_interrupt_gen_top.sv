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
// Date   : 04/29/2021
//
// Description: Interrupt Generator Top
//
//------------------------------------------------------------------------------

module rp_interrupt_gen_top # (
   parameter ADDR_WIDTH    = 32,
   parameter DATA_WIDTH    = 32
 ) (
   // GENERIC BUS PORTS
   host_if.slave               host_if_slave,


   // clock/reset
   input                       clk,          // clock
   input                       rst_n,        // active low reset
   // Interrupts
   input      [31: 0]          interrupt_in,      // interrupt inputs
   output reg                  interrupt_out      // interrupt output
);

   // -------------------------------------------------------------------------
   // Version Log
   // -------------------------------------------------------------------------
   localparam VERSION          = 16'h01_00;  // Initial VERSION

   // -------------------------------------------------------------------------
   // Signal Declarations
   // -------------------------------------------------------------------------
   logic [31: 0]              int_clear;
   logic [31: 0]              int_set;  // for debug
   logic [31: 0]              int_mask;
   logic [31: 0]              int_status_q;
   

   // -------------------------------------------------------------------------
   // Component Instantiation
   // -------------------------------------------------------------------------
   interrupt_gen_reg_block # (
      .ADDR_WIDTH       (8))
   host_if0 (
   // Config/Status

  // FIELD OUTPUT PORTS
      .def_fld_reg_int_mask                  (int_mask),
      .int_set_reg_int_set                   (int_set),
      .int_clear_reg_int_clear               (int_clear),
  // FIELD INPUT PORTS
      .version_reg_version_ip                (VERSION),
      .def_fld_reg_int_status_ip             (int_status_q),

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
   
   // ======================================================================
   // Interrupt Operation
   // ======================================================================
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         int_status_q      <= '0;
         interrupt_out     <= '0;
      end else begin

         for (int i= 0; i < 32; i++) begin
            if (interrupt_in[i] || int_set[i]) begin // set interrupts
               int_status_q[i] <= int_mask[i];   // stick bits
            end else if (int_clear[i]) begin     // clear interrupts
               int_status_q[i] <= '0;
            end
         end

         interrupt_out <= |int_status_q;  // reduction or

      end
   end





endmodule
