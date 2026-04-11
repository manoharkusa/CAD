//####################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
// Author:        Chaitra Rangaswamaiah
// Project:       Uintah
//
// Description:   FIFO Core Module
//               
//               
//-------------------------------------------------------------------------------------------------------------------

`timescale 1ns/1ps

module rp_fifo_core # (
  parameter SIMONLY       = 0,  // 1 for behavior mem model, 0 for TSMC mem model 
  parameter MEM_WIDTH     = 32, // Data Width
  parameter MEM_LOG2DEPTH = 14  // FIFO Depth
 )
(
  input                          parity_odd_not_even, // Parity odd not even
  output reg                     fifo_err_parity,     // Parity error
  output reg [MEM_LOG2DEPTH:0]   err_addr,            // Error address location
  input                          clear_err_addr,      // Clear error address (pulse)

  input                          clk,                 // Input clock
  input                          rst_n,               // Active low reset

  input [MEM_LOG2DEPTH-1:0]      fifo_thresh,         // Programmable threshold - at reset 14'h2000
  input                          resync,              // Resync wr_ptr to rd_ptr 
  input                          read_init,           // Read enable
  input                          wr_en,               // Write enable
  output reg                     fifo_overrun,        // FIFO overrun
  output reg                     fifo_underrun,       // FIFO underrun
  output reg [MEM_WIDTH-1:0]     read_data,           // Read data 
  input      [MEM_WIDTH-1:0]     write_data,          // Write data
  output reg                     fifo_rdy,            // FIFO ready 
  output reg                     fifo_full,           // FIFO full
  output reg                     fifo_empty,          // FIFO empty
  output reg [MEM_LOG2DEPTH:0]   fifo_level,          // FIFO level
  input                          capture,             // Capture - ingress_cnt, egress_cnt and fifo_level

 //Status Counter
  input                          clear,               // Clear ingress_cnt and egress_cnt 
  output reg [MEM_WIDTH-1:0]     ingress_cnt,         // write counter 
  output reg [MEM_WIDTH-1:0]     egress_cnt,          // read counter  

//MBIST
//  input                          mbist_en,
//  input [3:0]                    mbist_mode,
//  input                          mbist_init,
//  output reg                     mbist_pass_nfail,
//  output reg                     mbist_done,

 //Test I/F
  input      [7:0]              test_sel,
  output reg [7:0]              test_data
 
);
 // int i;

  logic [MEM_LOG2DEPTH:0]        wr_ptr;              
  logic [MEM_LOG2DEPTH:0]        rd_ptr;              
  logic [MEM_WIDTH-1:0]          ingress_counter;  
  logic [MEM_WIDTH-1:0]          egress_counter;
  logic                          increment_ingress;  
  logic                          increment_egress;
  logic [MEM_LOG2DEPTH:0]        fifo_level_real;

  logic                          mem_we_a;
  logic [MEM_WIDTH:0]            mem_wdata_a; // (32 bit data +1 bit parity ) 33 bit 
  logic [MEM_WIDTH:0]            mem_rdata_b; // (32 bit data + 1 bit parity) 33 bit
  
  logic [MEM_LOG2DEPTH:0]        wr_ptr_next;
  logic                          parity_bit;
  logic                          parity_check;
  logic [MEM_LOG2DEPTH:0]        mem_addr_q;
  logic                          read_init_q;


  assign fifo_empty = (wr_ptr_next == rd_ptr) ? 1'b1 : 1'b0;
  assign fifo_full = ((wr_ptr_next[MEM_LOG2DEPTH] != rd_ptr[MEM_LOG2DEPTH]) & (wr_ptr_next[MEM_LOG2DEPTH-1:0] == rd_ptr[MEM_LOG2DEPTH-1:0])) ? 1'b1 : 1'b0;
  assign fifo_level_real = (wr_ptr_next - rd_ptr);
  assign parity_bit = ^{write_data, parity_odd_not_even};
  assign parity_check = ^{parity_odd_not_even, mem_rdata_b};

always_ff@(posedge clk, negedge rst_n)begin

      if(!rst_n)
      begin
            fifo_overrun        <= '0;
            fifo_underrun       <= '0;
            read_data           <= '0;
            wr_ptr              <= '0;
            rd_ptr              <= '0;
            ingress_cnt         <= '0;
            egress_cnt          <= '0;
            mem_we_a            <= '0;
            mem_wdata_a         <= '0;
            ingress_counter     <= '0;
            egress_counter      <= '0;
            fifo_level          <= '0;
            wr_ptr_next         <= '0;
            fifo_err_parity     <= '0;
            err_addr            <= '0;
            increment_ingress   <= '0;
            increment_egress    <= '0;

      end
      else begin
            mem_we_a             <= '0;
            fifo_overrun         <= '0;
            fifo_underrun        <= '0;
            fifo_err_parity      <= '0;
            increment_ingress    <= '0;
            increment_egress     <= '0;
            read_init_q          <= read_init;
            mem_addr_q           <= rd_ptr;
              
               if(wr_en) begin               
                 if(!read_init)begin
                     if(fifo_full)begin
                        fifo_overrun <= 1'b1;            
                     end
                     else begin //if(!fifo_full) begin
                        increment_ingress <= 1'b1;
                        mem_we_a          <= 1;
                        mem_wdata_a       <= {parity_bit, write_data}; // 33 bit, goes to mem_wrapper
                        wr_ptr_next       <= wr_ptr_next+1'b1;
                        wr_ptr            <= wr_ptr_next;
                     end
                  end
                  else begin //if(read_init) begin               // both wr_en and read_init = 1
                       if(fifo_empty)begin        
                          increment_ingress <= 1'b1;              // since FIFO empty, only write can happen
                          mem_we_a      <= 1;
                          mem_wdata_a   <= {parity_bit, write_data};
                          wr_ptr_next   <= wr_ptr_next +1'b1 ;
                          wr_ptr        <= wr_ptr_next;   
                          fifo_underrun <= 1'b1;                  
                       end
                       //successful read and write
                       else begin //if(!fifo_empty)begin  
                             increment_egress <= 1'b1;
                             if(fifo_full)begin
                                fifo_overrun     <= 1'b1;
                                read_data        <= mem_rdata_b[31:0];
                                rd_ptr           <= rd_ptr + 1'b1;
                                fifo_err_parity  <= parity_check;
                             end
                             else begin  //if(!fifo_full) begin
                                increment_ingress <= 1'b1;
                                mem_we_a         <= 1;
                                mem_wdata_a      <= {parity_bit,write_data};
                                wr_ptr_next      <= wr_ptr_next +1'b1 ;
                                wr_ptr           <= wr_ptr_next;
                                read_data        <= mem_rdata_b[31:0];
                                rd_ptr           <= rd_ptr + 1'b1;
                                fifo_err_parity  <= parity_check;
                             end
                       end
                  end
               end
               else if(read_init)begin // && wr_en == 0) begin
                       if(fifo_empty)begin
                          fifo_underrun <= 1'b1;
                       end
                       else begin //if(!fifo_empty) begin
                          increment_egress  <= 1'b1;
                          read_data         <= mem_rdata_b[31:0];
                          rd_ptr            <= rd_ptr + 1'b1;
                          fifo_err_parity   <= parity_check;
                       end  
               end
        
            if(clear_err_addr) begin
                err_addr <= '0;
            end 
            else if (parity_check && read_init_q) begin
                 err_addr <= mem_addr_q;
            end
 
            if(clear)begin
               ingress_counter <= '0;
               egress_counter  <= '0;
            end
            else begin
                 if(increment_ingress) begin
                    ingress_counter <= ingress_counter + 1 ;
                 end
                 if(increment_egress) begin
                    egress_counter <= egress_counter + 1;
                 end
            end

            if(resync)begin
               wr_ptr      <= rd_ptr;
               wr_ptr_next <= rd_ptr; 
            end

            if(capture) begin
               ingress_cnt        <= ingress_counter;
               egress_cnt         <= egress_counter;
               fifo_level         <= fifo_level_real;
            end
      end  
end

always@(posedge clk, negedge rst_n) begin
       if(!rst_n)
       begin
            fifo_rdy <= 1'b0;
       end
       else begin
                 if(fifo_level_real >= fifo_thresh)begin
                      fifo_rdy <= 1'b1;
                 end
                 else begin
                      fifo_rdy <= 1'b0;
                 end
            end
end
 
rp_fifo_mem_wrapper #(
     .SIMONLY       (SIMONLY),
     .MEM_LOG2DEPTH (MEM_LOG2DEPTH),
     .MEM_WIDTH     (MEM_WIDTH+1)
)
rp_fifo_mem_wrapper0(
      .clk        (clk),
      .rst_n      (rst_n),
      // -------------------
      .addr_a     (wr_ptr[MEM_LOG2DEPTH-1:0]),
      .we_a       (mem_we_a),
      .din_a      (mem_wdata_a),
      .dout_a     (),
      // -------------------
      .addr_b     (rd_ptr[MEM_LOG2DEPTH-1:0]),
      .we_b       (1'b0),
      .din_b      (33'd0),
      .dout_b     (mem_rdata_b)
   );

   // ------------------------------------------------------------------------
   // Test Mux Logic
   // ------------------------------------------------------------------------
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         test_data      <= '0;
      end else begin
         case (test_sel)
         00       : test_data <= '0;
         01       : test_data <= 8'({parity_odd_not_even, fifo_err_parity, clear_err_addr}); // parity debug
         04       : test_data <= read_data [7:0];
         05       : test_data <= read_data [15:8];   
         06       : test_data <= read_data [23:16];
         07       : test_data <= read_data [31:24];
         08       : test_data <= fifo_level [7:0];
         09       : test_data <= fifo_level [14:8];
         10       : test_data <= 8'({fifo_rdy, wr_en, read_init, fifo_full, fifo_empty, fifo_overrun, fifo_underrun});       
         11       : test_data <= wr_ptr [7:0];
         12       : test_data <= wr_ptr [14:0];
         13       : test_data <= rd_ptr [7:0];        
         14       : test_data <= rd_ptr [14:8];
         15       : test_data <= 8'({wr_en, read_init});
         16       : test_data <= 8'({capture, clear, resync}); 
         default  : test_data <= '0;
         endcase
      end
   end



endmodule
