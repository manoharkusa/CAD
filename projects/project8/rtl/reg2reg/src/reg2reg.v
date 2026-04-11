module reg2reg(output reg q, input a,b,c,d,clk,rst);
reg qint;
wire combo_out1,combo_out2;

assign combo_out1 = a & b;
assign combo_out2 = c & d & qint;

always @(posedge clk or negedge rst)
begin
	if (!rst)
	begin
	q<=0;
	qint<=0;
	end
	else
	begin
	q<=combo_out2;
	qint<=combo_out1;
	end
end
endmodule
