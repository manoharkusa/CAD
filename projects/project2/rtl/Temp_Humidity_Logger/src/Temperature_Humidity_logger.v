module TempHumidityLogger (
  input wire clk,           // Clock signal
  input wire reset,         // Reset signal
  output reg [7:0] temp,   // 8-bit simulated temperature
  output reg  [7:0] humidity // 8-bit simulated humidity
);
  reg [7:0] temp_data;      // Internal temperature data
  reg [7:0] humidity_data;  // Internal humidity data
  reg [31:0] timestamp;     // Internal timestamp counter
  reg [1:0] state;          // Internal state machine state
  
  // Simulated data values (you would replace these with real sensor data)
  initial begin
    temp_data = 8'h7F; // 127 (degrees Celsius)
    humidity_data = 8'h50; // 80% humidity
    timestamp = 32'h0;
    state = 2'b00;
  end
  
  // State machine for logging
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= 2'b00;
      timestamp <= 32'h0;
    end else begin
      case (state)
        2'b00: begin // Initialize
          temp <= temp_data;
          humidity <= humidity_data;
          state <= 2'b01;
        end
        2'b01: begin // Log data
          temp <= temp_data;
          humidity <= humidity_data;
          timestamp <= timestamp + 1; // Increment timestamp (simulation)
          if (timestamp == 32'hFFFF_FFFF) begin
            state <= 2'b00; // Reset after reaching max timestamp (simulation)
          end
        end
        default: begin
          state <= 2'b00; // Default state
        end
      endcase
    end
  end

endmodule
