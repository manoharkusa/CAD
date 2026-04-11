//####################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
// Author:        Puneeth Reddy
// Project:       Uintah  
//
// Description:  
//               
//               
//-------------------------------------------------------------------------------------------------------------------
module      rp_tia_offset_cancel_top
            #
            (
			    ADDR_WIDTH=8,
				DATA_WIDTH=32,
                DACWIDTH = 8
            )                     
            (
                output   logic                          tia_off_comp_clk,
                output   logic        [DACWIDTH-1:0]    tia_off_dac_in,


                input   logic                           clk,
                input   logic                           rst_n,
                input   logic                           tia_off_start,
                input   logic                           tia_off_reset,
                input   logic         [DACWIDTH-1:0]    tia_off_adjust,
                input   logic                           tia_off_comp_out,
                


				// GENERIC BUS PORTS


                host_if.slave                           host_if_slave,

                // For Debugging
                input      [7:0]                        test_mux_sel,     // Test Select
                output reg [7:0]                        test_data         // Test Data
            );

localparam BITPOINTER_WIDTH = 3;
localparam SATCOUNTER_WIDTH = 10;

enum logic [3:0] {IDLE=4'b0001, COMPOUT0_SETDACVAL = 4'b0010, COMPOUT1_SETDACVAL=4'b0100, COMPCLK=4'b1000}   state, state_next;



logic [DACWIDTH-1:0] dac_value;
logic [DACWIDTH-1:0] dac_value_ff;
logic [DACWIDTH:0] dac_off_adjust_val;

logic [BITPOINTER_WIDTH-1:0] bit_pointer;
logic [BITPOINTER_WIDTH-1:0] bit_pointer_ff;
logic comp_clk;
logic comp_clk_ff;

logic dis_adjust;
logic dis_adjust_ff;

logic capture_dac;
logic [SATCOUNTER_WIDTH-1:0] sat_count;
logic [SATCOUNTER_WIDTH-1:0] sat_count_ff;
logic sat_out;
logic sat_counter_en;
logic sat_counter_en_ff;

logic tia_off_comp_out_sync;

logic [DACWIDTH-1:0] dac_ambient_off_val;
logic [DACWIDTH-1:0] dac_in_val;

localparam REG_BLOCK_REVISION_ID          = 16'd1; 


logic [9:0]  comp_settling_time_settling_time;
logic [9:0]  dac_settling_time_settling_time ;
logic [15:0] id_reg_block_revision_ip;
logic [7:0]  dac_ambient_cancel_value_dac_debug_ip;
logic [7:0]  dac_monitor_dac_debug_ip             ;

logic tia_off_reset_ff;
logic tia_off_start_ff;

/////////////////////////   Modules ///////////////////////////


tia_offset_cancel_reg_block
    #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
    )
    dut_tia_offset_cancel_reg_block
    (
    .comp_settling_time_settling_time (comp_settling_time_settling_time),
    .dac_settling_time_settling_time  (dac_settling_time_settling_time),
    .id_reg_block_revision_ip         (id_reg_block_revision_ip),  
    .dac_ambient_cancel_value_dac_debug_ip  (dac_ambient_cancel_value_dac_debug_ip),
    .dac_monitor_dac_debug_ip         (dac_monitor_dac_debug_ip),
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


rp_sat_counter
            
    #
    (
    .COUNTER_WIDTH(SATCOUNTER_WIDTH)
    )
    dut1_rp_sat_counter
    (
    .clk             (clk),
    .rst_n           (rst_n),
    .sat_val         (sat_count_ff),
    .counter_en      (sat_counter_en_ff),
    .counter_clr     (1'b0),
    
    .sat_out         (sat_out),
    .counter_out     ()   
    );

rp_synch_sim
    dut_rp_synch_sim
	(
	.clk    (clk),
	.rst_n  (rst_n),
	.din    (tia_off_comp_out),

	.dout   (tia_off_comp_out_sync)
	);

    

///// State Machine ////////
always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        state  <= IDLE;
		bit_pointer_ff <= 'b0;
		dac_value_ff   <= 'b0;
        sat_counter_en_ff   <= 'b0;
        sat_count_ff      <= 'b0;
        comp_clk_ff       <= 'b1;
        dis_adjust_ff     <= 'b0;
        tia_off_start_ff  <= 1'b0;
        tia_off_reset_ff  <= 1'b0;
        
    end
    else
    begin
        state  <= state_next;
	    bit_pointer_ff <= bit_pointer;
        sat_counter_en_ff   <= sat_counter_en;
        sat_count_ff      <= sat_count;
        comp_clk_ff       <= comp_clk;
        dis_adjust_ff     <= dis_adjust;
        tia_off_start_ff  <= tia_off_start;
        tia_off_reset_ff  <= tia_off_reset;  
        if(tia_off_reset_ff && (!dis_adjust ))
        begin
           dac_value_ff <= 'b0;        
        end      
        else
        begin
            dac_value_ff <= dac_value;
        end
    end
end





always_comb  
begin
    state_next           = state;
    dac_value            = dac_value_ff;
    bit_pointer          = bit_pointer_ff;
    comp_clk             = comp_clk_ff;
    dis_adjust           = dis_adjust_ff;
	capture_dac			 = 1'b0;
    sat_counter_en         = sat_counter_en_ff;
    sat_count            = sat_count_ff;
    case (state)
         IDLE       : begin
                        comp_clk = 1'b1;
                        dis_adjust = 1'b0;
                        if(tia_off_start_ff)
                        begin
                            bit_pointer          = 3'd6;       
                            dis_adjust           = 1'b1;
                            state_next           = COMPOUT0_SETDACVAL;                                                                                                
                        end
                      end
        COMPOUT0_SETDACVAL : begin
                      sat_count                = dac_settling_time_settling_time;
                      sat_counter_en           = 1'b1; 
                      dac_value[bit_pointer]   = 1'b1;                
					  if(sat_out)
                      begin
                            state_next           = COMPCLK;    
                            sat_counter_en       = 1'b0;                 
                      end
                      end
        COMPOUT1_SETDACVAL : begin
                      sat_count                = dac_settling_time_settling_time;
                      sat_counter_en           = 1'b1; 
                      dac_value[bit_pointer + 1'b1] = 1'b0;                                                                                            
                      dac_value[bit_pointer]   = 1'b1;                
					  if(sat_out)
                      begin
                            state_next           = COMPCLK;    
                            sat_counter_en       = 1'b0;                 
                      end
                      end
                     
        COMPCLK    : begin
                      sat_count                = comp_settling_time_settling_time;
                      sat_counter_en           = 1'b1; 
                      comp_clk                 = 1'b0;                
					  if(sat_out)
                      begin
                          if(bit_pointer_ff != 0)
                          begin
					     	bit_pointer = bit_pointer - 1'b1;	
						    comp_clk    = 1'b1;                             	 
                            if(tia_off_comp_out_sync)
                            begin
                                state_next           = COMPOUT1_SETDACVAL;  
                                sat_counter_en       = 1'b0;                 
                                                                  
                            end
                            else
                            begin
                                state_next           = COMPOUT0_SETDACVAL;    
                                sat_counter_en       = 1'b0;                 
                                                                 			 
                            end
                          end
                         else
                          begin
                             sat_counter_en       = 1'b0;                                              
                             sat_count    = 'b0;
                             dis_adjust  = 1'b0; 
                             capture_dac = 1'b1;
						     state_next  = IDLE;
                             comp_clk    = 1'b1;
                             if(tia_off_comp_out_sync)
                             begin
                                dac_value[bit_pointer] = 1'b0;
                             end        
                          end
                      end  
		    end			 

    endcase
end



always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        dac_ambient_off_val <= 'b0;
    end
    else
    begin
        if(tia_off_reset_ff)
        begin    
            dac_ambient_off_val <= 'b0;  
        end 
        else if(capture_dac)
        begin    
            dac_ambient_off_val <= dac_value;  
        end 
    end
end


always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        dac_in_val  <= 'b0;
    end
    else
    begin
        if(dis_adjust_ff)
        begin    
           dac_in_val <= dac_value;
        end 
        else
        begin /// Over flow detection 
            if(dac_off_adjust_val[DACWIDTH] || dac_off_adjust_val[DACWIDTH-1])
            begin
                dac_in_val <= 8'hFF;                                
            end        
            else
            begin
                dac_in_val <= dac_off_adjust_val[DACWIDTH-1:0];                
            end

        end

    end
end

assign dac_off_adjust_val  = 9'(dac_ambient_off_val) + 9'(tia_off_adjust);


assign tia_off_dac_in = dac_in_val;
assign tia_off_comp_clk = comp_clk_ff;
assign dac_ambient_cancel_value_dac_debug_ip = dac_ambient_off_val;
assign dac_monitor_dac_debug_ip = dac_in_val;
assign id_reg_block_revision_ip = REG_BLOCK_REVISION_ID;

   // ------------------------------------------------------------------------
   // Test Mux Logic
   // ------------------------------------------------------------------------
   always @ (posedge clk, negedge rst_n)
   begin
      if (!rst_n) begin
         test_data      <= '0;
      end else begin
         case (test_mux_sel)
         00       : test_data <= '0;
         01       : test_data <= {dac_in_val[5:0], tia_off_comp_out_sync, comp_clk_ff};
         default  : test_data <= '0;
         endcase
      end
   end

endmodule
