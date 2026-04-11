//####################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
// Author:        Puneeth Reddy
// Project:       Uintah  
//
// Description: This block generates the adc clk, rst and strobe signal pahse alligned and clocked at the negedge of clk 
//               
//               
//-------------------------------------------------------------------------------------------------------------------
module      rp_adc_clk_ctrl_top
            #
            (
			    ADDR_WIDTH=8,
				DATA_WIDTH=32
            )                     
            (
                output   logic                          adc_clk,
                output   logic                          adc_rst,
                output   logic                          adc_strobe,
                output   logic                          adc_conv_en_error,
                output   logic                          data_strobe,
                output   logic                          soc,
                output   logic                          eoc,



                input   logic                           clk,
                input   logic                           rst_n,
                input   logic                           adc_conv_en,
                input   logic                           [5:0] num_conv,
                input   logic                           adc_dout,
				// GENERIC BUS PORTS


                host_if.slave                           host_if_slave,
                
                // For Debugging
                input      [7:0]                        test_mux_sel,     // Test Select
                output reg [7:0]                        test_data         // Test Data
            );


enum logic [3:0] {IDLE=4'b0001, CONV_ACTIVE=4'b0010, WAIT_STATE=4'b0100, FORCE_EN=4'b1000}   state, state_next;


localparam  RESET_ACTIVE=1'b1;
localparam  RESET_INACTIVE=1'b0;
localparam  STROBE_DELAY_WIDTH=8;
localparam  CLK_DIV_WIDTH=8;
localparam  CLK_NCYCLES_WIDTH=9;
localparam  ADC_CLK_COUNT_WIDTH= CLK_NCYCLES_WIDTH + CLK_DIV_WIDTH + 2;


logic           clr_adc_conv_active;
logic  [ADC_CLK_COUNT_WIDTH-1:0]  adc_clk_count;
logic  [ADC_CLK_COUNT_WIDTH-1:0]  adc_clk_sat_count_out;
logic  [ADC_CLK_COUNT_WIDTH-1:0]  data_strobe_clk_count;

//logic  [ADC_CLK_COUNT_WIDTH-1:0]  strobe_delay_extended;
logic           conv_start;
//logic           conv_start_delayed;
logic           manual_start;
//logic           manual_start_delayed;
logic           div_clk_out;
logic           adc_rst_pos;
  
// logic  [CLK_DIV_WIDTH-1:0]       clk_div_period_minus_1;     
// logic           adc_clk_even;  
//logic  [STROBE_DELAY_WIDTH-1:0]  strobe_delay_frz;
logic  [CLK_DIV_WIDTH-1:0]       clk_div_half_period_frz   ;
logic  [CLK_NCYCLES_WIDTH-1:0]   conv_ncycles_frz     ;
//logic  [STROBE_DELAY_WIDTH-1:0] strobe_delay_strobe_ctrl_reg;
logic           manual_enable_manual_ctrl_reg  ;
logic  [CLK_DIV_WIDTH-1:0]       clk_div_half_period_adc_clk_ctrl_reg;
logic  [CLK_NCYCLES_WIDTH-1:0]   conv_ncycles_adc_clk_ctrl_reg  ;
logic           adc_conv_en_edge;
logic           adc_conv_en_ff;
logic           force_en;
// logic           adc_rst_ff;
logic  [CLK_DIV_WIDTH:0]         clk_div_period;
logic           strobe_clk_out;
logic           strobe_clk_out_ff;
logic           strobe_out;
logic           strobe_edge;
logic           force_en_ff;
logic           force_en_edge;
logic           conv_start_ff;
logic           conv_start_ff1;

logic           conv_start_edge;
logic           conv_manual_ff;
logic           conv_manual_ff1;
logic           conv_manual_ff2;
logic           conv_manual_ff3;


logic           data_strobe_clk_en;
logic           data_strobe_clk;
logic           data_strobe_clk_ff;
// logic           clr_data_strobe_clk;
logic           data_strobe_out;
logic           data_strobe_clk_neg_edge;
logic           data_strobe_clk_edge;
logic           [5:0] num_conv_frz;
logic           wait_sat_count_en;

localparam REG_BLOCK_REVISION_ID          = 16'd1; 
 
logic           [5:0] num_conv_count;
logic           [5:0] num_conv_count_ff;
logic           soc_out;
logic           eoc_out;
logic           [CLK_DIV_WIDTH+2:0] wait_sat_count;

logic           clr_wait_sat_count;
logic           strobe_clk_pos_edge;
logic           clr_data_strobe_clk_en;
logic           strobe_clk_neg_edge;

/////////////////////////   Modules ///////////////////////////

   

//assign adc_clk_div_en      = conv_start_delayed || manual_start_delayed ; 
//assign adc_strobe_div_en   = conv_start || manual_start ; 
assign force_en        = manual_enable_manual_ctrl_reg;
assign clk_div_period  = clk_div_half_period_frz * 2; 
assign wait_sat_count = clk_div_period * 3;
//assign strobe_delay_extended = {{CLK_NCYCLES_WIDTH{1'b0}},strobe_delay_frz};

adc_clk_ctrl_reg_block
    #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
    )
    dut_adc_clk_ctrl_reg_block
    (
      // FIELD OUTPUT PORTS
    .strobe_delay_strobe_ctrl_reg      ( ) ,
    .manual_enable_manual_ctrl_reg     (manual_enable_manual_ctrl_reg  ) ,
    .manual_override_manual_ctrl_reg   () ,
    .clk_div_half_period_adc_clk_ctrl_reg   (clk_div_half_period_adc_clk_ctrl_reg) ,
    .conv_ncycles_adc_clk_ctrl_reg     (conv_ncycles_adc_clk_ctrl_reg  ) ,
    .id_reg_block_revision_ip          (REG_BLOCK_REVISION_ID),

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


/// used to generate the adc_clk	signal	
rp_clk_div_pos_no_sync
	
	#
	(
	.DIV_WIDTH (CLK_DIV_WIDTH+1),
	.DIV_INIT  ('0),
    .START_EDGE(1'b1)
	)
    dut0_rp_clk_div_pos_no_sync
	(
	.clk            (clk),			// source clock
	.rst_n		    (rst_n),		// asynch reset input
	.clk_div_en     (conv_manual_ff2),		// other clock domain
	.clk_div_period	(clk_div_period),		// div by clk_vid_period + 1 syned
	.clk_out        (div_clk_out)
	);


/// used to generate the adc_strobe	signal	
rp_clk_div_pos_no_sync
	
	#
	(
	.DIV_WIDTH (CLK_DIV_WIDTH+1),
	.DIV_INIT  ('0),
    .START_EDGE(1'b1)
	)
    dut1_rp_clk_div_pos_no_sync
	(
	.clk            (clk),			// source clock
	.rst_n		    (rst_n),		// asynch reset input
	.clk_div_en     (conv_manual_ff2),		// other clock domain
	.clk_div_period	(clk_div_period),		// div by clk_vid_period + 1 syned
	.clk_out        (strobe_clk_out)
	);


/// used to generate the data_strobe signal 	
rp_clk_div_pos_no_sync
	
	#
	(
	.DIV_WIDTH (CLK_DIV_WIDTH+1),
	.DIV_INIT  ('0),
    .START_EDGE(1'b1)
	)
    dut2_rp_clk_div_pos_no_sync
	(
	.clk            (clk),			// source clock
	.rst_n		    (rst_n),		// asynch reset input
	.clk_div_en     (data_strobe_clk_en),		// other clock domain
	.clk_div_period	(clk_div_period),		// div by clk_vid_period + 1 syned
	.clk_out        (data_strobe_clk)
	);

rp_sat_counter
            
    #
    (
    .COUNTER_WIDTH(ADC_CLK_COUNT_WIDTH)
    )
    dut0_rp_sat_counter
    (
    .clk             (clk),
    .rst_n           (rst_n),
    .sat_val         (adc_clk_count),
    .counter_en      (conv_manual_ff2),
    .counter_clr     (1'b0),
    
    .sat_out         (clr_adc_conv_active),
    .counter_out     (adc_clk_sat_count_out)   
    );


rp_sat_counter
            
    #
    (
    .COUNTER_WIDTH(ADC_CLK_COUNT_WIDTH)
    )
    dut2_rp_sat_counter
    (
    .clk             (clk),
    .rst_n           (rst_n),
    .sat_val         (adc_clk_count),
    .counter_en      (data_strobe_clk_en),
    .counter_clr     (1'b0),
    
    .sat_out         (clr_data_strobe_clk_en),
    .counter_out     (data_strobe_clk_count)   
    );




rp_sat_counter
            
    #
    (
    .COUNTER_WIDTH(CLK_DIV_WIDTH+3)
    )
    dut4_rp_sat_counter
    (
    .clk             (clk),
    .rst_n           (rst_n),
    .sat_val         (wait_sat_count),
    .counter_en      (wait_sat_count_en),
    .counter_clr     (1'b0),
    
    .sat_out         (clr_wait_sat_count),
    .counter_out     ()   
    );

///////////////////////////////////////////////////////////////////////////////

// assign adc_clk_count = (clk_div_half_period_frz * conv_ncycles_frz * 2) - clk_div_half_period_frz;
assign adc_clk_count = ((clk_div_half_period_frz * conv_ncycles_frz) << 1) - clk_div_half_period_frz;


////  Freeze register values during Adc covn or Force Enable

always_ff @ (posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        clk_div_half_period_frz    <= 'b0;
        conv_ncycles_frz      <= 'b0;     
    //    strobe_delay_frz      <= 'b0; 
        num_conv_frz          <= 'b0;
    end
    else
    begin
        if((adc_conv_en_edge || force_en_edge) & !conv_start)
        begin    
            clk_div_half_period_frz    <=    clk_div_half_period_adc_clk_ctrl_reg;
            conv_ncycles_frz      <=    conv_ncycles_adc_clk_ctrl_reg  ;
        //    strobe_delay_frz      <= strobe_delay_strobe_ctrl_reg; 
            num_conv_frz          <= num_conv;           
        end
     end
end


assign conv_start_edge  = !conv_start_ff && conv_start;
assign adc_conv_en_edge = !(adc_conv_en_ff) && (adc_conv_en);
assign strobe_clk_pos_edge = (!strobe_clk_out_ff) && (strobe_clk_out);
assign strobe_clk_neg_edge = (strobe_clk_out_ff) && (!strobe_clk_out);
assign strobe_edge   = strobe_clk_pos_edge | strobe_clk_neg_edge;
assign force_en_edge = !force_en_ff && force_en;
assign data_strobe_clk_neg_edge = data_strobe_clk_ff && !data_strobe_clk;
assign data_strobe_clk_edge = data_strobe_clk_neg_edge ;




/////  Edge detect adc_conv_en, strobe_clk_out 
always_ff @ (posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        adc_conv_en_ff <= 1'b0;
        strobe_clk_out_ff <= 1'b1;
        data_strobe_clk_ff <= 1'b1;
        force_en_ff    <= 1'b0;
        conv_start_ff  <= 1'b0;
        conv_start_ff1    <= 1'b0;                
        conv_manual_ff    <= 1'b0;
        conv_manual_ff1    <= 1'b0;
        conv_manual_ff2    <= 1'b0;
        conv_manual_ff3    <= 1'b0;
        
    end
    else
    begin
        adc_conv_en_ff <= adc_conv_en;
        strobe_clk_out_ff <= strobe_clk_out; 
        data_strobe_clk_ff <= data_strobe_clk;       
        force_en_ff       <= force_en; 
        conv_start_ff     <= conv_start;   
        conv_start_ff1    <= conv_start_ff;        
        conv_manual_ff    <= (conv_start | manual_start);
        conv_manual_ff1    <= conv_manual_ff;
        conv_manual_ff2    <= conv_manual_ff1;
        conv_manual_ff3    <= conv_manual_ff2;
  
     end
end


//// Detect any new adc_conv_en while 
//// current adc_conv_en is ongoing. Generate an adc_conv_error if happens
always_ff @ (posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        adc_conv_en_error <= 1'b0;
    end
    else
    begin
        if(state == CONV_ACTIVE && adc_conv_en_edge) 
        begin 
            adc_conv_en_error <= 1'b1;            
        end
        else
        begin
            adc_conv_en_error <= 1'b0;
        end
    end
end



///// Generate adc strobe 
always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        strobe_out        <= 1'b1;
    end
    else
    begin
        if(force_en_edge || conv_start_edge)
        begin
            strobe_out        <= 1'b0;           
        end
        else if(conv_manual_ff || conv_manual_ff2)
        begin
          strobe_out        <= strobe_edge;                                 
        end
        else
        begin
            strobe_out        <= 1'b1;                                             
        end
    end
end


///// Generate adc strobe 
always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        data_strobe_out        <= 1'b0;
    end
    else
    begin
        data_strobe_out        <= data_strobe_clk_edge;           
    end
end


///// Generate adc strobe 
always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        soc_out        <= 1'b0;
    end
    else
    begin
        soc_out        <= (data_strobe_clk_count == 2);           
    end
end



///// Generate adc strobe 
always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        eoc_out        <= 1'b0;
    end
    else
    begin
        eoc_out        <= (data_strobe_clk_count == (adc_clk_count - (clk_div_period/2) + 2));           
    end
end



///// Generate data strobe en
always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        data_strobe_clk_en <= 'b0;
    end
    else
    begin
        if((adc_clk_sat_count_out == clk_div_period + (clk_div_period/2 - 3)) && conv_start_ff1 )
        begin 
            data_strobe_clk_en <= 1'b1;
        end
        else if(clr_data_strobe_clk_en)
        begin 
            data_strobe_clk_en <= 1'b0;
        end

    end
end






///// Generate reset 
always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        adc_rst_pos        <= RESET_ACTIVE;
    end
    else
    begin
        if(conv_manual_ff3 & conv_manual_ff )
        begin
            adc_rst_pos        <= RESET_INACTIVE;
        end
        else if ((adc_rst_pos == RESET_INACTIVE) & !conv_manual_ff )
        begin
            adc_rst_pos        <= RESET_ACTIVE;
        end
    end
end



///// State Machine ////////
always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        state  <= IDLE;
        num_conv_count_ff <= 'b0;
    end
    else
    begin
        state  <= state_next;
        num_conv_count_ff <= num_conv_count;
    end
end

always_comb  ///  TO-DO : optimize ST machine, can replace Forceen/dis with just Force
begin
    state_next           = state;
    conv_start           = 1'b0;
    manual_start         = 1'b0;   
    num_conv_count       = num_conv_count_ff; 
    wait_sat_count_en = 1'b0;  
    
    case (state)
         IDLE       : begin
                        if(force_en)
                        begin
                            state_next           = FORCE_EN;
                            manual_start         = 1'b1;
                        end
                        else if(adc_conv_en_edge)
                        begin
                            state_next           = CONV_ACTIVE;                           
                            num_conv_count       = 'b0;
                        end
                        
 
                      end
        CONV_ACTIVE : begin
                        conv_start           = 1'b1;  
                        if(clr_adc_conv_active)
                        begin   
                            num_conv_count    = num_conv_count + 1'b1;  // TO-DO : not sure what is wrong here : JIRA RDA 128                                                                           
                            state_next           = WAIT_STATE;    
                            conv_start           = 1'b0;       
                        end                                             
                      end
        WAIT_STATE  : begin
                        wait_sat_count_en = 1'b1;
                        if(clr_wait_sat_count)
                        begin
                          wait_sat_count_en = 1'b0;                          
                         if(num_conv_count == num_conv_frz)
                         begin
                          state_next        = IDLE;                             
                         end                        
                         else
                         begin
                          state_next        = CONV_ACTIVE;                             
                         end  
                        end                         
                      end

        FORCE_EN    : begin
                        if(force_en)
                        begin
                            manual_start         = 1'b1;
                        end
                        else
                        begin
                            state_next           = IDLE;
                            manual_start         = 1'b0;                            
                        end

                       end
        default     :
                    begin
                            state_next           = IDLE;
                    end
    endcase
end



assign  adc_clk     = div_clk_out;
assign  adc_rst     = adc_rst_pos;
assign  adc_strobe  = strobe_out;
assign  data_strobe = data_strobe_out;
assign  soc         = soc_out;
assign  eoc         = eoc_out;
         
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
         01       : test_data <= 8'({div_clk_out, adc_rst_pos, strobe_out, adc_dout});
         default  : test_data <= '0;
         endcase
      end
   end

endmodule














