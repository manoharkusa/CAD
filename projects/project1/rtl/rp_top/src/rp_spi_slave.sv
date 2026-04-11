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
// Date   : 04/25/2021
//
// Description: SPI Slave
//              TBD
//
//-------------------------------------------------------------------------------

`timescale 1ns/1ps

module rp_spi_slave #(
   parameter ADDR_WIDTH    = 16,
   parameter DATA_WIDTH    = 32,
   parameter CPOL          = 0,  // clock polarity   0 = clock idle at 0, 1 = clock idle at 1 (!!! Only support clock idle at 0)
   parameter CPHA          = 0,  // clock phase      (TBD)
   parameter SPOL          = 0  ) // select polarity  0 = active low, 1 = active high ( !!! Only support active low )
  (
   // Clock / Reset
   input                       clk,              // clock
   input                       rst_n,            // reset (active low)
   // SPI Interface
   input                       spi_clk,          // spi clk
   input                       spi_sen,          // spi select (active low)
   input                       spi_mosi,         // spi mosi
   output reg                  spi_miso,         // spi miso
   // Host Interface
   output reg [ADDR_WIDTH-1:0] local_addr,        // host address
   output reg                  local_write,       // host write strobe
   output reg                  local_read,        // host write strobe
   output reg [DATA_WIDTH-1:0] local_wdata,  // host write data
   input      [DATA_WIDTH-1:0] local_rdata,   // host read data
   // Errors / Status
   output reg                  err_fsm_start,    // Error - FSM starting at wrong state
   output reg                  err_burst_wr_incomp,    // Error - spi write cancelled prematurely
   output reg                  err_burst_wr_last_word,  //E
   output reg                  err_timeout,      // Error - FSM watchdog timer
   // For Debugging
   input      [7:0]            test_sel,         // Test Select
   output reg [7:0]            test_data         // Test Data
);
   // Signal Declaration -------------------------------------------------------
   localparam  WDG_TO_CNT  = 50000000;  // Watchdog Timer Time Out (50e6 cycles)  1second with 50MHz clock
   localparam  CYC_ADDR    = 14; // 15 Cycles of Address
   localparam  CYC_DIR     =  1; //  1 Cycle  of Direction
   localparam  CYC_TA      =  8; //  8 Cycles of Turnaround
   localparam  CYC_HOST_WRITE_TA =  4; //  8 Cycles of Turnaround
   localparam  CYC_DATA    = 32; // 32 Cycles of Data
   localparam  CYC_DATA_BURST = 128;
  // localparam  FIFO_ADDR   = 14'h3FFF;
   localparam  DEV_FIFO    = 5;
   localparam  DEV_SEQ    = 1;
   localparam  FIFO_READ_INIT = 8'h24;
   localparam  SEQ_MEM_ADDR_ADDR = 8'h10;
   localparam  SEQ_MEM_WRITE_ADDR = 8'h14;
   localparam  SEQ_MEM_WDATA_3_ADDR = 8'h20;
   localparam  SEQ_MEM_WDATA_2_ADDR = 8'h24;
   localparam  SEQ_MEM_WDATA_1_ADDR = 8'h28;
   localparam  SEQ_MEM_WDATA_0_ADDR = 8'h2C;
   localparam  logic[31:0] PREAMBLE = 32'h5A_00_00_00;

   localparam  FIFO_READ_DATA = 8'h28;
   enum logic [9:0]  // 7-bits
   {ST_IDLE      =10'b0000000001,  // IDLE
    ST_BURST_CMD =10'b0000000010,  // BURST/SINGLE
    ST_ADDR      =10'b0000000100,  // Address
    ST_DIR       =10'b0000001000,  // Direction
    ST_TA        =10'b0000010000,  // Turnaround
    ST_DATA      =10'b0000100000,  // Data
    ST_CR        =10'b0001000000,  //Continuous Read
    ST_CW        =10'b0010000000,
    ST_DATA_CONT =10'b0100000000,
    ST_LAST_WR_BURST = 10'b1000000000 }  // Data
    state;

   logic[7:0]              cnt_bits;  // 6-bit cnt_bitser
   logic[3:0]              cnt1_bits;  // 4-bit cnt_bitser
   logic[3:0]              cnt2_bits;  // 4-bit cnt_bitser

   logic[31:0]             data_out;
   logic[13:0]             addr;      // could be shared with temp register
   logic                   dir_rnw;
   logic                   spi_clk_q;
   logic                   spi_sen_q;
   logic                   spi_mosi_q;
   logic                   spi_clk_2q ;
   logic                   spi_sen_2q ;
   logic[31:0]             wdg_timer; // Watchdog timer
   logic                   fifo_read_next;
   logic [31:0]            wdata_in;
   logic [31:0]            wdata_127_96;
   logic [31:0]            wdata_95_64;
   logic [31:0]            wdata_63_32;
   logic [31:0]            wdata_31_0;
   logic [31:0]            wdata_127_96_frz;
   logic [31:0]            wdata_95_64_frz;
   logic [31:0]            wdata_63_32_frz;
   logic [31:0]            wdata_31_0_frz;
   logic                   enable_burst_wr_data;
   logic                   freeze_burst_wr_data;
   logic                   start_write_burst_ta;
   logic                   burst_cmd;
   logic                   [11:0] seq_mem_addr;
   // LOGIC STARTS HERE --------------------------------------------------------
  // assign test_stb = 1;

  // FSM Process
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         state                      <= ST_IDLE;
         local_addr                 <= '0;
         local_write                <= '0;
         local_read                 <= '0;
         local_wdata                <= '0;
         cnt_bits                   <= '0;
         addr                       <= '0;
         dir_rnw                    <= '0;
         spi_clk_q                  <= '0;
         spi_sen_q                  <= '0;
         spi_mosi_q                 <= '0;
         spi_clk_2q                 <= '0;
         spi_sen_2q                 <= '0;
         data_out                   <= '0;  // variable (blocking)
         err_fsm_start              <= '0;
         err_burst_wr_incomp        <= '0;
         err_timeout                <= '0;
         wdg_timer                  <= '0;
         enable_burst_wr_data       <= '0;
         freeze_burst_wr_data       <= '0;
         start_write_burst_ta       <= '0;
         fifo_read_next             <= '0;
         wdata_in                   <= '0;
         wdata_31_0                 <= '0;
         wdata_63_32                <= '0;
         wdata_95_64                <= '0;
         wdata_127_96               <= '0;
         wdata_31_0                 <= '0;
         wdata_31_0_frz             <= '0;
         wdata_63_32_frz            <= '0;
         wdata_95_64_frz            <= '0;
         wdata_127_96_frz           <= '0;
         wdata_31_0_frz             <= '0;
         seq_mem_addr               <= '0;
         cnt1_bits                  <= '0;
         cnt2_bits                  <= '0;
         err_burst_wr_last_word     <= '0;
         burst_cmd                  <= '0;
         

      end else begin
         spi_clk_q                  <= spi_clk;
         spi_sen_q                  <= spi_sen;
         spi_mosi_q                 <= spi_mosi;
         spi_clk_2q                 <= spi_clk_q;
         spi_sen_2q                 <= spi_sen_q;
         local_write                <= '0;
         local_read                 <= '0;
         err_fsm_start              <= '0;
         err_burst_wr_incomp        <= '0;
         err_timeout                <= '0;
         err_burst_wr_last_word     <= '0;
         freeze_burst_wr_data       <= '0;

         case(state)  // State Machine
         ST_IDLE  : begin  // IDLE STATE
            if (spi_sen_2q & ~spi_sen_q) begin  // Detection of high to low
               state          <= ST_BURST_CMD;
               seq_mem_addr   <= '0;
               cnt_bits       <= '0;
               data_out[31:0] <= PREAMBLE; // load 5A to be transmitted to the micro
            end
         end
         ST_BURST_CMD  : begin  // BURST CMD STATE
            if (spi_clk_q & ~spi_clk_2q) begin
               burst_cmd   <= spi_mosi_q;
               cnt_bits    <= '0;
               state <= ST_ADDR;
               data_out <= {data_out[30:0], 1'b0};
            end
         end

         ST_ADDR  : begin  // ADDRESS STATE
            if (spi_clk_q & ~spi_clk_2q) begin
               cnt_bits    <= cnt_bits + 1'b1;
               // MSB comes in first
               addr        <= {addr[12:0], spi_mosi_q};
               data_out <= {data_out[30:0], 1'b0};
               if(cnt_bits == 3)  // along with 5A also send burst_cmd and 7 bits of addr
               begin
                data_out <= {data_out[30:28],burst_cmd,addr[2:0],25'd0};
               end
               if(cnt_bits == 7)
               begin
                data_out <= {data_out[30:28],addr[3:0],25'd0};
               end



               if (cnt_bits == CYC_ADDR-1) begin
                  state    <= ST_DIR;
               end
            end
         end

         ST_DIR   : begin  // DIRECTION STATE
            if (spi_clk_q & ~spi_clk_2q) begin
               dir_rnw     <= spi_mosi_q;
               data_out    <= '0;
               cnt_bits    <= '0;
               local_addr  <= 16'(addr); // extend to 16-bits
              if(spi_mosi_q)begin
               if(burst_cmd)begin
                  burst_cmd  <= '0;
                  cnt_bits <= '0;
                  state <= ST_CR;
                end
                else begin
                  state    <= ST_TA;
                  local_read <= 1'b1;
                end
              end
              else begin
               if(burst_cmd) begin  // a write burst is only allowed to the sequencer memory
                  burst_cmd <= '0;
                  cnt_bits <= '0;
                  state <= ST_CW;
                  seq_mem_addr <= addr[11:0];
                  cnt1_bits <= '0;
                  cnt2_bits <= '0;
                end
                else begin
                    state    <= ST_DATA;
                 end
              end
           end
        end // ST_DIR

         ST_TA    : begin // Read turnaround time
            if (spi_clk_q & ~spi_clk_2q) begin
               cnt_bits <= cnt_bits + 1'b1;
               if (cnt_bits == CYC_TA-1) begin
                  state       <= ST_DATA;
                  cnt_bits    <= '0;
                  data_out    <= local_rdata; //input from host bus if
               end
            end
         end

         ST_DATA  : begin   // R/W DATA
           if (spi_clk_q & ~spi_clk_2q) begin
               cnt_bits <= cnt_bits + 1'b1;
               data_out <= {data_out[30:0], spi_mosi_q};
               if (cnt_bits == CYC_DATA-1) begin
                  state         <= ST_IDLE;
                  local_write   <= ~dir_rnw;
                  local_wdata   <= {data_out[30:0], spi_mosi_q}; //after this state data gets assigned to local_wdata
               end
            end
         end

         ST_CR   : begin  //Continuous Read Turn around time +sends read_init and read_data commands
            if (spi_clk_q & ~spi_clk_2q) begin
                cnt_bits    <= cnt_bits + 1'b1;
                 if(cnt_bits == '0) begin
                    local_addr <= {8'(DEV_FIFO),FIFO_READ_INIT};
                    local_wdata <= 32'h000_0001;
                    local_write <= 1'b1;
                 end
                 else if(cnt_bits == 4)begin //check by changing 16,17,..
                       local_addr <= {8'(DEV_FIFO), FIFO_READ_DATA};
                       local_read <= 1'b1;
                 end
                 else if (cnt_bits == CYC_TA-1) begin
                    state <= ST_DATA_CONT;
                    cnt_bits <= '0;
                    data_out <= local_rdata;
                end
             end
          end
         ST_CW   : begin
            if (spi_clk_q & ~spi_clk_2q) begin
                cnt_bits    <= cnt_bits + 1'b1;
                wdata_in <= {wdata_in[30:0], spi_mosi_q};
            end
                if(cnt_bits == 32) begin
                    wdata_127_96 <= wdata_in;
                end
                if(cnt_bits == 64) begin
                    wdata_95_64 <= wdata_in;
                end
                if(cnt_bits == 96) begin
                    wdata_63_32 <= wdata_in;
                end
                if(cnt_bits == 128) begin
                    wdata_31_0 <= wdata_in;
                    cnt_bits <= '0;
                    freeze_burst_wr_data <= 1'b1;
                 end

            if (freeze_burst_wr_data) begin
                wdata_127_96_frz <= wdata_127_96;
                wdata_95_64_frz  <= wdata_95_64;
                wdata_63_32_frz  <= wdata_63_32;
                wdata_31_0_frz   <= wdata_31_0;
                enable_burst_wr_data <= 1'b1;
            end
           if(enable_burst_wr_data)
           begin
               if(cnt1_bits == '0 & !start_write_burst_ta) begin ///
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WDATA_3_ADDR};
                    local_wdata <= wdata_127_96_frz;
                    local_write <= 1'b1;
                    start_write_burst_ta <= 1'b1;

               end
               if(cnt1_bits == 1 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WDATA_2_ADDR};
                    local_wdata <= wdata_95_64_frz;
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 2 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WDATA_1_ADDR};
                    local_wdata <= wdata_63_32_frz;
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 3 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WDATA_0_ADDR};
                    local_wdata <= wdata_31_0_frz;
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 4 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_ADDR_ADDR};
                    local_wdata <= 32'(seq_mem_addr);
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 5 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WRITE_ADDR};
                    local_wdata <= 32'(1'b1);
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 6 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WRITE_ADDR};
                    local_wdata <= 32'(1'b0);
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 7 & !start_write_burst_ta) begin
                    seq_mem_addr <= seq_mem_addr + 1'b1;
                    cnt1_bits <= '0;
                    enable_burst_wr_data  <= 1'b0;

               end
               if(start_write_burst_ta) begin
                   cnt2_bits <= cnt2_bits + 1'b1;
                   if (cnt2_bits == CYC_HOST_WRITE_TA) begin
                      start_write_burst_ta <= 1'b0;
                      cnt2_bits  <= '0;
                      cnt1_bits  <= cnt1_bits + 1'b1;
                   end
                end
              end

          end
         ST_DATA_CONT   : begin //Read data continuously
             if (spi_clk_q & ~spi_clk_2q) begin //spi clk event
                 cnt_bits <= cnt_bits + 1'b1;  //increment mod 32 counter
                 data_out <={data_out[30:0], spi_mosi_q};
                 if(cnt_bits == '0)begin
                     fifo_read_next <= spi_mosi_q;
                 end
                 if(cnt_bits == 10) begin  //enable fifo read_init
                    if(fifo_read_next == 1)begin
                    local_addr <= {8'(DEV_FIFO),FIFO_READ_INIT};
                    local_wdata <= 32'h000_0001;
                    local_write <= 1'b1;
                    end

                  end
                 if(cnt_bits == 16)begin //read fifo
                    if(fifo_read_next == 1)begin
                       local_addr <= {8'(DEV_FIFO), FIFO_READ_DATA};
                       local_read <= 1'b1;
                    end
                 end
                 if(cnt_bits == CYC_DATA-1)begin
                        if(fifo_read_next == 1)begin
                           data_out <= local_rdata;
                           cnt_bits <= '0;
                        end
                        else begin
                             state <= ST_IDLE;
                             cnt_bits <= '0;
                        end
                  end
               end
         end
         ST_LAST_WR_BURST  : begin
           if (freeze_burst_wr_data) begin
                wdata_127_96_frz <= wdata_127_96;
                wdata_95_64_frz  <= wdata_95_64;
                wdata_63_32_frz  <= wdata_63_32;
                wdata_31_0_frz   <= wdata_31_0;
                enable_burst_wr_data <= 1'b1;
            end

               if(!spi_sen_q & spi_sen_2q) begin
                  err_burst_wr_last_word <= 1'b1;
               end
               if(cnt1_bits == '0 & !start_write_burst_ta) begin ///
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WDATA_3_ADDR};
                    local_wdata <= wdata_127_96_frz;
                    local_write <= 1'b1;
                    start_write_burst_ta <=1'b1;
               end
               if(cnt1_bits == 1 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WDATA_2_ADDR};
                    local_wdata <= wdata_95_64_frz;
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 2 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WDATA_1_ADDR};
                    local_wdata <= wdata_63_32_frz;
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 3 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WDATA_0_ADDR};
                    local_wdata <= wdata_31_0_frz;
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 4 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_ADDR_ADDR};
                    local_wdata <= 32'(seq_mem_addr);
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 5 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WRITE_ADDR};
                    local_wdata <= 32'(1'b1);
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 6 & !start_write_burst_ta) begin
                    start_write_burst_ta <=1'b1;
                    local_addr <= {8'(DEV_SEQ),SEQ_MEM_WRITE_ADDR};
                    local_wdata <= 32'(1'b0);
                    local_write <= 1'b1;
               end
               if(cnt1_bits == 7 & !start_write_burst_ta) begin
                    cnt1_bits <= '0;
                    enable_burst_wr_data  <= 1'b0;
                    state  <= ST_IDLE;

               end
               if(start_write_burst_ta) begin
                   cnt2_bits <= cnt2_bits + 1'b1;
                   if (cnt2_bits == CYC_HOST_WRITE_TA) begin
                      start_write_burst_ta <= 1'b0;
                      cnt2_bits  <= '0;
                      cnt1_bits  <= cnt1_bits + 1'b1;
                   end
                end
            end

         default : begin // CASE OTHERS
            state <= ST_IDLE;
         end

         endcase

         // Go to IDLE state when spi_sen_q goes inactive
         if (spi_sen_q) begin
            if(state == ST_CW) begin
                 if(cnt_bits == 128) begin
                      state    <= ST_LAST_WR_BURST;
                    freeze_burst_wr_data <= 1'b1;
                 end
                 else if(cnt_bits != '0) begin
                     err_burst_wr_incomp <= 1'b1;
                     state <= ST_IDLE;
                  end
                 else begin
                    cnt1_bits <= '0;
                    if(freeze_burst_wr_data | enable_burst_wr_data) begin
                      enable_burst_wr_data <= '0;
                      state    <= ST_LAST_WR_BURST;
                    end
                    else begin
                      state    <= ST_IDLE;
                    end
                 end
            end
            else if ((state != ST_IDLE) & (state != ST_LAST_WR_BURST )) begin
                state <= ST_IDLE;
                err_fsm_start <= 1'b1;
            end

         end else begin
            if (wdg_timer == WDG_TO_CNT) begin
               state          <= ST_IDLE;
               err_timeout    <= 1'b1;  // Watchdog Timeout
            end
        end

         // Watchdog Timer
         // Increment timer when 1. state is not in ST_IDLE and
         //                      2. there is no clock activity
         if ((state != ST_IDLE) && (spi_clk_q & spi_clk_2q))
            wdg_timer   <= wdg_timer + 1'b1;
         else
            wdg_timer   <= '0;

      end
   end


   // drive out miso
   assign spi_miso  = data_out[31];

   // ------------------------------------------------------------------------
   // Test Mux Logic
   // ------------------------------------------------------------------------
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         test_data      <= '0;
      end else begin
         case (test_sel)
         00       : test_data <= {cnt_bits[4:0], spi_clk_q, spi_mosi_q, spi_sen_q};
         01       : test_data <= state[7:0];
         02       : test_data <= wdg_timer[7:0];
         default  : test_data <= '0;
         endcase
      end
   end

endmodule

