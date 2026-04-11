module rtl_output (clk, reset, start, in_a, in_b, quotient, remainder, done,
test_se);
input clk, reset, start, test_se;
input [3:0] in_a, in_b;
output [3:0] quotient, remainder;
reg [3:0] quotient, remainder;
output done;
reg done;
parameter S_IDLE = 'd0;
parameter S_INIT = 'd1;
parameter S_FETCHINPUT = 'd2;
parameter S_BUSY = 'd3;
reg [1:0] present_state, next_state;
// Update present state
always @ (posedge clk) begin
if (test_se == 1'b0) begin
if (reset == 1'b1) begin
present_state <= S_IDLE;
end
else begin
present_state <= next_state;
end
end
else begin
present_state[1] <= quotient[3];
present_state[0] <= quotient[2];
end
end
// Next state
always @ (present_state or start or remainder or in_b) begin
next_state = present_state;
case (present_state)
S_IDLE: begin
if (start == 1'b1) begin
next_state = S_INIT;
end
end


S_INIT: next_state = S_FETCHINPUT;
S_FETCHINPUT: next_state = S_BUSY;
default: begin
if (remainder < in_b) begin
next_state = S_IDLE;
end
end
endcase
end
// Done signal
always @ (posedge clk) begin
        if (test_se == 1'b0) begin
                if (present_state == S_IDLE) begin
                done <= 1'b1;
                end
                else begin
                done <= 1'b0;
                end
                end
        else begin
        done <= present_state[0];
        end
        end
// Remainder calculation
always @ (posedge clk) begin
        if (test_se == 1'b0) begin
                if (present_state == S_FETCHINPUT) begin
                remainder <= in_a;
                end
                else begin
                        if (remainder >= in_b) begin
                        remainder <= remainder - in_b;
                        end
                     end
                end


        else begin
                remainder[3] <= in_a[3];
                remainder[2] <= in_a[2];
                remainder[1] <= in_a[1];
                remainder[0] <= quotient[1];
             end
             end
// Quotient calculation
always @ (posedge clk) begin
                if (test_se == 1'b0) begin
                        if (present_state == S_INIT) begin
                        quotient <= 0;
                        end
                        else begin
                                if (present_state == S_BUSY) begin
                                        if (remainder > in_b) begin
                                        quotient <= quotient + 1;
                                        end
                                end
                                end
                        end
                else begin
                        quotient[3] <= remainder[3];
                        quotient[2] <= remainder[2];
                        quotient[1] <= remainder[1];
                        quotient[0] <= present_state[1];
                        end
                end
endmodule
