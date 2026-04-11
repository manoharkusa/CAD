////////////////////////////////////////////////////////////////////////////////////////////
//	Program to realise a Register. The operation depends on Clock and load		///
///////////////////////////////////////////////////////////////////////////////////////////

module regC (clk, loadC, dataCin, dataCout);
input clk;
input loadC;
input [31:0] dataCin;
output [31:0] dataCout;

reg [31:0] dataCout;
reg [31:0] tempC;

always@(posedge clk or posedge loadC)
 
	begin
		if ( loadC == 1) begin
		dataCout <= dataCin;
		tempC <= dataCin;
		end

		else if (loadC == 0) begin
		dataCout <= tempC;
		end
	end

endmodule
