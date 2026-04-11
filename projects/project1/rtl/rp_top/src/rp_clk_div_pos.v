//###################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
// Author:              Yeong Wang
//
// Project:             Kahuna 1
//
// Description:         ecc_dec16
//
//-------------------------------------------------------------------------------

//`include "rp_synch_rst.v"
//`include "rp_synch_sim.v"


// ==============================================
// Can not div by 1 (clk_div_period = 0)
// ==============================================

`ifndef __RP_CLK_DIV_POS_V__
`define __RP_CLK_DIV_POS_V__

module	rp_clk_div_pos
	#
	(
	parameter
	DIV_WIDTH	= 8,
	DIV_INIT	= 8'hF
	)
	(
	clk,			// source clock
	ext_rst_n,		// asynch reset input
	clk_div_enb,		// other clock domain
	clk_div_upd,		// clk_div_period update pulse syned to clk domain
	clk_div_period,		// div by clk_vid_period + 1 syned
	clk_stopped_in,

	clk_stopped_out,
	clk_out
	);
input			clk;			// source clock
input			ext_rst_n;		// asynch reset input
input			clk_div_enb;		// other clock domain
input			clk_div_upd;		// clk_div_period update pulse syned to clk domain
input	[DIV_WIDTH-1:0]	clk_div_period;		// div by clk_vid_period + 1 syned
input			clk_stopped_in;

output			clk_stopped_out;
output			clk_out;

// ======================================================================
// Declaration
// ======================================================================

reg			clk_div_enb_hys;
reg	[DIV_WIDTH-1:0]	clk_div_period_cur;
reg	[DIV_WIDTH-1:0]	clk_div_period_sync;
reg	[DIV_WIDTH-1:0]	clk_div_ctr;
reg			div_clk;

wire			rst_n;
wire			clk_div_enb_sync;
wire			clr_clk_div_enb;
wire			clk_stopped_out;
wire			clk_div_ctr_eq_period;
wire			clk_div_ctr_eq_high;
wire			clk_out;

// ======================================================================


rp_synch_rst	synch_rst_clk
	(
	.clk		(clk),
	.raw_rst_n	(ext_rst_n),

	.rst_n		(rst_n)
	);



rp_synch_sim	synch_sim_div_enb
	(
	.clk		(clk),
	.rst_n		(rst_n),
	.din		(clk_div_enb),

	.dout		(clk_div_enb_sync)
	);

// Disable clock only after the next stage clock is disabled and disabled at end of clk_out period
assign	clr_clk_div_enb	= ~clk_div_enb_sync && clk_div_ctr_eq_period && clk_stopped_in;


always @(posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
    clk_div_enb_hys	<= 1'b0;
  end
  else if(clk_div_enb_sync) begin
    clk_div_enb_hys	<= 1'b1;
  end
  else if(clr_clk_div_enb) begin
    clk_div_enb_hys	<= 1'b0;
  end
end

assign	clk_stopped_out	= ~clk_div_enb_hys;

always @(posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
    clk_div_period_sync[DIV_WIDTH-1:0]	<= DIV_INIT;
  end
  else if(clk_div_upd) begin
    clk_div_period_sync[DIV_WIDTH-1:0]	<= clk_div_period[DIV_WIDTH-1:0];
  end
end

// Only update new period value at the end of one full clock period
always @(posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
    clk_div_period_cur[DIV_WIDTH-1:0]	<= DIV_INIT;
  end
  else if(clk_div_ctr_eq_period) begin
    clk_div_period_cur[DIV_WIDTH-1:0]	<= clk_div_period_sync[DIV_WIDTH-1:0];
  end
end



// ================================================================
// CLOCK GENERATOR
// ================================================================

assign clk_div_ctr_eq_period	= (clk_div_ctr[DIV_WIDTH-1:0] == clk_div_period_cur[DIV_WIDTH-1:0]);

always @(posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
    clk_div_ctr[DIV_WIDTH-1:0]	<= 0;
  end
  else if(clk_div_ctr_eq_period) begin
    clk_div_ctr[DIV_WIDTH-1:0]	<= 0;
  end
  else if(clk_div_enb_hys) begin
    clk_div_ctr[DIV_WIDTH-1:0]	<= clk_div_ctr[DIV_WIDTH-1:0] + 1'b1;
  end
end

// 50% duty cycle with truncation
assign	clk_div_ctr_eq_high	= (clk_div_ctr == {1'b0,clk_div_period_cur[DIV_WIDTH-1:1]});

always @(posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
    div_clk	<= 1'b0;
  end
  else if(clr_clk_div_enb) begin
    div_clk	<= 1'b0;
  end
  else if(clk_div_ctr_eq_period && clk_div_enb_hys) begin
    div_clk	<= 1'b1;
  end
  else if(clk_div_ctr_eq_high) begin
    div_clk	<= 1'b0;
  end
end

assign	clk_out	= div_clk;


endmodule

`endif // __RP_CLK_DIV_POS_V__
