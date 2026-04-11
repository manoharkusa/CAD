module ShiftRegister (
  input wire clk,           // Clock signal
  input wire reset,         // Reset signal
  input wire shift_enable,  // Shift enable signal
  input wire serial_in,     // Serial input data
  output wire [7:0] parallel_out // Parallel output data (8 bits)
);

  reg [7:0] register [0:7]; // 8-bit shift register
integer i;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < 8; i = i + 1) begin
        register[i] <= 8'h0; // Clear the shift register on reset
      end
    end else if (shift_enable) begin
      // Shift data to the right
      for (i = 7; i > 0; i = i - 1) begin
        register[i] <= register[i - 1];
      end
      // Load serial input data into the first stage
      register[0] <= serial_in;
    end
  end

  assign parallel_out = register[7]; // Parallel output from the last stage

endmodule
