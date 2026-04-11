//####################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
// Author:        Puneeth Reddy
// Project:       Uintah  
//
// Description: This block generates an adc chop signal based on the chop sym and chop_sym_ncycles
//               
//               
//-------------------------------------------------------------------------------------------------------------------

module      rp_adcchopgen
            #
            (
			    CHOP_SYM_WIDTH=8,
				CHOP_SYM_NCYCLE_WIDTH=16
            )                     
            (
                output  logic									chop_seq_out,




                input   logic                                   clk,
                input   logic           						rst_n,
				input   logic                                   chop_en,
				input   logic   [CHOP_SYM_WIDTH-1:0]  			chop_sym, 
				input   logic   [CHOP_SYM_NCYCLE_WIDTH-1:0]  	chop_sym_ncycle

            );
			
			
			
			
logic                                   rotate;
logic                                   chop_en_ff;
logic                                   chop_en_edge;
logic   [CHOP_SYM_WIDTH-1:0]            rotate_reg;
logic   [CHOP_SYM_NCYCLE_WIDTH-1:0]  	sat_chop_sym_ncycle;
			
			
			
			
rp_sat_counter
            #
            (
            .COUNTER_WIDTH(CHOP_SYM_NCYCLE_WIDTH)
            )
			dut_rp_sat_counter            
            (
			.clk            (clk),
			.rst_n			(rst_n),
			.sat_val	    (sat_chop_sym_ncycle),
			.counter_en		(chop_en),
            .counter_clr    (1'b0),
			
			.sat_out		(rotate),
			.counter_out     ()

            
            );
	
always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        chop_en_ff  <=  1'b0;
	end
	else
	begin
        chop_en_ff  <=  chop_en;        
	end			
end
    
assign chop_en_edge = (chop_en_ff == 1'b0) && ((chop_en == 1'b1)) ;   
    		
always_ff @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
		rotate_reg          <= 8'b11111111;
        sat_chop_sym_ncycle <= 8'b00000000;       
	end
	else
	begin
        if(!chop_en)
		begin
			rotate_reg <= 8'b11111111;
		end
        else if(chop_en_edge)
		begin
			rotate_reg <= chop_sym;
            sat_chop_sym_ncycle <= chop_sym_ncycle;       
		end

        else if(rotate )
		begin 
			rotate_reg <= {rotate_reg[0],rotate_reg[7:1]};
		end 
	end			
end

assign chop_seq_out = rotate_reg[0];

endmodule

