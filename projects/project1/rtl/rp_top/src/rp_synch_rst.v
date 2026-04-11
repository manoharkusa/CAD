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
// Description:         ecc_dec16
//
//-------------------------------------------------------------------------------

`ifndef __RP_SYNCH_RST__
`define __RP_SYNCH_RST__

module	rp_synch_rst
	(
	clk,
	raw_rst_n,

	rst_n
	);
input		clk;
input		raw_rst_n;

output		rst_n;

// =======================================
// Declaration
// =======================================

wire		rst_n;

// =======================================

rp_synch_sim	synch_reset
	(
	.clk	(clk),
	.rst_n	(raw_rst_n),
	.din	(1'b1),

	.dout	(rst_n)
	);

endmodule

`endif // __RP_SYNCH_RST__
