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
// Date   : 08/09/2021
//
// Description: Sequencer Mux
//
//-------------------------------------------------------------------------------

`timescale 1ns/1ps

import rp_sequencer_pkg::*;

module rp_sequencer_mux (
   // clock/reset cfg/cmd
   input                      clk,                 // clock
   input                      rst_n,               // active low reset

   // Sequencer instruction
   input                      seq_strobe     ,     // sequencer strobe
   input      [ 7:0]          seq_opcode     ,     // sequencer opcode
   input      [95:0]          seq_data       ,     // sequencer data

   // manual select
   input                      man_ctrl_sel    ,    // 1-manual override, 0 - sequencer to driver all outputs
   input                      man_cfg_opa4_sel,    // 1-manual override, 0 - sequencer to driver all outputs
   input                      man_cfg_opa3_sel,    // 1-manual override, 0 - sequencer to driver all outputs
   input                      man_cfg_opa2_sel,    // 1-manual override, 0 - sequencer to driver all outputs
   input                      man_cfg_opa1_sel,    // 1-manual override, 0 - sequencer to driver all outputs
   input                      man_cfg_opa0_sel,    // 1-manual override, 0 - sequencer to driver all outputs
   input                      man_cfg_wlm_sel ,    // 1-manual override, 0 - sequencer to driver all outputs
   input                      man_cfg_adc2_sel,    // 1-manual override, 0 - sequencer to driver all outputs
   input                      man_cfg_adc1_sel,    // 1-manual override, 0 - sequencer to driver all outputs
   input                      man_cfg_tia_sel ,    // 1-manual override, 0 - sequencer to driver all outputs
   input                      man_cfg_tx_sel  ,    // 1-manual override, 0 - sequencer to driver all outputs
   input      [95:0]          man_cfg_tx     ,     // manual config transmit
   input      [95:0]          man_cfg_tia    ,     // manual config tia
   input      [95:0]          man_cfg_adc1   ,     // manual config ADC1
   input      [95:0]          man_cfg_adc2   ,     // manual config ADC2
   input      [95:0]          man_cfg_wlm    ,     // manual config WLM
   input      [95:0]          man_cfg_opa0   ,     // manual config OPA0
   input      [95:0]          man_cfg_opa1   ,     // manual config OPA1
   input      [95:0]          man_cfg_opa2   ,     // manual config OPA2
   input      [95:0]          man_cfg_opa3   ,     // manual config OPA3
   input      [95:0]          man_cfg_opa4   ,     // manual config OPA4
   input      [95:0]          man_ctrl       ,     // manual control

   // Analog transmit interface [79-signals]
   output reg [13:0]          lan_en,           // Laser/LED anode enable
   output reg [ 9:0]          dac_las_sel,      // Laser/LED DAC current select
   output reg                 las_n_led,        // Select mode: 1=laser 0=LED
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
   output reg [ 5:0]          adc_num_conv    [0:15], // ADC number of conversions

   // CTRL signals [4 TIAs, 16 ADCs, ]
   output reg [ 3:0]          tia_off_cal_start, // TIA 3-0 offset calibration start [bit0 controls TIA0, bit1 controls TIA1, ...]
   output reg [ 3:0]          tia_off_cal_reset, // TIA 3-0 offset calibration reset [bit0 controls TIA0, bit1 controls TIA1, ...]
   output reg [15:0]          adc_start,         // ADC conversion start [bit0 controls ADC0, bit1 controls ADC1, ...]
   output reg [ 6:0]          adc_seq_id,        // ADC sequence ID
   output reg                 opa_sweep_reset,   // OPA sweep reset
   output reg                 opa_sweep_start,   // OPA sweep start

   // Test I/F
   input      [6:0]           test_mux_sel, // test mux select
   output reg [7:0]           test_data     // test data
);

   // ------------------------------------------------------------------------
   // Signal Declaration
   // ------------------------------------------------------------------------
   data_tx_t                  data_tx;   // TX type data
   data_wlm_t                 data_wlm;  // WLM type data
   cfg_opa0_t                 cfg_opa0;
   cfg_opa1_4_t               cfg_opa1_4;
   cfg_tia_t                  cfg_tia;
   cfg_adc1_t                 cfg_adc1;
   cfg_adc2_t                 cfg_adc2;
   ctrl_t                     ctrl;

   data_tx_t                  data_tx_man;   // TX type data  (manual)
   data_wlm_t                 data_wlm_man;  // WLM type data (manual)
   cfg_opa0_t                 cfg_opa0_man;
   cfg_opa1_4_t               cfg_opa1_man;
   cfg_opa1_4_t               cfg_opa2_man;
   cfg_opa1_4_t               cfg_opa3_man;
   cfg_opa1_4_t               cfg_opa4_man;
   cfg_tia_t                  cfg_tia_man;
   cfg_adc1_t                 cfg_adc1_man;
   cfg_adc2_t                 cfg_adc2_man;
   ctrl_t                     ctrl_man;

   logic                      reset_cfg_tx     ;
   logic                      reset_cfg_wlm    ;
   logic                      reset_cfg_opa    ;
   logic                      reset_cfg_tia    ;
   logic                      reset_cfg_adc    ;
   // ------------------------------------------------------------------------
   // OPCODE Decoder
   // ------------------------------------------------------------------------

   // CTRL instruction
   assign ctrl = {>>{seq_data}};   // place seq_data to ctrl type
   assign ctrl_man = {>>{man_ctrl}};

   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         tia_off_cal_start <= '0;
         tia_off_cal_reset <= '0;
         adc_start         <= '0;
         adc_seq_id        <= '0;
         opa_sweep_reset   <= '0;
         opa_sweep_start   <= '0;
         reset_cfg_tx      <= '0;
         reset_cfg_wlm     <= '0;
         reset_cfg_opa     <= '0;
         reset_cfg_tia     <= '0;
         reset_cfg_adc     <= '0;
      end else begin
         // Self Clear F/Fs
         tia_off_cal_start <= '0;
         tia_off_cal_reset <= '0;
         adc_start         <= '0;
         opa_sweep_reset   <= '0;
         opa_sweep_start   <= '0;
         reset_cfg_tx      <= '0;
         reset_cfg_wlm     <= '0;
         reset_cfg_opa     <= '0;
         reset_cfg_tia     <= '0;
         reset_cfg_adc     <= '0;


         if (man_ctrl_sel) begin
            tia_off_cal_start <= ctrl_man.tia_off_cal_start;
            tia_off_cal_reset <= ctrl_man.tia_off_cal_reset;
            adc_start         <= ctrl_man.adc_start        ;
            opa_sweep_reset   <= ctrl_man.opa_sweep_reset  ;
            opa_sweep_start   <= ctrl_man.opa_sweep_start  ;
            reset_cfg_tx      <= ctrl_man.reset_cfg_tx  ;
            reset_cfg_wlm     <= ctrl_man.reset_cfg_wlm ;
            reset_cfg_opa     <= ctrl_man.reset_cfg_opa ;
            reset_cfg_tia     <= ctrl_man.reset_cfg_tia;
            reset_cfg_adc     <= ctrl_man.reset_cfg_adc;
            // Assign Sequence ID only if adc_seq_id_valid is set
            if (ctrl_man.adc_seq_id_valid) begin
               adc_seq_id        <= ctrl_man.adc_seq_id    ;
            end

         end else if ((seq_strobe) && (seq_opcode == OPCODE_CTRL)) begin
            tia_off_cal_start <= ctrl.tia_off_cal_start;
            tia_off_cal_reset <= ctrl.tia_off_cal_reset;
            adc_start         <= ctrl.adc_start        ;
            opa_sweep_reset   <= ctrl.opa_sweep_reset  ;
            opa_sweep_start   <= ctrl.opa_sweep_start  ;
            reset_cfg_tx      <= ctrl.reset_cfg_tx  ;
            reset_cfg_wlm     <= ctrl.reset_cfg_wlm ;
            reset_cfg_opa     <= ctrl.reset_cfg_opa ;
            reset_cfg_tia     <= ctrl.reset_cfg_tia;
            reset_cfg_adc     <= ctrl.reset_cfg_adc;

            // Assign Sequence ID only if adc_seq_id_valid is set
            if (ctrl.adc_seq_id_valid) begin
               adc_seq_id        <= ctrl.adc_seq_id    ;
            end
         end
      end
   end

   // TX CFG
   assign data_tx     = {>>{seq_data}};   // place seq_data to data_tx type
   assign data_tx_man = {>>{man_cfg_tx}};

   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         lan_en            <= '0;
         dac_las_sel       <= '0;
         las_n_led         <= '0;
         lcat_en           <= '0;
         hga_sel           <= '0;
         hgc_sel           <= '0;
         dac_htr_las_sel   <= '0;
      end else begin
         if (reset_cfg_tx) begin
            lan_en            <= '0;
            dac_las_sel       <= '0;
            las_n_led         <= '0;
            lcat_en           <= '0;
            hga_sel           <= '0;
            hgc_sel           <= '0;
            dac_htr_las_sel   <= '0;
         end else if (man_cfg_tx_sel) begin
            lan_en            <= data_tx_man.lan_en         ;
            dac_las_sel       <= data_tx_man.dac_las_sel    ;
            las_n_led         <= data_tx_man.las_n_led      ;
            lcat_en           <= data_tx_man.lcat_en        ;
            hga_sel           <= data_tx_man.hga_sel        ;
            hgc_sel           <= data_tx_man.hgc_sel        ;
            dac_htr_las_sel   <= data_tx_man.dac_htr_las_sel;
         end else if ((seq_strobe) && (seq_opcode == OPCODE_CFG_TX)) begin
            lan_en            <= data_tx.lan_en         ;
            dac_las_sel       <= data_tx.dac_las_sel    ;
            las_n_led         <= data_tx.las_n_led      ;
            lcat_en           <= data_tx.lcat_en        ;
            hga_sel           <= data_tx.hga_sel        ;
            hgc_sel           <= data_tx.hgc_sel        ;
            dac_htr_las_sel   <= data_tx.dac_htr_las_sel;
         end
      end
   end

   // TIA CFG
   assign cfg_tia     = {>>{seq_data}};   // place seq_data to data_tx type
   assign cfg_tia_man = {>>{man_cfg_tia}};
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         tia_enhc             <= '0;
         tia_gain_ctrl        <= '0;
         tia_offset_adjust    <= '{default : 0};
      end else begin
         if (reset_cfg_tia) begin
            tia_enhc          <= '0;
            tia_gain_ctrl     <= '0;
            tia_offset_adjust <= '{default : 0};
         end else if (man_cfg_tia_sel) begin
            tia_enhc         [0]     <= cfg_tia_man.tia0_enhc         ;
            tia_gain_ctrl    [ 3: 0] <= cfg_tia_man.tia0_gain_ctrl    ;
            tia_offset_adjust[0]     <= cfg_tia_man.tia0_offset_adjust;
            tia_enhc         [1]     <= cfg_tia_man.tia1_enhc         ;
            tia_gain_ctrl    [ 7: 4] <= cfg_tia_man.tia1_gain_ctrl    ;
            tia_offset_adjust[1]     <= cfg_tia_man.tia1_offset_adjust;
            tia_enhc         [2]     <= cfg_tia_man.tia2_enhc         ;
            tia_gain_ctrl    [11: 8] <= cfg_tia_man.tia2_gain_ctrl    ;
            tia_offset_adjust[2]     <= cfg_tia_man.tia2_offset_adjust;
            tia_enhc         [3]     <= cfg_tia_man.tia3_enhc         ;
            tia_gain_ctrl    [15:12] <= cfg_tia_man.tia3_gain_ctrl    ;
            tia_offset_adjust[3]     <= cfg_tia_man.tia3_offset_adjust;
         end else if ((seq_strobe) && (seq_opcode == OPCODE_CFG_TIA)) begin
            tia_enhc         [0]     <= cfg_tia.tia0_enhc         ;
            tia_gain_ctrl    [ 3: 0] <= cfg_tia.tia0_gain_ctrl    ;
            tia_offset_adjust[0]     <= cfg_tia.tia0_offset_adjust;
            tia_enhc         [1]     <= cfg_tia.tia1_enhc         ;
            tia_gain_ctrl    [ 7: 4] <= cfg_tia.tia1_gain_ctrl    ;
            tia_offset_adjust[1]     <= cfg_tia.tia1_offset_adjust;
            tia_enhc         [2]     <= cfg_tia.tia2_enhc         ;
            tia_gain_ctrl    [11: 8] <= cfg_tia.tia2_gain_ctrl    ;
            tia_offset_adjust[2]     <= cfg_tia.tia2_offset_adjust;
            tia_enhc         [3]     <= cfg_tia.tia3_enhc         ;
            tia_gain_ctrl    [15:12] <= cfg_tia.tia3_gain_ctrl    ;
            tia_offset_adjust[3]     <= cfg_tia.tia3_offset_adjust;
         end
      end
   end

   // ADC1 & ADC2 CFGs
   assign cfg_adc1 = {>>{seq_data}};   // place seq_data to adc1 type
   assign cfg_adc2 = {>>{seq_data}};   // place seq_data to adc2 type
   assign cfg_adc1_man = {>>{man_cfg_adc1}};
   assign cfg_adc2_man = {>>{man_cfg_adc2}};

   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         adc_avg_en           <= '0;
         adc_num_conv         <= '{default : 0};
      end else begin
         if (reset_cfg_adc) begin
            adc_avg_en        [9:0] <= '0;
            adc_num_conv      [0:9] <= '{default : 0};
         end else if (man_cfg_adc1_sel) begin
            adc_avg_en        [ 0] <= cfg_adc1_man.adc0_avg_en  ;
            adc_num_conv      [ 0] <= cfg_adc1_man.adc0_num_conv    ;
            adc_avg_en        [ 1] <= cfg_adc1_man.adc1_avg_en  ;
            adc_num_conv      [ 1] <= cfg_adc1_man.adc1_num_conv    ;
            adc_avg_en        [ 2] <= cfg_adc1_man.adc2_avg_en  ;
            adc_num_conv      [ 2] <= cfg_adc1_man.adc2_num_conv    ;
            adc_avg_en        [ 3] <= cfg_adc1_man.adc3_avg_en  ;
            adc_num_conv      [ 3] <= cfg_adc1_man.adc3_num_conv    ;
            adc_avg_en        [ 4] <= cfg_adc1_man.adc4_avg_en  ;
            adc_num_conv      [ 4] <= cfg_adc1_man.adc4_num_conv    ;
            adc_avg_en        [ 5] <= cfg_adc1_man.adc5_avg_en  ;
            adc_num_conv      [ 5] <= cfg_adc1_man.adc5_num_conv    ;
            adc_avg_en        [ 6] <= cfg_adc1_man.adc6_avg_en  ;
            adc_num_conv      [ 6] <= cfg_adc1_man.adc6_num_conv    ;
            adc_avg_en        [ 7] <= cfg_adc1_man.adc7_avg_en  ;
            adc_num_conv      [ 7] <= cfg_adc1_man.adc7_num_conv    ;
            adc_avg_en        [ 8] <= cfg_adc1_man.adc8_avg_en  ;
            adc_num_conv      [ 8] <= cfg_adc1_man.adc8_num_conv    ;
            adc_avg_en        [ 9] <= cfg_adc1_man.adc9_avg_en  ;
            adc_num_conv      [ 9] <= cfg_adc1_man.adc9_num_conv    ;
         end else if ((seq_strobe) && (seq_opcode == OPCODE_CFG_ADC1)) begin
            adc_avg_en        [ 0] <= cfg_adc1.adc0_avg_en  ;
            adc_num_conv      [ 0] <= cfg_adc1.adc0_num_conv    ;
            adc_avg_en        [ 1] <= cfg_adc1.adc1_avg_en  ;
            adc_num_conv      [ 1] <= cfg_adc1.adc1_num_conv    ;
            adc_avg_en        [ 2] <= cfg_adc1.adc2_avg_en  ;
            adc_num_conv      [ 2] <= cfg_adc1.adc2_num_conv    ;
            adc_avg_en        [ 3] <= cfg_adc1.adc3_avg_en  ;
            adc_num_conv      [ 3] <= cfg_adc1.adc3_num_conv    ;
            adc_avg_en        [ 4] <= cfg_adc1.adc4_avg_en  ;
            adc_num_conv      [ 4] <= cfg_adc1.adc4_num_conv    ;
            adc_avg_en        [ 5] <= cfg_adc1.adc5_avg_en  ;
            adc_num_conv      [ 5] <= cfg_adc1.adc5_num_conv    ;
            adc_avg_en        [ 6] <= cfg_adc1.adc6_avg_en  ;
            adc_num_conv      [ 6] <= cfg_adc1.adc6_num_conv    ;
            adc_avg_en        [ 7] <= cfg_adc1.adc7_avg_en  ;
            adc_num_conv      [ 7] <= cfg_adc1.adc7_num_conv    ;
            adc_avg_en        [ 8] <= cfg_adc1.adc8_avg_en  ;
            adc_num_conv      [ 8] <= cfg_adc1.adc8_num_conv    ;
            adc_avg_en        [ 9] <= cfg_adc1.adc9_avg_en  ;
            adc_num_conv      [ 9] <= cfg_adc1.adc9_num_conv    ;
         end

         if (reset_cfg_adc) begin
            adc_avg_en        [15:10] <= '0;
            adc_num_conv      [10:15] <= '{default : 0};
         end else if (man_cfg_adc2_sel) begin
            adc_avg_en        [10] <= cfg_adc2_man.adc10_avg_en  ;
            adc_num_conv      [10] <= cfg_adc2_man.adc10_num_conv    ;
            adc_avg_en        [11] <= cfg_adc2_man.adc11_avg_en  ;
            adc_num_conv      [11] <= cfg_adc2_man.adc11_num_conv    ;
            adc_avg_en        [12] <= cfg_adc2_man.adc12_avg_en  ;
            adc_num_conv      [12] <= cfg_adc2_man.adc12_num_conv    ;
            adc_avg_en        [13] <= cfg_adc2_man.adc13_avg_en  ;
            adc_num_conv      [13] <= cfg_adc2_man.adc13_num_conv    ;
            adc_avg_en        [14] <= cfg_adc2_man.adc14_avg_en  ;
            adc_num_conv      [14] <= cfg_adc2_man.adc14_num_conv    ;
            adc_avg_en        [15] <= cfg_adc2_man.adc15_avg_en  ;
            adc_num_conv      [15] <= cfg_adc2_man.adc15_num_conv    ;
         end else if ((seq_strobe) && (seq_opcode == OPCODE_CFG_ADC2)) begin
            adc_avg_en        [10] <= cfg_adc2.adc10_avg_en  ;
            adc_num_conv      [10] <= cfg_adc2.adc10_num_conv    ;
            adc_avg_en        [11] <= cfg_adc2.adc11_avg_en  ;
            adc_num_conv      [11] <= cfg_adc2.adc11_num_conv    ;
            adc_avg_en        [12] <= cfg_adc2.adc12_avg_en  ;
            adc_num_conv      [12] <= cfg_adc2.adc12_num_conv    ;
            adc_avg_en        [13] <= cfg_adc2.adc13_avg_en  ;
            adc_num_conv      [13] <= cfg_adc2.adc13_num_conv    ;
            adc_avg_en        [14] <= cfg_adc2.adc14_avg_en  ;
            adc_num_conv      [14] <= cfg_adc2.adc14_num_conv    ;
            adc_avg_en        [15] <= cfg_adc2.adc15_avg_en  ;
            adc_num_conv      [15] <= cfg_adc2.adc15_num_conv    ;
         end
      end
   end

   // WLM CFG
   assign data_wlm     = {>>{seq_data}};
   assign data_wlm_man = {>>{man_cfg_wlm}};

   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         d1mzisw_sel    <= '0;
         d2mzisw_sel    <= '0;
         d3mzisw_sel    <= '0;
         d4mzisw_sel    <= '0;
         d1mzilw_sel    <= '0;
         d2mzilw_sel    <= '0;
         d3mzilw_sel    <= '0;
         d4mzilw_sel    <= '0;
      end else begin
         if (reset_cfg_wlm) begin
            d1mzisw_sel <= '0;
            d2mzisw_sel <= '0;
            d3mzisw_sel <= '0;
            d4mzisw_sel <= '0;
            d1mzilw_sel <= '0;
            d2mzilw_sel <= '0;
            d3mzilw_sel <= '0;
            d4mzilw_sel <= '0;
         end else if (man_cfg_wlm_sel) begin
            d1mzisw_sel <= data_wlm_man.d1mzisw_sel;
            d2mzisw_sel <= data_wlm_man.d2mzisw_sel;
            d3mzisw_sel <= data_wlm_man.d3mzisw_sel;
            d4mzisw_sel <= data_wlm_man.d4mzisw_sel;
            d1mzilw_sel <= data_wlm_man.d1mzilw_sel;
            d2mzilw_sel <= data_wlm_man.d2mzilw_sel;
            d3mzilw_sel <= data_wlm_man.d3mzilw_sel;
            d4mzilw_sel <= data_wlm_man.d4mzilw_sel;
         end else if ((seq_strobe) && (seq_opcode == OPCODE_CFG_WLM)) begin
            d1mzisw_sel <= data_wlm.d1mzisw_sel;
            d2mzisw_sel <= data_wlm.d2mzisw_sel;
            d3mzisw_sel <= data_wlm.d3mzisw_sel;
            d4mzisw_sel <= data_wlm.d4mzisw_sel;
            d1mzilw_sel <= data_wlm.d1mzilw_sel;
            d2mzilw_sel <= data_wlm.d2mzilw_sel;
            d3mzilw_sel <= data_wlm.d3mzilw_sel;
            d4mzilw_sel <= data_wlm.d4mzilw_sel;
         end
      end
   end

   // OPA0 CFG
   assign cfg_opa0      = {>>{seq_data}};
   assign cfg_opa0_man  = {>>{man_cfg_opa0}};
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         opa_ramp_duration <= '0;
         opa_num_ramps     <= '0;
         opa_dac_rate      <= '0;
      end else begin
         if (reset_cfg_opa) begin
            opa_ramp_duration <= '0;
            opa_num_ramps     <= '0;
            opa_dac_rate      <= '0;
         end else if (man_cfg_opa0_sel) begin
            opa_ramp_duration <= cfg_opa0_man.opa_ramp_duration;
            opa_num_ramps     <= cfg_opa0_man.opa_num_ramps    ;
            opa_dac_rate      <= cfg_opa0_man.opa_dac_rate     ;
         end else if ((seq_strobe) && (seq_opcode == OPCODE_CFG_OPA0)) begin
            opa_ramp_duration <= cfg_opa0.opa_ramp_duration;
            opa_num_ramps     <= cfg_opa0.opa_num_ramps    ;
            opa_dac_rate      <= cfg_opa0.opa_dac_rate     ;
         end
      end
   end

   // OPA1-OPA4 CFG
   assign cfg_opa1_4    = {>>{seq_data}};
   assign cfg_opa1_man  = {>>{man_cfg_opa1}};
   assign cfg_opa2_man  = {>>{man_cfg_opa2}};
   assign cfg_opa3_man  = {>>{man_cfg_opa3}};
   assign cfg_opa4_man  = {>>{man_cfg_opa4}};
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         opa_init_val   <= '{default : 0};
         opa_step_size  <= '{default : 0};
         opa_limit_min  <= '{default : 0};
         opa_limit_max  <= '{default : 0};
      end else begin
         // opa1 config
         if (reset_cfg_opa) begin
            opa_init_val [0]  <= '0;
            opa_step_size[0]  <= '0;
            opa_limit_min[0]  <= '0;
            opa_limit_max[0]  <= '0;
         end else if (man_cfg_opa1_sel) begin
            opa_init_val [0]  <= cfg_opa1_man.opa_init_val ;
            opa_step_size[0]  <= cfg_opa1_man.opa_step_size;
            opa_limit_min[0]  <= cfg_opa1_man.opa_limit_min;
            opa_limit_max[0]  <= cfg_opa1_man.opa_limit_max;
         end else if ((seq_strobe) && (seq_opcode == OPCODE_CFG_OPA1)) begin
            opa_init_val [0]  <= cfg_opa1_4.opa_init_val ;
            opa_step_size[0]  <= cfg_opa1_4.opa_step_size;
            opa_limit_min[0]  <= cfg_opa1_4.opa_limit_min;
            opa_limit_max[0]  <= cfg_opa1_4.opa_limit_max;
         end

         // opa2 config
         if (reset_cfg_opa) begin
            opa_init_val [1]  <= '0;
            opa_step_size[1]  <= '0;
            opa_limit_min[1]  <= '0;
            opa_limit_max[1]  <= '0;
         end else if (man_cfg_opa2_sel) begin
            opa_init_val [1]  <= cfg_opa2_man.opa_init_val ;
            opa_step_size[1]  <= cfg_opa2_man.opa_step_size;
            opa_limit_min[1]  <= cfg_opa2_man.opa_limit_min;
            opa_limit_max[1]  <= cfg_opa2_man.opa_limit_max;
         end else if ((seq_strobe) && (seq_opcode == OPCODE_CFG_OPA2)) begin
            opa_init_val [1]  <= cfg_opa1_4.opa_init_val ;
            opa_step_size[1]  <= cfg_opa1_4.opa_step_size;
            opa_limit_min[1]  <= cfg_opa1_4.opa_limit_min;
            opa_limit_max[1]  <= cfg_opa1_4.opa_limit_max;
         end

         // opa3 config
         if (reset_cfg_opa) begin
            opa_init_val [2]  <= '0;
            opa_step_size[2]  <= '0;
            opa_limit_min[2]  <= '0;
            opa_limit_max[2]  <= '0;
         end else if (man_cfg_opa3_sel) begin
            opa_init_val [2]  <= cfg_opa3_man.opa_init_val ;
            opa_step_size[2]  <= cfg_opa3_man.opa_step_size;
            opa_limit_min[2]  <= cfg_opa3_man.opa_limit_min;
            opa_limit_max[2]  <= cfg_opa3_man.opa_limit_max;
         end else if ((seq_strobe) && (seq_opcode == OPCODE_CFG_OPA3)) begin
            opa_init_val [2]  <= cfg_opa1_4.opa_init_val ;
            opa_step_size[2]  <= cfg_opa1_4.opa_step_size;
            opa_limit_min[2]  <= cfg_opa1_4.opa_limit_min;
            opa_limit_max[2]  <= cfg_opa1_4.opa_limit_max;
         end

         // opa4 config
         if (reset_cfg_opa) begin
            opa_init_val [3]  <= '0;
            opa_step_size[3]  <= '0;
            opa_limit_min[3]  <= '0;
            opa_limit_max[3]  <= '0;
         end else if (man_cfg_opa4_sel) begin
            opa_init_val [3]  <= cfg_opa4_man.opa_init_val ;
            opa_step_size[3]  <= cfg_opa4_man.opa_step_size;
            opa_limit_min[3]  <= cfg_opa4_man.opa_limit_min;
            opa_limit_max[3]  <= cfg_opa4_man.opa_limit_max;
         end else if ((seq_strobe) && (seq_opcode == OPCODE_CFG_OPA4)) begin
            opa_init_val [3]  <= cfg_opa1_4.opa_init_val ;
            opa_step_size[3]  <= cfg_opa1_4.opa_step_size;
            opa_limit_min[3]  <= cfg_opa1_4.opa_limit_min;
            opa_limit_max[3]  <= cfg_opa1_4.opa_limit_max;
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
         case (test_mux_sel[6:0])
         00      : test_data <= lan_en[7:0];
         01      : test_data <= dac_las_sel[7:0];
         02      : test_data <= lcat_en[7:0];
         03      : test_data <= hga_sel[7:0];
         04      : test_data <= 8'({las_n_led, hgc_sel});
         05      : test_data <= dac_htr_las_sel[7:0];
         06      : test_data <= d1mzisw_sel[7:0];
         07      : test_data <= d2mzisw_sel[7:0];
         08      : test_data <= d3mzisw_sel[7:0];
         09      : test_data <= d4mzisw_sel[7:0];
         10      : test_data <= d1mzilw_sel[7:0];
         11      : test_data <= d2mzilw_sel[7:0];
         12      : test_data <= d3mzilw_sel[7:0];
         13      : test_data <= d4mzilw_sel[7:0];
         14      : test_data <= opa_ramp_duration[7:0];
         15      : test_data <= opa_num_ramps    [7:0];
         16      : test_data <= opa_dac_rate     [7:0];
         17      : test_data <= opa_init_val [0][7:0];
         18      : test_data <= opa_step_size[0][7:0];
         19      : test_data <= opa_limit_min[0][7:0];
         20      : test_data <= opa_limit_max[0][7:0];
         21      : test_data <= opa_init_val [1][7:0];
         22      : test_data <= opa_step_size[1][7:0];
         23      : test_data <= opa_limit_min[1][7:0];
         24      : test_data <= opa_limit_max[1][7:0];
         25      : test_data <= opa_init_val [2][7:0];
         26      : test_data <= opa_step_size[2][7:0];
         27      : test_data <= opa_limit_min[2][7:0];
         28      : test_data <= opa_limit_max[2][7:0];
         29      : test_data <= opa_init_val [3][7:0];
         30      : test_data <= opa_step_size[3][7:0];
         31      : test_data <= opa_limit_min[3][7:0];
         32      : test_data <= opa_limit_max[3][7:0];
         33      : test_data <= 8'(tia_enhc);
         34      : test_data <= tia_gain_ctrl[7:0];
         35      : test_data <= tia_offset_adjust[0];
         36      : test_data <= tia_offset_adjust[1];
         37      : test_data <= tia_offset_adjust[2];
         38      : test_data <= tia_offset_adjust[3];
         39      : test_data <= '0;
         40      : test_data <= '0;
         41      : test_data <= adc_avg_en[7:0];
         42      : test_data <= 8'(adc_num_conv     [0][5:0]);
         43      : test_data <= 8'(adc_num_conv    [15][5:0]);
         44      : test_data <= 8'(tia_off_cal_start);
         45      : test_data <= 8'(tia_off_cal_reset);
         46      : test_data <= adc_start[7:0];
         47      : test_data <= 8'(adc_seq_id);
         48      : test_data <= 8'({opa_sweep_reset, opa_sweep_start});
         default  : test_data <= '0;
         endcase
      end
   end

endmodule