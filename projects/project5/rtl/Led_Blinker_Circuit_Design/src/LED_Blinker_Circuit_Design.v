module LEDBlinker (
  input wire clk,      // Clock signal
  input wire reset,    // Reset signal
  output wire led      // LED output
);

  reg [23:0] counter;  // Counter for generating the blink rate
  reg blink_state;     // State to control LED blinking

  // Define a constant for the blink rate (adjust as needed)
  localparam BLINK_RATE = 10000000; // 10 MHz clock => 1 Hz blink rate

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      counter <= 0;
      blink_state <= 1'b0; // Start with LED off
    end else if (counter == BLINK_RATE / 2) begin
      counter <= 0;
      blink_state <= ~blink_state; // Toggle LED state
    end else begin
      counter <= counter + 1;
    end
  end

  assign led = blink_state; // Connect the LED to the blink state

endmodule
