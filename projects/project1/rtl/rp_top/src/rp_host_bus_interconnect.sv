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
// Date   : 04/26/2021
//
// Description: Host Bus Interconnect
//              TBD
//
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module rp_host_bus_interconnect #(
   parameter NUM_DEV   = 6,
   parameter ADDR_WIDTH    = 16,
   parameter DATA_WIDTH    = 32
) (
   // Clock / Reset
   input                       clk,             // clock
   input                       rst_n,           // reset (active low)
   // Local Bus Interface    
   input      [ADDR_WIDTH-1:0] local_addr,       // local address
   input                       local_wstrobe,         // local write strobe
   input                       local_rstrobe,         // local write strobe
   input      [DATA_WIDTH-1:0] local_wdata,      // local write data
   output reg [DATA_WIDTH-1:0] host_rdata,      // local read data
   // Host Interface
   
   host_if.master         host_if_master [0:NUM_DEV-1],
   input                       test_stb,       // test strobe
   output reg                  host_raddrerr,
   output reg                  host_waddrerr
);

   // Signal Declaration -------------------------------------------------------

   // LOGIC STARTS HERE --------------------------------------------------------
    logic host_wstrobe_sync;
    logic host_rstrobe_sync;
    logic waddrerr;
    logic raddrerr;
    logic waddrerr_sync;
    logic raddrerr_sync;

    logic rack;
    logic rack_sync;

    logic host_clk;
    logic host_rst_n;

    logic [DATA_WIDTH - 1:0] rdata_ff;
    logic [DATA_WIDTH - 1:0] local_wdata_ff;
    logic [ADDR_WIDTH - 1:0] local_addr_ff;
    
    logic [DATA_WIDTH - 1:0] local_rdata;
    logic [DATA_WIDTH - 1:0] local_rdata_ff;
    
    

    logic [DATA_WIDTH - 1:0] host_wdata;
    logic [ADDR_WIDTH-1:0]   host_addr;

    logic host_wstrobe ;
    logic host_rstrobe ;
    logic [NUM_DEV - 1 : 0] accumulated_waddrerr;
    logic [NUM_DEV - 1 : 0] accumulated_raddrerr;  
    logic [NUM_DEV - 1 : 0] accumulated_rack;          
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_0_array ;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_1_array ;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_2_array ;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_3_array ;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_4_array ;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_5_array ;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_6_array ;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_7_array ;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_8_array ;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_9_array ;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_10_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_11_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_12_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_13_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_14_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_15_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_16_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_17_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_18_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_19_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_20_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_21_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_22_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_23_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_24_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_25_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_26_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_27_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_28_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_29_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_30_array;
    logic [NUM_DEV - 1 : 0] rdata_validated_bit_31_array;

 

   // ------------------------------------------------------------------------
   // WRITE OPERATION
   // ------------------------------------------------------------------------

////// sync wstrobe, rstrobe, wdata and addr to hclk domain 
assign host_clk = host_if_master[0].hclk;
assign host_rst_n = host_if_master[0].hrst_n;


rp_synch_sim	               
                inst_rp_synch_sim_wstrobe    (
                .clk		(host_clk),
                .rst_n		(host_rst_n),
                .din		(local_wstrobe),

                .dout		(host_wstrobe_sync)
                );


rp_synch_sim	               
                inst_rp_synch_sim_rstrobe    (
                .clk		(host_clk),
                .rst_n		(host_rst_n),
                .din		(local_rstrobe),

                .dout		(host_rstrobe_sync)
                );


always_ff @ (posedge clk or negedge rst_n)
begin
      if (!rst_n) begin
         local_wdata_ff  <= 'b0;
         local_addr_ff   <= 'b0;
         
      end 
      else begin
         if(local_wstrobe || local_rstrobe) begin
            local_wdata_ff  <= local_wdata;
            local_addr_ff   <= local_addr;
         end
      end     
end

always_ff @ (posedge host_clk or negedge host_rst_n)
begin
      if (!host_rst_n) begin
         host_rstrobe   <= 'b0;
         host_wstrobe   <= 'b0;
         host_wdata     <= 'b0;
         host_addr      <= 'b0;

         
      end 
      else begin
         if(host_wstrobe_sync || host_rstrobe_sync) begin
             host_wdata     <= local_wdata_ff;
             host_addr      <= local_addr_ff;
         end
         host_rstrobe   <= host_rstrobe_sync;
         host_wstrobe   <= host_wstrobe_sync;


      end     
end

generate
    for(genvar i=0;i<NUM_DEV;i++) begin : all_signals
       assign host_if_master[i].wstrobe = host_wstrobe & (host_addr[15:8] == i) ;
       assign host_if_master[i].rstrobe = host_rstrobe & (host_addr[15:8] == i) ;   
       assign host_if_master[i].addr    = (host_addr[15:8] == i) ? host_addr[7:0] : 'b0 ;
       assign host_if_master[i].wdata   = (host_addr[15:8] == i) ? host_wdata : 'b0 ;     
    end
endgenerate
   // ------------------------------------------------------------------------
   // READ OPERATION
   // ------------------------------------------------------------------------

generate
    for(genvar i=0;i<NUM_DEV;i++)
    begin : rdata_validate
        assign  rdata_validated_bit_0_array [i]  =    host_if_master[i].rdata[0] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_1_array [i]  =    host_if_master[i].rdata[1] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_2_array [i]  =    host_if_master[i].rdata[2] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_3_array [i]  =    host_if_master[i].rdata[3] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_4_array [i]  =    host_if_master[i].rdata[4] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_5_array [i]  =    host_if_master[i].rdata[5] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_6_array [i]  =    host_if_master[i].rdata[6] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_7_array [i]  =    host_if_master[i].rdata[7] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_8_array [i]  =    host_if_master[i].rdata[8] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_9_array [i]  =    host_if_master[i].rdata[9] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_10_array[i]  =    host_if_master[i].rdata[10] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_11_array[i]  =    host_if_master[i].rdata[11] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_12_array[i]  =    host_if_master[i].rdata[12] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_13_array[i]  =    host_if_master[i].rdata[13] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_14_array[i]  =    host_if_master[i].rdata[14] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_15_array[i]  =    host_if_master[i].rdata[15] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_16_array[i]  =    host_if_master[i].rdata[16] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_17_array[i]  =    host_if_master[i].rdata[17] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_18_array[i]  =    host_if_master[i].rdata[18] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_19_array[i]  =    host_if_master[i].rdata[19] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_20_array[i]  =    host_if_master[i].rdata[20] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_21_array[i]  =    host_if_master[i].rdata[21] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_22_array[i]  =    host_if_master[i].rdata[22] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_23_array[i]  =    host_if_master[i].rdata[23] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_24_array[i]  =    host_if_master[i].rdata[24] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_25_array[i]  =    host_if_master[i].rdata[25] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_26_array[i]  =    host_if_master[i].rdata[26] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_27_array[i]  =    host_if_master[i].rdata[27] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_28_array[i]  =    host_if_master[i].rdata[28] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_29_array[i]  =    host_if_master[i].rdata[29] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_30_array[i]  =    host_if_master[i].rdata[30] & (local_addr[15:8] == i);
        assign  rdata_validated_bit_31_array[i]  =    host_if_master[i].rdata[31] & (local_addr[15:8] == i);
    end
endgenerate

// bitwise or the rdata_validated  
            assign     local_rdata[0]    =     |rdata_validated_bit_0_array     ;
            assign     local_rdata[1]     =    |rdata_validated_bit_1_array     ;
            assign     local_rdata[2]    =     |rdata_validated_bit_2_array     ;
            assign     local_rdata[3]  =       |rdata_validated_bit_3_array     ;
            assign     local_rdata[4]   =      |rdata_validated_bit_4_array     ;
            assign     local_rdata[5]   =      |rdata_validated_bit_5_array     ;
            assign     local_rdata[6]   =      |rdata_validated_bit_6_array     ;
            assign     local_rdata[7]   =      |rdata_validated_bit_7_array     ;
            assign     local_rdata[8]   =      |rdata_validated_bit_8_array     ;
            assign     local_rdata[9]   =      |rdata_validated_bit_9_array     ;
            assign     local_rdata[10]   =     |rdata_validated_bit_10_array    ;
            assign     local_rdata[11]   =     |rdata_validated_bit_11_array    ;
            assign     local_rdata[12]    =    |rdata_validated_bit_12_array    ;
            assign     local_rdata[13]    =    |rdata_validated_bit_13_array    ;
            assign     local_rdata[14]    =    |rdata_validated_bit_14_array    ;
            assign     local_rdata[15]    =    |rdata_validated_bit_15_array    ;
            assign     local_rdata[16]    =    |rdata_validated_bit_16_array    ;
            assign     local_rdata[17]    =    |rdata_validated_bit_17_array    ;
            assign     local_rdata[18]    =    |rdata_validated_bit_18_array    ;
            assign     local_rdata[19]    =    |rdata_validated_bit_19_array    ;
            assign     local_rdata[20]    =    |rdata_validated_bit_20_array    ;
            assign     local_rdata[21]    =    |rdata_validated_bit_21_array    ;
            assign     local_rdata[22]    =    |rdata_validated_bit_22_array    ;
            assign     local_rdata[23]    =    |rdata_validated_bit_23_array    ;
            assign     local_rdata[24]    =    |rdata_validated_bit_24_array    ;
            assign     local_rdata[25]    =    |rdata_validated_bit_25_array    ;
            assign     local_rdata[26]    =    |rdata_validated_bit_26_array    ;
            assign     local_rdata[27]    =    |rdata_validated_bit_27_array    ;
            assign     local_rdata[28]    =    |rdata_validated_bit_28_array    ;
            assign     local_rdata[29]    =    |rdata_validated_bit_29_array    ;
            assign     local_rdata[30]    =    |rdata_validated_bit_30_array    ;
            assign     local_rdata[31]    =    |rdata_validated_bit_31_array    ;



   // ------------------------------------------------------------------------
   // ERROR REPORTING
   // ------------------------------------------------------------------------

// Accumulate pready and pslverr from slaves into a bit vector
generate
    for(genvar i=0;i<NUM_DEV;i++)
    begin: accumulate_error_and_ack
        assign accumulated_waddrerr[i] = host_if_master[i].waddrerr; 
        assign accumulated_raddrerr[i] = host_if_master[i].raddrerr;
        assign accumulated_rack[i]     = host_if_master[i].rack;        
    end
endgenerate


   assign waddrerr = |accumulated_waddrerr;
   assign raddrerr = |accumulated_raddrerr;
   assign rack     = |accumulated_rack;
   assign host_waddrerr  = waddrerr_sync;
   assign host_raddrerr  = raddrerr_sync;


rp_synch_sim	               
                inst_rp_synch_sim_rack    (
                .clk		(clk),
                .rst_n		(rst_n),
                .din		(rack),

                .dout		(rack_sync)
                );


rp_synch_sim	               
                inst_rp_synch_sim_raddrerr    (
                .clk		(clk),
                .rst_n		(rst_n),
                .din		(raddrerr),           
                .dout		(raddrerr_sync)
                );

rp_synch_sim	               
                inst_rp_synch_sim_waddrerr    (
                .clk		(clk),
                .rst_n		(rst_n),
                .din		(waddrerr),

                .dout		(waddrerr_sync)
                );

always @ (posedge host_clk, negedge host_rst_n)
begin
   if (!host_rst_n) begin
      local_rdata_ff    <= 1'b0;

      
   end else begin
      if(rack == 1'b1) begin
         local_rdata_ff     <= local_rdata;
      end
   end
end


    

always @ (posedge clk, negedge rst_n)
begin
   if (!rst_n) begin
      host_rdata        <= 'b0;

      
   end else begin
      if(rack_sync == 1'b1) begin
         host_rdata     <= local_rdata_ff;
      end
   end
end


endmodule

