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
// Date   : 04/08/2021
//
// Description: Sequencer Top
//
//------------------------------------------------------------------------------

import rp_sequencer_pkg::*;

module rp_sequencer_top # (
   parameter SIMONLY       = 0,      // 1 for behavior mem model, TSMC mem model for others
   parameter ADDR_WIDTH    = 32,
   parameter DATA_WIDTH    = 32
 ) (
   // GENERIC BUS PORTS
   host_if.slave              host_if_slave,

   // clock/reset cfg/status
   input                      clk,          // clock
   input                      rst_n,        // active low reset

   // Analog transmit interface [79-signals]
   output reg [13:0]          lan_en,           // Laser/LED anode enable
   output reg [ 9:0]          dac_las_sel,      // Laser/LED DAC current select
   output reg                 las_n_led,        // Select mode: 1=laser, 0=LED
   output reg [12:0]          lcat_en,          // Laser cathode enable
   output reg [25:0]          hga_sel,          // Grating heater anode select
   output reg [ 4:0]          hgc_sel,          // Grating heater cathode seelct
   output reg [ 9:0]          dac_htr_las_sel,  // Laser/LED DAC Current select

   // WLM interface [80-signals]
   output reg [ 9:0]          d1mzisw_sel,      // SW MZI heater DAC current select
   output reg [ 9:0]          d2mzisw_sel,      // SW MZI heater DAC current select
   output reg [ 9:0]          d3mzisw_sel,      // SW MZI heater DAC current select
   output reg [ 9:0]          d4mzisw_sel,      // SW MZI heater DAC current select
   output reg [ 9:0]          d1mzilw_sel,      // LW MZI heater DAC current select
   output reg [ 9:0]          d2mzilw_sel,      // LW MZI heater DAC current select
   output reg [ 9:0]          d3mzilw_sel,      // LW MZI heater DAC current select
   output reg [ 9:0]          d4mzilw_sel,      // LW MZI heater DAC current select

   // OPA interface [396-signals]
   output reg [11:0]          opa_ramp_duration, // OPA ramp duration, number of DAC updates
   output reg [ 7:0]          opa_num_ramps,     // OPA number of ramps
   output reg [ 7:0]          opa_dac_rate,      // OPA DAC update rate
   output reg [19:0]          opa_init_val [ 0:3], // OPA init value
   output reg [31:0]          opa_step_size[ 0:3], // OPA step size
   output reg [19:0]          opa_limit_min[ 0:3], // OPA min limit
   output reg [19:0]          opa_limit_max[ 0:3], // OPA max limit

   // RX TIA CFG [4 TIAs] to TIA Analog Circuit
   output reg [ 3:0]          tia_enhc,          // TIA 3-0 enable high capacitance mode [bit0 controls TIA0, bit1 controls TIA1, ...]
   output reg [15:0]          tia_gain_ctrl,     // TIA 3-0 Gain Control {bits[3-0] controls TIA0, bits[7-4] controls TIA1, ...}, 4-bits per TIA
   output reg [ 7:0]          tia_offset_adjust[0:3], // TIA 0-3 offset adjust {bits[7-0] each}

   // RX ADC CFG [16 ADCs]
   output reg [15:0]          adc_avg_en,             // ADC averager enables
   output reg [ 5:0]          adc_num_conv[0:15],     // ADC averager number of conversions

   // CTRL signals [4 TIAs, 16 ADCs, ]
   output reg [ 3:0]          tia_off_cal_start, // TIA 3-0 offset calibration start [bit0 controls TIA0, bit1 controls TIA1, ...]
   output reg [ 3:0]          tia_off_cal_reset, // TIA 3-0 offset calibration reset [bit0 controls TIA0, bit1 controls TIA1, ...]
   output reg [15:0]          adc_start,         // ADC conversion start [bit0 controls ADC0, bit1 controls ADC1, ...]
   output reg [ 6:0]          adc_seq_id,        // ADC sequence ID
   output reg                 opa_sweep_reset,   // OPA sweep reset
   output reg                 opa_sweep_start,   // OPA sweep start

   // Interrupts
   output reg                  err_parity,       // Parity error   (pulse)
   output reg                  err_opcode,       // Bad opcode     (pulse)
   output reg                  seq_done_pulse,   // Sequencer Done (pulse)
   output reg                  err_seq_mem_access,  // Seq memory acess fail (pulse)

   // Test I/F
   input      [7:0]            test_mux_sel, // test mux select
   output reg [7:0]            test_data     // test data
);
   // -------------------------------------------------------------------------
   // Version Log
   // -------------------------------------------------------------------------
   // localparam VERSION          = 16'h01_00;  // Initial VERSION
   localparam VERSION          = 16'h01_01;  // Updated to reflect changes shown in IC spec rev 1.0 draft 1, dated 7/30/21

   // -------------------------------------------------------------------------
   // Signal Declarations
   // -------------------------------------------------------------------------

   localparam MEM_LOG2DEPTH    = 12;            // Depth of 4096
   localparam MEM_WIDTH        = 128;           // Data Width of 128

   // Host I/F
   logic [MEM_LOG2DEPTH-1: 0]  mem_addr;        // memory address
   logic                       mem_write;       // memory write
   logic [MEM_WIDTH-1: 0]      mem_wdata;       // memory write data
   logic [MEM_WIDTH-1: 0]      mem_rdata;       // memory read data
   logic [127: 0]              if_mem_wdata;    // memory write data
   logic [127: 0]              if_mem_rdata;    // memory read data
   logic                       seq_start;       // sequencer start
   logic [MEM_LOG2DEPTH-1: 0]  seq_start_addr;  // sequencer start address
   logic                       parity_odd_not_even; // parity odd not even
   logic                       clear_done;
   logic                       clear_err_addr;
   logic                       seq_busy;
   logic                       seq_done;
   logic [MEM_LOG2DEPTH-1: 0]  err_addr;        // memory address with parity error
   logic                       seq_terminate;
   logic                       seq_strobe;
   logic [ 7:0]                seq_opcode;
   logic [95:0]                seq_data  ;

   logic                       man_ctrl_sel    ;
   logic                       man_cfg_opa4_sel;
   logic                       man_cfg_opa3_sel;
   logic                       man_cfg_opa2_sel;
   logic                       man_cfg_opa1_sel;
   logic                       man_cfg_opa0_sel;
   logic                       man_cfg_wlm_sel ;
   logic                       man_cfg_adc1_sel;
   logic                       man_cfg_adc2_sel;
   logic                       man_cfg_tia_sel ;
   logic                       man_cfg_tx_sel  ;
   logic [95:0]                man_cfg_tx      ;
   logic [95:0]                man_cfg_tia     ;
   logic [95:0]                man_cfg_adc1    ;
   logic [95:0]                man_cfg_adc2    ;
   logic [95:0]                man_cfg_wlm     ;
   logic [95:0]                man_cfg_opa0    ;
   logic [95:0]                man_cfg_opa1    ;
   logic [95:0]                man_cfg_opa2    ;
   logic [95:0]                man_cfg_opa3    ;
   logic [95:0]                man_cfg_opa4    ;
   logic [95:0]                man_ctrl        ;

   logic  [7:0]                test_data_mux;
   logic  [7:0]                test_data_seq;

   // -------------------------------------------------------------------------
   // Component Instantiation
   // -------------------------------------------------------------------------
   sequencer_reg_block # (
      .ADDR_WIDTH       (8))
   host_if0 (
   // Config/Status
      .mem_addr_reg_seq_mem_addr       (mem_addr),
      .mem_write_reg_seq_mem_write     (mem_write),
      .parity_odd_not_even_reg_seq_cfg (parity_odd_not_even),
      .clear_done_reg_seq_cmd          (clear_done),
      .clear_err_addr_reg_seq_cmd      (clear_err_addr),
      .start_addr_reg_seq_start        (seq_start_addr),
      .start_reg_seq_start             (seq_start),
      .terminate_reg_seq_terminate     (seq_terminate),
      .def_fld_reg_seq_mem_wdata_3     (if_mem_wdata[127:96]),
      .def_fld_reg_seq_mem_wdata_2     (if_mem_wdata[95:64]),
      .def_fld_reg_seq_mem_wdata_1     (if_mem_wdata[63:32]),
      .def_fld_reg_seq_mem_wdata_0     (if_mem_wdata[31:00]),
      .version_reg_seq_version_ip      (VERSION),
      .def_fld_reg_seq_mem_rdata_3_ip  (if_mem_rdata[127:96]),
      .def_fld_reg_seq_mem_rdata_2_ip  (if_mem_rdata[95:64]),
      .def_fld_reg_seq_mem_rdata_1_ip  (if_mem_rdata[63:32]),
      .def_fld_reg_seq_mem_rdata_0_ip  (if_mem_rdata[31:00]),
      .err_addr_reg_seq_status_ip      (err_addr),
      .done_reg_seq_status_ip          (seq_done),
      .busy_reg_seq_status_ip          (seq_busy),

      .man_ctrl_sel_reg_seq_mux_sel     (man_ctrl_sel    ),
      .man_cfg_opa4_sel_reg_seq_mux_sel (man_cfg_opa4_sel),
      .man_cfg_opa3_sel_reg_seq_mux_sel (man_cfg_opa3_sel),
      .man_cfg_opa2_sel_reg_seq_mux_sel (man_cfg_opa2_sel),
      .man_cfg_opa1_sel_reg_seq_mux_sel (man_cfg_opa1_sel),
      .man_cfg_opa0_sel_reg_seq_mux_sel (man_cfg_opa0_sel),
      .man_cfg_wlm_sel_reg_seq_mux_sel  (man_cfg_wlm_sel ),
      .man_cfg_adc2_sel_reg_seq_mux_sel (man_cfg_adc2_sel),
      .man_cfg_adc1_sel_reg_seq_mux_sel (man_cfg_adc1_sel),
      .man_cfg_tia_sel_reg_seq_mux_sel  (man_cfg_tia_sel ),
      .man_cfg_tx_sel_reg_seq_mux_sel   (man_cfg_tx_sel  ),
      .def_fld_reg_seq_man_cfg_tx_2     (man_cfg_tx  [95:64]),
      .def_fld_reg_seq_man_cfg_tx_1     (man_cfg_tx  [63:32]),
      .def_fld_reg_seq_man_cfg_tx_0     (man_cfg_tx  [31:00]),
      .def_fld_reg_seq_man_cfg_tia_2    (man_cfg_tia [95:64]),
      .def_fld_reg_seq_man_cfg_tia_1    (man_cfg_tia [63:32]),
      .def_fld_reg_seq_man_cfg_tia_0    (man_cfg_tia [31:00]),
      .def_fld_reg_seq_man_cfg_adc1_2   (man_cfg_adc1[95:64]),
      .def_fld_reg_seq_man_cfg_adc1_1   (man_cfg_adc1[63:32]),
      .def_fld_reg_seq_man_cfg_adc1_0   (man_cfg_adc1[31:00]),
      .def_fld_reg_seq_man_cfg_adc2_2   (man_cfg_adc2[95:64]),
      .def_fld_reg_seq_man_cfg_adc2_1   (man_cfg_adc2[63:32]),
      .def_fld_reg_seq_man_cfg_adc2_0   (man_cfg_adc2[31:00]),
      .def_fld_reg_seq_man_cfg_wlm_2    (man_cfg_wlm [95:64]),
      .def_fld_reg_seq_man_cfg_wlm_1    (man_cfg_wlm [63:32]),
      .def_fld_reg_seq_man_cfg_wlm_0    (man_cfg_wlm [31:00]),
      .def_fld_reg_seq_man_cfg_opa0_2   (man_cfg_opa0[95:64]),
      .def_fld_reg_seq_man_cfg_opa0_1   (man_cfg_opa0[63:32]),
      .def_fld_reg_seq_man_cfg_opa0_0   (man_cfg_opa0[31:00]),
      .def_fld_reg_seq_man_cfg_opa1_2   (man_cfg_opa1[95:64]),
      .def_fld_reg_seq_man_cfg_opa1_1   (man_cfg_opa1[63:32]),
      .def_fld_reg_seq_man_cfg_opa1_0   (man_cfg_opa1[31:00]),
      .def_fld_reg_seq_man_cfg_opa2_2   (man_cfg_opa2[95:64]),
      .def_fld_reg_seq_man_cfg_opa2_1   (man_cfg_opa2[63:32]),
      .def_fld_reg_seq_man_cfg_opa2_0   (man_cfg_opa2[31:00]),
      .def_fld_reg_seq_man_cfg_opa3_2   (man_cfg_opa3[95:64]),
      .def_fld_reg_seq_man_cfg_opa3_1   (man_cfg_opa3[63:32]),
      .def_fld_reg_seq_man_cfg_opa3_0   (man_cfg_opa3[31:00]),
      .def_fld_reg_seq_man_cfg_opa4_2   (man_cfg_opa4[95:64]),
      .def_fld_reg_seq_man_cfg_opa4_1   (man_cfg_opa4[63:32]),
      .def_fld_reg_seq_man_cfg_opa4_0   (man_cfg_opa4[31:00]),
      .seq_man_ctrl2_reg_seq_man_ctrl_2 (man_ctrl    [95:64]),
      .seq_man_ctrl1_reg_seq_man_ctrl_1 (man_ctrl    [63:32]),
      .seq_man_ctrl0_reg_seq_man_ctrl_0 (man_ctrl    [31:00]),

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

   assign mem_wdata    = if_mem_wdata;
   assign if_mem_rdata = mem_rdata;

   rp_sequencer #(
      .SIMONLY             (SIMONLY),
      .MEM_LOG2DEPTH       (MEM_LOG2DEPTH),
      .MEM_WIDTH           (MEM_WIDTH))
   sequencer_core (
      // Host I/F
      .hif_mem_addr        (mem_addr),
      .hif_mem_wdata       (mem_wdata),
      .hif_mem_write       (mem_write),
      .hif_mem_rdata       (mem_rdata),
      // Clock/Reset
      .clk                 (clk),
      .rst_n               (rst_n),
      // Config/Controls
      .seq_start           (seq_start),
      .seq_terminate       (seq_terminate),
      .seq_start_addr      (seq_start_addr),
      .parity_odd_not_even (parity_odd_not_even),
      // Command
      .clear_done          (clear_done),
      .clear_err_addr      (clear_err_addr),
      // outputs
      .seq_strobe          (seq_strobe      ),
      .seq_opcode          (seq_opcode      ),
      .seq_data            (seq_data        ),
      // Status
      .seq_busy            (seq_busy),
      .err_parity          (err_parity),
      .err_addr            (err_addr  ),
      .err_opcode          (err_opcode),
      .err_seq_mem_access  (err_seq_mem_access),
      .seq_done_pulse      (seq_done_pulse),
      .seq_done            (seq_done),
      // Test I/F
      .test_mux_sel        (test_mux_sel[6:0]),
      .test_data           (test_data_seq   )
   );

   rp_sequencer_mux rp_sequencer_mux0(
      .clk                (clk             ),
      .rst_n              (rst_n           ),
      .seq_strobe         (seq_strobe      ),
      .seq_opcode         (seq_opcode      ),
      .seq_data           (seq_data        ),
      .man_ctrl_sel       (man_ctrl_sel    ),
      .man_cfg_opa4_sel   (man_cfg_opa4_sel),
      .man_cfg_opa3_sel   (man_cfg_opa3_sel),
      .man_cfg_opa2_sel   (man_cfg_opa2_sel),
      .man_cfg_opa1_sel   (man_cfg_opa1_sel),
      .man_cfg_opa0_sel   (man_cfg_opa0_sel),
      .man_cfg_wlm_sel    (man_cfg_wlm_sel ),
      .man_cfg_adc2_sel   (man_cfg_adc2_sel),
      .man_cfg_adc1_sel   (man_cfg_adc1_sel),
      .man_cfg_tia_sel    (man_cfg_tia_sel ),
      .man_cfg_tx_sel     (man_cfg_tx_sel  ),
      .man_cfg_tx         (man_cfg_tx      ),
      .man_cfg_tia        (man_cfg_tia     ),
      .man_cfg_adc1       (man_cfg_adc1    ),
      .man_cfg_adc2       (man_cfg_adc2    ),
      .man_cfg_wlm        (man_cfg_wlm     ),
      .man_cfg_opa0       (man_cfg_opa0    ),
      .man_cfg_opa1       (man_cfg_opa1    ),
      .man_cfg_opa2       (man_cfg_opa2    ),
      .man_cfg_opa3       (man_cfg_opa3    ),
      .man_cfg_opa4       (man_cfg_opa4    ),
      .man_ctrl           (man_ctrl        ),
      // Analog transmit interface [79-signals]
      .lan_en              (lan_en         ),
      .dac_las_sel         (dac_las_sel    ),
      .las_n_led           (las_n_led      ),
      .lcat_en             (lcat_en        ),
      .hga_sel             (hga_sel        ),
      .hgc_sel             (hgc_sel        ),
      .dac_htr_las_sel     (dac_htr_las_sel),
      // WLM interface [80-signals]
      .d1mzisw_sel         (d1mzisw_sel),
      .d2mzisw_sel         (d2mzisw_sel),
      .d3mzisw_sel         (d3mzisw_sel),
      .d4mzisw_sel         (d4mzisw_sel),
      .d1mzilw_sel         (d1mzilw_sel),
      .d2mzilw_sel         (d2mzilw_sel),
      .d3mzilw_sel         (d3mzilw_sel),
      .d4mzilw_sel         (d4mzilw_sel),
      // OPA Configuration
      .opa_ramp_duration   (opa_ramp_duration),
      .opa_num_ramps       (opa_num_ramps    ),
      .opa_dac_rate        (opa_dac_rate     ),
      .opa_init_val        (opa_init_val     ),
      .opa_step_size       (opa_step_size    ),
      .opa_limit_min       (opa_limit_min    ),
      .opa_limit_max       (opa_limit_max    ),
      // TIA Configuration
      .tia_enhc            (tia_enhc         ),
      .tia_gain_ctrl       (tia_gain_ctrl    ),
      .tia_offset_adjust   (tia_offset_adjust),
      // ADC Configuration
      .adc_avg_en          (adc_avg_en      ),
      .adc_num_conv        (adc_num_conv    ),
       // Controls
      .tia_off_cal_start   (tia_off_cal_start),
      .tia_off_cal_reset   (tia_off_cal_reset),
      .adc_start           (adc_start        ),
      .adc_seq_id          (adc_seq_id       ),
      .opa_sweep_reset     (opa_sweep_reset  ),
      .opa_sweep_start     (opa_sweep_start  ),
      // Test Mux
      .test_mux_sel        (test_mux_sel[6:0]),
      .test_data           (test_data_mux   )
   );

   // ------------------------------------------------------------------------
   // Test Mux
   // ------------------------------------------------------------------------
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         test_data      <= '0;
      end else begin
         if (test_mux_sel[7]) begin  // msb is 1
            test_data   <= test_data_mux;
         end else begin             // msb is 0
            test_data   <= test_data_seq;
         end
      end
   end

endmodule
