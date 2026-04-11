//###################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################

//------------------------------------------------------------------------------
// © Copyright Rockley Photonics Limited 2016
//
// Author:              Yeong Wang
//
// Project:             Kahuna 1
//
// Description:         synch_pulse
//
//-------------------------------------------------------------------------------




//`include "rp_synch_sim.v"

`ifndef __RP_SYNCH_PULSE_V__
`define __RP_SYNCH_PULSE_V__

module	rp_synch_pulse
	(
	a_clk,
	a_rst_n,
	b_clk,
	b_rst_n,
	a_in,

	b_out
	);

input		a_clk;
input		a_rst_n;
input		b_clk;
input		b_rst_n;
input		a_in;

output		b_out;

// ======================================================================
// DECLARATION
// ======================================================================

reg		pulse_detect;
reg		pulse_detect_out_dly;
reg		b_out;

wire		clr_pulse_detect;
wire		pulse_detect_out;
wire		pulse_out;

// ======================================================================

// ======================================
// CLOCK A DOMAIN
// ======================================

always @(posedge a_clk or negedge a_rst_n)
begin
  if(~a_rst_n) begin
    pulse_detect	<= 1'b0;
  end
  else if(clr_pulse_detect) begin
    pulse_detect	<= 1'b0;
  end
  else if(a_in) begin
    pulse_detect	<= 1'b1;
  end
end

rp_synch_sim	synch_sim_clr_pulse_detect
	(
	.clk	(a_clk),
	.rst_n	(a_rst_n),
	.din	(pulse_detect_out),

	.dout	(clr_pulse_detect)
	);

// ======================================
// CLOCK B DOMAIN
// ======================================

rp_synch_sim	synch_sim_pulse_detect_out
	(
	.clk	(b_clk),
	.rst_n	(b_rst_n),
	.din	(pulse_detect),

	.dout	(pulse_detect_out)
	);

always @(posedge b_clk or negedge b_rst_n)
begin
  if(~b_rst_n) begin
    pulse_detect_out_dly	<= 1'b0;
  end
  else begin
    pulse_detect_out_dly	<= pulse_detect_out;
  end
end

assign	pulse_out	= ~pulse_detect_out_dly && pulse_detect_out;

always @(posedge b_clk or negedge b_rst_n)
begin
  if(~b_rst_n) begin
    b_out	<= 1'b0;
  end
  else begin
    b_out	<= pulse_out;
  end
end

endmodule


`endif // __RP_SYNCH_PULSE_V__
