module can_transmitter (
    input wire clk,              // Clock input
    input wire rst,              // Reset input
    output wire tx_can,          // CAN TX output
    input wire [10:0] can_data,  // CAN data (11 bits)
    input wire tx_start          // Start transmission signal
);

reg [3:0] state;                // State machine state
reg [10:0] tx_data_reg;         // Register to store CAN data
reg tx_ready;                   // Ready to transmit signal

assign tx_can = tx_ready;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= 4'b0000;
        tx_data_reg <= 11'b00000000000;
        tx_ready <= 1'b0;
    end else begin
        case (state)
            4'b0000: begin
                if (tx_start) begin
                    tx_data_reg <= can_data;
                    state <= 4'b0001;
                end
            end
            4'b0001: begin
                tx_ready <= 1'b1;
                state <= 4'b0010;
            end
            4'b0010: begin
                tx_ready <= 1'b0;
                state <= 4'b0011;
            end
            4'b0011: begin
                state <= 4'b0000;
            end
            default: begin
                state <= 4'b0000;
            end
        endcase
    end
end

endmodule