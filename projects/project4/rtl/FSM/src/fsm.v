module fsm_example (
    input wire clk,          // Clock input
    input wire reset,        // Reset input
    input wire start,        // Start signal input
    output wire state_idle,  // Output indicating IDLE state
    output wire state_count_up, // Output indicating COUNT_UP state
    output wire state_count_down // Output indicating COUNT_DOWN state
);

// Define state encoding
parameter IDLE_STATE = 2'b00;
parameter COUNT_UP_STATE = 2'b01;
parameter COUNT_DOWN_STATE = 2'b10;

// Define state and next_state registers
reg [1:0] state, next_state;

// Initialize state register
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE_STATE;
    end else begin
        state <= next_state;
    end
end

// Define outputs based on the current state
assign state_idle = (state == IDLE_STATE);
assign state_count_up = (state == COUNT_UP_STATE);
assign state_count_down = (state == COUNT_DOWN_STATE);

// Define state transition logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        next_state <= IDLE_STATE;
    end else begin
        case(state)
            IDLE_STATE: begin
                if (start) begin
                    next_state <= COUNT_UP_STATE;
                end else begin
                    next_state <= IDLE_STATE;
                end
            end
            COUNT_UP_STATE: begin
                if (start) begin
                    next_state <= COUNT_DOWN_STATE;
                end else begin
                    next_state <= COUNT_UP_STATE;
                end
            end
            COUNT_DOWN_STATE: begin
                if (start) begin
                    next_state <= COUNT_UP_STATE;
                end else begin
                    next_state <= COUNT_DOWN_STATE;
                end
            end
            default: next_state <= IDLE_STATE;
        endcase
    end
end

endmodule