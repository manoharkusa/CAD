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
// Description: Uintah Top Package
//
//------------------------------------------------------------------------------
package rp_top_top_pkg;

   //-------------------------------------------------------------------------
   //  Constants
   //-------------------------------------------------------------------------
   localparam NUM_ADC               = 16;     // Number of ADC devices
   localparam NUM_TOC               = 4;      // Number of TIA Offset Canceler blocks
   localparam NUM_OPA               = 4;      // Number of OPA blocks

   //-------------------------------------------------------------------------
   //  Uintah System Memory map
   //  14-BIT ADDRESS [0x00000 to 0x3FFF]
   //  UPPER 6-BITS ARE USED FOR BASE ADDRESS]
   //-------------------------------------------------------------------------
   localparam OFFSET_LOCAL          = 0;                                        // 0x0000 - 0x00FF    LOCAL MEMORY  OFFSET
   localparam OFFSET_SEQ            = 1;                                        // 0x0100 - 0x01FF    SEQUENCER     OFFSET
   localparam OFFSET_ANA            = 2;                                        // 0x0200 - 0x02FF    ANALOG CONFIG OFFSET
   localparam OFFSET_INT            = 3;                                        // 0x0300 - 0x03FF    INTERRUPT     OFFSET
   localparam OFFSET_TEST_MUX       = 4;                                        // 0x0400 - 0x04FF    TEST_MUX      OFFSET
   localparam OFFSET_FIFO           = 5;                                        // 0x0500 - 0x05FF    FIFO          OFFSET
   localparam OFFSET_ARB            = 6;                                        // 0x0600 - 0x06FF    ARBITER       OFFSET
   localparam OFFSET_ADC_CLK_OFF    = 7;                                        // 0x0700 - 0x16FF    ADC CLOCK     OFFSET (WITH 16 ADCs)
   localparam OFFSET_APP_OFF        = OFFSET_ADC_CLK_OFF+NUM_ADC;               // 0x1700 - 0x26FF    APP           OFFSET (WITH 16 ADCs)
   localparam OFFSET_TOC_OFF        = OFFSET_APP_OFF    +NUM_ADC;               // 0x2700 - 0x2AFF    TOA           OFFSET
   localparam NUM_MEM_BLOCKS        = OFFSET_TOC_OFF    +NUM_TOC;               // 0x2B = 43

   //-------------------------------------------------------------------------
   //  Uintah System Test Mux  - DEVICE ID /MODULE SELECT
   //  8-BITS Module Select in Test Mux is used to bring out test signals from
   //  selected module
   //-------------------------------------------------------------------------
   localparam TMUX_ID_SPI               = 0;                                    //  0    SPI
   localparam TMUX_ID_SEQ               = 1;                                    //  1    SEQUENCER
   localparam TMUX_ID_ANA               = 2;                                    //  2    ANALOG CONFIG
   localparam TMUX_ID_FIFO              = 3;                                    //  3    FIFO
   localparam TMUX_ID_ARB               = 4;                                    //  4    ARBITER
   localparam TMUX_ID_ADC_CLK_OFF       = 5;                                    //  5-20 ADC CLOCK
   localparam TMUX_ID_APP_OFF           = TMUX_ID_ADC_CLK_OFF+NUM_ADC;          // 21-36 APP
   localparam TMUX_ID_TOC_OFF           = TMUX_ID_APP_OFF    +NUM_ADC;          // 37-40 TOA
   localparam TMUX_ID_OPA_OFF           = TMUX_ID_TOC_OFF    +NUM_TOC;          // 41    OPA
   localparam TMUX_ID_INTERCONNECT      = TMUX_ID_OPA_OFF    +1      ;          // 42    INTERCONNECT
   localparam NUM_TMUX_ID               = TMUX_ID_INTERCONNECT +1;              // 43

endpackage
