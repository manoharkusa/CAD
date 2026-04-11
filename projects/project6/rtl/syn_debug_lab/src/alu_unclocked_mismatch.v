module invBox2 (a,z);
  input a;
  output z;

  invert inv1 (.A(a), .Z(z));
  
endmodule

module multN (clk, rst, a, b, q, si, se, so);
  parameter size = 8 ;
  input  clk, rst, si, se;
  input  [size-1:0] a, b;
  output so;
  output [2*size-1:0] q;
  reg    [2*size-1:0] q;

  always @(posedge clk or negedge rst)
    if (rst == 1'b0)
      q <=  {2*size {1'b0}};
    else
      if (a == b)
        q <= a * b;
      else 
        q <= a + b;
endmodule

 
module adderN (a, b, q, ci, co);
  parameter size = 8 ;
  input             ci;
  input  [size-1:0] a, b;
  output            co;
  output [size-1:0]   q;
 
 assign q = a+b+ci ;
 assign co = (a&b) | (b&ci) | (a&ci);

//  assign {co,q} = a + b + ci;
endmodule
  
module adderNLatched (a, b, q, ci, co, en);
  parameter size = 8 ;
  input             ci, en;
  input  [size-1:0] a, b;
  output            co;
  output [size-1:0]   q;
  reg    [size-1:0]   q; 
  reg               co;
  
 always @(a or b or ci or en)
 begin
  if (en == 1) 
  begin
     q  <= a+b+ci ;
     co <= (a&b) | (b&ci) | (a&ci);
  end
 end
 
//  assign {co,q} = a + b + ci;
endmodule

module regN (clk, rst, regin, regout, en, si, se, so) ;
  parameter size = 8 ;
  input             en, si, se;
  output            so;
  input  [size-1:0] regin;
  output [size-1:0] regout;
  input             clk, rst ;
  reg    [size-1:0] regout;
  
  always @(posedge clk or negedge rst)
  begin
    if (rst == 1'b0)
    regout <=  {size{1'b0}};
    else
      if (en == 1'b1)
        regout <= regin ;
  end
endmodule
  
module regNnoR (clk, regin, regout, en, si, se, so) ;
  parameter size = 8 ;
  input             en, si, se;
  output            so;
  input  [size-1:0] regin;
  output [size-1:0] regout;
  input             clk ;
  reg    [size-1:0] regout;
  
  always @(posedge clk )
  begin
      if (en == 1'b1)
        regout <= regin ;
  end
endmodule
  
module orN (clk, rst, a, b, c, d, orAll) ;
  parameter size = 8 ;
  input             clk, rst ;
  input  [size-1:0] a, b, c, d;
  output [2*size-1:0] orAll;
  reg  [2*size-1:0] orAll;
  always @(posedge clk or negedge rst)
  begin
    if (rst == 1'b0)
    orAll <= 16'b0;
    else
    orAll <= a || b || c || d ;
  end
endmodule

module myAlu (clk, powerDwn, rst, a, b, c, d, q, ci, co, orAll_r, si, se, so, TRI, I1, I2, TE, adda, addb, sumab, taiwan);
  
  parameter size = 8 ;
  
  input                   clk, powerDwn, rst, ci, si, se, I1, I2, TE, TRI;
  input  [size-1:0]       a, b, c, d, adda, addb;
  //input  [15:0]           a, b, c, d, adda, addb;
  output [size:0]         sumab ;
  //output [16:0]           sumab ;
  output             co, so;
  output [2*size-1:0] orAll_r;
  output [(2*size)-1:0]   q;
  //output                  [31:0] q;
  output                  taiwan ;

  wire   [size-1:0]         apb, cpd;
  wire   [size:0]         addaPlusAddb ;
  wire   [size-1:0]       a_r, b_r, c_r, d_r;
  wire                    internalRst, s1, s2, s3, s4, ckMul, ck2x, coInt;
  wire   [2*size-1:0]     orAll_r;
  wire   [(2*size)-1:0]   mulOut;
  reg                     s1clk;
  
  assign taiwan = 1'b1 ;
  assign addaPlusAddb = adda + addb ;
  assign sumab = TRI ? addaPlusAddb : {size+1{1'bz}} ;
  
  adderNLatched #(size)   ADD1  (.a(a_r), .b(b_r), .q(apb), .ci(ci), .co(s1), .en(I1));
  adderN        #(size)   ADD2  (.a(c_r), .b(d_r), .q(cpd), .ci(s3), .co(coInt));
  
  //invert                  IV1   (.A(s1), .Z(s2));
invert                  IV1   (.B(s), .Z(s6));


//	 I modified pin names to get mismatch errors

  invBox2                 IV2   (.a(s6), .d(s3));
  
  clockGenerator ckGen (.ckin(clk), .ckout(ckMul), .ck2x(ck2x), .invCK(I2), .TE(TE));
  
  multN         #(size)   MUL1  (.clk(ckMul), .rst(internalRst), .a(apb), .b(cpd), .q(mulOut), .si(si), .se(se), .so(so));
  
  reset                   RST1  (.reset(internalRst), .se(TE), .rst(rst), .s1clk(s1clk));
  
  regNnoR       #(size)   REGa (.en(powerDwn), .clk(clk), .regin(a), .regout(a_r)) ;
  regN          #(size)   REGb (.en(powerDwn), .clk(clk), .rst(rst), .regin(b), .regout(b_r)) ;
  regN          #(size)   REGc (.en(powerDwn), .clk(clk), .rst(rst), .regin(c), .regout(c_r)) ;
  regN          #(size)   REGd (.en(powerDwn), .clk(clk), .rst(rst), .regin(d), .regout(d_r)) ;
  regN          #(2*size) REGm (.en(powerDwn), .clk(ck2x), .rst(rst), .regin(mulOut), .regout(q)) ;


// here I removed clock pin fo orN to check unclocked pins  
  orN            #(size)    ORALL ( .rst(rst), .a(a), .b(b), .c(c), .d(d), .orAll(orAll_r)) ;

  assign co = TE? coInt : 1'bz;
  
always @(posedge clk)
begin
  s1clk <= s1 ;
end
//assign internalRst = s1clk ;

endmodule
  
 
module reset (se, rst, s1clk, reset);
input se, rst, s1clk;
output reset ;

assign reset = se ? rst :  s1clk;

endmodule

module clockGenerator (ckin, invCK, TE, ck2x, ckout);
input ckin, invCK, TE;
output ck2x, ckout ;
reg ckDiv;
wire comboclock, muxout, ckinXor ;

//assign muxout     = TE ? comboclock : ck2x ;
assign ckinXor    = invCK ^ ckin ;
assign comboclock = TE ? ckin : ckinXor ;

always @(posedge ckin)
 begin
  ckDiv <= ~ckDiv ;  
 end

assign  ck2x = TE ? ckin : ckDiv;  

assign ckout = comboclock ; 

endmodule

  
  
  
module invert (Z,A);
input A;
output Z;

assign Z = ~A;
endmodule











