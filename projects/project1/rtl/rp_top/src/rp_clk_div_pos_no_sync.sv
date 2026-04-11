//###################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
// Author:              Puneeth Reddy
// Project:             Uintah
//
// Description:  This is a clock divider, that can perform even clock divison only i.e 0,2,4,6 ....      
//               Note: This clock divider assumes that no synchronizers are requried 
//               Meaning the clk_div_en and clk_div_preiod are coming from the same clk domain
//               as the clk. Also the clk_div_period can only be changed when the clk_div_enb is 0
//-------------------------------------------------------------------------------------------------------------------

module	rp_clk_div_pos_no_sync
	#
	(
	parameter
	DIV_WIDTH	= 8,
	DIV_INIT	= 8'hF,
    START_EDGE  = 1'b0 // defines the edge the clk out starts from on reset 
	)
	(
	clk,			// source clock
	rst_n,		// asynch reset input
	clk_div_en,		// other clock domain
	clk_div_period,		// div by clk_vid_period 
	clk_out
	);
input			clk;			// source clock
input           rst_n;
input			clk_div_en;		// other clock domain
input	[DIV_WIDTH-1:0]	clk_div_period;		// div by clk_vid_period 
output			clk_out;

// ======================================================================
// Declaration
// ======================================================================

reg			clk_div_en_hys;
reg	[DIV_WIDTH-1:0]	clk_div_period;
reg	[DIV_WIDTH-1:0]	clk_div_ctr;
reg			div_clk;

wire			clr_clk_div_en;
wire			clk_div_ctr_eq_period;
wire			clk_div_ctr_eq_zero;
wire			clk_div_ctr_eq_high;
wire			clk_out;

// ======================================================================


// Disable clock only after the next stage clock is disabled and disabled at end of clk_out period
assign	clr_clk_div_en	= ~clk_div_en && clk_div_ctr_eq_period;


always @(posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
    clk_div_en_hys	<= 1'b0;
  end
  else if(clk_div_en) begin
    clk_div_en_hys	<= 1'b1;
  end
  else if(clr_clk_div_en) begin
    clk_div_en_hys	<= 1'b0;
  end
end





// ================================================================
// CLOCK GENERATOR
// ================================================================

assign clk_div_ctr_eq_period	= (clk_div_ctr[DIV_WIDTH-1:0] == (clk_div_period[DIV_WIDTH-1:0] - 1));
assign clk_div_ctr_eq_zero	    = (clk_div_ctr[DIV_WIDTH-1:0] == 'b0);
always @(posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
    clk_div_ctr[DIV_WIDTH-1:0]	<= 0;
  end
  else if(clk_div_ctr_eq_period) begin
    clk_div_ctr[DIV_WIDTH-1:0]	<= 0;
  end
  else if(clk_div_en_hys) begin
    clk_div_ctr[DIV_WIDTH-1:0]	<= clk_div_ctr[DIV_WIDTH-1:0] + 1;
  end
end

// 50% duty cycle with truncation
assign	clk_div_ctr_eq_high	= (clk_div_ctr == {1'b0,clk_div_period[DIV_WIDTH-1:1]});

always @(posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
    div_clk	<= START_EDGE;
  end
  else if (clk_div_period == 'b0)
  begin
    div_clk	<= START_EDGE;    
  end
  else if(clk_div_ctr_eq_zero && clk_div_en_hys) begin
    div_clk	<= !START_EDGE;
  end
  else if(clk_div_ctr_eq_high) begin
    div_clk	<= START_EDGE;
  end
end

assign	clk_out	= div_clk;


endmodule


