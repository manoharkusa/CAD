module PipelinedRISCProcessor (
  input wire clk,                // Clock signal
  input wire reset,              // Reset signal
  input wire [31:0] instruction, // Instruction input
  output reg  [31:0] result      // Result output
);

  reg [31:0] pc;         // Program counter
  reg [31:0] ir;         // Instruction register
  reg [31:0] alu_result; // ALU result

  // Pipeline registers
  reg [31:0] if_id_reg; // Instruction fetch to decode
  reg [31:0] id_ex_reg; // Decode to execute
  reg [31:0] ex_mem_reg; // Execute to memory access

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pc <= 32'h0;
      ir <= 32'h0;
      alu_result <= 32'h0;
    end else begin
      pc <= pc + 4; // Increment the program counter (for simplicity)
      ir <= instruction;
      alu_result <= id_ex_reg + 2; // Simulated ALU operation (for simplicity)
    end
  end

  // Pipeline stages
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      if_id_reg <= 32'h0;
      id_ex_reg <= 32'h0;
      ex_mem_reg <= 32'h0;
    end else begin
      if_id_reg <= ir;
      id_ex_reg <= if_id_reg + 1; // Simulated decode stage (for simplicity)
      ex_mem_reg <= id_ex_reg;    // Simulated execute stage (for simplicity)
    end
  end

  // Result output (from memory access stage)
  always @(posedge clk) begin
    result <= ex_mem_reg;
  end

endmodule
