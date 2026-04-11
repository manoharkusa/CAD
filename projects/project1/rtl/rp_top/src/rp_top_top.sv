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
// Date   : 04/09/2021
//
// Description: Digital Top
//
//------------------------------------------------------------------------------

import rp_top_top_pkg::*;

module rp_top_top #(
   parameter                  SIMONLY = 0       // 1 for behavior mem model, TSMC mem model for others
) (
   // clock/reset
   input                      clk,              // clock            // scan clock
   input                      rst_n,            // active low reset

   // Scan signals
   input                      scan_mode,        // Scan mode
   input                      scan_en  ,        // Scan enable

   // JTAG enable
   input                      jtag_en,          // JTAG enable (1 - JTAG, 0 - DMUX)
   input                      jtag_tck,         // JTAG TCLK
   input                      jtag_tms,         // JTAG TMS
   input                      jtag_tdi,         // JTAG TDI
   output                     jtag_tdo_dmux3,   // JTAG TDO  / DMUX3  [output]

   // digital mux
   output                     dmux0,            // DMUX0    Output
   output                     dmux1,            // DMUX1    Output
   output                     dmux2,            // DMUX2    Output
   output                     dmux_0_2_out_en,  // DMUX0-2  Output Enable (Tie to ~jtag_en input internally in the IC to control tristate buffers)

   // SPI interface [4-signals]
   input                      spi_clk ,         // SPI clock            // scan clock
   input                      spi_sen ,         // SPI chip select      // scan update ?
   input                      spi_mosi,         // SPI serial data in   // scan in
   output reg                 spi_miso,         // SPI serial data out  // scan out

   // Analog transmit interface [79-signals]
   output reg [13:0]          lan_en,           // Laser/LED anode enable
   output reg [ 9:0]          dac_las_sel,      // Laser/LED DAC current select
   output reg                 las_n_led,        // Select mode: 1=laser, 0=LED
   output reg [12:0]          lcat_en,          // Laser cathode enable
   output reg [25:0]          hga_sel,          // Grating heater anode select
   output reg [ 4:0]          hgc_sel,          // Grating heater cathode select
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

   // OPA Waveform Generator Interface
   output reg [ 9:0]          d1_opa,           // OPA Heater DAC1 input
   output reg [ 9:0]          d2_opa,           // OPA Heater DAC2 input
   output reg [ 9:0]          d3_opa,           // OPA Heater DAC3 input
   output reg [ 9:0]          d4_opa,           // OPA Heater DAC4 input

   // RX TIA interface [4 TIAs]
   output reg [ 3:0]          tia_enhc,          // TIA 3-0 enable high capacitance mode [bit0 controls TIA0, bit1 controls TIA1, ...]
   output reg [15:0]          tia_gain_ctrl,     // TIA 3-0 Gain Control {bits[3-0] controls TIA0, bits[7-4] controls TIA1, ...}, 4-bits per TIA
   output reg [31:0]          tia_off_dac,       // TIA 3-0 offset DAC select         // [from TABLE 9-16], IS THIS SAME AS OFFSET_ADJUST?
   input      [ 3:0]          tia_off_comp_out,  // TIA 3-0 offset comparator output [bit0 controls TIA0, bit1 controls TIA1, ...]
   output reg [ 3:0]          tia_off_cal_clk,   // TIA 3-0 offset calibration clock [bit0 controls TIA0, bit1 controls TIA1, ...]

   // ADC interface
   // ADC[0-3] - PDEXT[0-3]
   // ADC[04]  - ADC WLM LW PD0
   // ADC[05]  - ADC WLM LW PD2-PD1
   // ADC[06]  - ADC WLM LW PD4-PD3
   // ADC[07]  - ADC WLM SW PD0
   // ADC[08]  - ADC WLM SW PD2-PD1
   // ADC[09]  - ADC WLM SW PD4-PD3
   // ADC[10]  - ADC DTD0
   // ADC[11]  - ADC DTD1
   // ADC[12]  - ADC DTD2
   // ADC[13]  - ADC DTD3
   // ADC[14]  - ADC DTD4
   // ADC[15]  - ADC DTD5
   output reg [NUM_ADC-1:0]   adc_rst,           // ADC resets
   output reg [NUM_ADC-1:0]   adc_clk,           // ADC clocks
   output reg [NUM_ADC-1:0]   adc_stb,           // ADC strobes
   input      [NUM_ADC-1:0]   adc_dout,          // ADC data (from ADCs)

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

   // Interrupt
   output reg                 prg_int_out       // Programmable interrupt
);

// ---------------------------------------------------------------------------
// Version History
// ---------------------------------------------------------------------------
   // localparam logic [15:0] VERSION = 16'h01_00;  // trial RTL release Aug 19
   localparam logic [15:0] VERSION = 16'h01_01;  // Added DFT ports  - 09/10/21

// ---------------------------------------------------------------------------
// Signal Declaration
// ---------------------------------------------------------------------------
   // global reset
   logic                rst_n_2q;

   // SPI Slave Module
   logic                err_fsm_start;
   logic                err_timeout  ;
   logic                err_burst_wr_incomp;
   logic                err_burst_wr_last_word;
   logic [15:0]         local_addr   ;
   logic                local_write  ;
   logic                local_read   ;
   logic [31:0]         local_wdata  ;
   logic [31:0]         host_rdata   ;

   // host interface interconnect
   host_if              host_if_top[0:NUM_MEM_BLOCKS-1] (clk, rst_n_2q);
   logic                host_raddrerr ;
   logic                host_waddrerr ;

   // Interrupt Generator
   logic [31:0]         interrupt_int;

   // Sequencer outputs
   logic [11:0]         opa_ramp_duration  ;
   logic [ 7:0]         opa_num_ramps      ;
   logic [ 7:0]         opa_dac_rate       ;
   logic [19:0]         opa_init_val [ 0:3];
   logic [31:0]         opa_step_size[ 0:3];
   logic [19:0]         opa_limit_min[ 0:3];
   logic [19:0]         opa_limit_max[ 0:3];
   logic [ 7:0]         tia_offset_adjust[0:NUM_TOC-1];
   logic [NUM_TOC-1:0]  tia_off_cal_start ;
   logic [NUM_TOC-1:0]  tia_off_cal_reset ;
   logic [NUM_ADC-1:0]  adc_avg_en            ;
   logic [ 5:0]         adc_num_conv [0:NUM_ADC-1];
   logic [NUM_ADC-1:0]  adc_start         ;

   logic [ 6:0]         adc_seq_id        ;
   logic                opa_sweep_reset   ;
   logic                opa_sweep_start   ;
   logic                err_parity        ;
   logic                err_opcode        ;
   logic                seq_done_pulse    ;
   logic                err_seq_mem_access;

   // OPA Waveform Generator Outputs
   logic [ 9:0]         opa_wfm[0:NUM_OPA-1];

   // TIA Offset Canceler
   logic [7:0]          tia_off_dac_array [0:NUM_TOC-1];  // offset DAC select

   // ADC Clock Control Signals
   logic [NUM_ADC-1:0]  adc_conv_en_error;  // adc conversion enable
   logic [NUM_ADC-1:0]  adc_soc     ;
   logic [NUM_ADC-1:0]  adc_eoc     ;
   logic [NUM_ADC-1:0]  adc_dout_stb;

   // ADC Post Processor Signals
   logic [NUM_ADC-1:0]  app_req  ;
   logic [NUM_ADC-1:0]  app_grant;
   logic [NUM_ADC-1:0]  app_dv   ;
   logic [31:0]         app_data [0:NUM_ADC-1];
   logic [NUM_ADC-1:0]  app_err_timeout;
   logic [NUM_ADC-1:0]  app_err_avg_start;
   logic [NUM_ADC-1:0]  app_rail_err   ;
   logic [NUM_ADC-1:0]  app_err_dec_start;
   logic [NUM_ADC-1:0]  app_err_dec_soc_eoc_overlap;

   // Arbiter outputs
   logic                arb_dv  ;
   logic [31:0]         arb_data;
   logic                arb_err_timeout;

   // FIFO outputs
   logic                fifo_overrun ;
   logic                fifo_underrun;
   logic                fifo_rdy;
   logic                fifo_err_parity;

   // Test Mux Outputs
   logic [ 7:0]         test_mux_sel_data;
   logic [ 7:0]         test_data[0:NUM_TMUX_ID-1]; // test data in
   logic [ 3:0]         test_data_out;
   logic                err_invalid_block;

   // *************************************************************************
   // *************************************************************************
   // *************************************************************************
   // DFT LOGIC (START HERE)

   // -------------------------------------------------------------------------
   // Signal Declaration
   // -------------------------------------------------------------------------
   logic                   dmux3;
   logic                   spi_miso_i;

   // JTAG signals
   logic                   jtag_tdo;

   // Scan signals
   logic                   scan_clk;
   logic                   scan_out;
   logic                   scan_in;
   logic                   scan_update;

   // -------------------------------------------------------------------------
   // JTAG LOGIC
   // -------------------------------------------------------------------------
   // Available JTAG Signals
   // jtag_en        // JTAG Enable
   // jtag_tck       // Test Clock    (TCKDM0 PAD pin is shared with dmux0, dmux_0_2_out_en is as output enable for tristate buffer)
   // jtag_tms       // Test Mode     (TMSDM1 PAD pin is shared with dmux1, dmux_0_2_out_en is as output enable for tristate buffer)
   // jtag_tdi       // Test Data In  (TDIDM2 PAD pin is shared with dmux2, dmux_0_2_out_en is as output enable for tristate buffer)
   // jtag_tdo       // Test Data Out (shared with dmux3)

   assign dmux_0_2_out_en  = ~jtag_en;                               // dmux output buffer enable when JTAG is disable
   assign jtag_tdo_dmux3   = (jtag_en == 1'b1) ? jtag_tdo : dmux3;   // use dmux3 as jtag_tdo_dmux3 output when JTAG is disable otherwise use jtag_tdo;
   assign jtag_tdo         = '0;  // !!! REPLACE IT WITH ACTUAL JTAG TDO

   // -------------------------------------------------------------------------
   // SCAN LOGIC
   // -------------------------------------------------------------------------
   // Available Scan Signals
   // scan_mode      // Scan mode
   // scan_en        // Scan enable
   // scan_clk       // Scan clock   (shared with SPI clk )
   // scan_in        // Scan in      (shared with SPI mosi)
   // scan_update    // Scan update  (shared with SPI sen )
   // scan_out       // Scan out     (shared with SPI miso)

   assign scan_clk    = spi_clk;                               // SPI CLK  input is shared with scan clock
   assign scan_in     = spi_mosi;                              // SPI MOSI input is shared with scan in
   assign scan_update = spi_sen;                               // SPI SEN  input is shared with scan update

   assign spi_miso = (scan_en == 1'b1) ? scan_out : spi_miso_i;  // SPI MISO output is shared with scan out and SPI MISO
   assign scan_out = '0;                                         // !!! REPLACE IT WITH ACTUAL SCAN OUT

   // DFT LOGIC (END HERE)
   // *************************************************************************
   // *************************************************************************
   // *************************************************************************



// ---------------------------------------------------------------------------
// Component instantiation
// ---------------------------------------------------------------------------

   // ------------------------------------------------------------------------
   // Reset Synchronizer
   // ------------------------------------------------------------------------
   rp_synch_rst rp_synch_rst0 (
      // clock
      .clk        (clk),
      // reset in
      .raw_rst_n  (rst_n),
      // reset out (sync'ed to clk input)
      .rst_n      (rst_n_2q)
   );

   // ------------------------------------------------------------------------
   // SPI Module
   // ------------------------------------------------------------------------
   rp_spi_slave spi_slave0 (
      // Clock / Reset
      .clk              (clk),
      .rst_n            (rst_n_2q),
      // SPI Interface
      .spi_clk          (spi_clk),
      .spi_sen          (spi_sen ),
      .spi_mosi         (spi_mosi),
      // .spi_miso         (spi_miso),
      .spi_miso         (spi_miso_i),
      // Host Interface
      .local_addr       (local_addr ),
      .local_write      (local_write),
      .local_read       (local_read ),
      .local_wdata      (local_wdata),
      .local_rdata      (host_rdata ),
      .err_fsm_start    (err_fsm_start),
      .err_burst_wr_incomp (err_burst_wr_incomp),
      .err_burst_wr_last_word(err_burst_wr_last_word),

      .err_timeout      (err_timeout  ),
      .test_sel         (test_mux_sel_data ),
      .test_data        (test_data[TMUX_ID_SPI])
   );

   // ------------------------------------------------------------------------
   // Host Bus Interconnect
   // ------------------------------------------------------------------------
   rp_host_bus_interconnect #(
      .NUM_DEV             (NUM_MEM_BLOCKS))
   host_bus_interconnect0 (
      // Clock / Reset
      .clk                 (clk),
      .rst_n               (rst_n_2q),
      // Local Bus Interface
      .local_addr          (local_addr),
      .local_wstrobe       (local_write),
      .local_rstrobe       (local_read),
      .local_wdata         (local_wdata),
      .host_rdata          (host_rdata),
      // Host Interface
      .host_if_master      (host_if_top),
      .test_stb            (1'b0), ///  TO-DO Not implemented
      .host_raddrerr       (host_raddrerr),
      .host_waddrerr       (host_waddrerr)
   );
   assign test_data[TMUX_ID_INTERCONNECT] = '0;

   // ------------------------------------------------------------------------
   // Local Module
   // ------------------------------------------------------------------------
   rp_local_top # (
      .VERSION (VERSION ),
      .NUM_ADC (NUM_ADC ),
      .NUM_TOC (NUM_TOC ),
      .NUM_OPA (NUM_OPA ))
   local_top0 (
      // Local Bus Interface
      .host_if_slave       (host_if_top[OFFSET_LOCAL]),
      // clock/reset cfg/status
      .clk                 (clk),
      .rst_n               (rst_n_2q)
   );

   // ------------------------------------------------------------------------
   // Sequencer Module
   // ------------------------------------------------------------------------
   rp_sequencer_top
   # ( .SIMONLY      (SIMONLY))
   sequencer_top0 (
      // Local Bus Interface
      .host_if_slave       (host_if_top[OFFSET_SEQ]),
      // clock/reset cfg/status
      .clk                 (clk),
      .rst_n               (rst_n_2q),
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
      // OPA interface [396-signals]
      .opa_ramp_duration   (opa_ramp_duration),
      .opa_num_ramps       (opa_num_ramps    ),
      .opa_dac_rate        (opa_dac_rate     ),
      .opa_init_val        (opa_init_val     ),
      .opa_step_size       (opa_step_size    ),
      .opa_limit_min       (opa_limit_min    ),
      .opa_limit_max       (opa_limit_max    ),
      // RX TIA CFG [4 TIAs] to TIA Analog Circuit
      .tia_enhc            (tia_enhc         ),
      .tia_gain_ctrl       (tia_gain_ctrl    ),
      .tia_offset_adjust   (tia_offset_adjust),
      // RX ADC CFG [16 ADCs]
      .adc_avg_en          (adc_avg_en      ),
      .adc_num_conv        (adc_num_conv    ),
      // CTRL signals [4 TIAs, 16 ADCs, ]
      .tia_off_cal_start   (tia_off_cal_start),
      .tia_off_cal_reset   (tia_off_cal_reset),
      .adc_start           (adc_start        ),
      .adc_seq_id          (adc_seq_id       ),
      .opa_sweep_reset     (opa_sweep_reset  ),
      .opa_sweep_start     (opa_sweep_start  ),
      // Interrupts
      .err_parity          (err_parity        ),
      .err_opcode          (err_opcode        ),
      .seq_done_pulse      (seq_done_pulse    ),
      .err_seq_mem_access  (err_seq_mem_access),
      // Test I/F
      .test_mux_sel        (test_mux_sel_data ),
      .test_data           (test_data[TMUX_ID_SEQ])
   );

   // --------------------------------------------------------------------
   // ADC Clock Gen & Post Processor (Multiple isntances)
   // --------------------------------------------------------------------
   genvar i;
   generate
      for (i=0; i<NUM_ADC; i++) begin : generate_ADC_blocks
         // --------------------------------------------------------------------
         // ADC Clock Gen
         // --------------------------------------------------------------------
         rp_adc_clk_ctrl_top
         #( .ADDR_WIDTH (8 ),
            .DATA_WIDTH (32))
         rp_adc_clk_ctrl_top0 (
            .adc_clk             (adc_clk[i]),
            .adc_rst             (adc_rst[i]),
            .adc_strobe          (adc_stb[i]),
            .adc_dout            (adc_dout[i]),
            .adc_conv_en_error   (adc_conv_en_error[i]),
            .data_strobe         (adc_dout_stb[i]),
            .soc                 (adc_soc     [i]),
            .eoc                 (adc_eoc     [i]),
            .clk                 (clk),
            .rst_n               (rst_n_2q),
            .adc_conv_en         (adc_start   [i]),
            .num_conv            (adc_num_conv[i]),
            .host_if_slave       (host_if_top[OFFSET_ADC_CLK_OFF+i]),
            // Test I/F
            .test_mux_sel        (test_mux_sel_data),
            .test_data           (test_data[TMUX_ID_ADC_CLK_OFF+i])
         );

         // --------------------------------------------------------------------
         // Decimator Module
         // --------------------------------------------------------------------
         rp_adc_postproc_top #(
            .ADC_ID                 (i))  // passing ADC ID #
         rp_adc_postproc_top0(
            // Local Bus Interface
            .host_if_slave (host_if_top[OFFSET_APP_OFF+i]),
            // clock/reset cfg/status
            .clk                    (clk),
            .rst_n                  (rst_n_2q),
            // data from ADC along with controls from ADC clock ctrl
            .in_soc                 (adc_soc     [i]),
            .in_eoc                 (adc_eoc     [i]),
            .in_stb                 (adc_dout_stb[i]),
            .in_data                (adc_dout    [i]),
            // CFG/CTRL from sequencer
            .in_adc_start           (adc_start[i]),
            .in_seq_id              (adc_seq_id),
            .in_adc_avg_en          (adc_avg_en  [i]),
            .in_adc_num_conv        (adc_num_conv[i]),
            // output interface
            .app_req                (app_req  [i]),
            .app_grant              (app_grant[i]),
            .app_dv                 (app_dv   [i]),
            .app_data               (app_data [i]),

            // errors
            .out_err_dec_start           (app_err_dec_start          [i]),
            .out_err_dec_soc_eoc_overlap (app_err_dec_soc_eoc_overlap[i]),
            .out_err_avg_start      (app_err_avg_start[i]),
            .out_err_timeout        (app_err_timeout[i]),
            .out_rail_err           (app_rail_err   [i]),

            // Test I/F
            .test_mux_sel           (test_mux_sel_data),
            .test_data              (test_data[TMUX_ID_APP_OFF+i])
         );

      end : generate_ADC_blocks
   endgenerate

   // ------------------------------------------------------------------------
   // Arbiter Module
   // ------------------------------------------------------------------------
   rp_arbiter_top #(
      .NUM_DEV                (NUM_ADC))
   rp_arbiter_top0 (
      // Local Bus Interface
      .host_if_slave (host_if_top[OFFSET_ARB]),
      // clock/reset cfg/status
      .clk                    (clk),
      .rst_n                  (rst_n_2q),
      .app_req                (app_req  ),
      .app_grant              (app_grant),
      .app_dv                 (app_dv   ),
      .app_data               (app_data ),
      .out_dv                 (arb_dv   ),
      .out_data               (arb_data ),

      .err_timeout            (arb_err_timeout),

      // Test I/F
      .test_mux_sel           (test_mux_sel_data),
      .test_data              (test_data[TMUX_ID_ARB])
   );

   // ------------------------------------------------------------------------
   // FIFO Module
   // ------------------------------------------------------------------------
   rp_fifo_top #(.SIMONLY(SIMONLY))
   fifo_top0(
       // Local Bus Interface
      .host_if_slave       (host_if_top[OFFSET_FIFO]),
      // clock/reset cfg/status
      .clk                 (clk),
      .rst_n               (rst_n_2q),

      // adc inouts
      .din_dv              (arb_dv  ),
      .din_data            (arb_data),

      //fifo output
      .fifo_rdy            (fifo_rdy),
      .fifo_overrun        (fifo_overrun),
      .fifo_underrun       (fifo_underrun),
      .fifo_err_parity     (fifo_err_parity),

     // Test I/F
      .test_sel            (test_mux_sel_data),
      .test_data           (test_data[TMUX_ID_FIFO])
   );

   // ------------------------------------------------------------------------
   // OPA WAVEFORM GENERATOR
   // ------------------------------------------------------------------------
   rp_opa_wfm_gen_top rp_opa_wfm_gen_top0 (
       // clock/reset
       .clk                 (clk     ),
       .rst_n               (rst_n_2q),
       // controls
       .sweep_reset         (opa_sweep_reset),
       .sweep_start         (opa_sweep_start),
       // Configurations
       .cfg_accum_ivalue1   (opa_init_val [0] ),
       .cfg_step_size1      (opa_step_size[0] ),
       .cfg_limit_max1      (opa_limit_max[0] ),
       .cfg_limit_min1      (opa_limit_min[0] ),
       .cfg_accum_ivalue2   (opa_init_val [1] ),
       .cfg_step_size2      (opa_step_size[1] ),
       .cfg_limit_max2      (opa_limit_max[1] ),
       .cfg_limit_min2      (opa_limit_min[1] ),
       .cfg_accum_ivalue3   (opa_init_val [2] ),
       .cfg_step_size3      (opa_step_size[2] ),
       .cfg_limit_max3      (opa_limit_max[2] ),
       .cfg_limit_min3      (opa_limit_min[2] ),
       .cfg_accum_ivalue4   (opa_init_val [3] ),
       .cfg_step_size4      (opa_step_size[3] ),
       .cfg_limit_max4      (opa_limit_max[3] ),
       .cfg_limit_min4      (opa_limit_min[3] ),
       .cfg_num_ramps       (opa_num_ramps    ),
       .cfg_update_rate     (opa_dac_rate     ),
       .cfg_ramp_duration   (opa_ramp_duration),
       .out_opa_wfm1        (d1_opa),
       .out_opa_wfm2        (d2_opa),
       .out_opa_wfm3        (d3_opa),
       .out_opa_wfm4        (d4_opa),
       .test_mux_sel        (test_mux_sel_data),
       .test_data           (test_data[TMUX_ID_OPA_OFF])
    );

   // ------------------------------------------------------------------------
   // Analog Config
   // ------------------------------------------------------------------------
   rp_analog_config_top analog_config_top0 (
      // Local Bus Interface
      .host_if_slave (host_if_top[OFFSET_ANA]),
      // clock/reset cfg/status
      .clk           (clk),
      .rst_n         (rst_n_2q),

      .itrim_tx         (itrim_tx  ),
      .pd_tx_n          (pd_tx_n   ),
      .itrim_rx         (itrim_rx  ),
      .pd_rx_n          (pd_rx_n   ),
      .bypass_tia       (bypass_tia),
      .en_amux_output   (en_amux_output),
      .afe_mux_sel      (afe_mux_sel),
      .bypass_wlm_afe   (bypass_wlm_afe),
      .bypass_ts_afe    (bypass_ts_afe),
      .alg_amux_sel     (alg_amux_sel),
      .alg_dmux_sel     (alg_dmux_sel),
      .alg_dmux         (alg_dmux),
      .watchdog_active  (watchdog_active),
      // Test I/F
      .test_mux_sel     (test_mux_sel_data),
      .test_data        (test_data[TMUX_ID_ANA])
   );

   // ------------------------------------------------------------------------
   // TIA Offset Cancellation
   // ------------------------------------------------------------------------
   genvar k;
   generate
      for (k=0; k<NUM_TOC; k++) begin : generate_TOC_blocks
         rp_tia_offset_cancel_top tia_offset_cancel0 (
            .tia_off_comp_clk    (tia_off_cal_clk[k]),
            .tia_off_dac_in      (tia_off_dac_array[k]),
            .clk                 (clk),
            .rst_n               (rst_n_2q),
            .tia_off_start       (tia_off_cal_start[k]),  // inputs from seq
            .tia_off_reset       (tia_off_cal_reset[k]),  // inputs from seq
            .tia_off_adjust      (tia_offset_adjust[k]),  // inputs from seq
            .tia_off_comp_out    (tia_off_comp_out[k]),   // input from analog
            .host_if_slave       (host_if_top[OFFSET_TOC_OFF+k]),
            // Test I/F
            .test_mux_sel        (test_mux_sel_data),
            .test_data           (test_data[TMUX_ID_TOC_OFF+k])
         );
      end : generate_TOC_blocks
   endgenerate

   assign tia_off_dac = {tia_off_dac_array[3],  // TIA-3 bits[31-24]
                         tia_off_dac_array[2],  // TIA-2 bits[23-16]
                         tia_off_dac_array[1],  // TIA-1 bits[15- 8]
                         tia_off_dac_array[0]}; // TIA-0 bits[ 7- 0]

   // ------------------------------------------------------------------------
   // Interrupt Generator
   // ------------------------------------------------------------------------
   rp_interrupt_gen_top interrupt_gen_top0 (
      // Local Bus Interface
      .host_if_slave (host_if_top[OFFSET_INT]),
      // clock/reset cfg/status
      .clk           (clk),
      .rst_n         (rst_n_2q),

      // Interrupts
      .interrupt_in  (interrupt_int),
      .interrupt_out (prg_int_out)
   );

   // Assign interrupts
   assign interrupt_int[00] = err_fsm_start;      // from spi slave
   assign interrupt_int[01] = err_timeout  ;      // from spi slave
   assign interrupt_int[02] = fifo_overrun ;      // from fifo
   assign interrupt_int[03] = fifo_underrun;      // from fifo
   assign interrupt_int[04] = host_raddrerr;      // from host if interconnect
   assign interrupt_int[05] = host_waddrerr;      // from host if interconnect
   assign interrupt_int[06] = |adc_conv_en_error; // from ADC Clock Control (Reduce OR on all errors)
   assign interrupt_int[07] = fifo_rdy;           // from FIFO
   assign interrupt_int[08] = err_parity        ; // from sequencer
   assign interrupt_int[09] = err_opcode        ; // from sequencer
   assign interrupt_int[10] = seq_done_pulse    ; // from sequencer
   assign interrupt_int[11] = err_seq_mem_access; // from sequencer
   assign interrupt_int[12] = arb_err_timeout   ; // from arbiter
   assign interrupt_int[13] = |app_err_timeout  ; // from ADC Post Processor (Reduce OR on all errors)
   assign interrupt_int[14] = |app_rail_err     ; // from ADC Post Processor (Reduce OR on all errors)
   assign interrupt_int[15] = |app_err_avg_start; // from ADC Post Processor (Reduce OR on all errors)
   assign interrupt_int[16] = |app_err_dec_start; // from ADC Post Processor (Reduce OR on all errors)
   assign interrupt_int[17] = |app_err_dec_soc_eoc_overlap; // from ADC Post Processor (Reduce OR on all errors)
   assign interrupt_int[18] = err_burst_wr_incomp;       // from spi slave
   assign interrupt_int[19] = err_burst_wr_last_word;    // from spi slave
   assign interrupt_int[20] = err_invalid_block;         // from Test Mux
   assign interrupt_int[31:21] = '0;
   // ------------------------------------------------------------------------
   // Test Mux
   // ------------------------------------------------------------------------
   rp_test_mux_top #(
      .NUM_BLOCKS    (NUM_TMUX_ID))
   test_mux_top0 (
      // Local Bus Interface
      .host_if_slave (host_if_top[OFFSET_TEST_MUX]),

      // clock/reset cfg/status
      .clk           (clk),
      .rst_n         (rst_n_2q),

      // data interface
      .test_mux_sel_data (test_mux_sel_data),
      // Test I/F

      // data interface
      .test_data_in     (test_data),
      .test_data_out    (test_data_out),

      .err_invalid_block (err_invalid_block)
   );

   assign dmux0 = test_data_out[0];
   assign dmux1 = test_data_out[1];
   assign dmux2 = test_data_out[2];
   assign dmux3 = test_data_out[3];

endmodule
