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
// Description: Analog Config Top
//
//------------------------------------------------------------------------------

module rp_analog_config_top # (
   parameter ADDR_WIDTH    = 32,
   parameter DATA_WIDTH    = 32
 ) (
   // GENERIC BUS PORTS
   host_if.slave                           host_if_slave,

   // clock/reset cfg/status
   input                       clk,          // clock
   input                       rst_n,        // active low reset

   // Analog Config (TX)
   output reg [3:0]           itrim_tx,          // TX Current Trim
   output reg [3:0]           pd_tx_n,           // Power Down Transmit Block (active low)

   // Analog Config (RX)
   output reg [3:0]           itrim_rx,          // RX Current Trim
   output reg [4:0]           pd_rx_n,           // Power Down Receive Block (active low)
   output reg                 bypass_tia,        // Bypass      TIAs
   output reg [15:0]          en_amux_output,    // Enable amux outputs
   output reg [5:0]           afe_mux_sel,       // WLM current select for amux
   output reg                 bypass_wlm_afe,    // Bypass WLM analog front end
   output reg                 bypass_ts_afe,     // Bypass temperature sensor analog front end

   output reg [11:0]          alg_amux_sel,     // Aanlog AMUX Select
   output reg [23:0]          alg_dmux_sel,     // Analog DMUX Select

   // Inputs from Analog
   input      [3:0]           alg_dmux,         // Analog DMUX [Tie this to Test Mux block]
   input                      watchdog_active,  // Watchdog Active

   // Test I/F
   input      [7:0]           test_mux_sel,     // test mux select
   output reg [7:0]           test_data         // test data
);

// -------------------------------------------------------------------------
   // Version Log
   // -------------------------------------------------------------------------
   // localparam VERSION          = 16'h01_00;  // Initial VERSION
   localparam VERSION          = 16'h01_01;  // Updated to reflect changes shown in David T.'s email. dated 8/17.


   // ------------------------------------------------------------------------
   // Test Mux
   // ------------------------------------------------------------------------
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         test_data   <= '0;
      end else begin
         case (test_mux_sel)
         00      : test_data  <= '0;
                   // place watchdog, 3x bypass signals & 4x alg_dmux to test_data
         01      : test_data  <= {watchdog_active, bypass_tia,
                                  bypass_wlm_afe, bypass_ts_afe,
                                  alg_dmux};
         default : test_data <= '0;
         endcase
      end
   end

   // -------------------------------------------------------------------------
   // Component Instantiation
   // -------------------------------------------------------------------------
   analog_config_reg_block # (
      .ADDR_WIDTH       (8))
   host_if0 (
  // FIELD OUTPUT PORTS
      .pd_tx_n_reg_config_tx             (pd_tx_n),
      .itrim_tx_reg_config_tx            (itrim_tx),
      .pd_rx_n_reg_config_rx             (pd_rx_n),
      .itrim_rx_reg_config_rx            (itrim_rx),
      .bypass_ts_afe_reg_config_bypass   (bypass_ts_afe),
      .bypass_wlm_afe_reg_config_bypass  (bypass_wlm_afe),
      .bypass_tia_reg_config_bypass      (bypass_tia),
      .afe_mux_sel_reg_config_afe_mux_sel(afe_mux_sel),
      .en_amux_output_reg_config_amux    (en_amux_output),
      .alg_amux_sel_reg_config_amux_sel  (alg_amux_sel),
      .alg_dmux_sel_reg_config_dmux_sel  (alg_dmux_sel),
  // FIELD INPUT PORTS
      .version_reg_version_ip            (VERSION),
      .watchdog_active_reg_status_ip     (watchdog_active),
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


endmodule
