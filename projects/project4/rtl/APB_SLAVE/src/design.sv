`ifndef APBSLAVE
`define APBSLAVE

module apbslave (
  input  wire pclk,
  input  wire presetn,
  input  wire pwrite,
  input  wire pselx,
  input  wire penable,
  output reg  pslver,
  output reg  pready,
  input  wire [31:0] paddr,
  input  wire [31:0] pwdata,
  output reg  [31:0] prdata
);
  
  typedef enum reg [2:0] {RESET,IDLE,SETUP,ACCESS} state_t;
  reg [31:0] mem [31:0];
  
  state_t c_state;
  
  //**********************
  // SAMPLING LOGIC
  //**********************
  always @(posedge pclk) begin
    if (presetn == 1'b0) begin
      	c_state <= RESET;
    end else begin
      		   if (pselx == 1'b0 && penable == 1'b0) begin
        c_state <= IDLE;
      end else if (pselx == 1'b1 && penable == 1'b0) begin
        c_state <= SETUP;
      end else if (pselx == 1'b1 && penable == 1'b1) begin
        c_state <= ACCESS;
      end else begin
        c_state <= IDLE;
      end
    end
  end // always
  
  //**********************
  // DRIVING LOGIC
  //**********************
  always @(negedge pclk) begin
    if (c_state == ACCESS) begin
      	pready <= 1'b1;
      if (paddr == 16'h1234) begin
        pslver <= 1'b1;
      end else begin
        pslver <= 1'b0;
        if (pwrite == 1'b1) begin
          mem [paddr] <= pwdata;
        end else if (pwrite == 1'b0) begin
          prdata <= mem [paddr];
        end
      end
    end else begin
      pready <= 1'b0;
      pslver <= 1'b0;
      prdata <= 16'h0;
    end
  end
    
endmodule : apbslave
`endif //APBSLAVE

