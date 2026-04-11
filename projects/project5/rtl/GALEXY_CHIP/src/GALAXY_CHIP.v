module GalaxyChip (
  input wire clk,
  input wire reset,
  input wire [7:0] data_in,
  output wire [7:0] data_out
);

  reg [7:0] internal_data;

  always @(posedge clk or posedge reset) begin
    if (reset)
      internal_data <= 0;
    else
      internal_data <= data_in;
  end

  assign data_out = internal_data;

endmodule