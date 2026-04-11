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
// Date   : 04/07/2021
//
// Description: Sequencer Package
//
//------------------------------------------------------------------------------
package rp_sequencer_pkg;

   parameter int BITS_OPCODE              = 08;
   parameter int BITS_NUM_CYC             = 24;
   parameter int BITS_OUTPUTS             = 96;

   // parameter logic[7:0] OPCODE_BAD        = 8'd00;
   parameter logic[7:0] OPCODE_CFG_TX     = 8'h01;
   parameter logic[7:0] OPCODE_CFG_TIA    = 8'h02;
   parameter logic[7:0] OPCODE_CFG_ADC1   = 8'h03;
   parameter logic[7:0] OPCODE_CFG_ADC2   = 8'h04;
   parameter logic[7:0] OPCODE_CFG_WLM    = 8'h05;
   parameter logic[7:0] OPCODE_CFG_OPA0   = 8'h06;
   parameter logic[7:0] OPCODE_CFG_OPA1   = 8'h07;
   parameter logic[7:0] OPCODE_CFG_OPA2   = 8'h08;
   parameter logic[7:0] OPCODE_CFG_OPA3   = 8'h09;
   parameter logic[7:0] OPCODE_CFG_OPA4   = 8'h0A;
   parameter logic[7:0] OPCODE_CTRL       = 8'h10;
   parameter logic[7:0] OPCODE_BRANCH     = 8'h14;
   parameter logic[7:0] OPCODE_WAIT       = 8'h15;
   parameter logic[7:0] OPCODE_PAUSE      = 8'h16;

   typedef struct {
      logic [BITS_OPCODE           -1 : 0] opcode;          // MSBS
      logic [BITS_NUM_CYC          -1 : 0] num_cyc;
      logic [BITS_OUTPUTS          -1 : 0] outputs;
   } data_t;

   // ------------------------------------------------------------------------
   // OPCODE_CFG_TX
   // ------------------------------------------------------------------------
   parameter int BITS_CFG_TX_RSV1     = 2;
   parameter int BITS_LAN_EN          = 14;
   parameter int BITS_CFG_TX_RSV2     = 3;
   parameter int BITS_LCAT_EN         = 13;

   parameter int BITS_CFG_TX_RSV3     = 6;
   parameter int BITS_DAC_LAS_SEL     = 10;
   parameter int BITS_CFG_TX_RSV4     = 6;
   parameter int BITS_DAC_HTR_LAS_SEL = 10;

   parameter int BITS_LAS_N_LED       = 1;
   parameter int BITS_HGC_SEL         = 5;
   parameter int BITS_HGA_SEL         = 26;

   typedef struct {  // bit 95 to bit 0
      logic [BITS_CFG_TX_RSV1     -1 : 0] reserved1      ;
      logic [BITS_LAN_EN          -1 : 0] lan_en         ;
      logic [BITS_CFG_TX_RSV2     -1 : 0] reserved2      ;
      logic [BITS_LCAT_EN         -1 : 0] lcat_en        ;
      logic [BITS_CFG_TX_RSV3     -1 : 0] reserved3      ;
      logic [BITS_DAC_LAS_SEL     -1 : 0] dac_las_sel    ;
      logic [BITS_CFG_TX_RSV4     -1 : 0] reserved4      ;
      logic [BITS_DAC_HTR_LAS_SEL -1 : 0] dac_htr_las_sel;
      logic [BITS_LAS_N_LED       -1 : 0] las_n_led      ;
      logic [BITS_HGC_SEL         -1 : 0] hgc_sel        ;
      logic [BITS_HGA_SEL         -1 : 0] hga_sel        ;
   } data_tx_t;

   // ------------------------------------------------------------------------
   // OPCODE_CFG_WLM
   // ------------------------------------------------------------------------
   parameter int BITS_CFG_WLM_RSV1  = 2;
   parameter int BITS_D1MZISW_SEL   = 10;
   parameter int BITS_D2MZISW_SEL   = 10;
   parameter int BITS_D3MZISW_SEL   = 10;

   parameter int BITS_CFG_WLM_RSV2  = 2;
   parameter int BITS_D4MZISW_SEL   = 10;
   parameter int BITS_D1MZILW_SEL   = 10;
   parameter int BITS_D2MZILW_SEL   = 10;

   parameter int BITS_CFG_WLM_RSV3  = 2;
   parameter int BITS_D3MZILW_SEL   = 10;
   parameter int BITS_D4MZILW_SEL   = 10;
   parameter int BITS_CFG_WLM_RSV4  = 10;

   typedef struct {  // bit 95 to bit 0
      logic [BITS_CFG_WLM_RSV1-1 :0] reserved1;
      logic [BITS_D1MZISW_SEL-1:0]   d1mzisw_sel;
      logic [BITS_D2MZISW_SEL-1:0]   d2mzisw_sel;
      logic [BITS_D3MZISW_SEL-1:0]   d3mzisw_sel;

      logic [BITS_CFG_WLM_RSV2-1 :0] reserved2;
      logic [BITS_D4MZISW_SEL-1:0]   d4mzisw_sel;
      logic [BITS_D1MZILW_SEL-1:0]   d1mzilw_sel;
      logic [BITS_D2MZILW_SEL-1:0]   d2mzilw_sel;

      logic [BITS_CFG_WLM_RSV3-1 :0] reserved3;
      logic [BITS_D3MZILW_SEL-1:0]   d3mzilw_sel;
      logic [BITS_D4MZILW_SEL-1:0]   d4mzilw_sel;
      logic [BITS_CFG_WLM_RSV4-1 :0] reserved4;
   } data_wlm_t;

   // ------------------------------------------------------------------------
   // OPCODE_CFG_OPA0
   // ------------------------------------------------------------------------
   parameter int BITS_CFG_OPA0_RSV       = 64 + 4;
   parameter int BITS_OPA_RAMP_DURATION  = 12;
   parameter int BITS_OPA_NUM_RAMPS      =  8;
   parameter int BITS_OPA_DAC_RATE       =  8;

   typedef struct {  // bit 95 to bit 0
      logic [BITS_CFG_OPA0_RSV     -1:0] reserved         ;
      logic [BITS_OPA_RAMP_DURATION-1:0] opa_ramp_duration;
      logic [BITS_OPA_NUM_RAMPS    -1:0] opa_num_ramps    ;
      logic [BITS_OPA_DAC_RATE     -1:0] opa_dac_rate     ;
   } cfg_opa0_t;

   // ------------------------------------------------------------------------
   // OPCODE_CFG_OPA1-4
   // ------------------------------------------------------------------------
   parameter int BITS_CFG_OPA1_4_RSV = 4;
   parameter int BITS_OPA_INIT_VAL  = 20;
   parameter int BITS_OPA_LIMIT_MIN = 20;
   parameter int BITS_OPA_LIMIT_MAX = 20;
   parameter int BITS_OPA_STEP_SIZE = 32;
   parameter int BITS_OPA1_4_CFG    = BITS_OPA_INIT_VAL
                                    + BITS_OPA_STEP_SIZE
                                    + BITS_OPA_LIMIT_MIN
                                    + BITS_OPA_LIMIT_MAX;
   typedef struct {  // bit 95 to bit 0
      logic [BITS_CFG_OPA1_4_RSV -1:0] reserved     ; // W3 [31:28]
      logic [BITS_OPA_INIT_VAL   -1:0] opa_init_val ; // W3 [27:08]
      logic [BITS_OPA_LIMIT_MIN  -1:0] opa_limit_min; // S3 [7:0] & [31:20]
      logic [BITS_OPA_LIMIT_MAX  -1:0] opa_limit_max; // [19:0]
      logic [BITS_OPA_STEP_SIZE  -1:0] opa_step_size; // [31:0]
   } cfg_opa1_4_t;

   // ------------------------------------------------------------------------
   // OPCODE_CFG_TIA
   // ------------------------------------------------------------------------
   parameter int BITS_CFG_TIA_RSV        = 3;
   parameter int BITS_TIA_ENHC           = 1;
   parameter int BITS_TIA_GAIN_CTRL      = 4;
   parameter int BITS_TIA_OFFSET_ADJUST  = 8;

   typedef struct {  // bit 95 to bit 0
      logic [BITS_CFG_TIA_RSV       -1 :0] reserved0         ;
      logic [BITS_TIA_ENHC          -1 :0] tia0_enhc         ;
      logic [BITS_TIA_GAIN_CTRL     -1 :0] tia0_gain_ctrl    ;
      logic [BITS_TIA_OFFSET_ADJUST -1 :0] tia0_offset_adjust;
      logic [BITS_CFG_TIA_RSV       -1 :0] reserved1         ;
      logic [BITS_TIA_ENHC          -1 :0] tia1_enhc         ;
      logic [BITS_TIA_GAIN_CTRL     -1 :0] tia1_gain_ctrl    ;
      logic [BITS_TIA_OFFSET_ADJUST -1 :0] tia1_offset_adjust;
      logic [BITS_CFG_TIA_RSV       -1 :0] reserved2         ;
      logic [BITS_TIA_ENHC          -1 :0] tia2_enhc         ;
      logic [BITS_TIA_GAIN_CTRL     -1 :0] tia2_gain_ctrl    ;
      logic [BITS_TIA_OFFSET_ADJUST -1 :0] tia2_offset_adjust;
      logic [BITS_CFG_TIA_RSV       -1 :0] reserved3         ;
      logic [BITS_TIA_ENHC          -1 :0] tia3_enhc         ;
      logic [BITS_TIA_GAIN_CTRL     -1 :0] tia3_gain_ctrl    ;
      logic [BITS_TIA_OFFSET_ADJUST -1 :0] tia3_offset_adjust;
      logic [32                     -1 :0] reserved4;
   } cfg_tia_t;

   // ------------------------------------------------------------------------
   // OPCODE_CFG_ADC1
   // ------------------------------------------------------------------------
   parameter int BITS_CFG_ADC_RSV      = 1;
   parameter int BITS_ADC_AVG_EN       = 1;
   parameter int BITS_ADC_NUM_CONV     = 6;

   typedef struct {  // bit 95 to bit 0
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved0    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc0_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc0_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved1    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc1_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc1_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved2    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc2_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc2_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved3    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc3_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc3_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved4    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc4_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc4_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved5    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc5_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc5_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved6    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc6_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc6_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved7    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc7_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc7_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved8    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc8_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc8_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved9    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc9_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc9_num_conv;
      logic [16                    -1 :0] padded_bits  ;
   } cfg_adc1_t;

   // ------------------------------------------------------------------------
   // OPCODE_CFG_ADC2
   // ------------------------------------------------------------------------
   typedef struct {  // bit 95 to bit 0
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved10    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc10_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc10_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved11    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc11_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc11_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved12    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc12_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc12_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved13    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc13_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc13_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved14    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc14_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc14_num_conv;
      logic [BITS_CFG_ADC_RSV      -1 :0] reserved15    ;
      logic [BITS_ADC_AVG_EN       -1 :0] adc15_avg_en  ;
      logic [BITS_ADC_NUM_CONV     -1 :0] adc15_num_conv;
      logic [48                    -1 :0] padded_bits  ;
   } cfg_adc2_t;

   // ------------------------------------------------------------------------
   // OPCODE_CTRL [4 TIAs, 16 ADCs, ]
   // ------------------------------------------------------------------------

   parameter int BITS_CTRL_RESERVED0    =  44;
   parameter int BITS_TIA_OFF_CAL_START =  4;  //
   parameter int BITS_CTRL_RESERVED1    =  4;
   parameter int BITS_TIA_OFF_CAL_RESET =  4;  //

   parameter int BITS_CTRL_RESERVED2    =  1;
   parameter int BITS_OPA_SWEEP_RESET   =  1;
   parameter int BITS_OPA_SWEEP_START   =  1;
   parameter int BITS_RESET_CFG_TX      =  1;
   parameter int BITS_RESET_CFG_WLM     =  1;
   parameter int BITS_RESET_CFG_OPA     =  1;
   parameter int BITS_RESET_CFG_TIA     =  1;
   parameter int BITS_RESET_CFG_ADC     =  1;

   parameter int BITS_ADC_SEQ_ID_VALID  =  1;
   parameter int BITS_ADC_SEQ_ID        =  7;
   parameter int BITS_CTRL_RESERVED3    =  8;
   parameter int BITS_ADC_START         = 16;

   typedef struct {  // bit 95 to bit 0
      logic [BITS_CTRL_RESERVED0    -1 :0] reserved0;
      logic [BITS_TIA_OFF_CAL_START -1 :0] tia_off_cal_start;
      logic [BITS_CTRL_RESERVED1    -1 :0] reserved1;
      logic [BITS_TIA_OFF_CAL_RESET -1 :0] tia_off_cal_reset;

      logic [BITS_CTRL_RESERVED2    -1 :0] reserved2        ;
      logic [BITS_OPA_SWEEP_RESET   -1 :0] opa_sweep_reset  ;
      logic [BITS_OPA_SWEEP_START   -1 :0] opa_sweep_start  ;
      logic [BITS_RESET_CFG_TX      -1 :0] reset_cfg_tx     ;
      logic [BITS_RESET_CFG_WLM     -1 :0] reset_cfg_wlm    ;
      logic [BITS_RESET_CFG_OPA     -1 :0] reset_cfg_opa    ;
      logic [BITS_RESET_CFG_TIA     -1 :0] reset_cfg_tia    ;
      logic [BITS_RESET_CFG_ADC     -1 :0] reset_cfg_adc    ;
      logic [BITS_ADC_SEQ_ID_VALID  -1 :0] adc_seq_id_valid ;
      logic [BITS_ADC_SEQ_ID        -1 :0] adc_seq_id       ;
      logic [BITS_CTRL_RESERVED3    -1 :0] reserved3        ;
      logic [BITS_ADC_START         -1 :0] adc_start        ;
   } ctrl_t;

endpackage
