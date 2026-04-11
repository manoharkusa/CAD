/*
   STAGE should be at least 1
   if 0, then don't use this module
   Revisions:
      10/08/21: First Documentation
*/

module pipe_reg # (
   parameter WIDTH = 16,
   parameter STAGE = 2
)
(
   input   [WIDTH - 1 : 0]  in,
   output logic [WIDTH - 1 : 0]  out,
   input                    clk,
   input                    rst_n
);

   logic [STAGE : 0][WIDTH - 1 : 0] pipe;
   assign pipe[0] = in;
   assign out = pipe[STAGE];
   integer i;

         always_ff @ (posedge clk or negedge rst_n) begin
            if (rst_n == 0) begin
               for (i = 1; i < STAGE + 1; i = i + 1) begin
                  pipe [i]  <= 0;
               end
            end
            else begin
               for (i = 1; i < STAGE + 1; i = i + 1) begin
                  pipe [i]  <= pipe [i-1];
               end
            end
         end


endmodule
