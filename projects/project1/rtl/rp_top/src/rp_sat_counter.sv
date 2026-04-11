//####################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
// Author:        Puneeth Reddy
// Project:       Uintah  
//
// Description: This block generates the adc clk, rst and chop signal pahse alligned and clocked at the negedge of clk 
//               
//               
//-------------------------------------------------------------------------------------------------------------------


module rp_sat_counter
            #(
          
            COUNTER_WIDTH = 8
            )
            (
    input  logic      clk,
    input  logic      rst_n,
    input  logic      [COUNTER_WIDTH - 1 : 0] sat_val,
    input  logic      counter_en,
    input  logic      counter_clr,
            
    output logic      sat_out,
    output logic      [COUNTER_WIDTH - 1 : 0] counter_out
            
            );

logic [COUNTER_WIDTH - 1 : 0] counter;

logic sat;


always @ (posedge clk or negedge rst_n)
begin 
    if(!rst_n)
    begin 
        counter <= 'b0;
        sat <= 1'b0;
    end
    else
    begin 
        if(counter_clr)
        begin
            counter <=   'b0;
            sat <=   1'b0;        
        end
        else if(counter_en)
        begin     
            if(counter == sat_val - 1)
            begin 
                counter <=   'b0;
                sat <=   1'b1;
            end 
            else 
            begin 
                counter <=   counter + 1'b1;
                sat <=   1'b0;
            end 
        end
        else 
        begin
            counter <=   'b0;        
            sat <= 1'b0;
        end
    end


end


assign counter_out = counter;
assign sat_out =   sat;
 

endmodule
