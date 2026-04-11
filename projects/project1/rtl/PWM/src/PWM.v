module pwm_generator(
    input wire clk,          // Clock input
    input wire rst,          // Reset input
    input wire [7:0] duty_cycle, // Duty cycle input (8 bits)
    output wire pwm_out      // PWM output
);

reg [7:0] counter;          // Counter to compare with duty cycle
reg pwm_logic;             // PWM logic signal

assign pwm_out = pwm_logic;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 8'b0;
        pwm_logic <= 1'b0;
    end else begin
        if (counter < duty_cycle) begin
            pwm_logic <= 1'b1;
        end else begin
            pwm_logic <= 1'b0;
        end
        
        if (counter == 8'b11111111) begin
            counter <= 8'b0;
        end else begin
            counter <= counter + 1'b1;
        end
    end
end

endmodule
