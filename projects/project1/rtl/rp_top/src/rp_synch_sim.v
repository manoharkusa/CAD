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
// Description:         synch_sim
//
//-------------------------------------------------------------------------------


`ifndef __RP_SYNCH_SIM_V__
`define __RP_SYNCH_SIM_V__

module	rp_synch_sim
	(
	clk,
	rst_n,
	din,

	dout
	);
input		clk;
input		rst_n;
input		din;

output		dout;

// =======================================
// Declaration
// =======================================

reg		din_d1;
reg		dout;

// =======================================

always @(posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
    din_d1	<= 1'b0;
    dout	<= 1'b0;
  end
  else begin
    din_d1	<= din;
    dout	<= din_d1;
  end
end



endmodule

`endif // __RP_SYNCH_SIM_V__
