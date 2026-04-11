module TrafficLightController (
  input wire clk,        // Clock signal
  input wire reset,      // Reset signal
  output wire red_ns,    // Red light for North/South
  output wire yellow_ns, // Yellow light for North/South
  output wire green_ns,  // Green light for North/South
  output wire red_ew,    // Red light for East/West
  output wire yellow_ew, // Yellow light for East/West
  output wire green_ew,  // Green light for East/West
  output wire walk,      // Pedestrian walk signal
  output wire dont_walk  // Pedestrian don't walk signal
);

  // Define states for the traffic light controller
  typedef enum logic [2:0] {
    NS_Red,
    NS_Green,
    EW_Red,
    EW_Green,
    Pedestrian
  } State;

  State current_state, next_state;

  // Define timing parameters (adjust as needed)
  localparam CLK_HALF_PERIOD = 5; // Half-period of the clock (in clock cycles)
  localparam NS_GREEN_TIME = 4;   // Number of clock cycles for North/South green
  localparam EW_GREEN_TIME = 4;   // Number of clock cycles for East/West green
  localparam PED_WAIT_TIME = 2;   // Number of clock cycles for pedestrian wait

  // Registers for state transition
  reg [2:0] count;
  reg [1:0] pedestrian_count;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= NS_Red;
      count <= 0;
      pedestrian_count <= 0;
    end else begin
      current_state <= next_state;
      count <= count + 1;
      pedestrian_count <= (current_state == Pedestrian) ? pedestrian_count + 1 : 0;
    end
  end

  always @(*) begin
    case (current_state)
      NS_Red: begin
        next_state = (count >= NS_GREEN_TIME) ? EW_Green : NS_Red;
      end
      NS_Green: begin
        next_state = (count >= NS_GREEN_TIME) ? Pedestrian : NS_Green;
      end
      EW_Red: begin
        next_state = (count >= EW_GREEN_TIME) ? NS_Green : EW_Red;
      end
      EW_Green: begin
        next_state = (count >= EW_GREEN_TIME) ? Pedestrian : EW_Green;
      end
      Pedestrian: begin
        next_state = (pedestrian_count >= PED_WAIT_TIME) ? NS_Red : Pedestrian;
      end
      default: begin
        next_state = NS_Red;
      end
    endcase
  end

  // Output logic for traffic lights
  assign red_ns = (current_state == NS_Red) ? 1'b1 : 1'b0;
  assign yellow_ns = (current_state == NS_Green) ? 1'b1 : 1'b0;
  assign green_ns = (current_state == NS_Green) ? 1'b1 : 1'b0;
  assign red_ew = (current_state == EW_Red) ? 1'b1 : 1'b0;
  assign yellow_ew = (current_state == EW_Green) ? 1'b1 : 1'b0;
  assign green_ew = (current_state == EW_Green) ? 1'b1 : 1'b0;
  assign walk = (current_state == Pedestrian) ? 1'b1 : 1'b0;
  assign dont_walk = (current_state == Pedestrian) ? 1'b0 : 1'b1;

endmodule
